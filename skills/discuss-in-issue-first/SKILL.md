---
name: discuss-in-issue-first
description: >
  For a non-trivial change, open or comment on the tracking issue and get the
  approach discussed BEFORE opening the PR — to make the change land FASTER, not to
  make it more likely to be accepted. Measured on Apache Solr: PRs with prior issue
  discussion merged at a median 3.4 days vs 5.8 days for cold PRs (~1.7× faster,
  p<0.001), with NO difference in merge rate (both ~83%). So discuss first to move
  faster, not to get in. Use before opening a PR for anything beyond a trivial
  typo/dep-bump. Trigger terms: issue-first, discuss first, open an issue, cold PR,
  RFC, design before code, faster merge.
scope: apache/solr
principle: ../../PRINCIPLES.md
---

# Discuss in the issue first (to move faster)

## Purpose

Prior discussion on the tracking issue means the PR lands into pre-built consensus:
the community already agreed the change matters and roughly how it should look, so
review is cheaper and faster. The honest, measured claim is about **speed, not
acceptance** — issue-first PRs merge markedly faster, but they do not merge at a
higher *rate*. So the reason to do it is to shorten time-to-merge and avoid a
rewrite after a cold PR meets a design objection, not to improve your odds of getting
in at all.

Calibration matters here: do NOT sell this as "gets accepted more often" (the data
refutes that), and do NOT pair it with a "minimize review cycles" rule — in the same
corpus, *more* review comments correlated with a *higher* merge rate, so cycles are a
sign of engagement that lands, not of doom.

## When to use

- Before opening a PR for any non-trivial change (behavior change, new API, refactor,
  anything with a design decision).
- Skip for genuinely trivial changes — typos, broken links, mechanical dep-bumps.

## When NOT to use

The change is genuinely trivial (typo, broken link, mechanical dep-bump) — the discussion overhead then costs more time than it saves.

## The practice (checklist)

- [ ] Find or open the tracking issue for the change.
- [ ] State the problem and your proposed approach on the issue; surface the design
      question rather than presenting a finished PR as a fait accompli.
- [ ] Get a maintainer's read on the approach (a "makes sense" / "PR welcome" nod).
- [ ] Then open the PR, linking the issue — the review starts from agreed ground.
- [ ] Don't fear the back-and-forth once the PR is open: review cycles correlate with
      landing, not with rejection. Engage, don't minimize.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "I'll open the PR straight away — the code speaks for itself." | Prior issue discussion lands it faster (measured 3.4 vs 5.8 days); a cold PR risks a design objection and a full rewrite. |
| "Discussing first won't raise my odds, so why bother?" | The lever is *speed*, not acceptance — you discuss to shorten time-to-merge and dodge a rewrite, not to get in at all. |
| "I'll minimize the back-and-forth to look decisive." | In the same corpus more review comments correlated with a *higher* merge rate; cycles are engagement that lands, not doom. |

## RECEIPT

**Corpus measurement (`corpus-solr-prs/`, 4,646 apache/solr PRs; observational).**
Joining each PR to its linked JIRA and counting comments predating the PR:

| group | n | merge-rate | median time-to-merge |
|---|---|---|---|
| issue-first (≥1 prior JIRA comment) | 1,666 | 83.0% | **3.37 d** |
| cold (linked issue, 0 prior comments) | 1,298 | 82.7% | **5.83 d** |

Merged-only comparison: 80.8 h vs 140.0 h median, Mann-Whitney z = −7.2, p < 0.001 —
issue-first merges ~1.7× faster. Merge-rate gap is negligible (0.3 pp, noise).

**Honesty labels (this is a correlation, not a proven lever):**
- **Speed only.** The claim is "lands faster", not "lands at all". Frame it that way.
- **Selection/reverse-causation confound.** Serious contributors do issue-first AND
  get merged; the practice may be a marker of the contributor, not a cause of speed.
  Observational data can't separate them. Not a maintainer quote — a measured pattern.
- **Do NOT bolt on "minimize review cycles":** the same corpus shows merge-rate rises
  with review-comment count (74%→89%), refuting that advice.

## Lifecycle

- **Signals it worked:** a design nod on the issue before you open the PR; review
  starts from agreement rather than a scope/approach objection; faster first review.
- **What to log on a misfire:** a case where issue-first discussion stalled or the
  maintainer preferred a cold PR — and whether the change was actually non-trivial.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** re-measure per project; this is an Apache Solr correlation.
  If a repo's data shows no speed gap, downgrade the claim for that repo. Retire if a
  larger controlled study overturns the speed finding.
- **Relates to:** carries the calibrated speed-not-acceptance claim and its
  measurement (issue-first is faster, not just more likely to land). Adjacent to
  offer-dont-grab (both are "align before you drop a PR").
