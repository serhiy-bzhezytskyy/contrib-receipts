---
name: obey-the-houses-own-tooling
description: >
  Before generating any project artifact a repo has a generator for (changelog,
  formatted source, build/lock files, license lists), create it with the repo's OWN
  documented tooling — never hand-craft a file a task owns. A maintainer detects
  careless or AI-assisted work by tool BYPASS, not by code style: a hand-made file
  doesn't match the pattern the generator produces. Use before writing any file the
  project ships a task/command for, and before saying "done". Trigger terms:
  changelog, AGENTS.md, gradle task, tidy, formatter, generated file, lock file,
  "it compiles and tests pass".
scope: general
principle: ../../PRINCIPLES.md
---

# Obey the house's own tooling

## Purpose

Every mature repo owns some of its files through generators: a changelog task, a
code formatter, a dependency-lock command, a license-list generator. When you
hand-write one of those files instead of running the tool, the output almost
never matches — spacing, ordering, category names, section shape all drift. To a
maintainer that mismatch is a loud signal, and the most defensible AI-detection
vector they have: it isn't about how the *code* reads, it's that you bypassed the
house's own machinery. Compliance with the repo's tooling is what makes
agent-assisted work acceptable in a strict house.

The same root produces a second rule: "it compiles and my tests pass" is a
checkpoint, not "done". The project defines "done" — encoded in its gate task
(`check`, `verify`, lint, license/lock validation). Skipping it ships the miss to CI.

## When to use

- You are about to produce a file the repo has a task for: changelog entry,
  formatted source, build config, dependency lock, license/NOTICE list.
- You are about to say a change is "done" or "validated".
- You matched a changelog/doc category or a title by hand instead of by convention.

## When NOT to use

The file has no generator or the repo ships no gate task — then there's no house pattern to match, and hand-authoring is simply how that file is made.

## The practice (checklist)

- [ ] **Read AGENTS.md first** (then CONTRIBUTING / dev-docs). It lists the exact
      commands — don't stop at CONTRIBUTING/README/CLAUDE.md; strict houses put the
      generator commands in AGENTS.md.
- [ ] **Never hand-craft a generated file.** If a task owns it (`writeChangelog`,
      the formatter, the lock command), run the task. If you already hand-made one,
      regenerate it with the task so it matches the pattern.
- [ ] **Match the house's conventions exactly** for anything you do write by hand:
      correct changelog `type` category, link the issue tracker (JIRA) not the PR
      when the house prefers it, write an informative summary not a terse title.
- [ ] **Run the repo's own gate before "done"** — the project's `check` / `verify`
      task plus formatter (`tidy`) plus the *full* dependency-lock command (run the
      documented commands together, not a convenient subset), not just compile + a
      few targeted tests. "Compiles + my tests pass" is a checkpoint, not the finish.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "It compiles and my tests pass — it's done." | The *house* gate (tidy / license / lock validation) defines done; skipping it just ships the miss to the reviewer's CI. |
| "I'll just hand-make this one file." | A hand-made file won't match the generator's spacing/ordering/categories — the most defensible AI-detection vector a maintainer has. |
| "Running the full lock/license regen is overkill for a small change." | The gate is the documented command *set*, not a convenient subset; a partial run leaves exactly the mismatch the tool exists to prevent. |

## RECEIPT

**A Solr committer, apache/solr PR #4612** (`corpus-solr-prs/pr-solr-4612.json`, review
comment) — the AI-detection-by-tool-bypass moment, verbatim:

> "I suspect you are using AI to create these files, and that AI is not using the
> Gradle tasks we've built & documented (including AGENTS.md) to create them. I can
> tell because the file doesn't match the pattern that tool creates. Same with your
> GJF upgrade."

Recovery (same PR, Serhiy): acknowledged the hand-creation and regenerated the
files with `writeChangelog` so they matched.

**The positive twin — the same Solr committer, apache/solr PR #4632** (`pr-solr-4632.json`), on a
changelog entry that *did* follow the house convention:

> "That's the best changelog entry I've seen in a long time; thank you!"

And on category/link conventions (`pr-solr-4612.json`):

> "this is undoubtedly a 'other' category change and not 'changed'";
> "When we have JIRA issues, we favor the JIRA issue instead of PR."

**The "done"-gate half (journal, Solr→Lucene-11 port):** a change reported "done +
validated" while the project's own gate then caught three mandatory steps compile
+ unit tests never surface — `tidy` (5 files not format-clean),
`validateConfigFileSanity` + `validateJarLicenses` failures, and the full
`updateLicenses resolveAndLockAll collectJarInfos --write-locks` regen of 74 files.

## Lifecycle

- **Signals it worked:** generated files match on first push; a maintainer stops
  flagging "this doesn't match our tool"; the house gate is green before review;
  positive convention feedback (the "best changelog" reaction).
- **What to log on a misfire:** which file you hand-made, which task owned it, and
  the exact mismatch the maintainer named — so the next run knows that generator
  exists. Record it in [`LEDGER.md`](../../LEDGER.md) (the #4612 row is the first).
- **Death criterion:** retire for a given repo only if it stops shipping
  generators/gate tasks (rare) — then the file just isn't tool-owned and this
  doesn't apply.
- **Relates to:** using the repo's own build system, reading AGENTS.md, and the
  AI-detection-by-tool-bypass insight. Absorbs the "run the repo's own done-gate"
  and "match the changelog/doc standard" lessons.
