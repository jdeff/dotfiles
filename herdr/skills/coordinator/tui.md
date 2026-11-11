# Coordinator reference: TUI host

Commands for the `herdr` CLI, used when the `dispatch` skill's Host check says TUI.
**Timeouts are MILLISECONDS**: `--timeout 3600000` is one hour.

## Resolve and name your agents

Newly spawned agents are unnamed, so give them stable handles before you start
driving them. Map worktree → workspace → pane, then rename:

```bash
# Which space belongs to which worktree checkout?
herdr workspace list   # .workspaces[]: workspace_id, label, worktree.checkout_path

# The agent panes in that space
herdr agent list       # .result.agents[]: pane_id, workspace_id, cwd, agent_status

# Give it a handle (must match [a-z][a-z0-9_-]{0,31}, unique among live agents)
herdr agent rename w3B:p1 auth-module
```

A name follows the current pane occupant and clears when that agent exits. From
here on, `auth-module` is a valid target anywhere a pane ID is.

```bash
# Handy: pane_id of the agent whose cwd is a given worktree path
herdr agent list | jq -r --arg p "$path" '.result.agents[]|select(.cwd==$p)|.pane_id'
```

## Monitor Status

```bash
# All agents, with status, cwd, workspace and current terminal title
herdr agent list

# One agent
herdr agent get auth-module
```

## Wait for Status

`herdr agent wait` takes **one** target. Wait on several by backgrounding each
and calling `wait`:

```bash
# Block until one agent settles (idle/done/blocked)
herdr agent wait auth-module --timeout 3600000

# Wait for a specific state
herdr agent wait auth-module --until idle --timeout 3600000

# Wait for several (all of them)
for a in auth-module api-tests docs-update; do
  herdr agent wait "$a" --until idle --until blocked --timeout 7200000 &
done
wait

# Confirm agents actually started
for a in auth-module api-tests; do
  herdr agent wait "$a" --until working --timeout 120000 &
done
wait
```

Always include `blocked` in a completion wait — otherwise an agent sitting on a
permission prompt looks like it's still working until the timeout expires.

## Capture Output

```bash
# Read the visible screen (default)
herdr agent read auth-module

# Last 50 lines of scrollback
herdr agent read auth-module --source recent --lines 50
```

Remember: reading does not mark the agent seen, so a background agent that
finished still reports `done` rather than flipping to `idle`.

## Send Instructions

```bash
# Send a short instruction
herdr agent prompt auth-module "fix the failing tests"

# Send a skill command
herdr agent prompt auth-module "/commit"

# Submit and wait for the agent to settle again
herdr agent prompt auth-module "fix the failing tests" --wait --until idle --timeout 1800000
```

`--wait` first requires an observed state change within 5000ms, or it returns
`agent_prompt_stalled`. It does not track turns: if the agent is already
`working`, that in-flight turn's completion may satisfy the wait. Prefer sending
to an `idle` agent.

For a long follow-up, write a file and point the agent at it — there is no
`-f` flag:

```bash
cat > /tmp/followup.md << 'EOF'
...long instructions...
EOF
herdr agent prompt auth-module "Read /tmp/followup.md and do what it says."
```

## Run Commands

Run a shell command in a specific pane:

```bash
# In the agent's own pane (only when it's idle — this types into its terminal)
herdr pane run w3B:p2 "pnpm test"

# Safer: a scratch pane in the agent's space, then run there
new=$(herdr pane split w3B:p1 --direction down --cwd "$path" --no-focus \
  | jq -r '.result.pane.pane_id')
herdr pane run "$new" "pnpm test"
herdr pane wait-output "$new" --match "Tests:" --timeout 600000
herdr pane read "$new" --source recent --lines 40
herdr pane close "$new"
```

Prefer the scratch-pane form: the worktree already has a shell pane from the
`jdeff.flow` layout, and running in the *agent's* pane while it works corrupts
its input.

## Merge & Cleanup

Tell the agent to merge its own branch via `/merge`, so it handles rebasing and
conflict resolution:

```bash
herdr agent prompt auth-module "/merge" --wait --until idle --timeout 1800000
```

Then remove the worktree checkout and its space (keeps the branch):

```bash
herdr worktree remove --workspace w3B
```

`herdr worktree list` shows the worktree-backed spaces; `remove` prompts before
forcing on a dirty tree.

## Cross-Project Work

Agent targets are global — a pane ID or live agent name resolves regardless of
which repo the agent lives in, so no `project:handle` syntax is needed. Lifecycle
commands are scoped by what you pass: `worktree create --cwd <repo>` and
`worktree remove --workspace <id>`.

## Fan-out / Fan-in example

```bash
# 1. Write ALL prompt files first (the dispatch skill)
# 2. Create the worktrees, staying put
repo="$(git rev-parse --show-toplevel)"
herdr worktree create --cwd "$repo" --branch auth-module --no-focus
herdr worktree create --cwd "$repo" --branch api-tests   --no-focus
herdr worktree create --cwd "$repo" --branch docs-update --no-focus

# 3. Name them (resolve pane IDs from herdr agent list / workspace list)
herdr agent rename <pane> auth-module
herdr agent rename <pane> api-tests
herdr agent rename <pane> docs-update

# 4. Confirm they started
for a in auth-module api-tests docs-update; do
  herdr agent wait "$a" --until working --timeout 120000 &
done; wait

# 5. Wait for completion (include blocked!)
for a in auth-module api-tests docs-update; do
  herdr agent wait "$a" --until idle --until done --until blocked --timeout 7200000 &
done; wait

# 6. Review results
herdr agent list
herdr agent read auth-module --source recent --lines 50
herdr agent read api-tests   --source recent --lines 50

# 7. Merge successful agents one at a time
herdr agent prompt auth-module "/merge" --wait --until idle --timeout 1800000
herdr agent prompt api-tests   "/merge" --wait --until idle --timeout 1800000

# 8. Follow up where needed
herdr agent prompt docs-update "also add the API reference section" \
  --wait --until idle --timeout 1800000
herdr agent prompt docs-update "/merge" --wait --until idle --timeout 1800000
```

