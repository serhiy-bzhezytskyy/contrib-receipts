---
name: match-the-house-shape
description: >
  Before shaping a PR, mine what ACTUALLY merges in this house — the median churn,
  changed-file count, title convention, and test-touch rate of recently merged PRs —
  and size/shape your contribution to that median. A reviewer's implicit expectation
  is set by what they routinely merge, not by what CONTRIBUTING.md states; a PR in the
  house's usual shape is cheaper to review and so more likely to land as help.
  Measured on Apache Solr: 3,510 merged PRs settle on a clear median shape (churn 58,
  4 changed files, 67.6% JIRA-key titles, 4.0 d to merge). Use before opening a PR,
  after picking the work. Trigger terms: house shape, median PR size, right-size the
  PR, split the PR, title convention, what actually merges.
scope: apache/solr
principle: ../../PRINCIPLES.md
---

# Match the house shape (what merges, not what's documented)

## Purpose

The reviewer who will read your PR has a shape in their head — and it was set by the
hundreds of PRs they have *already* merged, not by the words in CONTRIBUTING.md. A
change that arrives in that familiar shape (roughly the median churn, the usual
file-count, the expected title prefix, tests where tests usually go) is cheaper to
hold in the head and cheaper to sign off. A change that arrives three times the
usual size, spread across ten files, with no JIRA key in the title, costs the
reviewer extra work before they can even start — and that cost is what stalls it.

The honest framing is **review cost, not correctness**: matching the house's usual
shape makes your PR cheaper to review, which helps it land as help. It does not make a
wrong change right, and being small is not a virtue in itself. This is about fitting
the house so the reviewer's attention goes to the change, not to its packaging.

## When to use

- After you have picked the work and before you shape the PR — to decide how big,
  how many files, what the title looks like, whether to include tests.
- When a change feels large and you are unsure whether to split it.
- On a repo new to you, to learn its real conventions from data instead of docs.

## When NOT to use

For *when* to talk to maintainers before coding, that is discuss-in-issue-first; this skill governs the *shape* of what you submit, not the timing of the conversation.

## The practice (checklist)

- [ ] Query recently merged PRs:
      `gh pr list --repo <r> --state merged --limit 200 --json additions,deletions,changedFiles,title,createdAt,mergedAt,files`
- [ ] Compute the median churn (add+del), median changed-files, the title-prefix
      convention (e.g. share starting with a JIRA key), the test-touch rate, and the
      median days-to-merge.
- [ ] Compare your candidate PR to that median on each axis.
- [ ] If you are well above the median churn or file-count, split the work or scope
      it down until it fits.
- [ ] Adopt the title convention (for Solr, prefix with the JIRA key).
- [ ] Include tests if the house's merged PRs usually touch tests.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "CONTRIBUTING.md doesn't set a size, so any size is fine." | The reviewer's expectation comes from what they merge, not the doc; an off-shape PR costs extra review work before it can be read. |
| "One big PR is less overhead than three small ones." | Above the house's churn tail it is the *reviewer's* overhead that spikes — the 1000+ LOC tail is where oversize clearly bites; split to fit. |
| "Smaller is always better, so I'll shave it to nothing." | The buckets are fairly even across mid-ranges; the lever is *matching the median*, not minimizing. An underscoped change that omits needed tests is off-shape too. |

## RECEIPT

**Corpus measurement (local mirror of apache/solr PRs; observational).** Computed
over **3,510 MERGED apache/solr PRs** by [`tools/house-shape.py`](../../tools/house-shape.py),
the median shape of what merges:

| axis | value |
|---|---|
| median additions | +31 |
| median deletions | −13 |
| median churn (add+del) | 58 |
| median changed files | 4 |
| title starts with a JIRA key | 67.6% |
| median days-to-merge | 4.0 |

Churn distribution: ≤10 LOC — 815 PRs; 11–50 — 843; 51–200 — 871; 201–1000 — 716;
1000+ — 265.

**Reproduce it yourself** — the mirror command is in the tool's docstring, and its output
feeds the tool directly (both `gh`'s camelCase and the REST API's snake_case are read).
Run it against any house to get that house's numbers instead of Solr's; the corpus isn't
shipped because it's large and repo-specific. Don't take the table above on faith — a
12-PR slice of recent Solr merges lands at +54/−6, 5 files, 58.3% JIRA-key titles, 3.2 d,
so a small sample reads noisier but in the same place.

**Honesty labels (this is a correlation, not a proven lever):**
- **Shape of what merged.** This describes the shape the house actually merges; it is
  a CORRELATION, not proof that matching it CAUSES a merge.
- **Confound.** Bigger changes are both harder to review AND more likely to be
  genuinely complex or contested. A right-sized PR lowers review cost, but it does
  not make a wrong change right — the same discipline as discuss-in-issue-first's
  "faster, not more often".
- **Don't over-claim "smaller is always better".** The mid-range buckets are fairly
  even (843–871 across 11–200 LOC); only the 1000+ tail (265 PRs) is where being
  oversized clearly bites.

## Lifecycle

- **Signals it worked:** review focuses on the change itself, not on its size or
  packaging; no "please split this" or "add the JIRA key" round-trip; time-to-first-
  review in line with the house median.
- **What to log on a misfire:** a PR that fit the revealed shape but still stalled on
  size/packaging, or a house where the median mispredicted the reviewer's ask.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** retire for a repo if its merged-PR shape can't be queried, or
  if the house explicitly documents a different expected shape than it actually
  merges (follow the documented one there).
- **Relates to:** pairs with discuss-in-issue-first — that one is *when* to talk,
  this one is *what shape* to submit. Both are "fit the house".
