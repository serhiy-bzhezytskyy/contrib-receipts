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

# --- GitHub PRs: repo:number ---
# KEEP THIS LIST CURRENT: add every PR the moment it's opened, or "check status" silently skips it
# (the #600 comment on 2026-07-21 was missed because #600 wasn't listed here).
GH_PRS=(
  "apache/solr:4638" "apache/solr:4640" "apache/solr:4643" "apache/solr:4644"
  "apache/solr:4648"
  "mikemccand/luceneutil:595" "mikemccand/luceneutil:600"
  "jetty/jetty.project:15435"
  "apache/lucene:16411"
)
# --- GitHub issues I'm watching / where I OFFERED a fix (comment-first, PR pending nod) ---
GH_ISSUES=( "apache/lucene:14399" "apache/lucene:13313" "jetty/jetty.project:15368"
  "jetty/jetty.project:13569" "opensearch-project/OpenSearch:17140" "opensearch-project/OpenSearch:21537" )
# --- ASF JIRA keys ---
JIRAS=( SOLR-17764 SOLR-17316 SOLR-12239 SOLR-7177 SOLR-18308 SOLR-3284 SOLR-16851 )

hr(){ printf '%.0s─' {1..70}; echo; }

# --- run counters (fuel for the log line at the end) ---
CHANNELS=0          # distinct channels this sweep actually queried
ITEMS=0             # PRs + issues + JIRA keys swept
BALL_ON_YOU_GH=0    # "ball is on you" decided from a GitHub channel
BALL_ON_YOU_XTR=0   # "ball is on you" decided from a NON-GitHub channel (ASF JIRA / dev@)

echo "### GitHub PRs — all 3 comment channels + who moved last"
CHANNELS=$((CHANNELS+1))
for item in "${GH_PRS[@]}"; do
  repo="${item%%:*}"; n="${item##*:}"
  # gather (author, iso-date) across issue-comments, review-comments, reviews
  rows=$( { gh api "repos/$repo/issues/$n/comments" --jq '.[] | "\(.created_at)\t\(.user.login)\tissue-comment"' 2>/dev/null
           gh api "repos/$repo/pulls/$n/comments"  --jq '.[] | "\(.created_at)\t\(.user.login)\treview-comment"' 2>/dev/null
           gh api "repos/$repo/pulls/$n/reviews"   --jq '.[] | select(.submitted_at!=null) | "\(.submitted_at)\t\(.user.login)\treview:\(.state)"' 2>/dev/null
         } | sort )
  state=$(gh pr view "$n" --repo "$repo" --json state,reviewDecision --jq '"\(.state)/\(.reviewDecision // "no-review")"' 2>/dev/null)
  last=$(echo "$rows" | tail -1)
  lastwho=$(echo "$last" | cut -f2)
  ball="⚪ maintainer"
  [ -z "$rows" ] && ball="⚪ maintainer (no comments yet)"
  [ -n "$lastwho" ] && [ "$lastwho" != "$ME" ] && { ball="🔴 YOU (last: $lastwho)"; BALL_ON_YOU_GH=$((BALL_ON_YOU_GH+1)); }
  ITEMS=$((ITEMS+1))
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
  ball="⚪ them"; [ -n "$lastwho" ] && [ "$lastwho" != "$ME" ] && ball="🟡 last: $lastwho"
  ITEMS=$((ITEMS+1))
  printf "ISSUE %s#%s  %s\n" "$repo" "$n" "$ball"
  echo "$rows" | tail -2 | sed 's/^/    /'
done

hr
echo "### ASF JIRA — comments (the channel that was being MISSED)"
CHANNELS=$((CHANNELS+1))
JIRA_PY=$(mktemp /tmp/jira_check_XXXX.py)
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
for j in "${JIRAS[@]}"; do
  out=$(curl -s "https://issues.apache.org/jira/rest/api/2/issue/${j}?fields=status,updated,comment" 2>/dev/null | \
    KEY="$j" ME_JIRA="$ME_JIRA" python3 "$JIRA_PY")
  echo "$out"
  ITEMS=$((ITEMS+1))
  # a "YOU -> reply" on JIRA is a ball-on-you decided by a channel GitHub can't see = cross-tracker signal
  echo "$out" | grep -q "YOU -> reply" && BALL_ON_YOU_XTR=$((BALL_ON_YOU_XTR+1))
done
rm -f "$JIRA_PY"

hr
echo "### dev@ mailing list — lists.apache.org API (no auth). Threads I'm in + recent sort/index traffic."
CHANNELS=$((CHANNELS+1))
# months to scan (current + prior); extend as needed
MAIL_MONTHS=( 2026-07 2026-08 )
MAIL_PY=$(mktemp /tmp/mail_check_XXXX.py)
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
    curl -s -G https://lists.apache.org/api/stats.lua \
      --data-urlencode list=dev --data-urlencode domain="$dom" --data-urlencode d="$m" 2>/dev/null | \
      LABEL="dev@$dom $m" python3 "$MAIL_PY"
  done
done
rm -f "$MAIL_PY"
echo "  (to see if a thread got a NEW reply after mine: curl .../api/thread.lua?id=<mid>)"

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
[ "$BALL_ON_YOU_XTR" -gt 0 ] && echo "    ↳ $BALL_ON_YOU_XTR reply(ies) owed on a channel GitHub-alone can't see — the whole reason this sweep exists."
