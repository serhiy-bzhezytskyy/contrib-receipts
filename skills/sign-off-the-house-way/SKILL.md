---
name: sign-off-the-house-way
description: >
  Before opening a PR, know which contributor sign-off THAT house requires and make
  sure it's present — the contracts differ by house and a missing one is an instant,
  automated "didn't read the rules" bounce. Eclipse projects (e.g. Jetty) gate every
  PR on an ECA plus a DCO `Signed-off-by` trailer on each commit; Apache projects
  (Solr/Lucene) use a CLA with the committer resolving on merge and need no per-commit
  trailer; other houses need neither. Check the house's contract first, not after a
  bot rejects you. Use at front-gate, before the first commit. Trigger terms: DCO,
  ECA, CLA, Signed-off-by, sign-off, `git commit -s`, eca check, contributor agreement.
scope: general
principle: ../../PRINCIPLES.md
---

# Sign off the house way

## Purpose

Every house has a legal-provenance contract for outside contributions, and it is
enforced by a bot before a human ever looks at the change. Get it wrong and the PR
lands with a red check and a canned rejection — you read as someone who didn't read
the rules, which is exactly the "noise" signal this whole repo tries to avoid. The
trap is assuming one house's contract is universal: a `Signed-off-by` trailer that
Eclipse *requires* is simply noise in an Apache PR, and skipping it on an Eclipse PR
blocks the merge outright. The contract is house-specific; learn it before the first
commit, because a DCO trailer is set at commit time and is painful to add later
(interactive rebase across every commit).

## When to use

- Before the first commit on a repo you haven't contributed to before.
- When a PR comes back with a red legal/agreement check (ECA, CLA, DCO).
- When you're unsure whether to pass `-s` to `git commit`.

## When NOT to use

This covers the legal SIGN-OFF contract; for the build/format/generator gate the
house runs on your code, that's obey-the-houses-own-tooling.

## The practice (checklist)

- [ ] Identify the house's contract before committing: check CONTRIBUTING, the PR
      template, and the checks that ran on a recent merged PR (`gh pr checks <n>`).
- [ ] **Eclipse (Jetty):** sign the ECA once under the same email you commit with,
      and add a DCO trailer to *every* commit — `git commit -s` (or `-s` on rebase).
- [ ] **Apache (Solr/Lucene):** no per-commit trailer; the committer resolves the
      CLA/ICLA on merge. Don't add a `Signed-off-by` — it isn't the house convention.
- [ ] Make the commit email match the agreement you signed (a mismatch fails the ECA
      even when the agreement exists).
- [ ] If a legal check is red, fix it *before* pinging a human — it's your court.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "Sign-off is boilerplate, I'll add it if a bot complains." | The DCO trailer is set at commit time; retrofitting it means rebasing every commit. Do it up front with `-s`, not after a red check. |
| "One house wanted `Signed-off-by`, so I'll always add it." | It's house-specific — required on Eclipse, not the convention on Apache. A stray trailer on an Apache PR reads as copy-paste from another project. |
| "The legal check is red but the code is fine, a reviewer will wave it through." | Automated agreement gates don't get waved through; an unresolved ECA/CLA blocks merge regardless of code quality, and leaving it red is your unfinished move. |

## RECEIPT

**Eclipse / Jetty — ECA + per-commit DCO, verified via `gh` 2026-07-24.** The
`eclipsefdn/eca` check gates every PR and passed on #15435, #15472, and #15473:

> "The author(s) of the pull request is covered by necessary legal agreements in
> order to proceed!"

and #15435 carries a `Signed-off-by` trailer on all 3 of its 3 commits (`gh pr view
15435 --repo jetty/jetty.project --json commits`).

**Apache / Solr — CLA-on-merge, no per-commit DCO, verified via `gh`.** Merged PR
#4632 carries **zero** `Signed-off-by` trailers — consistent with Apache's model
where the committer resolves the agreement on merge and no per-commit sign-off is
expected. Two houses contributed to in the same month, two different contracts.

## Lifecycle

- **Signals it worked:** the legal check is green on first push; no rebase-to-add-
  sign-off round-trip; no "please sign the ECA/CLA" comment from a bot or maintainer.
- **What to log on a misfire:** which house, which contract you got wrong (missing
  trailer / stray trailer / email mismatch), and what the gate said. Record it in
  [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** retire for a house only if it drops its agreement gate
  entirely; the contracts themselves change rarely.
- **Relates to:** a front-gate sibling of obey-the-houses-own-tooling — both are
  "read this house's rules before you touch it", one for the legal sign-off, one for
  the build/generator tooling.
