#!/usr/bin/env bash
# Channel-complete status check across every place a maintainer can reach me.
# Fixes the failure mode where JIRA / inline-review / review channels were skipped.
# Usage: bash check-status.sh   (add JIRA keys / PRs to the arrays below as work evolves)
set -uo pipefail

ME="serhiy-bzhezytskyy"          # GitHub login
ME_JIRA="Serhiy Bzhezytskyy"     # JIRA display name (to detect if the LAST comment is mine)

# One structured line per run, appended to a local log OUTSIDE this repo (no churn, no leak).
# It records how much cross-channel reconstruction this sweep required — the whole reason this
# tool exists is that a maintainer's reply can land in a channel GitHub-alone can't see, and doing
# that sweep by hand once MISSED one. The `cross_tracker_signal` column is the payoff metric:
# it flags a run where a non-GitHub channel (ASF JIRA / dev@) drove a "ball is on you" decision —
# exactly the case a GitHub-only view is blind to. Override the path with CONTRIB_LOG=...
LOG="${CONTRIB_LOG:-$HOME/.contrib-receipts/status-log.tsv}"

# The TSV above records HOW MUCH; this records WHY — one JSON object per item per run
# (which item, which channel decided it, who moved last, the verdict). The counts alone
# can't answer "which thread was it, and what made me think the ball was mine?", which is
# exactly what a LEDGER entry needs weeks later, when it is being written from memory.
# One line per decision, append-only, outside the repo. Override with CONTRIB_DECISIONS=...
DECISIONS="${CONTRIB_DECISIONS:-$HOME/.contrib-receipts/decisions.jsonl}"
mkdir -p "$(dirname "$DECISIONS")"
RUN_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# decide <channel> <item> <verdict> <last_mover> [note]
# Kept deliberately dumb: no jq dependency, values are plain identifiers/logins, and
# anything free-text is passed through python for escaping.
decide() {
  RUN_TS="$RUN_TS" CH="$1" IT="$2" V="$3" WHO="${4:-}" NOTE="${5:-}" python3 -c '
import json, os
print(json.dumps({
    "ts":      os.environ["RUN_TS"],
    "channel": os.environ["CH"],
    "item":    os.environ["IT"],
    "verdict": os.environ["V"],
    "last":    os.environ["WHO"] or None,
    "note":    os.environ["NOTE"] or None,
}, ensure_ascii=False))' >> "$DECISIONS"
}

# --- GitHub PRs: repo:number ---
# KEEP THIS LIST CURRENT: add every PR the moment it's opened, or "check status" silently skips it
# (the #600 comment on 2026-07-21 was missed because #600 wasn't listed here).
GH_PRS=(
  "apache/solr:4638" "apache/solr:4640" "apache/solr:4643" "apache/solr:4644"
  "apache/solr:4648" "apache/solr:4678"
  # merged, kept listed: a review comment can land after the merge and is otherwise invisible.
  # #4651 was merged 2026-07-30 01:44 and dsmiley left a review comment on the changelog file at
  # 01:45 — one minute later. Not in this list at the time, so the sweep never saw it.
  "apache/solr:4639" "apache/solr:4651"
  "mikemccand/luceneutil:595" "mikemccand/luceneutil:600" "mikemccand/luceneutil:604"
  "jetty/jetty.project:15435" "jetty/jetty.project:15472" "jetty/jetty.project:15473"
  "apache/lucene:16411" "apache/lucene:16434"
  # 2026-08-02 — the CheckIndex / stored-fields-corruption arc, five PRs in one evening.
  # #16480 carries three commits and closes the issue I opened for it (#16479, in GH_ISSUES below).
  "apache/lucene:16474" "apache/lucene:16475" "apache/lucene:16476"
  "apache/lucene:16478" "apache/lucene:16480"
  # solr-orbit: #59 merged 2026-07-27, kept listed so a post-merge comment still surfaces
  "apache/solr-orbit:58" "apache/solr-orbit:59" "apache/solr-orbit:60"
  # OSB — the upstream siblings of the three solr-orbit fixes
  # #22534 was authored by me and was missing from this list until the audit below found it
  "opensearch-project/OpenSearch:22534"
  "opensearch-project/opensearch-benchmark:1096"
  "opensearch-project/opensearch-benchmark:1097"
  "opensearch-project/opensearch-benchmark:1098"
)
# --- GitHub issues I'm watching / where I OFFERED a fix (comment-first, PR pending nod) ---
GH_ISSUES=( "apache/lucene:14399" "apache/lucene:13313" "jetty/jetty.project:15368"
  # 2026-08-02 — issues I commented on in the CheckIndex arc. Four of them have had no reply in
  # 10+ years, so "last comment is mine" is the expected state; they are listed because a reply
  # after a decade is exactly the thing a sweep must not miss.
  # #16479 is mine, opened for #16480. #12872 is gokaai's stalled PR that #16476 carries forward.
  "apache/lucene:16479" "apache/lucene:7820" "apache/lucene:9967" "apache/lucene:12872"
  "apache/lucene:5501" "apache/lucene:10004" "apache/lucene:7823" "apache/lucene:7405"
  "jetty/jetty.project:13569" "opensearch-project/OpenSearch:17140" "opensearch-project/OpenSearch:21537"
  # solr-orbit issues I created (#56 closed by #59; #61 is parked on Jan's "feature creep" call)
  "apache/solr-orbit:55" "apache/solr-orbit:57" "apache/solr-orbit:61"
  "opensearch-project/opensearch-benchmark:1093"
  "opensearch-project/opensearch-benchmark:1094"
  "opensearch-project/opensearch-benchmark:1095" )
# --- ASF JIRA keys ---
JIRAS=( SOLR-17764 SOLR-17316 SOLR-12239 SOLR-7177 SOLR-18308 SOLR-3284 SOLR-16851
  SOLR-9355 SOLR-11881 SOLR-17841
  # merged but still Open, so nobody is watching them: SOLR-17707 needed janhoy to ask dsmiley to
  # resolve it; SOLR-18313 is in the same state right now (PR #4651 merged, JIRA still Open).
  SOLR-17707 SOLR-18313
  # found by the audit below, not by hand: resolved ones are kept because a post-resolution comment
  # is still a reply owed, and SOLR-18302 is open
  SOLR-18302 SOLR-17968 SOLR-18289 )

# --- Automatic discovery, so a missing manual entry degrades instead of silently hiding an item ---
# The manual lists above stay authoritative: they carry the notes, and they cover items where I am
# not the author (issues opened by others, JIRAs I only commented on). This adds a second pass that
# asks GitHub and JIRA "what else has my name on it", and reports anything the lists do not mention.
GH_AUTHOR="${GH_AUTHOR:-serhiy-bzhezytskyy}"
JIRA_AUTHOR="${JIRA_AUTHOR:-Serhiy Bzhezytskyy}"

hr(){ printf '%.0s─' {1..70}; echo; }

# Anything authored by me that the manual lists do not name. Printed as a gap in the lists, not as a
# work item: the point is to notice the omission, then add it above with a note.
audit_lists() {
  hr; echo "### List audit — mine on the tracker but NOT in the lists above"
  local listed missing=0
  listed=$(printf '%s\n' "${GH_PRS[@]}" "${GH_ISSUES[@]}")
  while IFS=$'\t' read -r repo num title; do
    [ -z "$num" ] && continue
    printf '%s\n' "$listed" | grep -qx "$repo:$num" && continue
    echo "  ⚠️ NOT LISTED  $repo#$num  $title"
    missing=$((missing+1))
  done < <(gh search prs --author "$GH_AUTHOR" --state open --limit 60 \
             --json repository,number,title \
             --jq '.[] | "\(.repository.nameWithOwner)\t\(.number)\t\(.title[0:60])"' 2>/dev/null)

  while IFS=$'\t' read -r key status summary; do
    [ -z "$key" ] && continue
    printf '%s\n' "${JIRAS[@]}" | grep -qx "$key" && continue
    echo "  ⚠️ NOT LISTED  $key [$status]  $summary"
    missing=$((missing+1))
  done < <(python3 - "$JIRA_AUTHOR" <<'PYEOF'
import json, sys, urllib.parse, urllib.request
author = sys.argv[1]
jql = f'project in (SOLR, LUCENE) AND (reporter = "{author}" OR assignee = "{author}" OR comment ~ "{author}") AND updated >= -60d ORDER BY updated DESC'
url = ('https://issues.apache.org/jira/rest/api/2/search?maxResults=60&fields=summary,status&jql='
       + urllib.parse.quote(jql))
try:
    for i in json.load(urllib.request.urlopen(url, timeout=40)).get('issues', []):
        print(f"{i['key']}\t{i['fields']['status']['name']}\t{i['fields']['summary'][:60]}")
except Exception as e:
    print(f"(jira audit unavailable: {e})", file=sys.stderr)
PYEOF
  )
  [ "$missing" -eq 0 ] && echo "  ✅ no gaps: every open item of mine is in a list above" \
    || echo "  ↳ $missing item(s) invisible to the sweep until added to GH_PRS / GH_ISSUES / JIRAS"
}

# --- run counters (fuel for the log line at the end) ---
CHANNELS=0          # distinct channels this sweep actually queried
ITEMS=0             # PRs + issues + JIRA keys swept
BALL_ON_YOU_GH=0    # "ball is on you" decided from a GitHub channel
BALL_ON_YOU_XTR=0   # "ball is on you" decided from a NON-GitHub channel (ASF JIRA / dev@)

echo "### GitHub PRs — all 4 channels (3 comment + commits) + who moved last"
CHANNELS=$((CHANNELS+1))
for item in "${GH_PRS[@]}"; do
  repo="${item%%:*}"; n="${item##*:}"
  # gather (author, iso-date) across issue-comments, review-comments, reviews, AND commits.
  # Commits are the 4th channel: a maintainer clicking "Update branch" writes a merge commit onto
  # MY branch and leaves NO comment anywhere, so a comment-only sweep reports "no activity".
  # Missed exactly that twice on 2026-07-27/28 (solr-orbit #58 351f1541, #60 9b4f1516, both janhoy).
  # It also matters mechanically, not just socially: the next push is rejected non-fast-forward,
  # and force-pushing past it would delete a committer's commit from the branch.
  rows=$( { gh api "repos/$repo/issues/$n/comments" --jq '.[] | "\(.created_at)\t\(.user.login)\tissue-comment"' 2>/dev/null
           gh api "repos/$repo/pulls/$n/comments"  --jq '.[] | "\(.created_at)\t\(.user.login)\treview-comment"' 2>/dev/null
           gh api "repos/$repo/pulls/$n/reviews"   --jq '.[] | select(.submitted_at!=null) | "\(.submitted_at)\t\(.user.login)\treview:\(.state)"' 2>/dev/null
           gh api "repos/$repo/pulls/$n/commits"   --jq '.[] | "\(.commit.author.date)\t\(.author.login // .commit.author.email)\tcommit:\(.sha[0:8])"' 2>/dev/null
         } | sort )
  state=$(gh pr view "$n" --repo "$repo" --json state,reviewDecision --jq '"\(.state)/\(.reviewDecision // "no-review")"' 2>/dev/null)
  last=$(echo "$rows" | tail -1)
  lastwho=$(echo "$last" | cut -f2)
  lastkind=$(echo "$last" | cut -f3)
  ball="⚪ maintainer"
  verdict="them"
  [ -z "$rows" ] && ball="⚪ maintainer (no comments yet)" && verdict="them-no-comments"
  if [ -n "$lastwho" ] && [ "$lastwho" != "$ME" ]; then
    case "$lastwho" in
      # A bot's CI/DCO chatter is not a human waiting on me. Counting it as "ball on you"
      # produced 3 fake red flags on the OSB PRs (last mover: github-actions[bot]) and buried
      # the one real cross-tracker reply among them.
      *"[bot]"|github-actions|codecov*|copilot*|dependabot*)
        ball="⚫ bot noise (last: $lastwho) — no human is waiting"
        verdict="bot" ;;
      *)
        case "$lastkind" in
          commit:*)
            # NOT a reply owed — nobody asked a question. It's a branch-state obligation:
            # rebase onto their commit before the next push, never force-push past it.
            ball="🟠 THEIR COMMIT on your branch ($lastwho $lastkind) — rebase, do NOT force-push"
            verdict="you-branch-state"
            BALL_ON_YOU_GH=$((BALL_ON_YOU_GH+1)) ;;
          *)
            # On a MERGED/CLOSED PR an approval or thanks is the end of the exchange, not a
            # question. #59 showed as "YOU" purely because janhoy's APPROVED review came last.
            case "$state" in
              MERGED*|CLOSED*)
                ball="✅ closed out (last: $lastwho $lastkind) — nothing owed"
                verdict="them-closed" ;;
              *)
                ball="🔴 YOU (last: $lastwho)"; verdict="you"
                BALL_ON_YOU_GH=$((BALL_ON_YOU_GH+1)) ;;
            esac ;;
        esac ;;
    esac
  fi
  ITEMS=$((ITEMS+1))
  decide github-pr "$repo#$n" "$verdict" "$lastwho" "$state"
  printf "PR %s#%s  [%s]  %s\n" "$repo" "$n" "$state" "$ball"
  [ -n "$rows" ] && echo "$rows" | tail -3 | sed 's/^/    /'
done

hr
echo "### GitHub issues watched"
CHANNELS=$((CHANNELS+1))
for item in "${GH_ISSUES[@]}"; do
  repo="${item%%:*}"; n="${item##*:}"
  rows=$(gh api "repos/$repo/issues/$n/comments" --jq '.[] | "\(.created_at)\t\(.user.login)"' 2>/dev/null | sort)
  last=$(echo "$rows" | tail -1); lastwho=$(echo "$last" | cut -f2)
  ball="⚪ them"; verdict="them"
  [ -n "$lastwho" ] && [ "$lastwho" != "$ME" ] && { ball="🟡 last: $lastwho"; verdict="watch"; }
  ITEMS=$((ITEMS+1))
  decide github-issue "$repo#$n" "$verdict" "$lastwho" ""
  printf "ISSUE %s#%s  %s\n" "$repo" "$n" "$ball"
  echo "$rows" | tail -2 | sed 's/^/    /'
done

hr
echo "### ASF JIRA — comments (the channel that was being MISSED)"
CHANNELS=$((CHANNELS+1))
# NOTE: the X's must be TRAILING. BSD/macOS mktemp does not accept a suffix after them, so
# `mktemp /tmp/jira_check_XXXX.py` creates that LITERAL path — no randomness — and then fails
# with "File exists" on the next run, which silently killed this whole section on 2026-07-28.
JIRA_PY=$(mktemp -t jira_check) || { echo "  ERR: mktemp failed, JIRA section SKIPPED"; JIRA_PY=""; }
cat > "$JIRA_PY" <<'PYEOF'
import json, sys, os
key = os.environ["KEY"]; me = os.environ["ME_JIRA"]
try:
    d = json.load(sys.stdin); f = d["fields"]
    cs = f.get("comment", {}).get("comments", [])
    st = f.get("status", {}).get("name")
    # ignore automated commit-notification comments when deciding "ball on you"
    BOTS = ("ASF subversion and git services", "ASF GitHub Bot")
    human = [c for c in cs if c.get("author", {}).get("displayName", "") not in BOTS]
    if cs:
        who = (human[-1] if human else cs[-1]).get("author", {}).get("displayName", "?")
        ball = ("YOU -> reply (last: %s)" % who) if who != me else "(last human comment mine)"
        print("%s  [%s]  %s" % (key, st, ball))
        for c in cs[-2:]:
            w = c.get("author", {}).get("displayName", "?")
            b = c.get("body", "").replace("\n", " ")[:150]
            print("    [%s %s] %s" % (w, c.get("created", "")[:10], b))
    else:
        print("%s  [%s]  (no comments)" % (key, st))
except Exception as e:
    print("%s  ERR %s" % (key, e))
PYEOF
SWEEP_ERRORS=0   # sections/items that failed to produce a verdict — must never be silent
for j in "${JIRAS[@]}"; do
  if [ -z "$JIRA_PY" ]; then out=""; else
    out=$(curl -s "https://issues.apache.org/jira/rest/api/2/issue/${j}?fields=status,updated,comment" 2>/dev/null | \
      KEY="$j" ME_JIRA="$ME_JIRA" python3 "$JIRA_PY" 2>&1)
  fi
  # An empty or ERR result is NOT "nothing to do" — it means this channel was not actually checked.
  # Counting it as swept is how a run reports "items=37" while 7 JIRA keys were never looked at.
  if [ -z "$out" ] || echo "$out" | grep -q "ERR"; then
    echo "  ⛔ $j — NOT CHECKED (empty/error response); this key was NOT swept"
    SWEEP_ERRORS=$((SWEEP_ERRORS+1))
    decide asf-jira "$j" "unchecked" "" "empty or error response"
    continue
  fi
  echo "$out"
  ITEMS=$((ITEMS+1))
  # a "YOU -> reply" on JIRA is a ball-on-you decided by a channel GitHub can't see = cross-tracker signal
  if echo "$out" | grep -q "YOU -> reply"; then
    BALL_ON_YOU_XTR=$((BALL_ON_YOU_XTR+1))
    # the cross-tracker case is the one worth a record: a GitHub-only view is blind to it
    decide asf-jira "$j" "you-cross-tracker" \
      "$(echo "$out" | sed -n 's/.*last: \([^)]*\)).*/\1/p')" "invisible to a GitHub-only sweep"
  else
    decide asf-jira "$j" "them" "" ""
  fi
done
rm -f "$JIRA_PY"

hr
echo "### dev@ mailing list — lists.apache.org API (no auth). Threads I'm in + recent sort/index traffic."
CHANNELS=$((CHANNELS+1))
# months to scan (current + prior); extend as needed
MAIL_MONTHS=( 2026-07 2026-08 )
MAIL_PY=$(mktemp -t mail_check) || { echo "  ERR: mktemp failed, dev@ section SKIPPED"; MAIL_PY=""; }
cat > "$MAIL_PY" <<'PYEOF'
import json, sys, os
me = "Serhiy Bzhezytskyy"
kw = ("sort", "index sorting", "searchafter", "search after", "resortindex")
try:
    es = json.load(sys.stdin).get("emails", [])
except Exception as e:
    print("  ERR", e); sys.exit(0)
hits = [e for e in es if any(k in (e.get("subject","").lower()) for k in kw)]
mine = [e for e in es if me.lower() in (e.get("from","").lower())]
print("  %s: %d msgs; %d sort/index-related; %d from me" % (os.environ["LABEL"], len(es), len(hits), len(mine)))
for e in sorted(hits, key=lambda x: x.get("epoch", 0)):
    who = e.get("from","")[:24]
    mark = " <-- me" if me.lower() in who.lower() else ""
    print("    [%s] %s  https://lists.apache.org/thread/%s%s" % (who, e.get("subject","")[:52], e.get("mid",""), mark))
PYEOF
for dom in solr.apache.org lucene.apache.org; do
  for m in "${MAIL_MONTHS[@]}"; do
    [ -z "$MAIL_PY" ] && break
    out=$(curl -s -G https://lists.apache.org/api/stats.lua \
      --data-urlencode list=dev --data-urlencode domain="$dom" --data-urlencode d="$m" 2>/dev/null | \
      LABEL="dev@$dom $m" python3 "$MAIL_PY" 2>&1)
    if [ -z "$out" ] || echo "$out" | grep -q "ERR"; then
      echo "  ⛔ dev@$dom $m — NOT CHECKED (empty/error response)"
      SWEEP_ERRORS=$((SWEEP_ERRORS+1))
    else
      echo "$out"
    fi
  done
done
rm -f "$MAIL_PY"
echo "  (to see if a thread got a NEW reply after mine: curl .../api/thread.lua?id=<mid>)"

# Run the list audit before the summary: an item missing from the lists is a gap in this tool, and it
# has to be visible in the same output as the findings, not in a separate command nobody runs.
audit_lists

# --- one structured log line per run: how much cross-channel reconstruction this sweep cost ---
# Columns: iso8601 | channels_queried | items_swept | ball_on_you_github | ball_on_you_cross_tracker
# The last column is the payoff metric: a ball-on-you decided by a channel a GitHub-only view is blind to.
hr
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$(dirname "$LOG")"
[ -s "$LOG" ] || printf 'ts\tchannels\titems\tball_on_you_gh\tball_on_you_cross_tracker\n' >> "$LOG"
printf '%s\t%d\t%d\t%d\t%d\n' "$TS" "$CHANNELS" "$ITEMS" "$BALL_ON_YOU_GH" "$BALL_ON_YOU_XTR" >> "$LOG"
echo "### run logged → $LOG"
echo "    channels=$CHANNELS items=$ITEMS ball-on-you: github=$BALL_ON_YOU_GH cross-tracker=$BALL_ON_YOU_XTR"
# A sweep that couldn't reach a channel must say so LOUDLY and last. The 2026-07-28 run printed a
# clean "items=37 cross-tracker=0" while every one of the 7 JIRA keys had silently failed — and
# cross-tracker=0 is indistinguishable from "JIRA is quiet", which is the answer this tool exists
# to give. An unreachable channel is an UNKNOWN, never a zero.
if [ "${SWEEP_ERRORS:-0}" -gt 0 ]; then
  echo "### ⛔ INCOMPLETE SWEEP: $SWEEP_ERRORS item(s)/section(s) were NOT checked (see ⛔ above)."
  echo "    Do NOT read the counters above as 'all quiet' — those channels returned no verdict at all."
fi
echo "### per-item decisions → $DECISIONS ($(grep -c . "$DECISIONS" 2>/dev/null || echo 0) total)"
echo "    a LEDGER entry weeks from now is written from these, not from memory:"
echo "    jq -r 'select(.ts==\"$RUN_TS\" and (.verdict|startswith(\"you\"))) | \"\(.channel) \(.item) last=\(.last)\"' $DECISIONS"
[ "$BALL_ON_YOU_XTR" -gt 0 ] && echo "    ↳ $BALL_ON_YOU_XTR reply(ies) owed on a channel GitHub-alone can't see — the whole reason this sweep exists."
