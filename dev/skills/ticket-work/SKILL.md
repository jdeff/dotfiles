---
name: ticket-work
description: Plan a Linear ticket in the current worktree, get the plan approved, then implement it. Use when working a ticket inside its own worktree; dispatched by /ticket, and runs standalone as /ticket-work ABC-123.
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

Ticket: $ARGUMENTS

## 1. Re-fetch

Fetch the issue and `list_comments` from Linear now. The dispatch prompt is a
pointer, not a source. A prior agent may have left a plan; a plan on a parent epic
may be stale relative to the sub-issues that were created after it.

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

`muster status` is fine here. Start no services yet.

## 3. Underspecified exit

If the ticket cannot be planned — a design is needed and none is attached,
acceptance criteria are ambiguous, or the AC contradicts the code — post the
questions as a Linear comment, tell the user, and stop. Do not guess.

## 4. Approval gate

Present the plan and ask for approval with AskUserQuestion (Approve / Revise /
Stop). Before approval:

- write no code
- post nothing to Linear
- do not change the issue status

## 5. After approval

1. Post the plan as a Linear comment.
2. Move the issue to In Progress.
3. Implement.
4. Verify. Use the `muster` skill for anything needing a live stack: check
   occupancy first, and never evict another occupant.
5. Commit, then `/open-pr`.

The branch name carries the ticket key, so Linear links the PR itself. Don't post a
PR-link comment unless you've confirmed the link is missing.
