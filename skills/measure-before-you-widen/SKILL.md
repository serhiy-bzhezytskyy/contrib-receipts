---
name: measure-before-you-widen
description: >
  A fix has landed in one component, and a second component calls the same routine,
  so it looks like it has the same defect. Do NOT widen on the strength of the
  reading: measure the second component on the same axis as the first — same input
  or corruption method, same outcome buckets, both results reported side by side —
  and let the numbers decide. The structure around a shared call decides the
  exposure, not the call itself, and the measurement usually finds something the
  reading missed. Use when about to extend a fix, a format change, or a hardening
  pass to a neighbouring component "because it's the same problem". Trigger terms:
  same vulnerability, also affected, extend the fix, third commit, consistency
  argues for, while we're here, same code path.
scope: general
principle: ../../PRINCIPLES.md
---

# Measure before you widen

## Purpose

Having fixed something in one place, the eye finds the next place that calls the same
routine and the mind supplies "same defect". That inference is cheap and often wrong,
and acting on it costs the most expensive kind of change — a second format version, a
second public API adjustment — for a problem that may not exist there. Measuring the
candidate first is a few minutes of work that either produces the evidence a reviewer
will ask for, or saves the change entirely. Either outcome is worth more than the
assertion, and the probe itself puts you inside code you had no reason to open.

## When to use

- A fix has landed and a neighbouring component shares the call, the parser, the
  offset arithmetic, or the file layout.
- Someone (including you) says "consistency argues for doing both".
- You are about to write "the same problem exists in X" in a PR body or an issue.
- A third commit is queued behind two that measured well.

## When NOT to use

- The change is mechanical and carries no risk — a renamed symbol, a corrected
  comment, a javadoc fix. Measuring a typo is theatre.
- The neighbour is *identical* code, not merely similar: a copied file, a generated
  variant. Then it is the same defect by construction, and the work is deduplication.
- The candidate cannot be measured without building the fix first. Say that plainly
  rather than pretending a number exists.

## The practice (checklist)

- [ ] **Re-run the original measurement** on the component you already fixed, so the
      baseline is in the same units, from the same harness, on the same day.
- [ ] **Run the identical method** on the candidate: same input or corruption technique,
      same sampling, same outcome buckets. A different method produces a number that
      cannot be compared, which is worse than no number. *Done when* you could describe
      the two runs in one sentence without an "except" in it.
- [ ] **Report both together**, in one table. A figure without its comparison is not
      evidence for or against widening.
- [ ] **State the sampling limits in the same breath** — corpus, fraction of positions
      covered, technique, what is classified and what is not. A measurement that refuses
      a change must be as honest as one that supports it.
- [ ] **If it refuses, keep what the probe found.** Being inside the candidate's code
      with corrupted inputs surfaces defects that reading it does not.
- [ ] **Put the refusal in the PR text**, not only in your notes: a reviewer benefits
      from knowing the neighbour was checked and why it was left alone.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "It's obviously the same code path." | The call is the same; the exposure is decided by what fraction of the file is payload, whether the risky branch is taken at all, and whether the data is read whole or one record at a time. Measured: 0.6% vs 48.5% on the same corruption method, and not one of the candidate's exceptions came from the shared routine. |
| "Consistency is its own argument." | Consistency across formats is worth something; a format version bump nobody needs is worth less. |
| "I'll measure after, to confirm." | A measurement run after the change is written is a measurement you are motivated to read favourably. |
| "It's only a small extra commit." | It is a second on-disk format version, a second back-compat surface, and a second thing a reviewer has to hold in their head. |
| "The reading is enough — I know this code." | The reading said "same LZ4 vulnerability". The premise was wrong on three counts the code does not advertise: the candidate is largely metadata (0.05 of the raw term bytes), it compresses only when four conditions hold at once, and a full scan exposes a discrepancy that a per-record read returns silently. |

## RECEIPT

`apache/lucene`, 2026-08-02. A per-chunk CRC32C had just landed for stored fields
(`.fdt`) and term vectors (`.tvd`). Blocktree (`.tim`) also calls `LZ4.decompress` on
bytes read from disk, so it was asserted to carry "the same vulnerability" and a third
format change was queued.

Measured instead — 320 single-byte corruptions across a 67 KB `.tim` of 20,000 long
shared-prefix terms, against the same method on `.fdt`:

| outcome | `.tim` | `.fdt` |
|---|---|---|
| silently wrong result returned | **0.6%** | **48.5%** |
| no effect | 93.4% | 5.2% |
| `ArrayIndexOutOfBoundsException` | 3.1% | 36.1% |

Two orders of magnitude apart, and **not one of the `.tim` exceptions came from LZ4**.
The premise was wrong: `.tim` is largely metadata — its size is 0.05 of the raw term
bytes — blocktree compresses suffixes only when four conditions hold at once, and a
full term scan exposes a discrepancy that a per-document read returns silently. The
third format change was dropped.

The same sweep put two of the 320 samples inside `LowercaseAsciiCompression#decompress`,
where exception offsets are accumulated from the data and used to index the output with
no bound check — an `ArrayIndexOutOfBoundsException` where an `IOException` belongs, in
a class there had been no reason to open. Fixed test-first, mutation-checked, and
shipped as the third commit after all: a different one.

⇒ The measurement refused the proposal and produced a better one. The reading would
have delivered the opposite of both.

Limits stated in the PR alongside the numbers: one corpus, 320 of 67,453 positions
(0.5%), all eight bits inverted rather than one, first exception only. The defensible
claim is "two orders of magnitude smaller here, and no basis for a format change" —
not "safe".

## Lifecycle

- **Signals it worked:** the numbers either give a reviewer the comparison they would
  have asked for, or they close the question before the change is written; and the
  probe finds something in the candidate you were not looking for.
- **What to log on a misfire:** a measurement whose method differed between the two
  components, so the comparison was meaningless; or a refusal reported as "safe"
  rather than as "smaller on this corpus". Record it in
  [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** none foreseeable, though the *cost* of widening is what makes
  it worth measuring — for changes with no back-compat or API surface, the reading may
  be enough.
- **Relates to:** [state-the-noise-floor](../state-the-noise-floor/SKILL.md) — both
  refuse a claim that has no measurement behind it. Adjacent to
  [one-fix-one-pr-then-coordinate](../one-fix-one-pr-then-coordinate/SKILL.md): the
  measurement often decides how many PRs there are.
