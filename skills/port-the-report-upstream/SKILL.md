---
name: port-the-report-upstream
description: >
  Use when the repo you found a bug in is a fork or port of another project and you
  are asking whether the original still has the same bug — or whether to report it
  there too. A port inherits its parent's bugs, so a defect found downstream is
  probably still live upstream, and vice versa. Check it, then report in both houses
  with each artifact cross-referencing its counterpart. But re-derive every anchor
  against the OTHER repo's own origin/main: line numbers drift, subcommands get
  deprecated, issue numbers autolink to the wrong project, label sets differ, and
  one house requires a DCO sign-off the other doesn't. Never copy a claim across a
  fork. Trigger terms: fork, port, upstream, downstream, vendored, same code,
  inherited bug, does upstream have this, does the original have this, is this
  fixed upstream, report it upstream too, cross-reference.
scope: general
principle: ../../PRINCIPLES.md
---

# Port the report upstream (but re-verify every anchor)

## Purpose

A port inherits its parent's bugs. Fixing one downstream and stopping there leaves
the defect live for the larger user base, and leaves the two projects diverging on a
file that was identical — which is a cost the downstream maintainer will pay at the
next sync. Reporting in both houses doubles the value of one investigation for near
zero extra investigation.

The trap is that it feels like copy-paste, and it is not. Everything *about* the code
differs even when the code doesn't: line numbers, the name of the subcommand you tell
people to run, which labels exist, whether commits need a sign-off, and — worst,
because it looks like it worked — issue numbers, which silently autolink to whatever
issue happens to have that number in the repo you're posting to. A ported report with
stale anchors is worse than no report: it tells the second maintainer you didn't
actually look at their code.

## When to use

- The repo you found a bug in is described as a port/fork of another project, or you
  recognize the file structure.
- You've landed (or are about to land) a downstream report and the offending file
  looks unmodified from its origin.
- Direction is symmetric: upstream→downstream is the same job.

## When NOT to use

- The two copies have genuinely diverged at the site you're reporting — then it's a
  new investigation in the second repo, not a port. Diff first.
- The upstream project is dead/archived, or the fork is a hard divergence nobody
  syncs.
- You haven't finished the downstream report yet. Land the evidence where you ran it
  first; the second report cites the first.

## The practice (checklist)

- [ ] **Diff the actual file, both from `origin/main`.** Not from your working
      branch — a clone you've been fixing in is checked out somewhere else.
      `git show origin/main:<path>` on both sides, then `diff`. Quote the diff in the
      report; "byte-identical apart from the import module name" is a claim a
      reviewer can check in one command.
- [ ] **Reproduce it in the second repo by running it, not by reading it.** The
      defect existing in the source is a hypothesis until the second project's own
      test run and CLI show it. Bring the same real-method-plus-control discipline.
- [ ] **Re-derive every anchor against the second repo's `origin/main`:**
      - **line numbers** — they drift; state each one only after reading it there;
      - **command/subcommand names** — the one you used downstream may be deprecated
        or renamed upstream, so your repro instructions would fail for a maintainer;
      - **issue/PR numbers in prose** — safe only if they belong to the repo you're
        posting *in*. Verify each resolves to the expected title, or use SHAs. A
        number that autolinks to a nonexistent or unrelated issue in the target repo
        is the most visible possible tell.

      *Done when* every anchor in the draft has been re-read in the second repo —
      count them and account for each, rather than checking the ones you remember.
- [ ] **Re-read the second house's contract**, don't assume it matches:
      - **labels** — an issue template can declare a label the repo doesn't have
        (downstream) while the other repo does (upstream);
      - **sign-off** — DCO `Signed-off-by` required in one house, license-by-
        submission in the other;
      - **CONTRIBUTING order** — issue-first vs PR-first can differ.
      (This is [sign-off-the-house-way](../sign-off-the-house-way/SKILL.md) and
      [read-the-houses-agent-file-first](../read-the-houses-agent-file-first/SKILL.md)
      applied a second time, from scratch. Two houses, two contracts.)
- [ ] **Cross-reference every artifact in both directions** — each issue and PR names
      its counterpart as "same code, found downstream/upstream", so either maintainer
      sees the whole picture and can tell the fixes won't diverge.
- [ ] **Keep the numbering parallel if you can.** Creating in the same defect order
      in both repos so #A↔#X, #B↔#Y line up costs nothing and makes every
      cross-reference readable. Worth more than any other ordering rationale.
- [ ] **Say where the provenance claim came from.** "Inherited, not introduced by the
      port" is load-bearing for the downstream reviewer — back it with the diff, and
      if you earlier guessed the opposite, correct it in the open rather than
      quietly.
- [ ] **Label CI evidence honestly per house.** One project may run checks for
      outside contributors immediately (green is *observed*); the other may hold
      workflows at `action_required` pending maintainer approval (green is only your
      *local* suite — say so). Per
      [verify-before-a-committer-comment](../verify-before-a-committer-comment/SKILL.md).

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "Same file, so the same report applies." | The *code* is the same; nothing else is. The `aggregate` dispatch is line **1186** upstream and **1215** downstream — a 29-line offset in files whose relevant function is byte-identical. |
| "I'll reuse the repro command from the downstream report." | Downstream's subcommand was `execute-test`; upstream has it in `DEPRECATED_SUBCOMMANDS` and expects `run`. A maintainer following your instructions would hit a deprecation path, not the bug. |
| "The issue numbers I cited are fine, it's the same project family." | They autolink per-repo. Citing `#882`/`#939` upstream resolved correctly; the same numbers downstream would have pointed at issues that don't exist in `apache/solr-orbit`. Use SHAs where numbers aren't native. |
| "The issue template lists the labels, so they exist." | Downstream's `bug_template.yml` declared `untriaged`; the repo has no such label. Upstream *does*. Check the label set, not the template. |
| "My commits are already fine, they passed downstream." | Upstream gates on DCO; downstream doesn't. Same commits, one house rejects them. Re-read the sign-off contract per repo. |
| "It's clearly port-specific, no need to check upstream." | I asserted exactly this about the unconditional blocker — a guess in a document meant to be evidence. Reading upstream's `aggregator.py:169` refuted it: identical wrong attribute. The guess would have understated the blast radius by an entire user base. |
| "I'll just note the equivalence and let them port it." | You already have the fix and the test; the second maintainer has neither, plus the burden of translating. Porting the patch is minutes when the file is identical. |

## RECEIPT

***SOURCING-receipt*** — **one investigation, two projects, 12 artifacts.** Verified
via `gh` 2026-07-25: all OPEN; upstream PRs show 3 × SUCCESS checks (Code-Diff-
Analyzer, Code-Diff-Reviewer, DCO) each.

Three `aggregate` defects were found downstream in **apache/solr-orbit** by finishing
a real benchmark campaign ([use-the-tool-for-its-purpose](../use-the-tool-for-its-purpose/SKILL.md)),
then established as **inherited** — not introduced by the port — and reported and
fixed upstream in **opensearch-project/opensearch-benchmark** as well:

| defect | solr-orbit | OpenSearch Benchmark |
|---|---|---|
| null metrics crash metric reduction | [#55](https://github.com/apache/solr-orbit/issues/55) → [#58](https://github.com/apache/solr-orbit/pull/58) | [#1093](https://github.com/opensearch-project/opensearch-benchmark/issues/1093) → [#1096](https://github.com/opensearch-project/opensearch-benchmark/pull/1096) |
| unconditional failure — reads a test-run attribute that doesn't exist | [#56](https://github.com/apache/solr-orbit/issues/56) → [#59](https://github.com/apache/solr-orbit/pull/59) | [#1094](https://github.com/opensearch-project/opensearch-benchmark/issues/1094) → [#1097](https://github.com/opensearch-project/opensearch-benchmark/pull/1097) |
| `--workload-path` parity gap with `run` | [#57](https://github.com/apache/solr-orbit/issues/57) → [#60](https://github.com/apache/solr-orbit/pull/60) | [#1095](https://github.com/opensearch-project/opensearch-benchmark/issues/1095) → [#1098](https://github.com/opensearch-project/opensearch-benchmark/pull/1098) |

**The provenance claim, checked not asserted** — both files from `origin/main`,
295 lines each:

```console
$ diff <(git -C solr-orbit show origin/main:solrorbit/aggregator.py) \
       <(git -C opensearch-benchmark show origin/main:osbenchmark/aggregator.py)
6,8c6,8
< from solrorbit.metrics import FileTestRunStore, TestRun
---
> from osbenchmark.metrics import FileTestRunStore, TestRun
[...import module name only...]
```

Byte-identical apart from three import lines. So every downstream conclusion
transfers — and the fixes did too, applied with only the module name rewritten.

**What re-verification caught before posting** (the clone was sitting on a fix
branch, which is what prompted re-deriving everything against `origin/main`):

- the `aggregate` dispatch line is **1186** upstream, **1215** downstream;
- the subcommand is **`run`** upstream — downstream's `execute-test` is in upstream's
  `DEPRECATED_SUBCOMMANDS`, so the ported repro instructions would have been wrong;
- `#882`/`#939`/`#638`/`#692` are safe to cite upstream (each verified to resolve
  with the expected title) and would have autolinked to nonexistent issues
  downstream — SHAs used there instead;
- `untriaged` exists upstream, not downstream, despite downstream's template
  declaring it;
- upstream requires DCO sign-off, downstream doesn't;
- and the provenance guess itself was wrong: I had written that the unconditional
  blocker "appears port-specific." Upstream's `aggregator.py:169` carries the
  identical wrong attribute. Corrected in the open.

**Also the same blind spot in both houses:** the aggregator suite never constructs a
real test-run object, so 1099 tests downstream and 1422 upstream passed over a command
that could not run once.

Baseline discipline per repo: each fix is one commit off that repo's own `origin/main`
(`edb3d03e` / `a5880562`), full suite compared to that repo's own baseline
(1422 → 1423/1424 upstream), lint clean by that repo's own config.

## Lifecycle

- **Signals it worked:** both maintainers engage; neither asks "does this apply to
  us?"; no correction of a line number, command name, or autolink in either thread.
- **What to log on a misfire:** which anchor was stale, and whether it came from
  copying the sibling report or from a clone that wasn't on `main`.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** if the two copies diverge enough that the diff is no longer
  small, this stops being a port and each report is its own investigation.
- **Relates to:** sourced by
  [use-the-tool-for-its-purpose](../use-the-tool-for-its-purpose/SKILL.md);
  re-applies [sign-off-the-house-way](../sign-off-the-house-way/SKILL.md),
  [read-the-houses-agent-file-first](../read-the-houses-agent-file-first/SKILL.md)
  and [match-the-house-shape](../match-the-house-shape/SKILL.md) from scratch in the
  second house; the anchor re-derivation is
  [verify-before-a-committer-comment](../verify-before-a-committer-comment/SKILL.md)
  applied to your own ported text.
