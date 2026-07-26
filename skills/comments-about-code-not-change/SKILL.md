---
name: comments-about-code-not-change
description: >
  Source comments explain what the DELIVERED code does, in the present tense — never
  the change history: no issue/PR numbers, no maintainer @handles, no "the previous
  code did X", no "confirmed by", no "aligned per". Change-narrative in source is a
  top AI tell, and it rots in the codebase; that context belongs in the PR body and
  commit message. Grep the diff's added comment lines before every push. Use before
  committing any code change to a repo you don't own. Trigger terms: code comment,
  "// previously", issue number in comment, @handle in source, over-explaining,
  AI smell, delivered documentation.
scope: general
principle: ../../PRINCIPLES.md
---

# Comments about the code, not the change

## Purpose

A source comment is read by someone opening the file cold in a year — not by
someone following your PR. So it must describe what the code *does and why*, in the
present tense, as if it were always this way. The moment a comment references the
change that produced it — an issue number, a PR number, a maintainer's @handle,
"the previous code did X", "close-enough mistake", "aligned per #NNNN" — it stops
being documentation and becomes change-narrative that belongs in the PR and commit,
where it is contextual and doesn't rot. Maintainers across projects call this out
as a top AI tell; it's a cheap, high-frequency source of "this reads like slop".

Exception: a **test** that guards a specific regression MAY cite the issue number in
a comment — that links the test to what it protects, and projects do this. Even
there, keep it to the ticket ref, not a change-narrative or an @handle.

## When to use

- Before committing any code change to a repo you don't own.
- Any time you write a comment that only makes sense to someone reading the PR.

## When NOT to use

Docstrings/comments that explain *behavior* — even long ones — are fine; this only bans change-narrative (issue#, @handle, "previously"), not thorough documentation.

## The practice (checklist)

- [ ] Write comments in the **present tense**, describing behavior and the reason
      for it — as if the code were always this way.
- [ ] Keep OUT of source: issue numbers, PR numbers, maintainer @handles,
      "confirmed by X", "the previous code did Y", "aligned per", "close-enough".
- [ ] Before pushing, **grep the diff's added (`+`) comment lines** for `#[0-9]`,
      `@[a-z]`, "previously", "used to", "was a mistake", "aligned", "confirmed by".
      *Done when* the grep has been run over the real diff and returns nothing, or
      every hit is a regression test's ticket ref (the one exception below).
- [ ] Move any change-context you find to the PR description / commit message.
- [ ] Test-only exception: a regression test may cite its ticket ref, nothing more.

Treat the pre-push comment grep as **mandatory**, not a "remember to" — this is a
pattern people regress on across projects even after learning it.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "One `// see #NNNN` is harmless." | It's the #1 AI tell; a reviewer greps the diff and the whole PR reads as slop. |
| "This context is useful — the reader should know what changed." | The reader opens the file cold in a year; change-context rots. It belongs in the PR body and commit, where it stays contextual. |
| "It's a test, so an issue ref is fine everywhere." | Only a regression test may cite its ticket ref — and only the ref, never an @handle or a change-narrative. |

## RECEIPT

**A Solr committer, apache/solr PR #4632** (`corpus-solr-prs/pr-solr-4632.json`, review
comment) — verbatim:

> "this wording here is indicative of a bug fix in the process of development but
> isn't useful in the delivered documentation. Of course 'not just the first'. AI
> loves to do this."

**Cross-project confirmation (journal) — a universal OSS norm, not one reviewer's
taste:**
- **Solr** — AGENTS.md §52: "changes shouldn't have code comments communicating the
  change."
- **Jetty** — a maintainer's first review comment on PR #15435: "Please remove this
  comment as the git history should be all the context needed."
- **OpenSearch** — #17140: an `advance()` comment shipped with "aligned per #17140…
  confirmed by @[maintainer]"; it was the only issue#/@handle comment in the whole file
  (zero precedent), rewritten to terse present-tense behavior.

## Lifecycle

- **Signals it worked:** no reviewer flags a comment as change-narrative or "AI
  loves to do this"; comments still make sense read cold, out of PR context.
- **What to log on a misfire:** the exact comment text a maintainer flagged and the
  file — recurring offenders (issue#, @handle, "previously") sharpen the grep list.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** none foreseeable; it's a stable cross-project norm.
- **Relates to:** sibling to verify-before-a-committer-comment (both are "don't put
  unverified/irrelevant narrative in front of a maintainer"). This one governs source
  comments specifically, not the PR text.
