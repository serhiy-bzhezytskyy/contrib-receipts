---
name: follow-the-thread
description: >
  When a red CI test, a failing check, or a single bug crosses your path, follow it
  instead of dismissing it — one thread reliably sources many issues worth working.
  A failing test maps to an existing issue whose root cause is often an existing
  UPSTREAM bug (downstream symptom → upstream cause); fixing that bug means reading
  the surrounding subsystem, where adjacent open issues surface; searching near the
  one you're fixing (same area / same reporter) seeds the next. A convenient "it also
  fixes X" is a hypothesis, not a finding — verify the mechanism. This is a SOURCING
  method: it finds where the help actually is, before any PR. Use when you hit a red
  CI on your own PR, a flake, or one bug and want to find the real work around it.
  Trigger terms: red CI, flaky test, follow the thread, downstream symptom, upstream
  root cause, adjacent issue, sibling bug, "not my bug", where's the real work.
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
