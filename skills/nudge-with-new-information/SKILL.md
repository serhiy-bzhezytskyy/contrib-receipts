---
name: nudge-with-new-information
description: >
  Use when a PR or issue has gone quiet and you are deciding whether to post a
  reminder, ping, or "any update?" — and what to put in it. Many houses explicitly
  invite reminders, so the question is not whether nudging is rude but whether this
  nudge will land: is it genuinely their turn, is the silence actually past the
  house's own measured response time, and does the message carry a fact the reader
  does not already have. A bare reminder can still work where the house invites one,
  but a reminder carrying a fact costs you nothing extra and cannot be resented, sent
  to the wrong thread, or burn the single follow-up you have. Never batch one sentence
  across several threads. Trigger terms:
  nudge, ping, follow up, any update, bump, reminder, chase a review, no response,
  gone quiet, stalled PR, how long should I wait, is it too early to ask.
scope: general
principle: ../../PRINCIPLES.md
---

# Nudge on their turn, with new information

## Purpose

A stalled PR creates an itch, and the cheapest response — "any update?" — is the one
whose cost you cannot see. Reminders are often welcome (many projects ask for them in
writing), and a bare one does sometimes draw a real reply. What it cannot do is fail
*safely*: it converts your one credible follow-up into a notification, it reads as a
sweep when sent to several threads at once, and it leaves the thread's next message
looking like pressure.

The discipline is to treat a nudge as a contribution with a delivery date: it must be
their turn, the silence must be genuinely abnormal *for this house*, and it must tell
the reader something. When those hold, a nudge is welcome. When they don't, waiting is
strictly better — and the gap is often closable by *generating* the missing
information rather than asking for attention.

## When to use

- A PR/issue of yours has gone quiet and you're weighing a reminder.
- You have several stalled threads and are tempted to work through them in one pass.
- CI is red, or something changed, and you're deciding whether that justifies posting.

## When NOT to use

- You haven't established whose turn it is yet — do that first
  ([track-whose-court](../track-whose-court/SKILL.md)); a reminder on your own turn is
  noise.
- A maintainer has stated a timeline ("let's give it a week", "I'll merge if X").
  Inside their own window, a nudge reads as distrust of a commitment they volunteered.
- Your last message on the thread is still unanswered *and* you already followed up
  once. Two consecutive unanswered messages from you is the ceiling.
- A substantive question of theirs is open and unanswered by you. Answer it instead.

## The practice (checklist)

- [ ] **Read the house's own contributing guide for a reminder policy first.** Many
      state one explicitly, including the unit of time. If it says "after a few days,
      friendly reminders", that is permission *and* a constraint — don't nudge at hour
      six, and don't be procedural about it.
- [ ] **Test 1 — is it their turn?** Check every channel a maintainer can reach you
      on, not just the PR. A reply can land on a mailing list or a separate tracker and
      be invisible to a GitHub-only check.
- [ ] **Test 2 — is the silence actually abnormal here?** Measure the house instead of
      reusing a generic "one week":
      ```bash
      gh pr list --repo <owner>/<repo> --state merged --limit 200 \
        --json number,createdAt,author,comments,reviews
      # → for each: time from createdAt to the first non-bot event by someone != author
      # → take the median and the p90; p90 is your "overdue" threshold
      ```
      Also count how many merged with **zero** human comments — if that fraction is
      large, silence is not neglect in this house and a nudge asks someone to account
      for ordinary behaviour.
- [ ] **Test 3 — does it carry a fact they don't have?** Write the message, then delete
      every sentence that restates what the PR page already shows. If nothing survives,
      it is a notification. *Done when* you can name the specific thing the reader
      learns.
- [ ] **Try to manufacture the fact before settling for asking.** Red CI you can
      triage, a failing test you can reproduce or fail to reproduce on the base branch,
      a rebase you can offer against named commits, a stale build you can spot — each
      turns "please look" into "here's what I found", which is a contribution rather
      than a request.
- [ ] **One thread, one message, its own words.** If a single sentence fits several
      PRs, it is informationless by construction, and a burst of identical comments is
      visible in the timeline as a sweep.
- [ ] **Prefer reviving the specific open question.** If your own last message ended in
      an offer or question they never answered, re-ask *that* — it is concrete and it
      shows you tracked the thread.
- [ ] **Count your consecutive unanswered messages.** At two, stop and change channel
      or wait, whatever the content.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "Nudging is rude, I'll just wait indefinitely." | Check the guide before assuming. Apache Solr's says outright: *"If no one responds to your patch after a few days, please make friendly reminders."* Silence-forever is not the respectful default; it is a different failure. |
| "It's been two days, that's ages." | Measure it. On 200 recently-merged Solr PRs the median time to a first human response was **0.33 d** but p90 was **4.8 d** — so day two is well inside normal. Nudging inside the distribution asks someone to explain statistically ordinary behaviour. |
| "No response means nobody's looking." | **63 of those 200 PRs merged with zero human comments.** Silence is a poor proxy for neglect; some houses merge quietly. |
| "'Any objections?' is polite and low-cost." | It is low-cost to *write* and it adds nothing to *read* — the PR already asks that. Its real cost is spending your follow-up: the next message on the thread becomes your second unanswered one, which is where pressure starts. |
| "I have six stalled PRs, I'll do one pass." | The batch is visible. Six identical sentences in five minutes reads as a sweep, not as attention — and two landing on the same maintainer inside a minute reads worse. |
| "A reminder is a reminder, content doesn't matter." | Measured, both can work — 3 of 6 generic reminders drew substantive replies within 4 hours (see the OUTCOME note in the receipt). What content buys is cost control, not effect: a reminder carrying a fact can't be resented, can't be sent to the wrong thread, and doesn't burn the single follow-up you have. Write the fact in because it is free to you and cheap for them, not because a bare reminder never lands. |
| "They said they'd merge it next week, but I'll check in anyway." | A maintainer who volunteers a timeline has already given you more than a nudge would buy. Interrupting inside it converts goodwill into a trust question. |

## RECEIPT

***SOURCING-receipt*** — **two batches of nudges the same morning, measured against the
house.** Verified via `gh` 2026-07-27.

**Batch A — 6 identical reminders, 08:02–08:06 UTC** across `apache/solr` #4638/#4640/#4643,
`apache/lucene` #16411, `mikemccand/luceneutil` #595/#604, each reading *"Are there any
objections to its merger? I am ready to resolve them, just let me know."* All three tests
were only partly met:

- **Test 1 (their turn):** held — a channel-complete sweep the day before confirmed the
  last human move was mine or nobody's on all of them.
- **Test 2 (overdue):** mostly not. Measured on 200 recently-merged `apache/solr` PRs —
  time from creation to first non-bot event by someone other than the author:
  **median 0.33 d, p75 1.05 d, p90 4.80 d, and 63/200 merged with zero human comments.**
  Several nudged PRs were inside p75.
- **Test 3 (new information):** failed by construction — one sentence fitting six
  threads. Two of them (luceneutil #595 and #604) reached the same maintainer inside a
  minute. On #595 the nudge also displaced something better: the maintainer had reviewed
  on 07-20 and the only open item was **my own unanswered offer** (a `lastMod` variant),
  so a specific question existed and a generic one was sent instead.
- The three PRs where a nudge was **most** defensible — `apache/solr` #4644/#4648/#4651,
  with **zero** comments, one of them green-lit on the dev list — got none.

> ⚠️ **OUTCOME, measured 4 hours later — and it corrects this skill's own prediction.**
> **3 of the 6 Batch-A nudges drew substantive maintainer engagement between 12:03 and
> 12:18 UTC:**
> - `apache/lucene#16411` — **its first review ever**, from a Lucene committer, asking for
>   benchmarks on the hot path and whether the optimization generalizes to two adjacent
>   cases;
> - `luceneutil#604` — a conditional +1 *and* a direct question (*"+1 to rename the other
>   two cases as long as they are also batch-optimized?"*);
> - `luceneutil#595` — the maintainer took up **the very offer the generic nudge had
>   displaced** (*"+1 for `lastMod` `searchAfter` tasks"*), with a design and a pointer to
>   his own existing Python tool.
>
> So "adds no information" was accurate about the **text** and wrong as a prediction of the
> **effect**. Honest reading: on a thread that is genuinely the maintainer's turn, a bare
> reminder can work — the house's own guide invites exactly that, and this house honoured
> it. What the three tests actually buy is not "will it work" but **cost control**: a
> reminder that carries a fact cannot be *resented*, cannot be sent to the wrong thread,
> and does not burn the one follow-up you have. Keep the tests as a quality bar, not as a
> predictor of silence. And note the *asymmetry that survived*: Batch A produced replies
> that each **hand work back to you** (run benchmarks, verify batch-optimization, find a
> tool), while Batch B's evidence comments asked a maintainer for one cheap action (re-run
> CI). Both are progress; only one of them was free.

**Batch B — 2 evidence-carrying comments, 10:43 and 10:46 UTC**, on `jetty/jetty.project`
#15473 and #15472, both of which had sat at `mergeStateStatus=BLOCKED` on red CI:

- [#15473](https://github.com/jetty/jetty.project/pull/15473#issuecomment-5090338978) —
  named the failing test and reported that it **reproduces on pristine `jetty-12.1.x`
  without the change** (1 failure in 6 runs under CPU contention on JDK 17, vs 0 in 8 on
  the branch), then asked for a re-run and offered a rebase against two named commits.
- [#15472](https://github.com/jetty/jetty.project/pull/15472#issuecomment-5090363095) —
  where the failure **did not** reproduce (18 runs), said so plainly and carried different
  facts instead: the racy assertion (a 1500 ms sleep against a 1000 ms idle timeout with
  no `await`), that test class's **10 prior flaky-test issues**, and the observation that
  the failing JDK 17 result came from **build 1** while the passing JDK 21/26 results came
  from **build 2 of the same commit** — i.e. a stale badge a re-run may simply clear.

The asymmetry is the receipt: the same underlying situation ("my PR is stuck") produced a
notification in one batch and a triage report in the other, and the difference was a few
hours spent generating evidence. Note also the two B comments deliberately differ in
strength — one says *reproduced*, the other says *doesn't reproduce for me* — because only
one earned the stronger verb.

**Where holding back was correct**, same session: `jetty#15435` (a maintainer's
architectural reservation was live and my answer to it was the thread's last word — a CI
note would have buried it), `apache/solr-orbit` #58–#60 (a committer had publicly
committed to merging within a stated window), and `opensearch-project/OpenSearch#22534`
(my own re-run request was already unanswered — a second would have been the third
consecutive message from me).

## Lifecycle

- **Signals it worked:** the nudge draws a substantive reply or an action (re-run, merge,
  review) rather than silence; you are never the author of two consecutive unanswered
  messages on a thread.
- **What to log on a misfire:** which of the three tests you skipped, whether the thread
  was actually past the house's p90, and what the message told the reader that the PR page
  didn't. Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** none foreseeable; the tests are house-independent even though the
  threshold is not. Re-measure the p90 when a project's review capacity visibly changes.
- **Relates to:** [track-whose-court](../track-whose-court/SKILL.md) answers test 1 and is
  a prerequisite; [verify-before-a-committer-comment](../verify-before-a-committer-comment/SKILL.md)
  governs the fact you carry (it must be checked, and stated at the strength you earned);
  [match-the-house-shape](../match-the-house-shape/SKILL.md) is the same
  measure-the-house-don't-guess method applied to PR size instead of timing.
