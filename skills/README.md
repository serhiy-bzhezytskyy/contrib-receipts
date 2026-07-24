# Skills index

Each skill is receipt-backed: a real merged PR, a verbatim maintainer quote, or a
runnable tool where the practice earned its keep — or, for the sourcing skills, a
*SOURCING-receipt*: a method that demonstrably found or delivered real value before
any PR merged (see the two receipt classes in the top-level README). No skill ships
without one. Ordered by workflow phase.

The "why" the skills hang off — the trust signal each one sends — is on one page in
[`../PRINCIPLES.md`](../PRINCIPLES.md).

The `→ next` column names the skill whose turn it is once this one's done — the
workflow reads as a chain, not a pile of loose rules. It's a reading aid, not a hard
gate: skip or reorder when the work calls for it.

## sourcing — find where the help actually is (before anything else)

| skill | scope | → next | receipt |
|-------|-------|--------|---------|
| [follow-the-thread](follow-the-thread/SKILL.md) | general | consolidate / offer-dont-grab | *SOURCING-receipt* — one Solr CI flake sourced 3 Jetty issues + 3 PRs: SOLR-17764 flake → jetty #15368/#15435 → (subsystem) #13569/#15472 → (adjacent) #13602/#15473. Verified via gh 2026-07-24, all OPEN/in-review. |
| [consolidate-a-scattered-thread](consolidate-a-scattered-thread/SKILL.md) | general | offer-dont-grab | *SOURCING-receipt* — SOLR-17764, a Solr committer: "unclear where to further that conversation" → a 4-thread map (incidental flakiness→SOLR-18285; test-framework CCE→SOLR-18295; upstream→jetty#15368/#15435; SolrJ retry gap→SOLR-18188). |

## front-gate — obey the house before you touch anything

| skill | scope | → next | receipt |
|-------|-------|--------|---------|
| [read-the-houses-agent-file-first](read-the-houses-agent-file-first/SKILL.md) | general | obey-the-houses-own-tooling | apache/solr #4612: a maintainer names the file — "AI is not using the Gradle tasks… (including AGENTS.md)"; Solr AGENTS.md §52 carries a comment-policy rule, proving the agent file is local law beyond tooling. The house's file overrides these skills. |
| [obey-the-houses-own-tooling](obey-the-houses-own-tooling/SKILL.md) | general | sign-off-the-house-way | a Solr committer, apache/solr #4612: "AI is not using the Gradle tasks we've built & documented (including AGENTS.md)… the file doesn't match the pattern that tool creates." |
| [sign-off-the-house-way](sign-off-the-house-way/SKILL.md) | general | match-the-house-shape | verified via gh: Eclipse/Jetty gates PRs #15435/#15472/#15473 on `eclipsefdn/eca` + a `Signed-off-by` on every commit (3/3 on #15435); Apache/Solr #4632 merged with zero DCO trailers (CLA-on-merge). Two houses, two sign-off contracts. |
| [match-the-house-shape](match-the-house-shape/SKILL.md) | apache/solr | offer-dont-grab | corpus (3,510 merged Solr PRs): the shape the house actually merges — median +31/−13 (churn 58), 4 changed files, 67.6% title-starts-with-JIRA-key, median 4.0 d to merge — is what to size the PR to, not what CONTRIBUTING says. |

## contribute — pick and shape the work

| skill | scope | → next | receipt |
|-------|-------|--------|---------|
| [offer-dont-grab](offer-dont-grab/SKILL.md) | general | discuss-in-issue-first | SOLR-3284 (14-yr dormant, offered): a Solr committer, "The proposal makes sense to me Serhiy; PR welcome :)"; predecessor credited on SOLR-17707. |
| [discuss-in-issue-first](discuss-in-issue-first/SKILL.md) | apache/solr | write-in-your-own-voice | corpus (4,646 PRs): issue-first merges median 3.4 d vs 5.8 d cold (~1.7× faster, p<0.001); NO merge-rate gap — faster, not more often. |

## submit — commit and comment hygiene on someone else's PR

| skill | scope | → next | receipt |
|-------|-------|--------|---------|
| [write-in-your-own-voice](write-in-your-own-voice/SKILL.md) | general | comments-about-code-not-change | a Solr committer, apache/solr #4632, on generated prose: "isn't useful in the delivered documentation… AI loves to do this"; the twin — a house-voice changelog drew "the best changelog entry I've seen in a long time." |
| [comments-about-code-not-change](comments-about-code-not-change/SKILL.md) | general | verify-before-a-committer-comment | a Solr committer, apache/solr #4632: "isn't useful in the delivered documentation… AI loves to do this." (+ a Jetty maintainer, #15435; OpenSearch #17140) |
| [no-force-push-a-reviewed-pr](no-force-push-a-reviewed-pr/SKILL.md) | general | verify-before-a-committer-comment | a Solr committer, apache/solr #4632: "Please don't force-push to PRs… It resets the GH review state for the reviewer." |
| [verify-before-a-committer-comment](verify-before-a-committer-comment/SKILL.md) | general | track-whose-court | apache/solr #4637: public self-correction chain ("correction on the CI red — it's not a flake… fails deterministically… My #4642 was a duplicate and I've closed it."). |

## follow-up — after the PR is open

| skill | scope | → next | receipt |
|-------|-------|--------|---------|
| [track-whose-court](track-whose-court/SKILL.md) | apache/solr | (loop: LEDGER) | runnable tool `tools/check-status.sh`; built after a committer's SOLR-17764 comment (ASF JIRA only) was missed and reported as "0 comments, untouched". |

---

Every skill carries a `## Lifecycle` section (signals it worked / what to log on a
misfire / death criterion / overlaps) — the skills are meant to be lived in and
corrected, not frozen. Applications (wins and misfires) are logged in
[`../LEDGER.md`](../LEDGER.md), the wrong-answers log.

Where a receipt is a measured corpus correlation rather than a maintainer quote, the
skill labels it as correlation-not-lever and names the confound.
