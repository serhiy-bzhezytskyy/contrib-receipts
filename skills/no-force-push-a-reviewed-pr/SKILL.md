---
name: no-force-push-a-reviewed-pr
description: >
  On a PR that already has reviewers, push follow-up changes as plain new commits
  only — never `git commit --amend`, never `git push --force` / `--force-with-lease`.
  Force-push rewrites the commits reviewers' inline comments anchor to, resets the
  GitHub review state, and forces a cold re-read — the opposite of the incremental
  trust you are building. Use whenever you push any change to a PR someone has
  already looked at. Trigger terms: force-push, --amend, --force-with-lease, rebase,
  "clean up history", pushing to an under-review PR.
scope: general
principle: ../../PRINCIPLES.md
---

# No force-push on a reviewed PR

## Purpose

Once a reviewer has read your PR, GitHub anchors their inline comments to specific
commits and diff positions. A force-push (or an amend followed by a force-push)
rewrites those commits, so GitHub can no longer tell what changed since their last
look — comments go "outdated", the diff resets, and the reviewer has to re-read the
whole thing cold. That cold re-read is exactly the cost incremental commits exist
to prevent. On a shared PR, force-push is not a style choice: it breaks other
people's review-in-progress.

Squashing/cleanup, if the house wants it, happens at merge time by the committer —
not mid-review by you.

## When to use

- Any push to a PR that has at least one reviewer or review comment.
- Any urge to `--amend` "just to fix the commit message" on a shared branch.
- Any rebase that would rewrite already-reviewed commits.

## When NOT to use

No reviewer or review comment is on the branch yet (or it's your own solo repo) — before anyone has looked, a rebase/amend anchors nothing and is fine.

## The practice (checklist)

- [ ] Default to a **new `git commit`** for every follow-up change, so each reviewer
      sees exactly the delta since their last look.
- [ ] **No `git commit --amend`** on a shared branch — even to fix a stale message.
- [ ] **No `git push --force` / `--force-with-lease`** on a shared branch.
- [ ] Leave squashing/history cleanup to the committer **at merge time**.
- [ ] If you already force-pushed, own it in the thread and switch to incremental
      commits from that point on.

Note (corpus): this is receipt-backed etiquette, not a statistically validated
lever — the Solr/Lucene corpora record no force-push event, so it cannot be tested
against merge outcomes. It stands on the maintainer's own words, below.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "Force-push gives a cleaner history." | It resets the GH review state and orphans reviewers' inline comments as "outdated" — forcing a cold re-read, the exact cost incremental commits prevent. |
| "It's just a commit-message fix, `--amend` is harmless." | Amend still rewrites the commit reviewers anchor to; on a shared branch that breaks their in-progress review the same way a force-push does. |
| "I'll squash before merge so it's tidy." | Squashing is the committer's call at merge time — not yours mid-review; do it early and you rewrite commits people are still reading. |

## RECEIPT

**A Solr committer, apache/solr PR #4632** (`corpus-solr-prs/pr-solr-4632.json`, issue
comment) — verbatim:

> "Please don't force-push to PRs, especially once someone has looked at it. It
> resets the GH review state for the reviewer, making it impossible to be sure what
> changed since the last reviewed changes."

Recovery (same PR, Serhiy): acknowledged the mistake and committed to incremental
commits only from that point. Context (journal): the SOLR-3284 branch (PR #4632)
had been amended + force-pushed three times with three readers on it before the
correction landed.

## Lifecycle

- **Signals it worked:** reviewers' prior inline comments stay anchored and
  non-"outdated" across your follow-up pushes; no maintainer asks "what changed?".
- **What to log on a misfire:** the PR#, how many reviewers were already on it, and
  which command rewrote history — force-push, amend, or rebase.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** retire only if GitHub changes so that review state survives
  history rewrites (it does not today).
- **Relates to:** history-rewrite hygiene once a PR is under review (prefer a plain
  `git push`; a force-push breaks reviewers' incremental view and comment anchoring).
  Pairs with the commit-hygiene rule for
  someone else's house (strip auto-appended `Co-Authored-By` / "Generated with"
  trailers on Apache commits; the human contributor owns the commit).
