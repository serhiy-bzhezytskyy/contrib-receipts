---
name: use-the-tool-for-its-purpose
description: >
  To find real bugs in an unfamiliar project, don't audit its code hunting for
  smells — USE the tool for its actual purpose, on real data, at realistic N. The
  defects that survive green CI live in the step everyone skips: the gap between
  "it ran" and "you have a result" (aggregate, compare, report, export, the second
  run). Then reproduce each finding against the REAL method with a passing control,
  rule out your own setup, and check whether the thing you call missing is actually
  documented. Use when picking what to contribute in a repo you don't know. Trigger
  terms: find a bug, what should I fix, unfamiliar repo, where to contribute, audit
  the code, N=1, test-mode, demo path, real data.
scope: general
principle: ../../PRINCIPLES.md
---

# Use the tool for its purpose (to find where the bugs actually are)

## Purpose

An LLM asked to "find bugs in this repo" will read code and produce plausible
smells: a maintainer's least favorite kind of contribution, because every one has to
be disproved by hand. The alternative costs more wall-clock and almost nothing in
reviewer trust: **run the project for the reason it exists**, on real input, at the
scale a real user would. Defects that survive months of green CI are concentrated in
the one workflow nobody walks end to end — and a bug found *by being blocked by it*
arrives with a reproduction, a stack trace, and an obvious severity, none of which
you had to argue for.

## When to use

- You want to contribute to a repo you don't own and don't yet know, and you're
  deciding *what*.
- The project is a tool, CLI, or pipeline with an end-to-end workflow you can run.
- You have a real task that happens to need this tool — best case. Be a user first;
  the bug list writes itself.

## When NOT to use

- The pain already came to you from a live thread or a CI failure — start from that
  instead: follow-the-thread (traverse it) or consolidate-a-scattered-thread (map it).
- The project isn't runnable in reasonable time/resources (huge cluster, paid
  service, 100GB corpus you don't have). Say so and pick a different sourcing route
  rather than faking a run.
- Library-only code with no workflow to walk — there is no "purpose" to exercise.

## The practice (checklist)

- [ ] **Run it for a real purpose, not as a demo.** Have an actual question you want
      the tool's answer to. Purposeless runs stop at the happy path.
- [ ] **Realistic N, real data.** `--test-mode`, sample corpora and N=1 are exactly
      the paths that are already covered. Bugs live at N≥2 and on the full input.
- [ ] **Target the step everyone skips.** Rank candidate surfaces by how likely a
      demo is to reach them:
      - the gap between "it ran" and "you have a result" — **aggregate, compare,
        summarize, report, export, publish**;
      - the **second** run: leftover state, caches, a checked-out repo that now has
        untracked files, "combine with previous results" code;
      - **optional/rare inputs** — the operation that returns null, the empty
        result set, the field nobody sets.
- [ ] **Finish the workflow.** Fixing one blocker usually reveals the next; a run
      that ends in a green checkmark you didn't verify the *output* of is not a
      finished run. *Done when* you have the artifact you originally wanted and have
      read its fields — not when the command stopped raising.
- [ ] **Reproduce against the REAL method, with a control that passes.** Bypass only
      the wiring you must (constructor/config/store); never mock the code under
      test. The control — the same call with healthy input, succeeding — is what
      proves the trigger is the trigger and not your harness.
- [ ] **Rule out your own setup before you call it a project bug.** Re-do it the way
      a normal user would (a real `git clone`, not your staged copy).
- [ ] **Check whether the "missing" thing is documented** before reporting it
      missing. Grep the config and the docs; a hit rescopes your report from
      "feature absent" to the real, narrower defect — which is the one that lands.
- [ ] **Separate proved from observed.** Report what you reproduced. Anything you
      merely saw and did not root-cause goes in as prose context inside a report you
      *did* prove, not as a claim of its own.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "I'll read the code and find bugs faster than running it." | You'll find *smells*, and each one costs a maintainer real time to disprove. The three blockers in the receipt below are in code that reads fine; nothing about `value.get(field, 0)` looks wrong until an operation reports an explicit `null`. |
| "CI is green, so the basics must work." | CI proved nothing here: 1099 tests passed over a command that could not run once, because the tests mocked the object the broken line read (comments: see mocks-cannot-verify-attribute-names in the companion notes). Green CI marks where nobody looked. |
| "`--test-mode` / a small sample is enough to exercise it." | Both blockers sit *past* the point a sample run reaches. N=1 has nothing to aggregate; test-mode never loads the operation that returns nulls. The cheap run is the covered run. |
| "The unit test passes now, the fix is done." | The first fix's unit test was green while real data still crashed — a second, independent null site in another function. "Fixed" means the end-to-end run produces *correct output*, not that it stopped raising. |
| "It broke on my machine, that's a bug." | One "defect" was my own `cp -R` staging leaving `__pycache__` behind; a real `git clone` is clean. Reporting it would have burned a maintainer's time on my setup. Re-do it the normal way first. |
| "This feature is missing." | Checked before reporting: the thing I called undocumented was in `benchmark.ini:28` and eight doc pages. The real defect was narrower and provable — `run` accepts `--workload-path`, `aggregate` doesn't. Overclaiming would have gotten the whole report dismissed. |

## RECEIPT

***SOURCING-receipt*** — **3 defects → 6 issues + 6 PRs across two projects, found by
finishing one benchmark campaign.** Verified via `gh` 2026-07-25, all twelve OPEN.

The task was a real question: does Solr on Lucene 11 regress against Lucene 10.4?
Answering it needed 5 runs per config averaged — so it needed `solr-orbit aggregate`,
and `aggregate` **could not run at all on `main`**:

| # | defect | apache/solr-orbit | opensearch-project/opensearch-benchmark |
|---|---|---|---|
| 1 | null metrics crash metric reduction (`min()`/`max()` over `value.get(field, 0)`, which doesn't fire on a present-but-null value) — plus a second, independent site found only on real data | [#55](https://github.com/apache/solr-orbit/issues/55) → [#58](https://github.com/apache/solr-orbit/pull/58) | [#1093](https://github.com/opensearch-project/opensearch-benchmark/issues/1093) → [#1096](https://github.com/opensearch-project/opensearch-benchmark/pull/1096) |
| 2 | **unconditional** — reads a test-run attribute that does not exist, so `aggregate` fails for every input, for everyone | [#56](https://github.com/apache/solr-orbit/issues/56) → [#59](https://github.com/apache/solr-orbit/pull/59) | [#1094](https://github.com/opensearch-project/opensearch-benchmark/issues/1094) → [#1097](https://github.com/opensearch-project/opensearch-benchmark/pull/1097) |
| 3 | parity gap — `run` takes `--workload-path`, `aggregate` doesn't, so a locally developed workload can be benchmarked and then not aggregated | [#57](https://github.com/apache/solr-orbit/issues/57) → [#60](https://github.com/apache/solr-orbit/pull/60) | [#1095](https://github.com/opensearch-project/opensearch-benchmark/issues/1095) → [#1098](https://github.com/opensearch-project/opensearch-benchmark/pull/1098) |

**Why they survived:** all three sit between *"you ran the benchmark"* and *"you have
a result."* `--test-mode` never reaches them. N=1 never reaches them — nothing to
aggregate. CI never reaches them — every test in the aggregator suite passes a bare
`Mock` as the test run, and a `Mock` answers any attribute name, so the wrong name
reads fine. **1099 green tests downstream and 1422 upstream, over a command that
could not succeed once.**

**Each was reproduced against the real method with a passing control** — e.g.
`calculate_weighted_average(null throughput)` → `TypeError: '<' not supported between
instances of 'NoneType' and 'NoneType'`, beside a control on numeric throughput that
returns cleanly, plus the bare-`Mock` control that reproduces what CI does and shows
no error. The upstream defects were then reproduced *by running OSB*, not by reading
it, and confirmed through the real CLI going `❌ FAILURE` → `✅ SUCCESS` with output
checked field by field.

**Two near-misses this checklist caught**, both of which would have been noise:
a `__pycache__` failure that was my own staging (downgraded to a `.gitignore` nit,
not reported), and "the workloads repo is undocumented" (it is documented —
rescoped to the narrow parity gap that became #57/#1095).

The upstream half of this receipt is the sibling skill's:
[port-the-report-upstream](../port-the-report-upstream/SKILL.md).

## Lifecycle

- **Signals it worked:** the report arrives with a stack trace and a control, and a
  maintainer engages with severity rather than asking "how did you hit this?"; your
  own blocked task is what dates the bug.
- **What to log on a misfire:** the surface you exercised, whether the finding
  survived the setup check, and whether the "missing" thing turned out documented.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** if a run of this method across a whole project yields only
  findings that don't survive the control/setup checks, the method is producing
  noise in that project — retire it there, not everywhere.
- **Relates to:** upstream propagation is
  [port-the-report-upstream](../port-the-report-upstream/SKILL.md) (do it *after*
  this one lands the downstream evidence). Sibling to
  [follow-the-thread](../follow-the-thread/SKILL.md) — that one starts from someone
  else's pain, this one from your own. What you *don't* report is
  [offer-dont-grab](../offer-dont-grab/SKILL.md)'s discipline applied to findings.
