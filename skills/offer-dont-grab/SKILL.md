---
name: offer-dont-grab
description: >
  To work an issue that's assigned to a maintainer, is the maintainer's own design,
  or has a dormant prior attempt: check whether the assignment is actually dormant
  (last activity, has the assignee ever commented, any linked PR), build a
  TDD-verified fix, then OFFER it — credit the prior work, ask the design question,
  open the PR on the maintainer's nod. Do NOT silently open a PR that grabs owned
  work. Assigned ≠ actively-worked; the rule is offer-don't-grab, not
  avoid-don't-touch. Use when the best-fit issue is already owned or has a stalled
  attempt. Trigger terms: assigned issue, dormant, stalled PR, "I'll take this",
  credit predecessor, revive, take over.
scope: general
principle: ../../PRINCIPLES.md
---

# Offer, don't grab

## Purpose

The best-fit issue is often already owned — assigned to a maintainer, or their own
old design, or carrying a stalled prior attempt. The reflex "assigned, don't touch"
leaves real value on the floor; the opposite reflex, silently opening a PR that
grabs the work, burns trust. The right move is in between: confirm the assignment is
*dormant*, do the hard verification work yourself, then **offer** the result and
hand the maintainer the design authority. An assigned issue being taken is
informative, not discouraging — it means you're reading the valuable area correctly.
This is the **owned/dormant** case, distinct from greenfield triage where grabbing
fresh unclaimed work is right.

## When to use

- The prime-fit issue is assigned to a maintainer or is their own design.
- There's a dormant prior PR/branch/POC on the issue.
- You have (or can build) a real, tested fix and want to contribute it without
  stepping on the owner.

## When NOT to use

The issue is genuinely unclaimed greenfield work — then just grab it; the offer ritual is for owned/dormant work, not fresh unassigned tickets.

## The practice (checklist)

**1. FIND — confirm the assignment is dormant (a signal, not a stop sign)**
- [ ] Check staleness: last activity date, **has the assignee ever commented**, is
      there any linked PR? Long-idle + assignee-never-commented + no PR = dormant
      triage-assignment, legitimately offerable.

**2. VERIFY — earn the offer (do this BEFORE you speak)**
- [ ] TDD red→green: turn the reporter's repro into a failing test first, prove it
      fails, then fix. The failing test is the evidence that makes the offer credible.
- [ ] Self-red-team: run a wider regression sweep, not just the happy path; if it
      catches your own regression, that's a credibility win to volunteer, not hide.
- [ ] Re-verify any parked/old fix on clean current HEAD before offering it.

**3. OFFER — the comment that lands**
- [ ] Lead with root cause + **credit the assignee's / predecessor's prior work**.
- [ ] Frame it as a bug (quote the violated contract) where you honestly can.
- [ ] Signal TDD ("test first (red) → fix"); volunteer any regression you caught.
- [ ] **Ask the design question and hand them authority** ("is X the right place?").
- [ ] Open the PR **on the nod**, and credit the predecessor in the PR description.

**Guardrail:** don't stack multiple open offers in the same subsystem with the same
reviewer before the first lands — review bandwidth is the scarce resource.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "This issue looks abandoned — I'll just take it." | Ownership ≠ inactivity; check the dormancy signals, then *offer* and credit the predecessor rather than silently grabbing owned work. |
| "It's assigned, so I shouldn't touch it at all." | The rule is offer-don't-grab, not avoid-don't-touch; a dormant triage-assignment leaves real value on the floor if you back off entirely. |
| "I have the fix — I'll open the PR to prove it." | Do the verification, then offer and ask the design question; open the PR *on the nod*, so the owner keeps design authority. |

## RECEIPT

**apache/solr JIRA SOLR-3284** (`corpus-solr-jira/jira-SOLR-3284.json`) — a 14-year
dormant issue (opened 2012), reopened from a production angle and offered, not
grabbed. A Solr committer, same day, verbatim:

> "The proposal makes sense to me Serhiy; PR welcome :)"

and on wrap-up:

> "Feel free to link as you see appropriate. I leave it to you to pursue further
> work here as it interests you. Thanks for getting this one done :)"

→ PR #4632 opened on the nod; merged.

**Credit-the-predecessor, live (JIRA SOLR-17707):** "Picked this up — PR #4639
(supersedes the POC in #3273; [~predecessor], feel free to close it — credited in the
description)."

**Cross-project (journal):** jetty #13569, assigned to the project lead but dormant
~10 months (assignee never commented, no linked PR) — offered with a TDD fix + a
volunteered self-caught regression, not grabbed.

## Lifecycle

- **Signals it worked:** a "PR welcome" / design-nod before you open the PR; the
  predecessor engages positively or bows out gracefully; you get the design
  authority handed to you rather than a scope argument.
- **What to log on a misfire:** an assignee who was actually active (misread the
  dormancy signal), or an offer that read as a grab — capture what made it land wrong.
  Record it in [`LEDGER.md`](../../LEDGER.md) (the jetty #15472 offer is logged there).
- **Death criterion:** none foreseeable; assignment etiquette is stable across
  repos, though the *dormancy thresholds* are per-project.
- **Relates to:** the owned/dormant case (assigned/claimed/stalled work) rather than
  greenfield triage. Adjacent to discuss-in-issue-first (both are "align before you
  drop a PR").
