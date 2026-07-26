---
name: read-the-houses-agent-file-first
description: >
  Before applying ANY skill in this repo, look for the house's own agent instructions
  — AGENTS.md (or CLAUDE.md, or any other agent-instruction file the house ships) —
  read it, and treat it as the higher authority. Where the house's file contradicts a skill
  here, the HOUSE wins: these skills are cross-house defaults, its file is local law.
  A house that ships an AGENTS.md has told you exactly how it wants agent-assisted work
  done; ignoring it while following a generic rulebook is the fastest way to read as
  noise. This is the meta-skill that runs first, before the rest of the front-gate.
  Use when starting on any repo you don't own, before invoking any other skill here,
  or when two rules conflict. Trigger terms: AGENTS.md, CLAUDE.md, agent-instruction
  file, agent instructions, house conventions, which rule wins, precedence.
scope: general
principle: ../../PRINCIPLES.md
---

# Read the house's agent file first

## Purpose

This repo is a set of *cross-house defaults* — practices that travel well across the
repos I've contributed to. But a house that publishes its own agent instructions has
already answered "how should an assistant behave here?" more specifically than any
general rulebook can. Its file is local law; these skills are only the fallback where
no local law exists. The discipline is one of humility about precedence: read the
house's AGENTS.md / CLAUDE.md first, follow it, and where it disagrees with a skill
here, follow the house — then log the conflict so the skill learns the house is not
alone in doing it that way.

Skipping this is a compounding error: you don't just miss one instruction, you apply
a generic rule *against* an explicit local one, which reads worse than having no
process at all. The house told you, in writing, and you brought a template instead.

## When to use

- First thing on any repo, before invoking any other skill here.
- When two rules seem to conflict and you need to know which wins (the house does).
- When a maintainer references "our AGENTS.md" / "the conventions" in review.

## When NOT to use

If the house ships no agent file at all, there's nothing to defer to — fall back to
these skills as the defaults they are (and to obey-the-houses-own-tooling for the
build/generator conventions, which is about tasks, not agent instructions).

## The practice (checklist)

- [ ] Look for the house's agent file: `AGENTS.md` first, then `CLAUDE.md` or any
      other agent-instruction file it ships, then `CONTRIBUTING`/dev-docs.
- [ ] Read it fully before invoking any other skill — it may set the build gate, the
      comment policy, the PR shape, the sign-off, all house-specifically.
- [ ] **Where it contradicts a skill here, follow the house.** These skills are
      defaults; its file is local law. Note the conflict, don't silently override it.
- [ ] Quote or point to the specific house rule when you act on it, so a reviewer
      sees you read their file (not a generic checklist).
- [ ] Log any skill↔house conflict in the LEDGER — a recurring one means the skill's
      advice is house-specific and should say so.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "I have a solid general rulebook, I don't need to read theirs." | A house that shipped an AGENTS.md told you exactly how it wants agent work done; applying a generic rule against an explicit local one reads worse than no process at all. |
| "CONTRIBUTING.md is enough, I'll skip AGENTS.md." | Strict houses put the agent-specific instructions (generator commands, comment policy) in AGENTS.md, not CONTRIBUTING — a maintainer named "AGENTS.md" by file when flagging bypass. |
| "My skill says X, so I'll do X even though their file says Y." | These skills are cross-house defaults; the house's file is local law and wins. Doing X against an explicit Y is the exact "didn't read our rules" signal. |

## RECEIPT

**apache/solr #4612 — a maintainer names the agent file by name, verbatim:**

> "AI is not using the Gradle tasks we've built & documented (including AGENTS.md) to
> create them. I can tell because the file doesn't match the pattern that tool
> creates."

The miss wasn't only skipping a tool — it was not reading the house's AGENTS.md,
which documented that tool. Reading it first would have pre-empted the bounce.

**Solr AGENTS.md §52 — the house's file carries rules beyond tooling.** It states
that "changes shouldn't have code comments communicating the change" — a
comment-policy rule that lives in the agent file, not just build commands. Proof that
AGENTS.md is a broad contract to read whole, not a command index to skim; it is the
source `comments-about-code-not-change` defers to.

## Lifecycle

- **Signals it worked:** no maintainer has to point you at "our AGENTS.md"; your PRs
  visibly follow house-specific rules a generic contributor would miss.
- **What to log on a misfire:** the house rule you missed or overrode, which skill
  here it conflicted with, and how the house wanted it. Record it in
  [`LEDGER.md`](../../LEDGER.md) — a repeated conflict means that skill should carry a
  house-specific note.
- **Death criterion:** none — deferring to the house's own instructions is a stable
  principle; only the file's name/location changes as conventions evolve.
- **Relates to:** the front-gate sibling of obey-the-houses-own-tooling (that one is
  the build/generator gate; this one is the agent-instruction contract that often
  points at it) and sign-off-the-house-way (another house-specific rule to read up
  front). This skill sets precedence over all the others.
