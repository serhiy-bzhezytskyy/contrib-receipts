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
| "The maintainer already asked for it, so I can just build it." | An invited feature is not a priced feature. On solr-orbit#61 the maintainer asked for an "elegant" auto-resolve believing it was a field read; writing the issue showed it needed a persisted-format change, and he then called it feature creep and proposed closing. Same finding either way — but from an issue it costs an afternoon, and from a PR it costs the patch plus a maintainer having to reject something he invited. |
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

**Second receipt — a maintainer-endorsed idea DECLINED after the issue priced it (apache/solr-orbit#61,
2026-07-27).** The corpus above measures *speed*; this one shows the mechanism, and it is the stronger of
the two.

A maintainer asked for a follow-up in his own review, believing it was cheap:

> "It would of course be elegant if we auto resolved the workload location from the stored run. Perhaps as a
> separate improvement in addition to this more explicit one?"

Rather than implement it, I filed the issue — and the act of writing it up required reading how the stored
run is actually persisted. It turned out the thing to "just read" **is not stored at all**: the run keeps the
workload's name, params and revision, but never its *source*. So the work was a persisted-format change plus
a backward-compatibility fallback for existing files, plus coordination with the upstream project whose copy
of that file is byte-identical. The issue said so, and named the two decisions that were not mine.

**Ten minutes before merging a different PR of mine, the same maintainer declined it:**

> "Since this is not a simple path read from the test-run file, I think we should defer or close this until
> it is deemed very useful. Right now it just feels like feature creep."

He was right, and **the issue is what made him right on time.** He had asked for the feature; the write-up
priced it; he declined the price. Arriving with a PR would have produced the identical finding *after* the
work, and would have put a maintainer in the position of rejecting code he had implicitly invited — the worst
version of this exchange for both sides.

**So the lever is bigger than speed:** issue-first converts "work then discover" into "discover then decide",
and the cost of a declined issue is one afternoon of reading, not a rejected patch. Note also the honesty
requirement that made it work — the issue had to state the *inconvenient* finding (this is harder than you
think) rather than the flattering one (great idea, I'll take it).

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
