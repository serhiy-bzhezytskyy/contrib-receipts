---
name: answer-only-what-was-asked
description: >
  Use when a maintainer asks for something mechanical — rebase, squash, rename, drop a
  file, apply a suggestion — and you are about to write a comment about having done it.
  The verification you run before pushing is for you; it is not the reply. GitHub already
  shows the force-push, the new commit and the green check, so a comment restating them
  adds reading cost and nothing else. Worse, a report of your own thoroughness reads as
  seeking credit for the request itself. The rule: do the mechanical thing, say at most
  that it is done, and say nothing when the timeline already says it. Comment only when
  you carry something the diff cannot show. Trigger terms:
  rebase, squash, force-push, "can you rebase", "needs a rebase", applied the suggestion,
  addressed the comments, done, updated, pushed, "I have verified", test summary in a
  comment, replying to a review comment.
scope: general
principle: ../../PRINCIPLES.md
---

# Answer the question that was asked, at the size it was asked

## Purpose

A maintainer writes "this will need one more rebase". The work is thirty seconds of
`git rebase`; the temptation is a paragraph. And the paragraph feels earned, because
you *did* verify — you reran the tests, you checked the conflict was textual, you
reverted your own change to confirm the tests still fail without it.

None of that was asked for, and posting it inverts who is doing whom a favour. The
reviewer asked for one mechanical act so that they could continue reviewing. A reply
enumerating your checks makes them read a status report before they can get back to
the thing they were doing. It also carries an implicit claim — *look how carefully I
work* — which is the reviewer's judgement to make from the diff, not yours to assert.

The verification is not wasted; it is what stops you pushing something broken. It is
simply not the answer. Two different audiences: your own gate, and their thread.

## When to use

- A reviewer asked for a rebase, squash, rename, file removal, or "please apply this".
- You are typing a comment whose first word is "Done", "Rebased", "Updated" or "Fixed".
- You are about to paste a test summary, a checklist, or a "verified both directions"
  note into a PR.
- A review comment on a single line has a one-line answer and you are writing five.

## When NOT to use

- The mechanical act **changed something the reviewer should know**: a conflict you had
  to resolve by choosing, a test you had to adapt, a behaviour that shifted. That is new
  information and belongs in a comment
  ([nudge-with-new-information](../nudge-with-new-information/SKILL.md) is the same
  test, applied to a different moment).
- The reviewer asked a **question**, not for an action. Questions get answers, and a
  question about design usually needs the reasoning that the diff omits.
- The house's own guide asks contributors to confirm in writing. Read it first
  ([read-the-houses-agent-file-first](../read-the-houses-agent-file-first/SKILL.md)).
- You are correcting an earlier claim of yours. Corrections are owed regardless of
  whether anyone asked ([verify-before-a-committer-comment](../verify-before-a-committer-comment/SKILL.md)).

## The practice (checklist)

- [ ] **Separate the gate from the reply.** Run whatever you need to be confident —
      rerun the suite, revert your change and confirm the tests fail, check the smoke
      tests. Then close that terminal and ask separately: what does the reviewer not
      already have?
- [ ] **Check what the timeline already shows.** A force-push, a new commit, a CI status
      and a resolved conversation are all visible on the PR page. Anything your comment
      would repeat from there is redundant by construction.
- [ ] **Write the comment, then delete every sentence the diff or timeline proves.**
      If nothing survives, post nothing. This is the same deletion test as a nudge; here
      it usually deletes the whole message.
- [ ] **Prefer silence over "done" for a pure force-push.** The head SHA changing *is*
      the confirmation. One short line is acceptable when the act is invisible (a
      rebase onto an unrelated base, a change made in a different repo) — then say
      which, not how well.
- [ ] **Never report your own test count as reassurance.** "All 13 tests pass" tells the
      reviewer what CI already tells them, from a less trustworthy source.
- [ ] **Match the size of the ask.** One-line review comment → one-line reply, or a
      resolved conversation with no reply at all.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "I should confirm I did it, so they know it's ready." | The head SHA and the green check say it, earlier and more credibly than you can. A confirmation comment is a notification they must open to learn nothing. |
| "Showing the verification builds trust." | Trust is built by the change being correct when they look at it. Announcing your rigour asks for credit *before* the evidence, and it reads as needing reassurance rather than giving it. |
| "It's only three sentences." | Three sentences per mechanical exchange, across a review with several rounds, is a thread the next reader has to skim past to find the actual discussion. Cost lands on everyone who reads the PR later, not on you. |
| "The tests I ran aren't in CI, so it's new information." | Then say *that*, in one clause — "rebased; the conflict was in the test file and I kept both sets" — not the method and the counts. The fact is what transfers. |
| "They might not notice I rebased." | They asked for it; it is the thing they are waiting on. GitHub notifies on force-push. |
| "Being thorough is what I'm for." | It is — silently. Thoroughness that has to be described was not visible in the work, which is the actual problem to fix. |

## RECEIPT

***SOURCING-receipt*** — **a comment deleted by the person I work for, on
`opensearch-project/opensearch-benchmark` PR #1098, 2026-07-30.**

The whole of what was asked, by the reviewer who had already approved the PR:

> "@serhiy-bzhezytskyy this will need one more rebase because of #1096 :)"

I rebased (one real conflict, in `tests/aggregator_test.py`, where both changes appended
tests to the same file — textual, resolved by keeping both), reran the suite (13 passed),
and mutation-checked my own tests by reverting `aggregator.py`/`benchmark.py` while
keeping the tests, which failed `test_aggregate_leaves_a_workload_path_alone` as intended.

Then I posted all of that. Four sentences, including *"13 tests pass, including the two
null-metric tests that arrived with #1096"* and *"Checked the other direction too…"*.

**It was deleted and replaced with the fact of the rebase alone.** The verdict was
one sentence: *"I was simply asked to rebase — why did you write all that?"*

⇒ Every check I ran was worth running: without the mutation check I would not have known
the rebase preserved the tests' meaning, and the conflict resolution needed a real
decision. **None of it was worth posting.** The reviewer had approved the PR and was
waiting on one mechanical act; what they needed from me was a new head SHA, which
GitHub delivers without my help.

⇒ The distinction the receipt teaches: **the audience for verification is the person
about to push, and the audience for a comment is the person about to read.** They are
not the same person, and confusing them turns diligence into noise.

## Lifecycle

- **Signals it worked:** a mechanical request closes in one exchange or none; no reviewer
  asks why you wrote all that; the thread stays short enough that the next reader finds
  the real discussion without scrolling.
- **What to log on a misfire:** the comment you posted, what the timeline already showed
  at the time, and — the harder case — an occasion where staying silent left a reviewer
  genuinely uninformed, because that marks the boundary with
  [nudge-with-new-information](../nudge-with-new-information/SKILL.md).
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** retire for a house whose guide asks contributors to confirm each
  action in writing — some do, and the house wins
  ([read-the-houses-agent-file-first](../read-the-houses-agent-file-first/SKILL.md)).
- **Relates to:** the mirror image of
  [nudge-with-new-information](../nudge-with-new-information/SKILL.md) — that one asks
  whether a message carries a fact before you send it unprompted; this one asks the same
  of a message you were invited to send. Both apply the deletion test, and here it
  usually deletes everything. Distinct from
  [write-in-your-own-voice](../write-in-your-own-voice/SKILL.md), which governs the
  register of prose that should exist; this governs whether it should exist at all.
