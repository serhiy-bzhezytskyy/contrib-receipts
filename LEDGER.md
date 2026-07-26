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
| 2026-07-25 | use-the-tool-for-its-purpose | apache/solr-orbit #55–#60 | worked *(sourcing-receipt)* | Ran a real N=5 × 3-config benchmark campaign to answer an actual question (Lucene 11 vs 10.4), rather than auditing code for smells. `aggregate` could not run at all: 3 defects, each hidden behind the previous, all in the gap between "it ran" and "you have a result". 3 issues + 3 PRs, one fix each, every finding reproduced against the real method with a passing control. Two candidate findings **withheld** by the same checklist: a `__pycache__` failure that was my own `cp -R` staging (a real `git clone` is clean → downgraded to a `.gitignore` nit), and "the workloads repo is undocumented" (it is documented — `benchmark.ini:28` + 8 doc pages → rescoped to the narrow `--workload-path` parity gap). |
| 2026-07-25 | port-the-report-upstream | opensearch-project/opensearch-benchmark #1093–#1098 | worked *(sourcing-receipt)*, with a corrected guess | Proved the 3 downstream defects **inherited** by diffing both files from `origin/main` (byte-identical apart from 3 import lines, 295 lines each), reproduced them upstream **by running OSB**, and reported all 6 artifacts cross-referencing their downstream counterparts. CI green incl. DCO. Corrects my own earlier written guess that the unconditional blocker "appears Solr-port-specific" — upstream carries the identical wrong attribute; a guess stated in a document meant to be evidence. Re-deriving anchors against the second repo's `origin/main` (prompted by noticing the clone sat on a fix branch) caught **5 stale anchors** before posting: dispatch line 1186 vs 1215, subcommand `run` vs deprecated `execute-test`, issue numbers that autolink per-repo, an `untriaged` label that exists in one house only, DCO required in one house only. |
| 2026-07-26 | port-the-report-upstream *(routing, not application)* | this repo — `tests/routing-evals.sh` | misfired → corrected | The skill was **unroutable**: it shipped with no `Use when…` clause at all, and after one was appended it still fired **0/3** on "this project looks forked from another one — does the original still have the same problem?" (Claude answered directly, never loading it). Two tools found two halves of the same defect: `tools/validate-skills.sh` caught the *missing* clause, then the routing evals showed the appended clause still didn't *route* — a description can satisfy every structural rule and still never fire. Cause: the clause sat in the middle, behind four lines of anchor-re-derivation mechanics, and the trigger terms answered "fork/port" but not the question a person actually asks. Fixed by opening the description with the routing case and adding the phrasings ("does the original have this", "is this fixed upstream", "report it upstream too") → **3/3, then 2/2 in a full-suite run**. Lesson: a receipt is worth nothing if the skill never loads; the `description` is a routing surface first and a summary second. |
| 2026-07-25 | verify-before-a-committer-comment | apache/solr-orbit #58 | misfired → caught pre-post | Drafted PR body claimed *"Five new tests… covering … `calculate_rsd` with nulls…"*; the diff had **two** tests and no `calculate_rsd` test. Caught by diffing the branch against `origin/main` before posting — not by a reviewer. Posted body names only the two that exist, states they were verified red by restoring main's `aggregator.py`, and discloses the gap openly. New checklist item: **check the PR body against its own diff, count by count, before posting** — a body written from what you *intended* drifts from what the commit contains, and the reviewer reads the prose beside the diff. |

## Reconstruction cost (sourcing skills)

The sourcing skills (`follow-the-thread`, `consolidate-a-scattered-thread`,
`use-the-tool-for-its-purpose`, `port-the-report-upstream`) don't just
succeed-or-misfire — each firing costs a measurable amount of *by-hand* cross-channel work
(graph hops, artifacts re-read, trackers crossed) that is redone from scratch every invocation,
with no memory between runs. Logging that cost turns "it worked once" into a running measure of
how much reconstruction the manual method is actually being asked to do.

Columns: date | skill | hops | artifacts re-read | trackers crossed | note.

| date | skill | hops | artifacts | trackers crossed | note |
|------|-------|------|-----------|------------------|------|
| 2026-07-20 | consolidate-a-scattered-thread | ~8 (full link-graph walk) | ~8 JIRA tickets + linked PRs + commits + dev@ posts | 3 (ASF JIRA, GitHub, dev@) | rebuilt the SOLR-17764 map from scratch by hand; the traversal + read alone "took hours" (felt-pain note). No cached graph — a second run would redo all of it. |
| 2026-07-23 | follow-the-thread | 4 (symptom → upstream → subsystem → adjacent) | SOLR-17764 flake + jetty #15368/#15435/#13569/#15472/#13602/#15473 | 2 (Solr JIRA, Jetty GitHub) | one downstream CI flake sourced 3 upstream issues + 3 PRs; each hop re-ran `gh` search + subsystem read live, discarded after. |
| 2026-07-25 | use-the-tool-for-its-purpose | 3 (blocker → next blocker → parity gap; each only visible once the prior was fixed) | 15 real benchmark runs (~38 min each) + `aggregator.py` + `metrics.py` + `benchmark.py` + `benchmark.ini` + 8 doc pages (the "is it documented" check) | 1 (GitHub) + local runs | the cost here is **wall-clock, not hops**: ~9.5 h of benchmark runtime is what bought the findings, and it is unavoidable — the defects are only reachable at realistic N. Two candidate findings discarded after re-testing (own-setup check, documented-already check). |
| 2026-07-25 | port-the-report-upstream | 2 (downstream site → upstream site) × 5 anchor classes re-derived | both `aggregator.py` from `origin/main` (diffed), `benchmark.py` dispatch, `metrics.py` assignment + legacy keys, 4 upstream PR numbers verified to resolve, 2 label sets, 2 CONTRIBUTING/DCO contracts | 2 (Apache GitHub, OpenSearch GitHub) | re-derivation is the whole cost and it is **not** compressible by copying: 5 anchors were stale, and the clone being on a fix branch (not `main`) is what exposed them. A cached "same code" answer would have shipped all 5. |

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
- The two 2026-07-25 sourcing rows are likewise **sourcing-receipts**: 6 issues + 6 PRs open across two
  projects, none merged yet. The upstream CI green on #1096/#1097/#1098 is *observed* (OpenSearch runs
  checks for outside contributors immediately); solr-orbit's #58/#59/#60 sit at `action_required`
  pending a maintainer, so the green claimed in those PR bodies is the local suite and is stated as such.
  Verified via `gh` 2026-07-25. Companion agentic-oss notes:
  `lessons/use-the-tool-for-its-purpose-to-find-bugs.md`, `lessons/mocks-cannot-verify-attribute-names.md`,
  `solr/issues/solr-orbit-aggregate/index.md`, `solr/candidates/osb-aggregate-upstream.md`.
