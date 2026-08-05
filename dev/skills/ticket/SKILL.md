---
name: ticket
description: Work a Linear ticket in a new git worktree — resolve it, gate on existing work, and dispatch a prompted agent. Invoke as /ticket ABC-123.
disable-model-invocation: true
allowed-tools: Bash, Write
---

Ticket: $ARGUMENTS

You are a dispatcher. Do NOT read, grep, or explore the codebase, and do not plan
the work — the dispatched agent does both. Resolve, gate, write the prompt, create
the worktree.

## 1. Resolve

Use the `workspace` skill for prefix → team → muster project → repos. Fetch the
issue with the Linear MCP (`get_issue`, `includeRelations: true`). Take the branch
name from `gitBranchName`; never invent one.

## 2. Stop conditions

Check in order. Report and stop on the first hit — do not create a worktree.

**Sub-issues.** `list_issues` with `parentId: <key>`. Any result means this is an
epic. Epic fan-out is not built yet: list the sub-issues with their statuses, note
that dependencies are often stated in descriptions rather than Linear relations,
and stop.

**Hard evidence of existing work.** Any of:

- a GitHub PR attachment on the Linear issue
- a branch or PR whose name carries the key
- an existing worktree under `~/.herdr/worktrees/<repo>/`

Match the key with a digit boundary, or `MG-13` also hits `mg-137`. Do not use
`gh pr list --search <key>` — it matches other tickets and stops you on their work.

```bash
key=ABC-123
git -C "$repo" branch -a | grep -iE "$key([^0-9]|$)"
gh pr list --state all --limit 200 --json number,state,headRefName \
  | jq -r --arg k "$key" '.[] | select(.headRefName | test("\($k)([^0-9]|$)"; "i"))
      | "\(.state) #\(.number) \(.headRefName)"'
```

One ticket legitimately has several PRs (expand / dual-write / backfill), so report
everything you find rather than assuming the first hit is the whole story.

**Empty description.** Nothing to plan from.

## 3. Soft signals — report, don't stop

Status `In Progress`/`In Review`, an assignee, or a prior plan comment are not
existing work. Status is routinely set before any code exists. Note them in one
line and continue.

## 4. Repo

Decide from the ticket's content which repos it touches; `default_repo` is a
starting point, not the answer. One worktree per repo. If it needs two repos and
you cannot tell which leads, ask.

## 5. Dispatch

**The prompt file must exist before the worktree is created.** The layout plugin
consumes it on the `worktree.created` event. Create the worktree first and you get a
bare Claude sitting idle in a correct-looking worktree — a silent no-op that reports
as success.

**Step 1 — write it, and prove it exists.** Do not continue on a zero byte count.

```bash
mkdir -p ~/.herdr/dispatch
branch="<gitBranchName>"
slug=$(printf '%s' "$branch" | tr -c '[:alnum:]' '-')
f="$HOME/.herdr/dispatch/$slug.md"
cat > "$f" << 'EOF'
Work Linear ticket <KEY>: <title>

Use the skill: /ticket-work <KEY>
EOF
wc -c "$f"
```

Keep the prompt thin — the agent re-fetches the ticket. Relative paths only.

**Step 2 — create the worktree.**

```bash
herdr worktree create --cwd <repo-path> --branch "$branch" --focus
```

**Step 3 — confirm the prompt was picked up.** The file is deleted when the agent
launches with it, so a file still on disk means a bare Claude:

```bash
sleep 3; [ -e "$f" ] && echo "BARE — prompt not consumed" || echo "consumed"
```

This check is the authoritative one. Agent status is not: a fast agent is already
`idle` by the time you look, so `idle` alone doesn't distinguish "never got a
prompt" from "finished". If the file was not consumed, report a failure — never
success.

Report the branch, the workspace, what the gates found, and the step 3 result.
