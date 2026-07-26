#!/usr/bin/env bash
# Do these skills LOAD when they should?
#
# A skill's body is never read until Claude decides to load it, and it decides from
# the `description` frontmatter alone. So a skill has two independent ways to fail:
# the advice can be wrong (receipts and the LEDGER cover that), or the description
# can fail to match how a person actually phrases the request — in which case the
# skill never fires and its receipt is worth nothing. Nothing else in this repo
# tests the second one. tools/validate-skills.sh checks a `Use when…` clause EXISTS;
# only a live session shows whether it ROUTES.
#
# Each case below is phrased the way someone would really say it, and deliberately
# avoids the skill's own trigger terms — testing against the words you already wrote
# into the description would be circular.
#
# Usage: bash tests/routing-evals.sh [case-name ...]
#        RUNS=3 bash tests/routing-evals.sh   # each case N times; reports the rate
#
# NOT part of tests/check-status-smoke.sh, on purpose: every case spawns a real
# Claude session (tokens + ~30-60s each). The smoke test stays free and offline.
#
# HONEST LIMIT — this is a SIGNAL, NOT A GATE. Routing is non-deterministic: a good
# description can still lose a coin flip on an ambiguous prompt, and the built-in
# skills of whatever Claude Code version you run are also competing for the request.
# A single miss means "look at this description", not "this skill is broken". Re-run
# before concluding anything. Cases where more than one skill here is a legitimate
# answer list every acceptable one.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"

command -v claude >/dev/null 2>&1 || { echo "skip - claude CLI not on PATH"; exit 0; }
command -v python3 >/dev/null 2>&1 || { echo "skip - python3 not on PATH"; exit 0; }

# --- the cases: name | expected skill(s), comma-separated | prompt ---
# Keep prompts in a user's voice. If you add a skill, add a case for it here.
CASES=(
  # The sourcing skill. Competes with verify-before-a-committer-comment (both are
  # "my CI is red") — the difference is intent: find the real work, vs assert a claim.
  "red-ci|follow-the-thread|The CI on my pull request just went red on a test I never touched. I'd rather not just shrug it off — where does this actually lead?"

  # The hardest case in the repo: the deliberately overlapping trio. This one is
  # about to ASSERT a technical fact to a maintainer, so verify- must win over
  # track-whose-court (whose turn) and offer-dont-grab (who owns the work).
  "assert-to-maintainer|verify-before-a-committer-comment|I want to leave a comment on the ticket saying my patch is what fixes those failing tests. About to paste it in."

  # Was provably unroutable until its description gained a use-clause: the
  # regression test for that fix.
  "fork-upstream|port-the-report-upstream|This project looks like it was forked from another one, and the file I just patched seems untouched since the copy. Does the original still have the same problem?"

  # Front-gate precedence. Must beat obey-the-houses-own-tooling (build/generator
  # gate) on a question about agent instructions specifically.
  "house-rules|read-the-houses-agent-file-first,obey-the-houses-own-tooling|I'm about to start work in a repo that isn't mine and it ships a file telling assistants how to behave here. What do I do with it?"

  # Whose-turn, not a factual claim — the other side of the trio boundary.
  "whose-turn|track-whose-court|It's been quiet on everything I've got open. Is anyone waiting on me, or am I waiting on them?"
)

RUNS="${RUNS:-1}"
WANT=("$@")
selected() {
  [ ${#WANT[@]} -eq 0 ] && return 0
  for w in "${WANT[@]}"; do [ "$w" = "$1" ] && return 0; done
  return 1
}

pass=0; fail=0; skipped=0
declare -a MISSES=()

for case in "${CASES[@]}"; do
  name="${case%%|*}"; rest="${case#*|}"
  expected="${rest%%|*}"; prompt="${rest#*|}"
  selected "$name" || { skipped=$((skipped+1)); continue; }

  printf '%-22s ' "$name"
  hits=0; observed=""
  for _ in $(seq 1 "$RUNS"); do
    # A clean project dir with ONLY this repo's skills installed, so the run measures
    # these descriptions rather than whatever else is in the developer's ~/.claude.
    work="$(mktemp -d "${TMPDIR:-/tmp}/routing-eval-XXXXXX")"
    mkdir -p "$work/.claude/skills"
    find "$REPO/skills" -mindepth 1 -maxdepth 1 -type d -exec cp -R {} "$work/.claude/skills/" \;

    actual=$( cd "$work" && claude -p "$prompt" \
        --output-format stream-json --verbose --max-turns 2 \
        --allowed-tools Skill 2>/dev/null \
      | python3 -c '
import sys, json
for line in sys.stdin:
    try: d = json.loads(line)
    except ValueError: continue
    if d.get("type") != "assistant": continue
    for c in d.get("message", {}).get("content", []):
        if c.get("type") == "tool_use" and c.get("name") == "Skill":
            print((c.get("input") or {}).get("skill", "?")); sys.exit(0)
' )
    rm -rf "$work"

    [ -z "$actual" ] && actual="(none)"
    observed="$observed $actual"
    printf '%s' ",$expected," | grep -q ",$actual," && hits=$((hits+1))
  done

  # All runs on target = pass. Any miss is reported with the rate, because a single
  # flip is noise and a consistent miss is a description problem.
  if [ "$hits" -eq "$RUNS" ]; then
    echo "ok   - $hits/$RUNS routed as expected"
    pass=$((pass+1))
  else
    echo "FAIL - $hits/$RUNS routed as expected; saw:$observed"
    MISSES+=("$name: $hits/$RUNS to [$expected]; saw:$observed")
    fail=$((fail+1))
  fi
done

echo "----"
echo "$pass routed as expected, $fail did not$([ "$skipped" -gt 0 ] && echo ", $skipped skipped")"
if [ "$fail" -gt 0 ]; then
  echo
  echo "A miss points at a DESCRIPTION to sharpen (the frontmatter is all Claude sees"
  echo "when routing), not at the skill's advice. Re-run before concluding — routing is"
  echo "non-deterministic. Log a repeated miss in LEDGER.md."
  for m in "${MISSES[@]}"; do echo "  - $m"; done
fi
[ "$fail" -eq 0 ] && echo "PASS" || echo "FAILED"
exit "$([ "$fail" -eq 0 ] && echo 0 || echo 1)"
