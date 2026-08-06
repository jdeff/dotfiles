---
name: ticket
description: Work a Linear ticket in a new git worktree — resolve the key, gate on existing work, and dispatch a prompted agent. Use whenever a bare ticket key like ABC-123 is the thing to be worked on.
allowed-tools: Bash, Write
---

Ticket: $ARGUMENTS

Resolve, gate, write the prompt, create the worktree — the dispatched agent plans and
implements. Everything here comes from Linear and `workspace.toml`; the codebase stays
unread until the worktree agent opens it.

## 1. Resolve

The `workspace` skill maps prefix → team → muster project → repos and names the Linear
server to ask. Fetch with `get_issue` (`includeRelations: true`) and take the branch
from `gitBranchName`.

## 2. Stop conditions

Check in order; report and stop on the first hit.

**Sub-issues.** `list_issues` with `parentId: <key>`. Any result makes this an epic,
which is a set of worktrees rather than one — list the sub-issues with their statuses
and stop. Their order rarely lives in Linear's relations graph; it's usually stated in
the descriptions.

**Existing work**, meaning hard evidence:

- a GitHub PR attachment on the Linear issue
- a branch or PR whose name carries the key
- an existing worktree under `~/.herdr/worktrees/<repo>/`

Match the key with a digit boundary, or `MG-13` also hits `mg-137`. `gh pr list
--search <key>` matches other tickets and stops you on their work — filter
`headRefName` instead:

```bash
key=ABC-123
git -C "$repo" branch -a | grep -iE "$key([^0-9]|$)"
gh pr list --state all --limit 200 --json number,state,headRefName \
  | jq -r --arg k "$key" '.[] | select(.headRefName | test("\($k)([^0-9]|$)"; "i"))
      | "\(.state) #\(.number) \(.headRefName)"'
```

One ticket legitimately has several PRs (expand / dual-write / backfill), so report
every hit rather than the first.

**Empty description.** Nothing to plan from.

## 3. Soft signals — report and continue

Status `In Progress`/`In Review`, an assignee, or a prior plan comment are routinely
set before any code exists. Note them in one line and carry on.

## 4. Repo

Which repos a ticket touches comes from its content; `default_repo` is only the
starting point. One worktree per repo, and ask when two are involved and the lead
isn't clear.

## 5. Dispatch

The `dispatch` skill's sequence, with:

- the branch exactly as `gitBranchName` gives it
- `--focus` for a single ticket, `--no-focus` for more than one
- a two-line prompt, since the agent re-fetches the ticket itself:

```
Work Linear ticket <KEY>: <title>

Use the skill: /ticket-work <KEY>
```

Report the branch, the workspace, what the gates found, and whether the prompt was
consumed.
