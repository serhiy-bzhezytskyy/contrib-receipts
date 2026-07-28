#!/usr/bin/env bash
# Smoke test for tools/check-status.sh — offline, no network.
# Verifies the script parses and its two embedded python3 heredocs compile.
# It does NOT hit gh / curl / JIRA (those need creds + network); it proves the
# script is syntactically runnable, which is the failure mode a smoke test guards.
# Usage: bash tests/check-status-smoke.sh   (exit 0 = pass)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../tools/check-status.sh"
fail=0

pass(){ printf 'ok   - %s\n' "$1"; }
bad(){  printf 'FAIL - %s\n' "$1"; fail=1; }

# 1. the script exists
[ -f "$SCRIPT" ] && pass "check-status.sh exists" || { bad "check-status.sh missing"; exit 1; }

# 2. bash parses it (catches unbalanced quotes / heredocs / syntax)
if bash -n "$SCRIPT" 2>/tmp/cs_bash_err; then
  pass "bash -n parses check-status.sh"
else
  bad "bash -n failed:"; cat /tmp/cs_bash_err
fi

# 3. each embedded python3 heredoc compiles (extract PYEOF blocks, compile each)
if command -v python3 >/dev/null 2>&1; then
  if python3 - "$SCRIPT" <<'PYCHECK'
import re, sys, py_compile, tempfile, os
src = open(sys.argv[1]).read()
blocks = re.findall(r"<<'PYEOF'\n(.*?)\nPYEOF", src, re.DOTALL)
if len(blocks) < 2:
    print("FAIL - expected >=2 python heredocs, found %d" % len(blocks)); sys.exit(1)
rc = 0
for i, b in enumerate(blocks, 1):
    fd, p = tempfile.mkstemp(suffix=".py"); os.write(fd, b.encode()); os.close(fd)
    try:
        py_compile.compile(p, doraise=True)
        print("ok   - embedded python heredoc #%d compiles" % i)
    except py_compile.PyCompileError as e:
        print("FAIL - embedded python heredoc #%d does not compile: %s" % (i, e)); rc = 1
    finally:
        os.remove(p)
sys.exit(rc)
PYCHECK
  then :; else bad "embedded python heredoc check failed"; fi
else
  printf 'skip - python3 not on PATH; heredoc compile check skipped\n'
fi

# 4. tools/house-shape.py (the match-the-house-shape receipt) compiles
HS="$HERE/../tools/house-shape.py"
if [ -f "$HS" ]; then
  if command -v python3 >/dev/null 2>&1; then
    if python3 -m py_compile "$HS" 2>/tmp/hs_err; then
      pass "house-shape.py compiles"
    else
      bad "house-shape.py does not compile:"; cat /tmp/hs_err
    fi
  else
    printf 'skip - python3 not on PATH; house-shape.py compile check skipped\n'
  fi
else
  bad "house-shape.py missing"
fi

# 4a. house-shape.py actually RUNS on both key conventions and computes the right numbers.
#     "It compiles" was the whole check here before, which is how it shipped unable to read
#     the `gh pr view --json` output its own docstring tells you to create: gh emits
#     camelCase, the script read snake_case, so every PR failed the merged filter and it
#     exited 1 with "No merged PRs found" on a corpus that was fine.
FIX="$HERE/fixtures/house-shape"
if [ -d "$FIX" ] && command -v python3 >/dev/null 2>&1; then
  if hs_out=$(python3 "$HS" "$FIX" 2>&1); then
    # 2 of the 3 fixtures are merged (one camelCase, one snake_case); the third is OPEN
    # and must be excluded. Medians over adds 55/9, dels 1/3, files 2/6.
    hs_fail=0
    check_line(){ printf '%s\n' "$hs_out" | grep -q "$1" || { bad "house-shape.py: expected '$1' in output"; hs_fail=1; }; }
    check_line "MERGED PRs in corpus: 2"
    check_line "median additions:  +32"
    check_line "median deletions:  -2"
    check_line "median changed_files: 4"
    check_line "test-file-touch rate: 50.0%"
    check_line "title starts with a tracker key: 50.0%"
    check_line "median days-to-merge: 3.0"
    [ "$hs_fail" -eq 0 ] && pass "house-shape.py runs on both gh camelCase and REST snake_case fixtures"
  else
    bad "house-shape.py failed on tests/fixtures/house-shape:"; printf '%s\n' "$hs_out" | sed 's/^/       /'
  fi
else
  printf 'skip - house-shape fixtures or python3 missing\n'
fi

# 4b. the inline `python3 -c '...'` snippets compile too (the heredoc check above only
#     sees <<'PYEOF' blocks, so a syntax error in a -c snippet would ship silently)
if command -v python3 >/dev/null 2>&1; then
  if python3 - "$SCRIPT" <<'PYCHECK'
import re, sys, ast
src = open(sys.argv[1]).read()
snippets = re.findall(r"python3 -c '(.*?)'", src, re.DOTALL)
if not snippets:
    print("ok   - no inline python3 -c snippets to check"); sys.exit(0)
rc = 0
for i, s in enumerate(snippets, 1):
    try:
        ast.parse(s)
        print("ok   - inline python3 -c snippet #%d parses" % i)
    except SyntaxError as e:
        print("FAIL - inline python3 -c snippet #%d: %s" % (i, e)); rc = 1
sys.exit(rc)
PYCHECK
  then :; else bad "inline python3 -c snippet check failed"; fi
fi

# 4c. mktemp templates must have TRAILING X's.
# This test suite passed on 2026-07-28 while the entire ASF JIRA section of check-status.sh was
# dead: `mktemp /tmp/jira_check_XXXX.py` is a literal path on BSD/macOS (no suffix allowed after
# the X's), so the second run ever hit "File exists" and 7 JIRA keys went unswept behind a
# clean-looking summary. Compiling the heredocs proved the Python was fine and told us nothing
# about whether it would be REACHED.
# Both greps below match ASSIGNMENTS ($(mktemp ...)) only. Matching the bare word also matched the
# comment that documents this very trap, so the first version of this test failed on prose.
MKT_ASSIGN='^[^#]*=\$\(mktemp'
if grep -nE "${MKT_ASSIGN}[^)]*_X+\\." "$SCRIPT" >/dev/null 2>&1; then
  bad "mktemp template has a suffix after the X's (literal path on macOS):"
  grep -nE "${MKT_ASSIGN}[^)]*_X+\\." "$SCRIPT" | sed 's/^/       /'
else
  pass "no mktemp template has a suffix after the X's"
fi

# 4d. every mktemp must be guarded, so a failure degrades loudly instead of running python3 on ""
n_mkt=$(grep -cE "$MKT_ASSIGN" "$SCRIPT")
n_grd=$(grep -cE "${MKT_ASSIGN}.*\\|\\|" "$SCRIPT")
if [ "$n_mkt" -gt 0 ] && [ "$n_mkt" -eq "$n_grd" ]; then
  pass "every mktemp call has a || failure branch ($n_mkt/$n_mkt)"
else
  bad "unguarded mktemp: $n_grd of $n_mkt guarded; a failure would silently skip its whole section"
fi

# 5. the skills themselves satisfy the invariants this repo promises about them
VS="$HERE/../tools/validate-skills.sh"
if [ -f "$VS" ]; then
  if bash "$VS" >/tmp/vs_out 2>&1; then
    pass "validate-skills.sh: all skill invariants hold"
  else
    bad "validate-skills.sh reported failures:"; grep '^FAIL' /tmp/vs_out | sed 's/^/       /'
  fi
else
  bad "validate-skills.sh missing"
fi

echo "----"
if [ "$fail" -eq 0 ]; then echo "PASS"; else echo "FAILED"; fi
exit "$fail"
