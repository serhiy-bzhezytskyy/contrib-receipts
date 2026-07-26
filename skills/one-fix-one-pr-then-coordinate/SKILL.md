---
name: one-fix-one-pr-then-coordinate
description: >
  Use when one investigation produced fixes for several related issues and you are
  deciding how to package them. Split by ISSUE — one PR per issue, each proven to
  stand alone on a clean base — rather than shipping the branch you happened to
  develop on. Then coordinate the cluster instead of flinging PRs: answer any open
  reviewer concern on the live PR FIRST, open the spin-offs, credit each reporter's
  own dig, and post ONE hub comment on the neutral root ISSUE linking the whole web.
  Never bundle independent fixes because they share a branch, and never bump a
  contested PR with cross-links. Trigger terms: several fixes one branch, split the
  PR, one PR per issue, bundle, cluster of issues, related PRs, spin-off, hub
  comment, cross-link, how do I package this, stacked fixes.
scope: general
principle: ../../PRINCIPLES.md
---

# One fix, one PR — then coordinate the cluster

## Purpose

A real investigation rarely produces exactly one fix. You go in after one bug, read the
subsystem, and come out with three — developed together, on one branch, touching the same
files. The path of least resistance is to ship that branch: "here's my graceful-shutdown
work." That forces a reviewer to evaluate unrelated changes as a unit, couples their merge
and revert, and destroys the one thing a PR must answer — *what does this change do?*

So the packaging is a separate act from the fixing: **split by issue, prove each stands
alone, then coordinate.** Coordination is the half people skip. Three PRs appearing at
once from a stranger reads as a dump; the same three, with the live PR answered first and
one hub comment mapping the web, reads as someone who did a piece of work and made it
navigable. The hub comment is the highest-value artifact in the whole cluster — it is the
only place a maintainer can see the shape without reconstructing it.

## When to use

- One thread of work yielded fixes for two or more filed issues.
- You developed several fixes on one branch and now have to decide what to open.
- A cluster is already open and nothing ties it together for a maintainer.

## When NOT to use

The fixes are genuinely interdependent — B doesn't work without A — then one PR is
correct, and say so in the body. Also skip when it's one fix for one issue: there is no
cluster to coordinate, and a hub comment for a single PR is noise.

## The practice (checklist)

**1. SPLIT — one issue per PR, independence proven not assumed**
- [ ] **Prove each fix stands alone** before splitting: on a clean base, does this fix
      resolve its issue *without* the others? *Done when* each fix has been built and
      its issue's tests run on a base that contains none of the sibling fixes.
- [ ] **Don't cherry-pick commits when the fixes share files** — cross-contamination is
      near-certain. Instead, per issue: branch off base, `git checkout <final-commit> --
      <files>` to take the fully-fixed files, then strip the other issues' hunks **by
      matching text, not line numbers**.
- [ ] **Clean up what the strip orphaned** — now-unused imports, dead locals.
- [ ] *Done when* each branch is one commit off base, its own tests are green, and the
      other issues' code *and* tests are verifiably absent. Check, don't assume: the
      strip is exactly where a stray hunk survives.

**2. COORDINATE — the order matters more than the speed**
- [ ] **Answer the live PR's open concerns FIRST.** The already-reviewed PR is the
      cluster's main door and where maintainers already look. Reply, thank, resolve —
      before anything new appears.
- [ ] **Open the spin-off PRs**, each naming its own issue.
- [ ] **Comment on each spin-off's ISSUE**, and **credit the reporter's own dig** —
      if they pinpointed the line, say so before presenting your fix. Offer-don't-grab
      tone extends to acknowledging prior work, not just to avoiding surprise PRs.
- [ ] **Post ONE hub comment** linking the whole web — every issue and PR, one line
      each on how they relate.
- [ ] **Put the hub on the neutral root ISSUE, not on a contested PR.** These are two
      different rules and conflating them costs you the hub entirely: "don't bump a
      contested PR" bans the cross-link *on that PR*; it does not ban a hub in the
      cluster. The root issue is where cluster-watchers look and pings nobody.
- [ ] **If a spin-off's issue is assigned, this is
      [offer-dont-grab](../offer-dont-grab/SKILL.md)** — wait for the nod or frame the
      PR explicitly as the offered fix.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "They're all the same subsystem, so one PR tells the story." | Same subsystem ≠ same bug. #13569 and #13602 fix different methods (`shutdown()`'s GOAWAY loop vs `doStop()`/`isShutdownDone()`'s future completion); bundling them makes a reviewer approve two unrelated changes at once and couples their revert. |
| "I'll cherry-pick the commits apart." | The fixes were developed mixed across commits touching the same files — cherry-picking carries the other issue's hunks with it. Take the finished files and strip by matching text, then verify the sibling's code AND tests are gone. |
| "I'll just open the three PRs; the titles explain themselves." | Three PRs at once from an outside contributor reads as a dump. The hub comment mapping issues→PRs is what makes it navigable, and it costs one comment. |
| "A senior reviewer has an open concern, so I'll stay quiet everywhere." | That bans the cross-link on *that PR*, not the hub in the cluster. Posting the hub on the neutral root issue links everything without bumping the contested thread — I nearly skipped the hub entirely by conflating the two. |
| "I'll post the cross-links on the contested PR — it's the busiest thread." | It reads as bumping a PR whose reviewer is mid-objection. Fold links into the concern-reply, or wait for it to resolve. |
| "The fix is mine, so the PR is mine to present." | The reporter often did the hard localization. Credit it first — #13602's reporter had pinpointed the `_shutdown`-null line. |

## RECEIPT

***SOURCING-receipt*** — **two independent applications, six PRs, one issue and one
commit each.** Verified via `gh` 2026-07-26.

**jetty (2026-07-23)** — one graceful-shutdown dig produced three fixes. #13569 and
#13602 were developed on **one branch, mixed across 5 commits touching the same two
files**, and were split per-issue rather than shipped as "my graceful-shutdown work":

| issue | PR | commits |
|---|---|---|
| [#15368](https://github.com/jetty/jetty.project/issues/15368) client abort | [#15435](https://github.com/jetty/jetty.project/pull/15435) *(the live PR)* | 3 |
| [#13569](https://github.com/jetty/jetty.project/issues/13569) no GOAWAY on shutdown | [#15472](https://github.com/jetty/jetty.project/pull/15472) | **1** |
| [#13602](https://github.com/jetty/jetty.project/issues/13602) orphaned shutdown future | [#15473](https://github.com/jetty/jetty.project/pull/15473) | **1** |

The hub landed on the root issue #15368, verbatim:

> "While digging this one I found two related graceful-shutdown issues on the server side,
> now with fixes up: #13569 — `connector.shutdown()` doesn't send a GOAWAY, so HTTP/2
> keeps accepting new streams (PR #15472) · #13602 — `connector.shutdown()` future never
> completes if `stop()` follows…"

Sequencing was load-bearing: #13569 is assigned to the same reviewer who had an open
concern on #15435, so the concern was answered there first, then the spin-offs opened,
then the hub posted on the neutral issue — with the #15435-side cross-link held.

**apache/solr-orbit + OpenSearch Benchmark (2026-07-25)** — the same packaging applied to
a different cluster: 3 `aggregate` defects → [#58](https://github.com/apache/solr-orbit/pull/58)
/ [#59](https://github.com/apache/solr-orbit/pull/59) / [#60](https://github.com/apache/solr-orbit/pull/60)
and [#1096](https://github.com/opensearch-project/opensearch-benchmark/pull/1096) /
[#1097](https://github.com/opensearch-project/opensearch-benchmark/pull/1097) /
[#1098](https://github.com/opensearch-project/opensearch-benchmark/pull/1098) — **six PRs,
one commit each**, one issue each, every artifact cross-referencing its counterpart. The
numbering was kept parallel (#55↔#1093, #56↔#1094, #57↔#1095) so the cross-references
read at a glance.

## Lifecycle

- **Signals it worked:** no reviewer asks "why are these together?" or "how do these
  relate?"; the PRs merge or revert independently; a maintainer uses your hub comment's
  framing when discussing the cluster.
- **What to log on a misfire:** a split that turned out not to be independent (a PR that
  failed without its sibling), a hub comment that read as bumping a contested thread, or
  a bundle a reviewer asked you to split after the fact.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** retire for a house that explicitly prefers batched changes — some
  do, and the house wins
  ([read-the-houses-agent-file-first](../read-the-houses-agent-file-first/SKILL.md)).
- **Relates to:** the packaging sibling of
  [no-force-push-a-reviewed-pr](../no-force-push-a-reviewed-pr/SKILL.md) — that one is how
  to commit *on* a PR under review, this one is how to shape the PRs before they exist.
  Clusters come from [follow-the-thread](../follow-the-thread/SKILL.md) and
  [use-the-tool-for-its-purpose](../use-the-tool-for-its-purpose/SKILL.md); the
  independence proof is [verify-before-a-committer-comment](../verify-before-a-committer-comment/SKILL.md)
  applied to your own split; the assigned-issue case is
  [offer-dont-grab](../offer-dont-grab/SKILL.md).
