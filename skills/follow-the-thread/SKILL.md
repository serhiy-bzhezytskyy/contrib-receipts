---
name: follow-the-thread
description: >
  When a red CI test, a failing check, or a single bug crosses your path, follow it
  instead of dismissing it — one thread reliably sources many issues worth working.
  A failing test maps to an existing issue whose root cause is often an existing
  UPSTREAM bug; fixing that means reading the surrounding subsystem, where adjacent
  open issues surface; searching near it seeds the next. A convenient "it also fixes
  X" is a hypothesis, not a finding — verify the mechanism. A SOURCING method: it
  finds where the help actually is, before any PR. Use when you hit a red CI, a
  flake, or one bug — and equally when a MAINTAINER hands you a lead in passing
  ("not fully related to this issue, but…", "years ago I…", "that's always been
  fragile"), the same method from the other end.
  Trigger terms: red CI, flaky test, follow the thread, upstream root cause,
  adjacent issue, sibling bug, "not my bug", where's the real work, reviewer
  mentioned something unrelated, offhand remark in a review, act on that comment.
scope: general
principle: ../../PRINCIPLES.md
---

# Follow the thread

## Purpose

The most productive way to find work worth doing is not triage or a good-first-issue
scan — it's to **follow a thread you already touched**. One red CI test, followed
honestly instead of waved off as "not my bug," root-causes to an upstream issue;
fixing that means reading the subsystem around it, where adjacent open issues are
already filed; searching near that one surfaces a third. The signal is in the code
you're already standing in. Etiquette skills stop you from being noise; this one
finds where the signal is.

The discipline is one question at every hop: **"why does THIS happen?"** instead of
"not mine." Each honest answer either ends the thread or hands you the next issue.

## When to use

- **A maintainer hands you the thread** — the highest-value entry point and the easiest to
  waste. Phrases to treat as a lead, not as small talk: *"not fully related to this issue,
  but…"*, *"on a branch years ago I…"*, *"we've always wanted to…"*, *"that's always been
  fragile"*. A committer volunteering unpaid history is telling you where a real defect
  lives, from memory nobody else has. See the second receipt.
- A red CI or a flake appears on your own PR, or on a repo you're already in.
- You've root-caused one bug and want to know whether it's isolated or a nest.
- You're standing in an unfamiliar subsystem and want to read outward, not just fix
  the one line you came for.

## When NOT to use

You already have a scoped, agreed task to land — don't let thread-following become scope creep that stalls the PR in front of you; source the next thread after this one ships.

## The practice (checklist)

- [ ] **Red CI on your own PR → follow it, don't dismiss it.** A flake on your PR is
      a seam. Triage it honestly first: is it actually flaky, or deterministic?
- [ ] **Map the failing test to its existing issue, then to the UPSTREAM cause.** A
      downstream symptom (a Solr test) is often an upstream bug (a Jetty defect).
      Follow downstream → upstream; the real root cause frequently lives one repo up.
- [ ] **While fixing the upstream bug, READ the surrounding subsystem.** Adjacent
      open issues surface there — filed, open, and in the code you're already reading.
      *Done when* you can name every open issue touching the files your fix touches,
      or say plainly that there are none.
- [ ] **Search open issues NEAR the one you're fixing** — same area, same reporter.
      One fix's investigation seeds the next; one query away is often a sibling bug.
      *Done when* both queries have actually been run (same component/label, and the
      reporter's other open issues) and each hit is either dismissed with a reason or
      recorded as a candidate.
- [ ] **Treat "it also fixes X" as a hypothesis, not a finding.** A convenient
      incidental green must be verified at the mechanism level — an adversarial test,
      not just a passing repro — or it's a false claim waiting to be caught.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "The red CI is just flaky — dismiss it." | The flake may map to a real upstream bug; following it downstream→upstream is exactly how one thread sourced three real issues. |
| "It also happens to fix X — I'll say so." | A convenient incidental green is a hypothesis, not a finding; unverified at the mechanism level it's a false claim waiting to be caught. |
| "I fixed the one bug, that thread's done." | The fix is a seam: read the surrounding subsystem and search near it (same area/reporter) — the adjacent open issue is one query away. |
| "He said it was *not related* to my issue, so it's just chat." | That phrase is how a committer offers an adjacent defect without asking you to widen the PR. On apache/solr#4638 a committer wrote *"Not fully related to this issue, but on a custom branch many years ago, I dealt with that fragile expectation of a SolrServerException by just unrolling the exception chain to get the root cause"* — which lands on the exact line my diff added. Filed away, that is a scoped follow-up with a committer's prior art attached; read as chat, it evaporates. |

## RECEIPT

**SOURCING-receipt** (per the README's two receipt classes — the *sourcing*
demonstrably worked even though the fix PRs are still in review). Verified via `gh`
2026-07-24, all authored by the contributor, all OPEN / in-review:

A single red "Run Solr Tests" flake on the contributor's own PR (a SOLR-3284
follow-up) was triaged "not a flake" → `TestGracefulJettyShutdown` fails with
`ClosedChannelException` → root-caused to an existing upstream issue **jetty #15368**
(an HTTP/2 client discarding a fully-received response on graceful-shutdown close) →
fix **PR #15435**. Reading the #15368 subsystem (GOAWAY / graceful beans) surfaced a
neighboring open issue **jetty #13569** (connector shutdown never sent a GOAWAY) →
fix **PR #15472**. Searching open issues near #13569 surfaced a third, same area,
same reporter — **jetty #13602** (shutdown-then-stop future hang) → fix **PR #15473**;
its "incidentally fixed by #13569" appearance was disproven by an adversarial test and
needed its own root-cause fix.

**One Solr CI flake sourced 3 Jetty issues + 3 PRs.**
Source detail: `agentic-oss/SCOREBOARD.md` + `agentic-oss/jetty/discovery-trail.md`.

**Second receipt — the maintainer-handed thread (apache/solr#4638, 2026-07-27).** The receipt above is
me following a thread outward. This one is a committer putting one in my hands, in a form easy to mistake
for small talk.

A Solr committer with no prior interaction with me, on a PR that had sat with zero reviews:

> "Seems fine to me.
>
> **Not fully related to this issue, but** on a custom branch many years ago, I dealt with that fragile
> expectation of a `SolrServerException` by just **unrolling the exception chain to get the root cause**
> rather than hoping the exception is a `SolrServerException`."

Read carelessly that is a soft +1 with a reminiscence attached. Read properly it contains four things:

1. **A defect claim** — the codebase's expectation that a failure arrives as `SolrServerException` is
   *fragile*.
2. **A fix shape** — unroll the cause chain to the root rather than type-testing the top.
3. **Prior art** — he has already done it, on a private branch, and it worked.
4. **An explicit scope fence** — *"not fully related to this issue"* means *don't put it in this PR*.

And it lands on the diff under review: that PR's change is precisely
`catch (Throwable e) { handleError(new SolrServerException(...e.getMessage(), e), ...) }` — i.e. it *adds* a
wrap that the reviewer is calling a fragile pattern. So the hint is not adjacent trivia; it is a reviewer
declining to block a narrow fix while telling you where the real one is.

**What the skill does with it:** file it as a scoped follow-up carrying his quote as the prior art, reply on
the PR engaging the hint *without* widening the diff, and leave the PR narrow. What loses it: thanking him
and moving on, or bolting the refactor onto #4638 and turning a 7-line fix into an exception-handling
redesign.

**The general form:** committers hedge their best leads. *"Not fully related, but…"*, *"years ago I…"*,
*"that's always been fragile"* are how someone with scarce time hands over knowledge they are not going to
act on themselves. Those clauses mark the lead, not diminish it.

## Lifecycle

- **Signals it worked:** one thread yields more than one real, filed issue; a
  downstream symptom resolves to a nameable upstream defect; adjacent open issues you
  didn't know existed surface from the subsystem you're already reading.
- **What to log on a misfire:** a thread followed into a dead end (the symptom really
  was local/environmental), or an "it also fixes X" that shipped as a claim and got
  disproven — capture what made the hypothesis look like a finding. Record it in
  [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** none foreseeable; downstream→upstream causation and adjacent-
  issue clustering are structural to layered software, not repo-specific.
- **Relates to:** the "verify the mechanism, don't trust an incidental green" half is
  its own discipline; the OFFER made on each sibling issue is offer-don't-grab. This
  skill precedes both — it's how you find the issue before you shape or offer a fix.
