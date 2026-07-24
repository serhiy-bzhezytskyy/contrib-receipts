# contrib-receipts

Rules and Claude Code skills for fixing an issue in **someone else's repository** — a repo with its own
conventions, its own review culture, that accepts outside contributors. Each rule is backed by a **receipt**:
a real, linked, merged pull request where the practice earned its keep.

> Bring help, not noise.

## WHY

AI made writing plausible code and plausible comments nearly free. In someone else's repo that shifts the
whole cost onto the maintainer: reading, verifying, and disproving contributions they didn't ask for. The
bottleneck is no longer *generating* a change — it's *earning the reviewer's trust* that the change is real,
scoped, and won't waste their scarce time.

So the goal of every skill here is one thing: **bring help (true value), not noise.** A practice earns a place
in this repo only if it helps a contribution land as help rather than get filed as noise — and only if I have a
receipt that it did.

[`PRINCIPLES.md`](PRINCIPLES.md) states this in one page and maps each *trust signal a skill sends* to the skill that
sends it — the "why" the skills hang off.

## WHAT

This is guidance for an **outside developer working with Claude Code** in a repo they don't own. Not limited to
open source — the same shape applies to inner-source and any repo that takes external contributors — but every
receipt here is from open source (Apache Solr / Lucene / Jetty), so that's what I can honestly stand behind.

It is a small **workflow** that invokes skills at the right moment, with two things a generic checklist misses:
- a **front gate** — read and obey the house's *own* conventions and tooling before you touch anything;
- a **learning loop** — after each use, record what worked / misfired / went stale (a LEDGER), and sharpen the
  skill. The skills are meant to be *lived in and corrected*, not frozen advice.

## HOW

The skills (each with a receipt where it earned its keep) live in **[`skills/README.md`](skills/README.md)** —
a single phase-indexed inventory (front-gate → contribute → submit → follow-up), each row naming the skill, its
scope, and its receipt. That file is the one source of truth for the inventory; this README does not duplicate
the table so the two can't drift.

Every skill file carries a `## Lifecycle` section (signals it worked, what to log on a misfire, when it's dead,
what it overlaps) and feeds [`LEDGER.md`](LEDGER.md) — the wrong-answers log, misfires kept next to the wins.
The skills are meant to be lived in and corrected, not frozen.

## Two honest receipt classes

Not every skill's value shows up as a merged diff. There are **two distinct, honest tiers of receipt** — kept
clearly labeled so sourcing and communication skills can be added later without diluting the merge bar:

- **MERGE-receipt** — a real, linked, *merged* pull request where the practice earned its keep. This is the
  strictest bar and it stays absolute for execution/etiquette skills.
- **SOURCING-receipt** — a method that *demonstrably found or delivered real value* even before any PR merged:
  a discovery method that surfaced real bugs, or a navigation/communication move a maintainer visibly acted on.
  "This method found 3 real issues" and "I handed a maintainer the map he asked for" are receipts of a
  different, legitimate kind than "this PR merged."

The two are not interchangeable: a SOURCING-receipt never substitutes for a MERGE-receipt on an execution skill.
It only opens the door to skills whose whole value is *finding where the help is* or *communicating it well*.

## Honest status

This is early — roughly my first month contributing to these projects. It is a **living, growing** tool, not a
finished framework: it holds open questions and hypotheses as openly as answers (see below). Some claims here
are backed by numbers measured across ~18k Solr + ~16k Lucene issues; some are single receipts; some are still
untested. Each is labeled.

## Open questions / hypotheses

- **issue-first vs cold PR** — measured on Solr: prior issue discussion made a PR land *faster* (median 3.4 vs
  5.8 days), not more often. So: discuss first to move faster, not to be accepted.
- **review cycles** — more review comments correlated with *higher* merge rate, not lower. "Minimize back-and-
  forth" would be the wrong advice.
- **PR size** — no general "small merges better" effect in the data; only mega-PRs (1k+ churn) clearly merge
  worse.
- **reviewer styles** — "merge after an unanswered tag" is a *project* culture pattern (~66% on Solr), not an
  individual trait; tailor by repo + change-type, not by person.

Each skill declares its own `scope` (e.g. `apache/solr`, or `general`) — so where a practice is
repo-specific vs broadly applicable is visible from the skill itself, not claimed up front here.

## License

MIT.
