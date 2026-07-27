---
name: read-the-projects-origin-story
description: >
  Use when you are about to PROPOSE something to a young project or subproject — a
  design, a new capability, a discussion thread — and want to know why it is the way it
  is: who built it, what it was chosen over, what its authors already called incomplete,
  and which design arguments are still unresolved. Read the discussion arc that CREATED
  the repo before proposing to it. Its founding threads name the known-incomplete edges
  (so you don't report them as discoveries), the objections its own committers recorded
  (so you don't reopen them), and who actually cares about your area — none of which git
  history or CONTRIBUTING can tell you. For "does the ORIGINAL of this fork still have
  the same bug?" use port-the-report-upstream: that is code lineage, this is decision
  history. Trigger terms: new subproject, young repo, why does this exist, what did they
  already decide, project history, founding thread, VOTE thread, was this discussed
  before, prior discussion, before I propose, am I repeating something, is this wanted.
scope: general
principle: ../../PRINCIPLES.md
---

# Read the project's origin story before you propose anything

## Purpose

Code tells you what a project *is*. Its founding discussion tells you what it was
*for*, what it beat, what its own authors flagged as unfinished, and which arguments
were left open. That context is what separates a proposal a maintainer can act on from
one that re-litigates a settled decision or announces a gap the author declared
themselves.

The cost of skipping it is not just ignorance — it is confidently framing your work
wrong. A defect you present as a discovery may be a known consequence of a fast initial
port the author already warned about. A "missing capability" may be the exact thing the
project was chosen *for*, making your report far more significant than you pitched it.
Neither reading is available from the diff.

## When to use

- The repo is young, or is a subproject of a larger foundation project (a port counts,
  but for a port's *code* lineage see port-the-report-upstream — this is its history).
- You are about to propose a design, open a discussion thread, or frame a report as
  "this is missing."
- A maintainer invites you to "start another thread about that" — find out who has
  already argued about it before you do.
- You are writing the *framing* of work already done (an email, a PR body's Notes
  section, a case study) and want the strongest true claim.

## When NOT to use

- Routine, self-contained bug fixes on a mature project. A one-line null guard does not
  need the 2015 founding thread.
- The project has no public discussion history (private origin, or a single-author repo
  with no list). Then the README/CHANGELOG and the maintainer's own issues are the
  substitute.
- You are mid-incident and the fix is time-critical. Do it after.

## The practice (checklist)

- [ ] **Find the threads that created the repo, not just the ones mentioning it.**
      Search the project's mailing-list archive / discussion forum by keyword over
      months, not by the thread you are currently in. For ASF projects:
      `lists.apache.org/api/stats.lua?list=<list>&domain=<project>.apache.org&d=lte=180d&q=<keyword>`
      then `thread.lua?id=<tid>` then `email.lua?id=<mid>` per message.
- [ ] **Read the VOTE / proposal thread whole**, including the +1s. Objections are
      recorded *inside* approvals — "+1, but I'm skeptical we need X" is a live
      disagreement wearing an approval.
- [ ] **Harvest four specific things** and write them down:
      1. **What the authors said was incomplete.** Founders describe their own MVPs
         accurately. Anything they called WIP is a known edge, not your discovery.
      2. **What it was chosen over, and on what argument.** That argument is the
         project's purpose statement, and the strongest frame for work that serves it.
      3. **Unresolved objections** — especially from committers who still voted +1.
         These are tripwires; naming one shows you read, reopening it costs you.
      4. **Who wants what.** Founders, the person who ran the vote, and the loudest
         user usually want three different things.
- [ ] **Re-frame work you already did against what you found.** *Done when* you can
      state your contribution in the project's own founding terms rather than your own
      — and you have checked whether that raises or lowers the claim.
- [ ] **Check whether the thing you are about to build already exists.** Young projects
      accumulate half-known tooling (guides, converters, scripts) that no one has
      announced since the founding thread.
- [ ] **Route the proposal to everyone with standing**, not just whoever invited you.
      The person who asked may not be the person who owns the repo you'd touch.

## Rationalizations

| Shortcut | Why it fails |
|---|---|
| "I read CONTRIBUTING and the README, that's the documented context." | Those describe the current state. They do not record what was rejected, who objected, or what the author called unfinished — and those are the three things that determine whether a proposal lands. |
| "Git history tells me the project's story." | It tells you what changed, never why this project exists rather than the alternative. The tool-selection argument that defines the project's purpose happened on a list, months before the first commit. |
| "The maintainer invited me to propose it, so I have what I need." | The inviter is often not the owner of the affected repo, and may be the third-most-invested person in the topic. In the receipt below, the person who invited the thread had *lost* the original tool-selection argument; the two people who won it were never in my inbox. |
| "It's a young repo, there's barely any history to read." | Young repos have the *most* load-bearing history and the least code to infer it from — the founding thread is a larger fraction of everything knowable. 35 messages covered this project's entire existence. |
| "My finding stands on its own evidence, framing is cosmetic." | The same three defects can be "I found bugs in a new tool" or "the only variance mechanism in this tool's entire lineage was unreachable" — both true, one actionable. Framing is which true thing you say. |
| "I'll read the history if a maintainer pushes back." | By then you've already spent the first impression, and possibly reopened a settled question in public. |

## RECEIPT

***SOURCING-receipt*** — **a 35-message, 3-thread founding arc, read *after* 12 artifacts
were already filed, that changed the framing of all of them.** Reconstructed 2026-07-27
from the ASF archive API; every item below is a verbatim quote from a message I read in
full.

Context: I had filed 6 issues + 6 PRs against `apache/solr-orbit` (a young ASF
subproject) and its upstream, based on running it. Only afterwards did I read the
Feb–May 2026 threads that created it. Four things I did not have:

1. **The author had declared the incompleteness I "found."** The tool's writer, in the
   thread presenting it: *"I made a new effort using LLM agents and this first working
   version was prepared in a few afternoons… view it as a MVP and WIP. **Only one
   workload / dataset is ported so far.**"* My three defects are the signature failure
   of exactly that process, and the "missing workloads" gap I was about to report as a
   finding was **declared at birth**.
2. **What the project was chosen over — and the argument raised my claim.** It won a
   bake-off against a rival tool because the rival's *"methodology for executing queries
   / drawing statistical conclusions leaves something to be desired (can expand in
   detail if anyone wants to hear)"* — an offer **nobody took up**. My work restored the
   project's only variance-measurement mechanism. That reframes "I fixed three bugs"
   into "I restored the capability this tool was selected for", which is the same
   evidence making a materially bigger claim.
3. **Two unresolved objections sitting inside +1 votes.** Two committers approved while
   recording doubt about a structural decision (*"I'm skeptical we need a separate
   'workloads' repository"* / *"I'm also unsure of having two separate repositories"*),
   and a third's renaming proposal was deferred to a follow-up vote **that never
   happened**. Any proposal touching that structure walks into a live disagreement I'd
   have had no idea existed.
4. **The person who invited my proposal was the wrong sole recipient.** A maintainer had
   said *"Let's start another thread about that!"* — but the founding threads show he had
   *lost* the original tool-selection argument, while the two people who mattered most
   (the author who owns the affected repo and asked twice for contributors, and the
   community member who ran the VOTE and chose the tool for that very capability) were
   in neither my inbox nor my notes.

**Also found by reading it:** a workload-creation guide and an upstream→downstream
**converter tool** already existed in the repo, documenting exactly which constructs
convert automatically vs. need manual work. I had been about to propose work whose
mechanical half was already built.

**The systematic sweep that missed all of it.** The day before, I had run a
channel-complete status check — every PR via `gh`, every tracker issue via the project's
REST API, the mailing-list thread via the archive API — and it correctly reported that
nothing was waiting on me. It was clean *and* blind: it covered open items addressed to
me, not the domain the work sits in. Those are different questions.
[track-whose-court](../track-whose-court/SKILL.md) answers the first; this skill answers
the second.

## Lifecycle

- **Signals it worked:** you can state your contribution in the project's own founding
  language; you name a prior objection before a maintainer has to; you don't announce a
  gap the authors already declared; your proposal reaches everyone with standing.
- **What to log on a misfire:** what the founding threads said that you'd assumed the
  opposite of, and whether it raised or lowered the claim you were about to make.
  Record it in [`LEDGER.md`](../../LEDGER.md).
- **Death criterion:** none for young/ported projects. For a mature project with a
  decade of history, the founding thread stops being load-bearing — read the recent
  design discussions in the affected area instead.
- **Relates to:** [use-the-tool-for-its-purpose](../use-the-tool-for-its-purpose/SKILL.md)
  finds the defect, this explains why it was there and what it's worth;
  [port-the-report-upstream](../port-the-report-upstream/SKILL.md) is the same
  "understand the lineage" instinct applied to code rather than history;
  [consolidate-a-scattered-thread](../consolidate-a-scattered-thread/SKILL.md) traverses
  a live discussion, this one excavates a settled one;
  [track-whose-court](../track-whose-court/SKILL.md) is the sweep this is NOT a
  substitute for, and vice versa.
