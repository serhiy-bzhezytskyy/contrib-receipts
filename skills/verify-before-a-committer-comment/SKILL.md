---
name: verify-before-a-committer-comment
description: >
  Before asserting a technical claim in a public JIRA/PR/committer-facing comment —
  "PR X fixes Y", "the bug is in layer Z", "test T still fails", "commit C did D" —
  verify it by reading the actual code path and running the test on clean state. Do
  NOT infer from PR titles, commit messages, or the issue link-graph. State your
  confidence (verified / inferred / open). A confident-wrong claim to a committer,
  especially about your OWN PR's scope, costs trust fast. Use before any
  committer-facing technical assertion. Trigger terms: post a comment, "this fixes",
  root cause, which layer, still fails, commit did X, assumed or checked.
scope: general
principle: ../../PRINCIPLES.md
---

# Verify before a committer-facing comment

## Purpose

AI makes a plausible technical claim nearly free to write, which shifts the cost of
disproving it onto the maintainer. A confident-but-wrong assertion in a public
thread — especially about your own PR's scope — is one of the fastest ways to burn
reviewer trust. The fix is a hard gate: before any committer-facing technical claim,
trace the real code path and re-run the relevant test on the right clean state,
rather than inferring from titles, commit messages, or the JIRA link-graph. Then
state confidence explicitly. Verifying often *flips* the answer — turning a wrong,
self-promoting claim into an accurate one that scopes your work honestly, which is a
far stronger position than being corrected in public.

## When to use

- Before posting any "PR/commit X does Y", "the bug is in layer Z", "test T
  fails/passes", or "A is the root cause of B" claim to a maintainer.
- Especially before claiming what your OWN PR fixes.

## When NOT to use

You're deciding whether a thread is even waiting on you (whose-turn), not asserting a technical fact — that's track-whose-court; this gate is for claims you're about to state as true.

## The practice (checklist)

- [ ] **"PR/commit X does Y"** → `git show <sha>` the actual DIFF; read what it
      touches, not the message. The diff often contradicts the message.
- [ ] **"The bug/gap is in layer Z"** → trace the real call path in code (who
      delegates to whom). Two similarly-named methods are usually different layers —
      confirm which one the failing scenario actually hits.
- [ ] **"Test T still fails/passes"** → re-run on the RIGHT clean state (a worktree
      off `origin/main`, correct JDK/toolchain); don't cite a remembered seed/rate.
- [ ] **"A is the root cause of B"** (causation) → match the stack trace, or HEDGE
      explicitly ("still fails with CCE" ≠ "is caused by X") if unproven.
- [ ] **Scope your own PR honestly** — "related symptom, different layer" beats
      overclaiming; committers see through overclaiming instantly.
- [ ] **Check the PR body against its own diff, line by line, before posting.** Every
      count ("N new tests"), every name, every "verified red without the fix" claim —
      confirm against `git diff <base>...HEAD -- <path>`. A body written from what you
      *intended* to do drifts from what the commit contains, and the diff is sitting
      right next to the prose for the reviewer to compare. Where the diff is thinner
      than the claim, **state the gap** rather than trimming the sentence and hoping.
- [ ] State confidence: verified / inferred / open. Get ahead of "assumed or checked?".
- [ ] **Adversarially re-read your own diff/comment before it ships** — with fresh
      context, as if it were a stranger's PR you were sent to poke holes in, not your
      own work you already believe. Surface at least one concrete problem, or state
      plainly why none survives. A zero-findings glance is a rubber stamp, not a
      review; the point is to catch it before a maintainer does.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "Tests pass locally, I can say so." | Local ≠ CI; a "tests pass" comment landed next to a red CI badge when CI later went red — verify on the right clean state before you speak. |
| "The PR title / commit message says what it does." | The diff often contradicts the message; `git show` the actual change rather than inferring from titles or the link-graph. |
| "It's obviously the root cause of this failure." | Match the stack trace or hedge explicitly — two similarly-named methods are usually different layers, and a confident-wrong claim about your own PR burns trust fast. |
| "I skimmed my own diff, it looks fine." | Skimming your own work rubber-stamps it — you already believe it. Re-read cold, as a hostile reviewer, and make yourself name one problem; the flake-vs-deterministic flip on #4637 only surfaced because the first "it's a flake" read was challenged, not trusted. |
| "I wrote the patch, so I know what the PR body should say." | You know what you *meant* to write. A drafted body for solr-orbit #58 claimed "five new tests" naming a `calculate_rsd` test; the diff had **two** and no such test. Caught by diffing before posting. The reviewer reads the prose beside the diff — a miscount there costs more trust than the missing test would have. |

## RECEIPT

**apache/solr PR #4637** (`corpus-solr-prs/pr-solr-4637.json`) — Serhiy's public
self-correction chain, verbatim across three comments:

> "checked the Crave CI red — it's IndexFetcherPacketProtocolTest … Unrelated … so
> looks like a flake"

→

> "correction on the CI red — it's not a flake. IndexFetcherPacketProtocolTest fails
> deterministically on clean main … with the CI seed 6FA33BD8BF6D0D4C, and passes
> with the default random seed"

→

> "it turned out another committer had already fixed it in #4624 … My #4642 was a
> duplicate and I've closed it."

Verification flipping the answer twice, in public — the behavior that builds trust.

**Near-miss (journal, SOLR-17764):** a drafted claim "my PR #4643 is the SolrJ retry
fix for these flaky tests" was wrong on the layer — #4643 patches
`CloudSolrClient.wasCommError`, not the `LBSolrClient` update-retry path the failing
tests hit. Posting as drafted would have had a committer correcting Serhiy on his own
PR; tracing the code path first turned it into an accurate, honestly-scoped claim.

**Near-miss (apache/solr-orbit #58, 2026-07-25):** the drafted PR body claimed *"Five
new tests… covering: all-null metrics, mixed…, null in the percentile branch,
`calculate_rsd` with nulls, and unchanged behaviour."* Diffing the branch against
`origin/main` before posting showed **two** tests and no `calculate_rsd` test at all.
The posted body names the two that exist, states they were verified red by restoring
main's `aggregator.py`, and discloses the gap in the open: *"The `calculate_rsd` site
has no dedicated unit test here — it is covered by the end-to-end runs above… I can
add a direct one if you'd prefer it in the suite."* Overclaiming your own test
coverage is uniquely cheap for a reviewer to catch: the diff is on the same page.

## Lifecycle

- **Signals it worked:** no maintainer correction of a factual claim you posted; your
  hedges ("inferred", "still open") match what later turns out true.
- **What to log on a misfire:** the claim, the source you inferred it from (title /
  message / link-graph), and what checking actually showed.
  Record it in [`LEDGER.md`](../../LEDGER.md) (the jetty #15435 CI-badge miss is logged there).
- **Death criterion:** none foreseeable; this is a stable trust discipline.
- **Relates to:** the general committer-facing-verification rule (verify a claim
  before it reaches a maintainer — e.g. check main before claiming a CI failure is
  pre-existing). Sibling to comments-about-code-not-change (both: don't put
  unverified narrative before a maintainer).
