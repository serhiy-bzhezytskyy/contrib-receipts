---
name: consolidate-a-scattered-thread
description: >
  When a maintainer says "unclear where this should live" or "unclear where to
  further that conversation," the high-value move is not to reply in place — it's to
  do the consolidation FOR them. Traverse the JIRA/GitHub link graph across every
  linked ticket, read ALL comments plus related PRs, commits, and mail, untangle the
  conflated concerns into distinct threads each with a home, verify each claim in
  code, and hand back a map: "here's where each sub-thread belongs." This is a
  SOURCING/communication move — it turns a maintainer's "where do I continue?" into a
  delivered map. Use when a discussion is fragmented across many tickets/PRs and a
  maintainer signals they can't see the shape. Trigger terms: unclear where this
  belongs, fragmented discussion, scattered across tickets, link graph, issuelinks,
  consolidate, untangle, which issue tracks this, where should this live.
scope: general
principle: ../../PRINCIPLES.md
---

# Consolidate a scattered thread

## Purpose

Long-running problems fragment: the truth about one bug ends up spread across a dozen
JIRA tickets, PRs, commits, and mailing-list threads, each holding a piece. When a
maintainer says *"unclear where to further that conversation,"* the graceful move is
not to add one more reply to one more ticket — it's to **do the consolidation for
them**. Traverse the whole link graph, read everything, and hand back a map that says
where each distinct sub-concern belongs. That turns "where do I continue?" into a
delivered artifact the maintainer can act on immediately.

This is a communication/navigation skill, not an execution one: its deliverable is a
map, not a diff. Its value is that a scarce maintainer no longer has to hold the whole
tangle in their head — you did, and you handed it back untangled.

## When to use

- A maintainer explicitly signals the discussion has no clear home ("unclear where
  this should live", "where do we track this?").
- A single problem is visibly spread across many linked tickets / PRs / commits / mail
  and the concerns in it are conflated.
- You've read enough of the graph to see distinct sub-threads the participants haven't
  separated.

## When NOT to use

The problem lives in a single ticket, or nobody has signalled confusion about where it belongs — then just reply in place; an unasked-for map is noise, not help.

## The practice (checklist)

- [ ] **Traverse the link graph.** Walk every linked ticket (`jira issuelinks` /
      GitHub cross-refs) — causes, is-duplicated-by, relates-to — until the graph
      closes. Draw it; the shape is the first deliverable. *Done when* a full pass
      adds no new node — not when you've read "enough".
- [ ] **Read ALL comments across all of them**, plus related PRs, commits, and dev@
      mail. The piece that resolves a conflation is usually in a ticket nobody linked
      from the one the maintainer was standing in. *Done when* every node in the graph
      you drew has been opened, including the ones that look irrelevant.
- [ ] **Untangle conflated concerns into distinct threads, each with a home.** Name
      each sub-concern separately and assign it the issue that should own it.
- [ ] **Verify each claim in code**, not from memory or from the comment history —
      the discussion may carry stale or wrong framings (including your own earlier
      ones; expect to correct some).
- [ ] **Hand back a map**, in plain voice: "here's where each sub-thread belongs."
      Offer venues, don't grab them; state the maintainer knows the layout better and
      you're happy either way.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "I'll just reply in this one ticket." | The truth is fragmented across the graph; a reply in place adds a ninth scattered piece instead of the map the maintainer actually needs. |
| "I've read the comments — I can map it from memory." | The discussion carries stale and conflated framings (including your own); verify each claim in code first or you hand back a wrong map. |
| "I'll pick the home for each sub-thread and move it." | Offer venues, don't grab them — the maintainer knows the layout better; deliver the map and let them act. |

## RECEIPT

**SOURCING-receipt** (per the README's two receipt classes — a navigation move that
demonstrably worked before any PR merged, not a merge-receipt).

**apache/solr SOLR-17764** — a Solr committer: *"unclear where to further that
conversation."* The graceful-shutdown truth was fragmented across ~8 JIRA tickets plus
PRs, commits, and the dev@ list. Rather than reply in place, the link graph was
traversed (`jira issuelinks`), every linked ticket and related PR read, and a
four-thread map handed back, each concern given its home:

- incidental test flakiness → **SOLR-18285** (make graceful shutdown opt-in);
- test-framework `ClosedChannelException` → **SOLR-18295**;
- the upstream root cause → **jetty #15368 / PR #15435**;
- the SolrJ retry-classification gap → **SOLR-18188 / #4643**.

Verifying each claim in code during the pass corrected two of the contributor's own
earlier wrong framings before they were posted.
Source detail: `agentic-oss/solr/issues/SOLR-17764/consolidation.md`.

## Lifecycle

- **Signals it worked:** the maintainer acts on the map (moves a sub-thread, closes or
  narrows a ticket, picks a venue); the "where does this live?" question stops
  recurring; participants adopt the thread separation you named.
- **What to log on a misfire:** a map that split concerns the maintainer considered
  one (over-consolidation), or one that missed a linked ticket and so mis-assigned a
  home — capture the wrong edge in the graph. Record it in
  [`LEDGER.md`](../../LEDGER.md) (the SOLR-17764 row is logged there).
- **Death criterion:** none foreseeable; fragmentation across trackers is structural
  to long-lived projects, though link-graph tooling (JIRA vs GitHub) is per-house.
- **Relates to:** the code-verification half overlaps verify-before-a-committer-comment;
  offering venues without claiming them is adjacent to offer-don't-grab. This is the
  communication counterpart to follow-the-thread — one finds the issues, this one maps
  where a tangle of them belongs.
