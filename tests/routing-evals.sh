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

# Running this from INSIDE a Claude Code session is the common case (you're editing a
# skill and want to know if it routes) — and the CLI refuses to nest:
#   "Claude Code cannot be launched inside another Claude Code session."
# That refusal is silent here: the JSON parse finds no Skill tool_use and every case
# reports `saw: (none)`, which looks exactly like a routing regression across ALL cases
# at once. That false alarm cost a debugging detour on 2026-07-27. Unset the marker so
# the child launches, and treat an all-cases-(none) result as harness breakage until
# proven otherwise.
unset CLAUDECODE

# --- the cases: name | expected skill(s), comma-separated | prompt ---
# Keep prompts in a user's voice. If you add a skill, add a case for it here.
CASES=(
  # The sourcing skill. Competes with verify-before-a-committer-comment (both are
  # "my CI is red") — the difference is intent: find the real work, vs assert a claim.
  "red-ci|follow-the-thread|The CI on my pull request just went red on a test I never touched. I'd rather not just shrug it off — where does this actually lead?"

  # follow-the-thread's SECOND entry point: neighborhood discovery reached from a
  # LANDED fix rather than from a symptom. Its description is all symptom-language
  # (red CI, flake, "not my bug"), so this tests whether the fold covers the
  # "I'm already standing in this subsystem — what's near it?" route. It does:
  # measured 10/11 (one run answered directly). This is the weakest case here and
  # the one to watch — a drop below ~8/10 means the symptom-only vocabulary has
  # stopped covering the post-fix route, and the fix is words in the description,
  # not a separate neighborhood-discovery skill.
  "post-fix-neighborhood|follow-the-thread|I just got my fix merged in a module I'd never touched before. While I was in there I noticed a few rough edges. What's worth doing next?"

  # The hardest case in the repo: the deliberately overlapping trio. This one is
  # about to ASSERT a technical fact to a maintainer, so verify- must win over
  # track-whose-court (whose turn) and offer-dont-grab (who owns the work).
  "assert-to-maintainer|verify-before-a-committer-comment|I want to leave a comment on the ticket saying my patch is what fixes those failing tests. About to paste it in."

  # Was provably unroutable until its description gained a use-clause: the
  # regression test for that fix — and then the collision case. Adding
  # read-the-projects-origin-story dropped this from 3/3 to 1/3 because both
  # descriptions claimed fork/port vocabulary; after that skill was narrowed to
  # "about to propose" plus an explicit hand-off line, this measured 7/9 and then
  # 3/3 twice. Watch it: a fresh drop here means a new skill is competing again.
  "fork-upstream|port-the-report-upstream|This project looks like it was forked from another one, and the file I just patched seems untouched since the copy. Does the original still have the same problem?"

  # Front-gate precedence. Must beat obey-the-houses-own-tooling (build/generator
  # gate) on a question about agent instructions specifically.
  "house-rules|read-the-houses-agent-file-first,obey-the-houses-own-tooling|I'm about to start work in a repo that isn't mine and it ships a file telling assistants how to behave here. What do I do with it?"

  # The other sourcing skill, and a deliberately BURIED trigger: this description
  # opens with "When a maintainer says…", not "Use when…". It routes anyway, which is
  # why front-loading the trigger is treated here as a fix for a measured miss rather
  # than a blanket rule (Hermes-Agent's runtime truncates descriptions to 60 chars in
  # its prompt index and so must front-load; Claude Code does not appear to).
  "scattered-thread|consolidate-a-scattered-thread|A committer just said he isn't sure where this discussion should even continue — it's spread over a pile of tickets and a mailing list thread. What should I send back?"

  # Packaging a cluster. Competes with match-the-house-shape, which also owns "split
  # the PR" — but that one is about SIZE vs the house median, this one about one
  # issue per PR when fixes are independent.
  "package-cluster|one-fix-one-pr-then-coordinate|My one branch ended up fixing three different filed bugs, all in the same two files. How should I actually open this?"

  # The number-discipline skill. Competes with use-the-tool-for-its-purpose (which
  # owns "run it at realistic N") and verify-before-a-committer-comment (which owns
  # "is my claim true") — this one is specifically: is the number above its own noise?
  # Prompt avoids "noise floor", "RSD", "variance" and "baseline".
  "is-the-number-real|state-the-noise-floor|I benchmarked the new version against the old one and it came out 13% slower. About to write that up for the mailing list. Anything I should do first?"

  # Size-of-reply discipline. Competes hard: nudge-with-new-information owns "does this
  # message carry a fact" for an UNPROMPTED message, write-in-your-own-voice owns the
  # register of prose that should exist — this one is whether the prose should exist at
  # all, on a message you were invited to send. Prompt avoids "only", "asked",
  # "verification" and any form of "answer". 3/3 on arrival, with stalled-pr and
  # pr-body-voice both still 2/2 alongside it — no collision despite the overlap.
  "just-a-rebase|answer-only-what-was-asked|A reviewer who already approved my PR left a one-line note saying it needs a rebase. I did it and reran everything locally. What should I put in the reply?"

  # Widening a landed fix to a neighbour. Competes with state-the-noise-floor (both
  # refuse an unmeasured claim) and one-fix-one-pr-then-coordinate (how many PRs).
  # Prompt avoids "measure", "widen", "same vulnerability" and "consistency".
  # 3/3 on arrival; is-the-number-real held 2/2 alongside it.
  "extend-to-neighbour|measure-before-you-widen|My fix landed for one file format, and a second format calls the exact same decompression routine, so it looks like it has the identical flaw. Should I queue up a third change for it?"

  # --- the eight original etiquette skills. Added later than the rest: every skill
  # shipped during the 07-26/27 arc got a case on arrival, while these eight had gone
  # unmeasured the longest — the inverse of what coverage should look like. All eight
  # routed first time, and the two pairs most at risk of colliding held at 3/3
  # (comment-in-code vs pr-body-voice; how-big-a-pr vs assigned-issue). So the original
  # descriptions were sound — worth knowing, since the newest skills needed two fixes.

  # Source comments. Competes with write-in-your-own-voice (prose register) — this one
  # is specifically about what a comment IN THE CODE may say.
  "comment-in-code|comments-about-code-not-change|I added a couple of explanatory comments in the file I patched, mentioning the ticket and what the old behaviour was. Fine to push?"

  # Timing of the conversation. Competes with read-the-projects-origin-story (settled
  # history) and offer-dont-grab (owned work) — this one is "talk before you code".
  "before-i-code|discuss-in-issue-first|I've got a design in mind for a fairly substantial change to a project I don't maintain. Should I just build it and show them, or something else first?"

  # PR shape vs the house median. Competes with one-fix-one-pr-then-coordinate, which
  # owns "one issue per PR" — this one is size/files/title conventions.
  "how-big-a-pr|match-the-house-shape|How large should my change be for a project like this, and does the title need to look a particular way? I don't want it bounced on packaging."

  # History rewriting on a reviewed PR. Prompt avoids "force-push" and "amend".
  "tidy-history|no-force-push-a-reviewed-pr|Someone has already left comments on my PR and my commits are messy. Can I clean them up into one before they look again?"

  # Owned/dormant work. Competes with discuss-in-issue-first (both "align first").
  "assigned-issue|offer-dont-grab|The bug I want to fix is assigned to one of the maintainers, but nothing has happened on it for months. Can I work on it?"

  # The legal sign-off contract. Prompt avoids DCO/ECA/CLA and "Signed-off-by".
  "legal-gate|sign-off-the-house-way|First time contributing to this project. Is there anything I need to attach to my commits before I open the PR, legally speaking?"

  # Finding work by running the thing. Competes with follow-the-thread (starts from a
  # symptom someone else hit) — this one starts from having no lead at all.
  "where-to-contribute|use-the-tool-for-its-purpose|I'd like to contribute to a project I've never worked on and there's no obvious bug to pick up. How do I find something real to fix?"

  # Human-facing prose register. Competes with comments-about-code-not-change.
  "pr-body-voice|write-in-your-own-voice|Drafting the description for my pull request. How should I write it so it doesn't read like it was generated?"

  # Whose-turn, not a factual claim — the other side of the trio boundary.
  "whose-turn|track-whose-court|It's been quiet on everything I've got open. Is anyone waiting on me, or am I waiting on them?"

  # Origin-story excavation. Competes with discuss-in-issue-first (which is "raise it
  # before you code") and consolidate-a-scattered-thread (which traverses a LIVE
  # discussion) — this one is about reading the SETTLED history that created a young
  # repo, before proposing to it. Prompt avoids "origin story", "founding" and "VOTE".
  "why-does-this-exist|read-the-projects-origin-story|This subproject is only a couple of months old and I'm about to suggest a fairly big addition to it. How do I find out what its authors already decided and argued about, so I'm not repeating something?"
  # Nudge timing/content. Competes directly with track-whose-court, whose description
  # already carries "nudge vs wait" — that one answers WHOSE TURN, this one answers
  # WHETHER NOW and WHAT TO SAY. Prompt avoids "nudge", "reminder" and "new
  # information" so it isn't circular. Either is a legitimate answer here (whose-turn
  # is a prerequisite for the nudge decision), so both are accepted. Measured 3/3 on
  # adding the skill, with `whose-turn` at 4/5 alongside it and every miss `(none)` —
  # i.e. noise, not the vocabulary collision that read-the-projects-origin-story caused.
  "stalled-pr|nudge-with-new-information,track-whose-court|My pull request has had no response for a few days. Should I say something on it, and if so what?"
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
