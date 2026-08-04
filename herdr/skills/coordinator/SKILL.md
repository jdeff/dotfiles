---
name: coordinator
description: Orchestrate multiple worktree agents in Herdr. Spawn, monitor, communicate, and merge.
allowed-tools: Bash, Write, Read, Task
disable-model-invocation: true
---

# Worktree Agent Coordinator

You are a coordinator agent. You orchestrate multiple worktree agents using the
`herdr` CLI. You do NOT implement tasks yourself. You spawn agents, monitor them,
send instructions, and trigger merges.

## Requirements

The Herdr server must be running and you must be inside a Herdr pane:

```bash
test "${HERDR_ENV:-}" = 1
```

If that fails, say you are not running inside Herdr and stop.

The `jdeff.flow` plugin must be enabled (`herdr plugin list`) — it lays out
Claude + a shell on `worktree.created` and launches the dispatched prompt.

## Core Concepts

- **Worktree agent**: a Claude Code session running in its own git
  worktree/branch, which Herdr opens as its own **workspace** (space) grouped
  under the source repo.
- **Target**: agent commands take either a **pane ID** (`w3B:p1`) or a unique
  **live agent name**. Agents start *unnamed* — see "Name your agents" below.
- **Statuses**: `working` (processing), `blocked` (an approval or question UI is
  up — needs you), `idle` (ready for input), `done` (the same underlying idle
  state, after unseen background work finished), `unknown` (an agent is present
  but unclassified — this does **not** prove completion).
- **Timeouts are MILLISECONDS**, not seconds. `--timeout 3600000` is one hour.
- CLI reads do **not** mark an agent as seen; focusing its tab or targeting it
  with a focus command does. That's the `done` vs `idle` distinction.

## Command Reference

### Spawn Agents

For each task, write a dispatch prompt file, then create the worktree. You are a
dispatcher. Do NOT read source files, edit code, or implement tasks yourself.

**Prompt file rules:**

- Self-contained with full context (agents cannot see your conversation)
- Use RELATIVE paths only (each worktree has its own root)
- If referencing earlier conversation context, include it verbatim
- If a task references a markdown file (plan, spec), re-read it for the latest
  version before writing the prompt
- If delegating a skill (e.g. `/auto`), instruct the agent to use it. Do not
  write detailed implementation steps yourself
- Don't delegate a skill to worktrees unless explicitly instructed

The dispatch contract: write the prompt to `~/.herdr/dispatch/<slug>.md`, where
`slug` is the branch run through `tr -c '[:alnum:]' '-'`. The `layout-agent-shell.sh`
script uses the identical transform to find it, and consumes/deletes the file when
Claude launches.

**Spawning workflow: write ALL files first, THEN create ALL worktrees.**

```bash
# Step 1: Write all prompt files (in parallel)
mkdir -p ~/.herdr/dispatch
repo="$(git rev-parse --show-toplevel)"

for b in auth-module api-tests; do :; done   # (illustrative; write each below)

slug=$(printf '%s' "auth-module" | tr -c '[:alnum:]' '-')
cat > ~/.herdr/dispatch/"$slug".md << 'EOF'
Implement auth module...
EOF

slug=$(printf '%s' "api-tests" | tr -c '[:alnum:]' '-')
cat > ~/.herdr/dispatch/"$slug".md << 'EOF'
Write API tests...
EOF

# Step 2: Create all worktrees (in parallel, after ALL files exist)
herdr worktree create --cwd "$repo" --branch auth-module --no-focus
herdr worktree create --cwd "$repo" --branch api-tests   --no-focus
```

Flags:

- `--no-focus`: stay in your own space (the equivalent of backgrounding)
- `--cwd <path>`: the repo to branch from. Same repo → `git rev-parse --show-toplevel`;
  cross-project → that repo's absolute path. Do not `cd`.
- `--base <ref>`: branch from `<ref>` instead of the repo's current HEAD
- `--branch <name>`: existing name checks out, new name creates the branch
- `--label <text>`: space label (defaults to the branch slug)

### Resolve and name your agents

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

### Monitor Status

```bash
# All agents, with status, cwd, workspace and current terminal title
herdr agent list

# One agent
herdr agent get auth-module
```

### Wait for Status

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

### Capture Output

```bash
# Read the visible screen (default)
herdr agent read auth-module

# Last 50 lines of scrollback
herdr agent read auth-module --source recent --lines 50
```

Remember: reading does not mark the agent seen, so a background agent that
finished still reports `done` rather than flipping to `idle`.

### Send Instructions

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

### Run Commands

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

### Merge & Cleanup

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

### Cross-Project Work

Agent targets are global — a pane ID or live agent name resolves regardless of
which repo the agent lives in, so no `project:handle` syntax is needed. Lifecycle
commands are scoped by what you pass: `worktree create --cwd <repo>` and
`worktree remove --workspace <id>`.

## Workflow Patterns

### Fan-out / Fan-in

```bash
# 1. Write ALL prompt files first (see "Spawn Agents" above)
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

## Rules

1. **Write ALL prompt files before creating any worktrees.** Prompts must be
   self-contained — agents cannot see your conversation.
2. **Always pass `--no-focus`** so you stay in your own space.
3. **Name each agent** right after spawning; pane IDs are stable but opaque, and
   a name survives you losing track of which space is which.
4. **Always confirm agents started** (`--until working`) before waiting for
   completion.
5. **Include `blocked` in completion waits.** A blocked agent needs you, and
   without it you burn the whole timeout.
6. **Capture and review output** before merging. Do not blindly merge.
7. **Merge one at a time**, waiting for each to finish before the next, to avoid
   conflicts.
8. **Timeouts are milliseconds.** Always pass one.
9. **Prompt files use relative paths** (each worktree has its own root).
10. **`unknown` is not `done`.** Never treat it as completion.
11. You are a coordinator, not an implementer. Never edit source files directly.
