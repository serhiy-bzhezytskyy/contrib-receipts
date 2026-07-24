---
name: track-whose-court
description: >
  To answer "is anything waiting on me?", run a channel-complete status check across
  EVERY channel a maintainer can reach you on — GitHub PR issue-comments, GitHub
  inline review-comments, GitHub reviews, watched-issue comments, ASF JIRA, and the
  dev@ mailing list — plus git diffs as a seventh source. Compare the last HUMAN
  commenter (filtering commit-bot authors) to you to decide whose turn it is.
  Hand-checking one channel silently misses the others. Use on any "check status" /
  "whose turn" / "anything waiting on me" request. Trigger terms: check status,
  whose court, turn tracking, ball on me, follow-up, did they reply, nudge vs wait.
scope: apache/solr
principle: ../../PRINCIPLES.md
---

# Track whose court the ball is in

## Purpose

A maintainer can reach you on any of several channels, and hand-checking one of them
silently misses the rest. The failure mode is concrete: reporting an issue as "0
comments, untouched" when a committer had commented that day — in a channel you
weren't querying. To answer "is anything waiting on me?" honestly, you have to sweep
*all* the channels, then compare the last human commenter to yourself to decide
whose turn it is. This ships as a runnable tool (`tools/check-status.sh`) so the
sweep is complete by construction, not by memory.

Scope note: the tool is wired for Apache Solr / Lucene / Jetty (GitHub + ASF JIRA +
lists.apache.org). The *method* is general; the specific endpoints and the JIRA/
mailing-list steps are ASF-shaped, hence `scope: apache/solr`.

## When to use

- Any "check status", "whose turn is it", or "anything waiting on me" request.
- Before a stand-up-style summary of open PRs/issues.
- Deciding nudge-vs-wait on a specific thread.

## When NOT to use

You already know a specific claim needs proving before you post it — that's verify-before-a-committer-comment; this skill answers *whose turn*, not *is my claim true*.

## The practice (checklist)

Check **all six channels** a maintainer can use, plus git diffs as a seventh:
- [ ] 1. GitHub PR issue-comments — `gh api repos/<repo>/issues/<n>/comments`
- [ ] 2. GitHub inline review-comments — `gh api repos/<repo>/pulls/<n>/comments`
- [ ] 3. GitHub reviews (APPROVE/CHANGES_REQUESTED/COMMENTED) — `gh api repos/<repo>/pulls/<n>/reviews`
- [ ] 4. Watched-issue comments — `gh api repos/<repo>/issues/<n>/comments`
- [ ] 5. **ASF JIRA** comments (public REST, no auth) —
      `curl -s https://issues.apache.org/jira/rest/api/2/issue/<KEY>?fields=status,comment`
- [ ] 6. **dev@ mailing list** — lists.apache.org has a no-auth JSON API
      (`stats.lua?list=dev&domain=<d>&d=YYYY-MM`); don't punt it to "manual".
- [ ] 7. **git diffs** — read the actual `git show <sha>`, not just commit messages
      (the diff often corrects the story the message tells).

**Whose-court logic:** compare the LAST *human* commenter to you. **Filter bot
authors** ("ASF subversion and git services" = commit notices, "ASF GitHub Bot") —
otherwise a commit notification looks like a maintainer pinged you.

**Keep the tool's lists current:** add every PR/JIRA the moment it opens. A real
miss happened because a PR wasn't in the array, so "check status" silently skipped it.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "No reply — I'll just ping again." | Check whose court it's actually in first; the last human move may be yours, and a nudge on your own turn reads as noise. |
| "GitHub shows no new comment, so it's on them." | A maintainer can reach you on six channels (JIRA, dev@, inline reviews…); one-channel checks reported "0 comments" the day a JIRA comment landed. |
| "A commit notification counts as their reply." | Filter bot authors ("ASF subversion and git services") — a commit notice false-positives as a maintainer ping and flips the court wrongly. |

## RECEIPT

**Runnable tool: `tools/check-status.sh`** (ships in this repo). It exists because a
hand-check missed a real comment: a committer's comment on SOLR-17764 lived only in
ASF JIRA — a channel not being queried — so the status was reported as "0 comments,
untouched" the day the comment landed. The tool sweeps all six channels + git diffs
and prints whose court each item is in.

Two fixes baked in from real misses:
- **Bot filter:** "ASF subversion and git services" commit notices false-positived
  as maintainer pings (SOLR-3284) until filtered out.
- **List completeness:** the #600 comment (2026-07-21) was missed because #600
  wasn't in the PR array — hence "add every PR the moment it opens".

This is a JOURNAL receipt (the miss is self-reported, not a maintainer quote), but
the tool is a concrete, runnable artifact — strong lived evidence.

## Lifecycle

- **Signals it worked:** no "you missed my comment" surprises; every open thread's
  court is known before you report status.
- **What to log on a misfire:** which channel or which un-listed PR/JIRA hid the
  comment; add it to the tool's arrays and, if a new channel, to the sweep.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** retire a channel only if a project abandons it (e.g. moves
  fully off JIRA or the mailing list); the tool's arrays are meant to be edited.
- **Relates to:** covers whose-court / turn-tracking across channels and
  nudge-vs-wait timing (who owes the next move, don't be the Nth watcher), and it
  ships a tool to sweep the channels.
