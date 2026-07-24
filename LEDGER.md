# LEDGER — the wrong-answers log

Every time a skill here is applied and the outcome is worth learning from, it goes in this table —
misfires next to wins. This is the trust artifact: it proves the skills are lived in and corrected,
not frozen advice. It is also the fuel for the learning loop.

## Why a LEDGER (not just a changelog)

Borrowed discipline: record what the tool got WRONG next to what it got right. A practice that keeps
being invoked while only misfiring is worse than one that's honestly retired. **"Last useful outcome,"
not "last invoked," is the death signal** — a skill with no useful outcome across recent applicable
contributions is a candidate for retirement.

Format: date | skill | context (repo/PR) | outcome (worked / misfired / stale) | what changed.

## Entries

| date | skill | context (repo/PR) | outcome | what changed |
|------|-------|-------------------|---------|--------------|
| 2026-07-07 | obey-the-houses-own-tooling | apache/solr #4612 (SOLR-18302) | misfired → corrected | Hand-created the changelog + GJF-upgrade files instead of running the house task. A Solr committer caught the tool-bypass: *"AI is not using the Gradle tasks we've built & documented (including AGENTS.md)… the file doesn't match the pattern that tool creates."* Recovered by owning it (*"Fair — I did hand-create these rather than run writeChangelog. I'll regenerate them with the task."*) and regenerating with `writeChangelog`. Sharpened the skill's "never hand-craft a generated file" checklist item. |
| 2026-07-20 | consolidate-a-scattered-thread *(navigation/communication; skill proposed, see feedback §B.2)* | apache/solr SOLR-17764 (reply to a Solr committer) | worked *(sourcing-receipt)* | The committer: *"unclear where to further that conversation"* — the graceful-shutdown truth was fragmented across ~8 JIRA tickets + PRs + commits + dev@. Instead of "reply here", traversed the JIRA link graph, read every linked ticket, and handed back a map untangling the conflated concerns into distinct homes (incidental flakiness / test-framework CCE / upstream jetty root cause / SolrJ retry gap). Verifying each claim in code corrected two of my own earlier wrong framings. A worked *communication/navigation* application; logged as a sourcing-receipt, not a merge-receipt. |
| 2026-07-23 | offer-dont-grab | jetty #15472 (fixes #13569, assigned to the HTTP/2 lead) | worked | #13569 was assigned to the HTTP/2 lead but dormant (assignee never commented, no linked PR). Built a TDD-verified fix, then opened the PR with explicit offer framing in the body ("the offered fix, no pressure — feel free to take it a different way") rather than silently grabbing the assigned issue. No grab; PR now in review awaiting the assignee's nod. Honored the guardrail against stacking offers with the same reviewer. |
| 2026-07-23 | verify-before-a-committer-comment | jetty #15435 (fixes #15368) | misfired → corrected | Pushed commit `fe9149e` and — in the same motion — posted a reply citing the tests ("also still passes") before the PR's CI settled. CI then came back red on two UNRELATED flakes: #14901 H3_QUICHE and a jetty-proxy concurrent-load test, neither touched by the change. A "tests pass" claim next to a red CI badge undermines credibility even when the change is innocent. New rule: local green ≠ CI green — wait for the PR's CI, and if a comment asserts test status, confirm CI FIRST (`gh pr checks`). Recovered by posting a follow-up naming the two flakes. |

## Reconstruction cost (sourcing skills)

The two sourcing skills (`follow-the-thread`, `consolidate-a-scattered-thread`) don't just
succeed-or-misfire — each firing costs a measurable amount of *by-hand* cross-channel work
(graph hops, artifacts re-read, trackers crossed) that is redone from scratch every invocation,
with no memory between runs. Logging that cost turns "it worked once" into a running measure of
how much reconstruction the manual method is actually being asked to do.

Columns: date | skill | hops | artifacts re-read | trackers crossed | note.

| date | skill | hops | artifacts | trackers crossed | note |
|------|-------|------|-----------|------------------|------|
| 2026-07-20 | consolidate-a-scattered-thread | ~8 (full link-graph walk) | ~8 JIRA tickets + linked PRs + commits + dev@ posts | 3 (ASF JIRA, GitHub, dev@) | rebuilt the SOLR-17764 map from scratch by hand; the traversal + read alone "took hours" (felt-pain note). No cached graph — a second run would redo all of it. |
| 2026-07-23 | follow-the-thread | 4 (symptom → upstream → subsystem → adjacent) | SOLR-17764 flake + jetty #15368/#15435/#13569/#15472/#13602/#15473 | 2 (Solr JIRA, Jetty GitHub) | one downstream CI flake sourced 3 upstream issues + 3 PRs; each hop re-ran `gh` search + subsystem read live, discarded after. |

`tools/check-status.sh` now logs its own version of this automatically — one line per run
(`ts | channels | items | ball_on_you_github | ball_on_you_cross_tracker`) to
`~/.contrib-receipts/status-log.tsv`, so the cross-channel sweep's cost accrues without manual
bookkeeping. The `cross_tracker` count is the one that matters: a reply owed on a channel a
GitHub-only view can't see.

## Notes

- Every entry above is a real, dated application sourced from the contribution journal (companion
  agentic-oss notes: `lessons/confirm-pr-ci-green-before-posting.md`, `solr/issues/SOLR-17764/
  consolidation.md`, `SCOREBOARD.md`, and per-reviewer profile notes). Nothing here is invented;
  an application that can't be verified against the source is omitted, not guessed.
- The SOLR-17764 row is a **sourcing/communication-receipt** (a method that demonstrably worked before
  any PR merged), not a merge-receipt — see the two receipt classes in the README.
