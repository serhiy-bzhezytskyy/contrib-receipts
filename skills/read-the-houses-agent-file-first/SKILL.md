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
      comment policy, the PR shape, the sign-off, all house-specifically. *Done when*
      you have checked it for each of those four and can say which it sets and which
      it leaves to these defaults.
- [ ] **Where it contradicts a skill here, follow the house.** These skills are
      defaults; its file is local law. Note the conflict, don't silently override it.
- [ ] Quote or point to the specific house rule when you act on it, so a reviewer
      sees you read their file (not a generic checklist).
- [ ] **Follow the file's own pointers before concluding it is silent on something.**
      An agent file is often an index: it may defer the real policy to
      `CONTRIBUTING`, `dev-docs/`, or a foundation-level page. "AGENTS.md doesn't
      mention X" is not "the house has no rule about X" until you've read what it
      points at. *Done when* you have followed every document it names.
- [ ] **Never attribute a rule to the house without a quote and a path.** If you
      cannot cite file and line, say "my own preference" or "unverified" instead.
      Inventing a house rule — usually a stricter one than exists — is worse than
      having no rule, because it is self-reinforcing and never meets evidence.
- [ ] **Separate what the house *wrote* from what its members *do*.** Both are facts,
      they often differ, and the gap is informative. One `git log --grep` over a year
      of the default branch settles "what do they actually do" in a single command.
- [ ] Log any skill↔house conflict in the LEDGER — a recurring one means the skill's
      advice is house-specific and should say so.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "I have a solid general rulebook, I don't need to read theirs." | A house that shipped an AGENTS.md told you exactly how it wants agent work done; applying a generic rule against an explicit local one reads worse than no process at all. |
| "Either file is enough on its own — I'll read one and skip the other." | They carry different things and each points at the other. Strict houses put agent-specific instructions (generator commands, comment policy) in AGENTS.md, not CONTRIBUTING — a maintainer named "AGENTS.md" by file when flagging bypass. And Solr's AGENTS.md line 3 defers its genAI policy *out* to `dev-docs/`. Reading one and stopping is how I asserted for weeks that a policy didn't exist. |
| "My skill says X, so I'll do X even though their file says Y." | These skills are cross-house defaults; the house's file is local law and wins. Doing X against an explicit Y is the exact "didn't read our rules" signal. |
| "I know the convention here, I don't need to cite it." | Then you cannot tell your own preference from the house's rule. I wrote "Apache convention is that the human contributor owns the commit (AGENTS.md says the same)" — neither clause was true, and it shaped decisions for weeks because it sat in my notes as established fact. No quote and path ⇒ say "my preference" or "unverified". |
| "The written policy says X, so contributors do X." | Written policy and observed practice are different measurements, and the gap is informative. The same project asked only for a disclosure line in the PR description, while three of its committers went further and named the AI model in a commit trailer. Measure both; one `git log --grep` settles the second. |

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

**Counter-receipt — the file is also an INDEX, and I asserted a rule the house
contradicts (2026-07-27).** `AGENTS.md` line 3 points onward: *"Also see
`dev-docs/how-to-contribute.adoc` for some guidelines when using genAI to contribute to
Solr."* I never followed that pointer, and instead wrote in my own notes that "Apache
convention is that the human contributor owns the commit (AGENTS.md says the same)" as
grounds for stripping AI co-author trailers. Measured against source:

- The document `AGENTS.md` actually points at carries a written policy asking the
  **opposite of silence**: *"For major AI-assisted contributions, disclose the use of AI
  tools in your PR description"*, and in its do-not list, no *"AI generated code without
  human review and transparent declaration."*
- Practice went further than the policy: **12 commits on the default branch in ~18
  months carry a `Co-authored-by: <AI model>` trailer, from three different
  committers** — including the person who wrote the AI policy. Widen the pattern to
  Copilot-class trailers and it is **38 commits from six authors**, so the gap between
  the written policy and observed practice is larger still. Count per-commit, and state
  your pattern — `grep -c` over `git log --format='%B'` counts *lines*, and the number
  moves with the pattern:
  `git log --since=18.months --format=%H origin/main | while read h; do git log -1 --format=%B $h | grep -qiE 'co-authored-by:.*(claude|anthropic)' && echo $h; done | wc -l`
- The foundation's own guidance recommends a different token entirely (`Generated-by:`)
  and is silent on AI co-authorship — and that token appears **zero** times in the repo.

Three separate facts — what the foundation recommends, what the house wrote, what its
committers do — and I had collapsed all three into one invented convention that matched
none of them. The underlying preference (a contributor choosing not to add AI trailers)
was legitimate and unchanged; what failed was laundering a preference into house
authority without a citation. Note the direction: the invented rule was *stricter* than
reality, which is the bias to expect — conservatism feels safe and is still wrong.

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
