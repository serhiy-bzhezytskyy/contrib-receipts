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
| [use-the-tool-for-its-purpose](use-the-tool-for-its-purpose/SKILL.md) | general | port-the-report-upstream / offer-dont-grab | *SOURCING-receipt* — one real N=5 benchmark campaign sourced 3 defects (2 blockers, one making the command unusable for everyone) → solr-orbit #55/#56/#57 + PRs #58/#59/#60. All in the gap between "it ran" and "you have a result"; 1099 green tests over a command that could not run once. Verified via gh 2026-07-25, all OPEN. |
| [read-the-projects-origin-story](read-the-projects-origin-story/SKILL.md) | general | port-the-report-upstream / discuss-in-issue-first | *SOURCING-receipt* — a 35-message, 3-thread founding arc (Feb–May 2026) read **after** 12 artifacts were filed, which reframed all of them: the author had publicly declared the incompleteness I "found" ("a MVP and WIP… Only one workload / dataset is ported so far"), the tool was chosen over a rival *for* the capability my fixes restored, two committers' structural objections sat unresolved inside their own +1 votes, and the maintainer who invited my proposal had lost the original argument — the two people who mattered were in neither my inbox nor my notes. A converter tool I was about to propose already existed. Verified via the ASF archive API 2026-07-27. |
| [port-the-report-upstream](port-the-report-upstream/SKILL.md) | general | match-the-house-shape (in the 2nd house) | *SOURCING-receipt* — the same 3 defects proven inherited (aggregator.py byte-identical apart from imports, 295 lines each, both from origin/main) → OSB #1093/#1094/#1095 + PRs #1096/#1097/#1098, CI green incl. DCO. Re-verification caught 5 stale anchors (dispatch line 1186 vs 1215; `run` vs deprecated `execute-test`; per-repo autolinks, labels, DCO). Verified via gh 2026-07-25. |

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
| [measure-before-you-widen](measure-before-you-widen/SKILL.md) | general | one-fix-one-pr-then-coordinate | apache/lucene 2026-08-02: after a per-chunk checksum landed in `.fdt`/`.tvd`, `.tim` was asserted to have "the same LZ4 vulnerability" and a third format change was queued. Measured on the same axis instead — **0.6% silent corruption vs 48.5%**, and not one `AIOOBE` came from LZ4. The change was dropped; the same 320-sample sweep found an unchecked array index in `LowercaseAsciiCompression#decompress` that nobody was looking for, shipped test-first as a different third commit. |

## submit — commit and comment hygiene on someone else's PR

| skill | scope | → next | receipt |
|-------|-------|--------|---------|
| [one-fix-one-pr-then-coordinate](one-fix-one-pr-then-coordinate/SKILL.md) | general | write-in-your-own-voice | *SOURCING-receipt* — two clusters packaged one-issue-per-PR: jetty #13569/#13602 split out of ONE branch of 5 mixed commits → PRs #15472/#15473, each 1 commit, hub comment on the neutral root issue #15368 with the contested PR's cross-link held; and solr-orbit #58/#59/#60 + OSB #1096/#1097/#1098, 6 PRs, 1 commit each, numbering kept parallel. Verified via gh 2026-07-26. |
| [write-in-your-own-voice](write-in-your-own-voice/SKILL.md) | general | comments-about-code-not-change | a Solr committer, apache/solr #4632, on generated prose: "isn't useful in the delivered documentation… AI loves to do this"; the twin — a house-voice changelog drew "the best changelog entry I've seen in a long time." |
| [answer-only-what-was-asked](answer-only-what-was-asked/SKILL.md) | general | comments-about-code-not-change | *SOURCING-receipt* — OSB #1098, 2026-07-30: asked only *"this will need one more rebase because of #1096 :)"*, I posted four sentences of my own verification (13 tests, mutation check, "checked the other direction too"). **The comment was deleted and replaced with the fact of the rebase alone.** Every check was worth running; none was worth posting — the audience for verification is the person about to push, not the person about to read. |
| [comments-about-code-not-change](comments-about-code-not-change/SKILL.md) | general | verify-before-a-committer-comment | a Solr committer, apache/solr #4632: "isn't useful in the delivered documentation… AI loves to do this." (+ a Jetty maintainer, #15435; OpenSearch #17140) |
| [no-force-push-a-reviewed-pr](no-force-push-a-reviewed-pr/SKILL.md) | general | verify-before-a-committer-comment | a Solr committer, apache/solr #4632: "Please don't force-push to PRs… It resets the GH review state for the reviewer." |
| [verify-before-a-committer-comment](verify-before-a-committer-comment/SKILL.md) | general | track-whose-court | apache/solr #4637: public self-correction chain ("correction on the CI red — it's not a flake… fails deterministically… My #4642 was a duplicate and I've closed it."). |
| [state-the-noise-floor](state-the-noise-floor/SKILL.md) | general | track-whose-court | *SOURCING-receipt* — the discipline caught two of my own errors before a maintainer had to. Benchmarking: N=1 endorsed a −13% regression, N=2 endorsed it again, **N=5 retracted it** — the tool's own RSD over five identical runs was **14.33%**, and the estimated "<±0.2% floor" was off ~70×; the same campaign also exposed 14 of 19 operations as throttled (pinned to the target rate by construction) and a **79% RSD** behind a meaningless −53%. Corpus mining: a shuffle floor (5 trials, fixed seed) corrected an already-published count from *"917 stale"* to **917 vs 633 expected by chance = 1.45×**, while narrowing the filter **raised** the ratio to 1.74× — and the same control **confirmed** a different claim at 88% vs a 24–27% shuffled baseline. |

## follow-up — after the PR is open

| skill | scope | → next | receipt |
|-------|-------|--------|---------|
| [nudge-with-new-information](nudge-with-new-information/SKILL.md) | general | (loop: LEDGER) | *SOURCING-receipt* — two nudge batches the same morning: 6 identical "any objections?" reminders (08:02–08:06) vs 2 evidence-carrying CI comments on jetty [#15473](https://github.com/jetty/jetty.project/pull/15473#issuecomment-5090338978) / [#15472](https://github.com/jetty/jetty.project/pull/15472#issuecomment-5090363095). Threshold measured, not guessed: 200 merged apache/solr PRs → median 0.33 d to first human response, **p90 4.80 d**, and **63/200 merged with zero human comments**. Solr's own guide invites reminders "after a few days". Verified via gh 2026-07-27. |
| [track-whose-court](track-whose-court/SKILL.md) | apache/solr | (loop: LEDGER) | runnable tool `tools/check-status.sh`; built after a committer's SOLR-17764 comment (ASF JIRA only) was missed and reported as "0 comments, untouched". |

---

Every skill carries a `## Lifecycle` section (signals it worked / what to log on a
misfire / death criterion / overlaps) — the skills are meant to be lived in and
corrected, not frozen. Applications (wins and misfires) are logged in
[`../LEDGER.md`](../LEDGER.md), the wrong-answers log.

Correction cuts both ways: **a skill should get shorter or sharper over time, not only
longer.** When a new rule supersedes old wording, the old wording goes in the same edit
and the removal is logged as `pruned` — otherwise a rule ends up stated three ways that
drift apart. Checklist steps say how you know the step is *done*, so "I did that one"
is checkable rather than felt.

Where a receipt is a measured corpus correlation rather than a maintainer quote, the
skill labels it as correlation-not-lever and names the confound.

The claims this file and each skill make about their own shape are checked, not
trusted: `bash tools/validate-skills.sh` enforces them — the uniform section order,
`name` matching its directory, a description Claude can route on (a `Use when…`
clause + `Trigger terms:`), both indexes listing every skill, resolving links,
no maintainer handles in prose, English-only. Add `--online` to re-resolve every
GitHub receipt link, so a receipt that goes dead fails a check instead of aging
quietly. It runs as part of [`../tests/check-status-smoke.sh`](../tests/check-status-smoke.sh).

The de-identification check is the one with real stakes and the one that has been wrong
most often — twice a miss, once a false positive, each caught by hand. It now treats
`@handle` and `[~handle]` as hits unconditionally, and a bare backticked `login` as a hit
only when the same line attributes something to it (*said*, *commented*, *reviewed*,
*verbatim*…). That gate is deliberate: without it the rule flags every skill name, every
SHA and `null`, and a check that cries wolf gets ignored — which is how this kind of rule
fails in practice. **Honest limit: a bare login with no attribution word nearby still
passes.** It is a filter, not a proof; the reader is still the last line.

Whether a skill actually *loads* is a separate question, and a separate test:
[`../tests/routing-evals.sh`](../tests/routing-evals.sh) puts a real request to Claude
in a clean directory holding only these skills, and checks which one fires. Claude
routes on the `description` frontmatter alone, so a skill can pass every structural
check and still never load — `port-the-report-upstream` did exactly that (0/3; see
[`../LEDGER.md`](../LEDGER.md)). Opt-in (`RUNS=3 bash tests/routing-evals.sh`), since
each case spawns a real session; a single miss is noise, a repeated one is a
description to sharpen.
