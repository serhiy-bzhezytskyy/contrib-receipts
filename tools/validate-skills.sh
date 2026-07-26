#!/usr/bin/env bash
# Check the invariants this repo promises about its own skills, mechanically.
#
# Every rule below is something the repo already claims — a uniform section order, a
# name that matches its directory, a description Claude can route on, a receipt in
# every skill, no maintainer names in prose, both indexes in sync. Those were held by
# hand across 15 skills and two indexes; this is the check that keeps holding them.
#
# Usage: bash tools/validate-skills.sh [--online]
#   (default) offline structural checks only — no network, no creds
#   --online  additionally resolve every GitHub receipt link via `gh` (needs auth)
# Exit 0 = all checks pass, 1 = at least one FAIL.
set -uo pipefail

# grep -P on multibyte input is locale-dependent; pin it so the Cyrillic check is
# not silently a no-op (it under-reported once, which is why this is set here).
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
ONLINE=0
for arg in "$@"; do
  case "$arg" in
    --online) ONLINE=1 ;;
    --help|-h) sed -n '2,12p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)"; exit 2 ;;
  esac
done

cd "$REPO" || exit 2

# --- the structural rules (offline) ---
python3 - "$REPO" <<'PYEOF'
import os, re, sys, glob, unicodedata

repo = sys.argv[1]
fails = []
oks = 0

def ok(msg):
    global oks
    oks += 1
    print("ok   - %s" % msg)

def bad(msg):
    fails.append(msg)
    print("FAIL - %s" % msg)

SECTIONS = ["Purpose", "When to use", "When NOT to use", "The practice (checklist)",
            "Rationalizations", "RECEIPT", "Lifecycle"]
REQUIRED_KEYS = ["name", "description", "scope", "principle"]
# A description Claude can route on: it must say WHEN to fire and carry trigger terms.
USE_CLAUSE = re.compile(r"\bUse (?:when|if|before|after|at|on|during|whenever)\b", re.I)

skill_dirs = sorted(d for d in glob.glob("skills/*") if os.path.isdir(d))
if not skill_dirs:
    bad("no skill directories found under skills/")

names = []
for d in skill_dirs:
    slug = os.path.basename(d)
    path = os.path.join(d, "SKILL.md")
    if not os.path.isfile(path):
        bad("%s: no SKILL.md" % slug)
        continue
    src = open(path, encoding="utf-8").read()

    m = re.match(r"---\n(.*?)\n---\n", src, re.DOTALL)
    if not m:
        bad("%s: no YAML frontmatter" % slug)
        continue
    fm, body = m.group(1), src[m.end():]

    # frontmatter completeness
    missing = [k for k in REQUIRED_KEYS if not re.search(r"^%s:" % k, fm, re.M)]
    if missing:
        bad("%s: frontmatter missing %s" % (slug, ", ".join(missing)))

    # name must match the directory (the slug is what Claude and every link use)
    nm = re.search(r"^name:\s*(\S+)", fm, re.M)
    if nm:
        names.append(nm.group(1))
        if nm.group(1) != slug:
            bad('%s: name "%s" does not match its directory' % (slug, nm.group(1)))

    # description: the load-bearing routing field
    dm = re.search(r"^description:\s*>\n((?:[ \t]+.*\n)+)", fm, re.M)
    if not dm:
        bad("%s: description is not a folded block (`description: >`)" % slug)
    else:
        desc = re.sub(r"\s+", " ", dm.group(1)).strip()
        if len(desc) > 1024:
            bad("%s: description is %d chars (max 1024)" % (slug, len(desc)))
        if not USE_CLAUSE.search(desc):
            bad('%s: description has no "Use when/before/..." clause — Claude cannot '
                "tell when to load it" % slug)
        if "Trigger terms:" not in desc:
            bad("%s: description has no `Trigger terms:` list" % slug)

    # the principle back-reference must actually resolve
    pm = re.search(r"^principle:\s*(\S+)", fm, re.M)
    if pm and not os.path.exists(os.path.normpath(os.path.join(d, pm.group(1)))):
        bad("%s: principle: %s does not resolve" % (slug, pm.group(1)))

    # uniform section set, in the same order, in every skill
    found = re.findall(r"^## (.+)$", body, re.M)
    if found != SECTIONS:
        extra = [s for s in found if s not in SECTIONS]
        gone = [s for s in SECTIONS if s not in found]
        detail = []
        if gone:
            detail.append("missing %s" % gone)
        if extra:
            detail.append("unexpected %s" % extra)
        if not detail:
            detail.append("out of order: %s" % found)
        bad("%s: sections %s" % (slug, "; ".join(detail)))

if not fails:
    ok("%d skills: frontmatter, name↔dir, description routing, section order" % len(skill_dirs))

# --- both indexes stay in sync with the skill set (two indexes drift by hand) ---
for index in ("skills/README.md", "PRINCIPLES.md"):
    if not os.path.isfile(index):
        bad("%s is missing" % index)
        continue
    txt = open(index, encoding="utf-8").read()
    absent = [os.path.basename(d) for d in skill_dirs
              if "%s/SKILL.md" % os.path.basename(d) not in txt]
    if absent:
        bad("%s does not list: %s" % (index, ", ".join(absent)))
    else:
        ok("%s lists all %d skills" % (index, len(skill_dirs)))

# --- the inventory's DERIVED cells must match their source ---
# The `receipt` and `→ next` prose is hand-written and belongs in the table, not in
# frontmatter — so this does not generate the table. It checks only the cells that
# have a source of truth elsewhere and can therefore drift silently: `scope`, which
# is duplicated from each skill's frontmatter, and the skill names in `→ next`,
# which must be skills that exist.
inv = "skills/README.md"
if os.path.isfile(inv):
    slugs = {os.path.basename(d) for d in skill_dirs}
    drift = []
    rows = re.findall(r"^\| \[([a-z][a-z-]*)\]\(([^)]+)\) \| ([^|]+) \| ([^|]+) \|",
                      open(inv, encoding="utf-8").read(), re.M)
    listed = {r[0] for r in rows}
    for slug, link, scope_cell, next_cell in rows:
        if slug not in slugs:
            drift.append("%s: row for a skill that does not exist" % slug)
            continue
        fm_src = open("skills/%s/SKILL.md" % slug, encoding="utf-8").read()
        fm_scope = re.search(r"^scope:\s*(\S+)", fm_src, re.M)
        if fm_scope and fm_scope.group(1) != scope_cell.strip():
            drift.append('%s: scope cell "%s" != frontmatter "%s"'
                         % (slug, scope_cell.strip(), fm_scope.group(1)))
        # hyphenated tokens in `→ next` are skill names; prose like "(in the 2nd
        # house)" or "(loop: LEDGER)" is not, so only check hyphenated candidates.
        for tok in re.findall(r"[a-z][a-z-]{4,}", next_cell):
            if "-" in tok and tok not in slugs:
                drift.append('%s: → next names "%s", which is not a skill' % (slug, tok))
    for s in sorted(slugs - listed):
        drift.append("%s: has no row in the inventory table" % s)
    if drift:
        for d_ in drift:
            bad("%s: %s" % (inv, d_))
    else:
        ok("%s: every row's scope and → next matches its source" % inv)

# --- every relative link resolves (receipts are the product; dead links are not) ---
broken = []
for f in glob.glob("*.md") + glob.glob("skills/**/*.md", recursive=True):
    base = os.path.dirname(f)
    for m in re.finditer(r"\[([^\]]+)\]\(([^)]+)\)", open(f, encoding="utf-8").read()):
        tgt = m.group(2)
        # `../../issues/new?...`, `../../blob/main/...` — GitHub repo-relative URLs
        # that GitHub resolves as routes, not paths on disk. Matched narrowly by route
        # segment so that real relative paths (`../../LEDGER.md`) stay checked.
        if re.match(r"\.\./\.\./(issues|pulls?|blob|tree|wiki|compare|commits?)(/|$)", tgt):
            continue
        if tgt.startswith(("http://", "https://", "#", "mailto:")):
            continue
        p = os.path.normpath(os.path.join(base, tgt.split("#")[0]))
        if not os.path.exists(p):
            broken.append("%s -> %s" % (f, tgt))
if broken:
    for b in broken:
        bad("broken relative link: %s" % b)
else:
    ok("all relative links resolve")

# --- de-identification: no maintainer handles in prose ---
# Pattern-based on purpose: hard-coding the names to look for would itself put them
# in the repo. JIRA `[~handle]` and bare `@handle` are the two forms that have shown
# up. tools/ is exempt: an owner handle inside an API path is a functional coordinate.
# Generic placeholders are the vocabulary these skills teach in ("no maintainer
# @handles in source"), not references to a person — so they are not hits.
PLACEHOLDERS = {"handle", "handles", "handle)", "name", "names", "someone", "me",
                "you", "user", "username", "maintainer", "committer", "reviewer",
                "author", "predecessor", "assignee", "a-z", "dev"}
handle_hits = []
for f in glob.glob("*.md") + glob.glob("skills/**/*.md", recursive=True):
    for i, line in enumerate(open(f, encoding="utf-8"), 1):
        for pat in (r"\[~([A-Za-z][\w.-]*)\]", r"(?<![\w/`])@([A-Za-z][\w-]{2,})"):
            for m in re.finditer(pat, line):
                if m.group(1).lower() in PLACEHOLDERS:
                    continue
                handle_hits.append("%s:%d %s" % (f, i, m.group(0)))
if handle_hits:
    for h in handle_hits:
        bad("maintainer handle in prose: %s (de-identify, per PRINCIPLES)" % h)
else:
    ok("no maintainer handles in prose")

# --- English-only (the journal this is extracted from is not) ---
cyr = []
for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs if d not in (".git", "__pycache__")]
    for fn in files:
        p = os.path.join(root, fn)
        try:
            txt = open(p, encoding="utf-8").read()
        except (UnicodeDecodeError, OSError):
            continue
        for ch in set(txt):
            if ord(ch) > 127 and "CYRILLIC" in unicodedata.name(ch, ""):
                cyr.append(p)
                break
if cyr:
    for p in sorted(set(cyr)):
        bad("non-English (Cyrillic) content in %s" % p)
else:
    ok("all content is English (no Cyrillic)")

print("----")
print("%d checks passed, %d failed" % (oks, len(fails)))
sys.exit(1 if fails else 0)
PYEOF
STRUCT_RC=$?

# --- receipt links resolve (opt-in: needs network + gh auth) ---
ONLINE_RC=0
if [ "$ONLINE" -eq 1 ]; then
  echo
  echo "### --online: resolving every GitHub receipt link"
  if ! command -v gh >/dev/null 2>&1; then
    echo "skip - gh not on PATH; receipt-link check skipped"
  else
    # Collect owner/repo + number from the issue/pull URLs cited as receipts.
    urls=$(grep -rhoE 'https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/(issues|pull)/[0-9]+' \
             --include='*.md' . | sort -u)
    n=0; miss=0
    for u in $urls; do
      repo=$(echo "$u" | sed -E 's#https://github.com/([^/]+/[^/]+)/.*#\1#')
      num=$(echo "$u" | sed -E 's#.*/([0-9]+)$#\1#')
      n=$((n+1))
      if state=$(gh api "repos/$repo/issues/$num" --jq '.state' 2>/dev/null); then
        printf 'ok   - %s [%s]\n' "$u" "$state"
      else
        printf 'FAIL - %s does not resolve\n' "$u"; miss=$((miss+1))
      fi
    done
    echo "----"
    echo "$n receipt links checked, $miss unresolved"
    [ "$miss" -gt 0 ] && ONLINE_RC=1
  fi
fi

if [ "$STRUCT_RC" -eq 0 ] && [ "$ONLINE_RC" -eq 0 ]; then
  echo "PASS"
  exit 0
fi
echo "FAILED"
exit 1
