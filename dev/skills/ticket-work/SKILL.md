---
name: ticket-work
description: Plan a Linear ticket in its worktree, get the plan approved, then implement it. Use when a ticket is to be worked inside its own worktree.
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

Ticket: $ARGUMENTS

## 1. Re-fetch

Fetch the issue and `list_comments` from Linear now — the dispatch prompt is a
pointer, not a source. A prior agent may have left a plan, and a plan on a parent epic
can predate the sub-issues that replaced it.

## 2. Plan

Explore the code, then write the plan with these sections:

- **Goal** — one sentence.
- **Summary of current code** — what exists today, with file paths.
- **Affected files** — grouped by repo.
- **System overview** — the path the change travels end to end.
- **Edge cases & hotspots**.
- **Suggested approach** — ordered steps.
- **Open questions**.
- **Confidence** — overall, and how much of the relevant code you actually read.

`muster status` reads freely here; services stay down until the plan is approved.

## 3. Underspecified exit

A ticket that cannot be planned — a design is needed and none is attached, acceptance
criteria are ambiguous, the AC contradicts the code — earns a Linear comment carrying
the questions, and a stop. The answers come from the author.

## 4. Approval gate

Present the plan and ask for approval with AskUserQuestion (Approve / Revise / Stop).
Until it is approved the plan is the only artifact: no code, nothing posted to Linear,
no status change.

## 5. After approval

1. Post the plan as a Linear comment.
2. Move the issue to In Progress.
3. Implement.
4. Verify. The `muster` skill covers anything needing a live stack — check occupancy
   first, and leave another occupant's stack running.
5. Commit, then open the PR through the `open-pr` skill, stacks included.
6. Hand off to the `pr-watch` skill for CI, comments, and rebasing.

Linear links the PR through the key in the branch name, so a PR-link comment is worth
posting only once you've confirmed the link is missing.
