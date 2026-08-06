---
name: ticket-work
description: Plan a Linear ticket in its worktree, get the plan approved, then implement it. Use when a ticket is to be worked inside its own worktree.
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, Task
---

Ticket: $ARGUMENTS

## 1. Re-fetch

Fetch the issue and `list_comments` from Linear now — the dispatch prompt is a
pointer, not a source. A prior agent may have left a plan, and a plan on a parent epic
can predate the sub-issues that replaced it.

## 2. Plan

Plan mode, with `Explore` for the codebase sweep. This is an ordinary engineering
plan — let it take the shape the ticket needs.

Two demands the default doesn't make:

- **Every acceptance criterion accounted for**, each mapped to what will satisfy it.
  An AC with nothing against it is the gap worth finding now.
- **Say what you didn't read.** Name the coverage you actually have, so approval is
  informed rather than assumed.

`muster status` reads freely here; services stay down until the plan is approved.

## 3. Underspecified exit

A ticket that cannot be planned — a design is needed and none is attached, acceptance
criteria are ambiguous, the AC contradicts the code — earns a Linear comment carrying
the questions, and a stop. The answers come from the author.

## 4. Approval gate

Present both artifacts, then stop at `ExitPlanMode`:

1. **The plan** — the engineering one, in full. This is what's being approved.
2. **The Linear comment you would post** — the same solution written for the people
   tracking the work rather than writing it.

Until it is approved the plan is the only artifact: no code, nothing posted to Linear,
no status change.

### The Linear version

Condensed and product-facing: what changes for a user, the approach in a line or two,
what's in scope and what is deliberately out, open questions needing a human, and how
it will be verified. Roughly the register of the ticket itself.

File paths, class and method names, and affected-file lists stay out. Reviewers get
those from the PR, where they sit beside the diff; on the ticket they are noise that
goes stale the moment the code moves.

## 5. After approval

1. Post the Linear comment.
2. Move the issue to In Progress.
3. Implement.
4. Verify. The `muster` skill covers anything needing a live stack — check occupancy
   first, and confirm before stopping another occupant's stack.
5. Commit, then open the PR through the `open-pr` skill, stacks included.
6. Hand off to the `pr-watch` skill for CI, comments, and rebasing.

Linear links the PR through the key in the branch name, so a PR-link comment is worth
posting only once you've confirmed the link is missing.
