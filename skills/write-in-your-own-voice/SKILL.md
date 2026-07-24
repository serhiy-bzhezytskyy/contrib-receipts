---
name: write-in-your-own-voice
description: >
  The PROSE you put in front of humans — PR body, issue text, review replies —
  should read as your own terse voice, not the generic-LLM register maintainers spot
  instantly ("comprehensive", "robust", "leverages", "this PR addresses the issue
  where…", over-hedged padding). AI-register prose gets flagged; house-voice prose
  lands. Cut the jargon, say what changed in one plain line, and match the house's
  short PR-body length; optionally few-shot from your OWN merged PRs to calibrate.
  Use when drafting any human-facing text on a repo you don't own. Trigger terms: PR
  body voice, AI tell, generic LLM prose, comprehensive/robust/leverages, press-
  release tone, write plainly, own voice.
scope: general
principle: ../../PRINCIPLES.md
---

# Write in your own voice

## Purpose

A maintainer reads a lot of PR bodies and issue text, and the generic-LLM register
is instantly recognizable: "comprehensive", "robust", "leverages", "seamless",
"this PR addresses the issue where…", and paragraphs of hedged padding around a
one-line change. That register reads as slop before the reviewer has looked at a
single line of the diff, and it costs you trust you have not spent yet. Prose in the
house's own plain voice does the opposite — it signals a human who did the work and
respects the reader's time.

This governs **human-facing prose** — the register of the text you write to people.
It is distinct from the sibling rule about source-code comments: the AI tell shows
up on two different surfaces, and this skill fights it in the prose.

## When to use

- When drafting a PR body, an issue, or a review reply on a repo you don't own.
- Any time a draft starts with "This PR addresses the issue where…" or leans on
  "comprehensive / robust / leverages / seamless / delve / it's worth noting".
- When you want a voice sample: pull your own merged PRs to calibrate before writing.

## When NOT to use

This is about human-facing PROSE; for whether an in-CODE comment should exist at all, that is comments-about-code-not-change.

## The practice (checklist)

- [ ] Cut the AI-jargon words: comprehensive, robust, leverages, seamless, delve,
      "it's worth noting", "this PR addresses the issue where…".
- [ ] Write what changed in one plain line — e.g. a real shipped title, "SOLR-3284:
      fix RemoteSolrException NPE when remoteError is null" (#4637), not "This PR
      addresses the issue where the null case was not being handled correctly".
- [ ] Match the house's PR-body length — short; don't pad a one-line fix into three
      paragraphs.
- [ ] Pull your own merged PRs as a voice sample when drafting:
      `gh search prs --author <me> --merged` — few-shot from text you actually wrote.
- [ ] Read it aloud — if it sounds like a press release or a product announcement,
      rewrite it plainer.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "A thorough, comprehensive PR body looks professional." | It reads as the generic-LLM register maintainers flag on sight ("AI loves to do this") — it spends trust before the diff is even read. |
| "More context in the body can't hurt." | Padding around a one-line change buries the point; the house voice is short, and a wall of hedged prose reads as slop. |
| "I don't have a voice sample to copy." | You do — your own merged PRs. `gh search prs --author <me> --merged` is a self-sourced, verifiable corpus, not borrowed advice. |

## RECEIPT

**Negative anchor — a Solr committer, apache/solr PR #4632**, on generated prose
that read as AI-filler — verbatim:

> "isn't useful in the delivered documentation… AI loves to do this."

This is the same maintainer signal that anchors comments-about-code-not-change for
*code comments*; here it is applied to the PR/issue **prose** register — the same
tell, a different surface.

**Positive twin — a Solr committer, apache/solr PR #4632**, reacting to a changelog
entry written in the house's own plain voice — verbatim:

> "That's the best changelog entry I've seen in a long time; thank you!"

House-voice prose lands; AI-register prose gets flagged.

**Few-shot half:** the author's own merged Solr PRs (e.g. #4632, merged) are the
self-sourced voice corpus — verifiable text you actually wrote, not borrowed advice.

## Lifecycle

- **Signals it worked:** no reviewer flags the PR body or issue text as AI-register /
  "AI loves to do this"; the prose reads as terse and human; a maintainer engages the
  change rather than the packaging.
- **What to log on a misfire:** the exact phrase a maintainer flagged as generic-LLM
  prose and the surface it appeared on — recurring tells (comprehensive, robust,
  leverages) sharpen the cut-list. Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** none foreseeable; a stable anti-AI-tell discipline.
- **Relates to:** sibling to comments-about-code-not-change — both fight the AI tell,
  one in code, one in prose. Also relates to match-the-house-shape — both are "fit
  the house".
