---
name: state-the-noise-floor
description: >
  Before you put a NUMBER in front of a maintainer — "N tickets affected", "X% of
  cases", "this run is 13% slower" — establish what that same number would be if
  nothing were wrong, and report the ratio. Build the floor by comparing against
  something that SHOULD be identical: repeat the measurement (N≥5), or shuffle the
  one variable your claim depends on and keep everything else fixed. If the signal
  is under ~2x the floor, say so yourself before the reviewer does. Use when you are
  about to quote a count, a percentage, or a performance delta in an issue, PR
  description or mailing-list post. Trigger terms: benchmark, regression, faster,
  slower, N tickets, X percent, how many, count, delta, improvement, is this
  significant, noise, variance, baseline.
scope: general
principle: ../../PRINCIPLES.md
---

# State the noise floor, not just the count

## Purpose

A number is the most persuasive thing you can hand a maintainer and the easiest thing
to get wrong. "14 of 19 operations regressed" and "917 records are stale" both read as
findings, and both can be exactly what you would see if nothing at all were wrong —
because measurements repeat differently, and because base rates produce coincidences
at scale.

The fix is one question asked *before* publishing: **what would this same number be if
there were no effect?** Answer it by measuring, not by estimating. Then quote the ratio,
not the raw count. A maintainer who sees `917 vs 633 expected by chance` can act on it;
a maintainer who sees `917` and later discovers the floor has learned that your numbers
need checking.

This is cheap, it is often a single extra loop or a `shuffle()`, and it is the
difference between a claim that survives review and one that gets quietly discounted.

## When to use

- You are about to write a number into an issue, a PR description, a benchmark report
  or a mailing-list post — a count, a percentage, a rate, or an A-vs-B delta.
- You ran a performance comparison, in any form. **One run per side is a demo, not a
  result.**
- You mined a corpus (issues, commits, logs) and are about to report "N items match".
- A tool you are using reports a variance statistic (RSD, stddev, confidence interval)
  and you were about to read only the mean.

## When NOT to use

- The property is **deterministic and unique**: a stack trace, a compile error, "this
  command cannot run at all", "the parameter is not in the code". `aggregate` crashing
  unconditionally needs no floor — it either runs or it does not.
- The measure is already **relative to a control population** by construction (rates
  reported as *open vs closed*, *treatment vs holdout*): the comparison group *is* the
  floor. Say that, rather than building a second one.
- A **status nobody sets by accident** (`Patch Available`, an explicit approval, a
  human label): a chance model for a deliberate act is not meaningful. Argue it in one
  line instead of computing it.
- You are reporting a **single reproduced defect**. n=1 with a reproduction and a
  control is evidence; do not dress it as a statistic.

## The practice (checklist)

- [ ] **Name the variable your claim depends on.** "917 edges went stale" depends on
      *which* closure paired with *which* edge. "Lucene 11 is 13% slower" depends on
      *which* build ran in *which* run. Write it down — the floor is built by
      destroying exactly that and nothing else.
- [ ] **Build the floor by comparison, not by estimate.** Two routes:
      - **repeat** — run the identical configuration N≥5 times and take the spread
        (RSD, stddev). If the tool computes it for you, use the tool's number, not
        your intuition;
      - **shuffle** — permute the dependent variable, hold graph/structure/marginals
        fixed, repeat ≥3 times with a fixed seed, and take the mean and spread.
      *Done when* you have a floor **and** the floor's own variability, so you know
      whether the floor itself is stable.
- [ ] **Compute signal ÷ floor and write it in the artifact.** Not the raw count
      alone. `917 vs 633 (1.45×)`. `95 vs 55 (1.74×)`.
- [ ] **Narrow the filter and re-measure.** A real effect gets *further* from chance as
      you make the criterion more specific; a base-rate artefact does not move. This is
      the single most convincing check you can show a reviewer, and it costs one rerun.
- [ ] **Disclose a weak ratio yourself.** Under ~2× is worth reporting *with the ratio
      attached and the interpretation softened* — "N against M expected by chance". Do
      not drop it and do not inflate it.
- [ ] **State which null model you used and one you did not.** A shuffle preserves some
      structure and destroys other structure; naming the alternative (block-permute
      within era, degree-preserving rewire, matched controls) shows the floor is a
      choice rather than a fact.
- [ ] **Say where the floor does not apply.** If part of your claim is a pure
      deterministic join with no random variable in it, that part has no floor — write
      that down instead of implying the whole thing was controlled.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "N=1 each side, the delta is huge, that's enough." | The receipt below: N=1 endorsed a −13% regression, N=2 endorsed it again, and N=5 retracted it. The tool's own RSD over five *identical* runs was 14.33% — the "signal" was inside the floor the whole time. |
| "I estimated the noise floor from experience — it's about ±0.2%." | That estimate was off by ~70×. An estimated floor is a guess wearing a number's clothes; the measured one came free from a command that already existed. |
| "917 is a big number, it can't be chance." | Shuffling the pairing gave 633 from pure base rates. Large corpora manufacture large coincidences; scale is the *reason* to compute a floor, not a reason to skip it. |
| "The tool printed a variance column, but the mean is what matters." | The variance column is the floor. In the receipt, 79% RSD on one operation carried a meaningless −53% that would have gone into a report as a finding. |
| "Adding a floor makes my result look weaker." | It makes it *survivable*. A 1.45× reported as 1.45× is a contribution; a 1.45× reported as a discovery is a thing the reviewer will find, and then they will re-check everything else you said. |
| "Throughput was rock-stable between two runs, so it's a reliable metric." | Between *two* runs. At N=5 the same metric showed 14.33% RSD on the same operation. Two identical-looking runs are not a variance estimate. |

## RECEIPT

***SOURCING-receipt*** — **the discipline retracted one finding and corrected one
published number, in two independent domains.** Both are internal measurements, not a
merged PR: this skill's evidence is that it caught *my own* errors before a maintainer
had to.

**1. Benchmarking — N=5 retracted what N=1 and N=2 both endorsed.** Task: does Solr on
Lucene 11 regress against Lucene 10.4? Method progression and outcome:

| stage | what it said | why it was wrong |
|---|---|---|
| N=1 per side | `index-append` throughput **−13%** on Lucene 11 | nothing to compare the variance against |
| noise floor estimated from two "identical" runs | throughput stable to **<±0.2%**, so −13% beat it ~50× | two runs is not a spread; one of them had been starved of CPU by other work on the machine (2.5 h vs ~38 min wall-clock for the same workload) |
| **N=5 per side + the tool's own `aggregate`** | **RSD 14.33%** on that operation across five *identical* runs | the −13% sits **inside** the real floor. **Finding retracted.** |

Two further things the floor exposed in the same campaign: **14 of 19 operations were
throttled**, so their throughput is pinned to the target rate by construction and
describes the scheduler rather than the server; and `refresh-after-index` carried
**79% RSD** behind a meaningless **−53%**. Without the floor, a −13% "regression" would
have gone to a mailing list as a result.

**2. Corpus mining — a shuffle floor corrected a number I had already published.** A
claim of the form *"917 records are stale: their dependency closed after the link was
made"*. Control: shuffle the closure dates among closed records, holding the graph,
statuses and link dates fixed; 5 trials, fixed seed.

| | count | records |
|---|---|---|
| real | **917** | 577 |
| shuffled floor (5 trials, floor RSD 1.6%) | **633** | 440 |
| **signal ÷ floor** | **1.45×** | 1.31× |

So **69% of the count was base rate**, and the honest headline is *"917 against 633
expected by chance"*. The check that made it credible rather than merely deflating:
**narrowing the filter raised the ratio** — restricting to dependency links whose
target was resolved *Fixed* gave **95 vs a floor of 55 = 1.74×**, which is what a real
effect does and an artefact does not.

The same shuffle control, applied to a different claim in the same body of work,
**confirmed** it decisively — a human label matched the code paths 88% of the time
against a shuffled baseline of 24–27%. **The technique is not a way to talk yourself
down; it is the thing that tells the two cases apart.**

## Lifecycle

- **Signals it worked:** the number you publish is the one that survives — nobody
  asks "how many runs?", "compared to what?", or "is that above noise?"; a reviewer
  engages with the mechanism instead of the statistic; and when you narrow the filter
  the ratio *rises*, which is the check you can show rather than assert.
- **Log a misfire when:** you shipped a count and *then* built the floor and it moved
  the claim (log the before/after ratio); the floor's own spread was so wide the
  comparison said nothing (wrong null model — log which one you used); or you built a
  floor for something deterministic and burned time on a chance model for a deliberate
  act.
- **Death criterion:** retire this if the houses you contribute to start requiring a
  variance statement in their own report templates, so the practice is enforced by the
  tooling rather than by you remembering it. Retire the *shuffle* half if a project
  ships a null-model utility you should be calling instead of hand-rolling.
- **Overlaps:** [use-the-tool-for-its-purpose](../use-the-tool-for-its-purpose/SKILL.md)
  gets you to N≥2 and real data in the first place — this skill is what you do with the
  numbers that come back;
  [verify-before-a-committer-comment](../verify-before-a-committer-comment/SKILL.md)
  covers correcting a claim you have already made, which is where a late floor lands
  you.
