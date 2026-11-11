---
name: coordinator
description: Orchestrate multiple worktree agents in Herdr — spawn, name, monitor, send follow-ups, and merge. Use when work needs the full lifecycle rather than fire-and-forget; for a single dispatch use /worktree, and for a Linear ticket use /ticket. Builds on the dispatch skill.
allowed-tools: Bash, Write, Read, Task
---

# Worktree Agent Coordinator

You are a coordinator agent. You orchestrate multiple worktree agents. You do NOT
implement tasks yourself. You spawn agents, monitor them, send instructions, and
trigger merges.

## Host and command reference

Settle the host with the `dispatch` skill's Host check, then read that host's
command reference before driving any agent — its commands, handles, and timeout
units differ:

- **TUI** → [`tui.md`](tui.md) (`herdr` CLI; timeouts in milliseconds)
- **Desktop** → [`desktop.md`](desktop.md) (`hc` + `herdr-app`; timeouts in seconds)

## Core Concepts

- **Worktree agent**: a Claude Code session running in its own git
  worktree/branch, which Herdr opens as its own space grouped under the source
  repo.
- **Handle**: how you address an agent — a pane ID or a name you give it (TUI), or
  its terminal address (Desktop). Pin one to each agent right after spawning.
- **Statuses**: `working` (processing), `blocked` (an approval or question UI is
  up — needs you), `idle` (ready for input), `done` (the same underlying idle
  state, after unseen background work finished). The TUI adds `unknown` and the
  Desktop adds `error`; neither proves completion.
- Reading an agent does **not** mark it as seen; focusing it does. That's the
  `done` vs `idle` distinction.

## Spawn Agents

Spawning is the `dispatch` skill: its host check, contract, write→verify→create→confirm
sequence, flags, and prompt rules. Use it rather than re-deriving them here.

Coordinator specifics:

- Always `--no-focus` — you stay in your own space.
- Don't delegate a skill to worktrees unless explicitly instructed.
- Confirm every prompt was consumed before you start monitoring. An unconsumed
  prompt means that agent is idle and bare, which looks identical to an agent that
  finished.

## Long follow-ups

For a long instruction, write a file and send the agent a pointer to it:

```bash
cat > /tmp/followup.md << 'EOF'
...long instructions...
EOF
# then send: "Read /tmp/followup.md and do what it says."
```

## Workflow: fan-out / fan-in

1. Write every prompt file (the `dispatch` skill).
2. Create the worktrees with `--no-focus`, and pin a handle to each agent.
3. Confirm each one started on its prompt.
4. Wait for all of them, with `blocked` ending the wait.
5. Read each agent's output and review it.
6. Merge the successful ones one at a time by sending `/merge`.
7. Send follow-ups where needed, then `/merge` those.

Each host reference ends with this workflow as commands.

## Rules

1. **Dispatch per the `dispatch` skill** — every prompt file written and verified
   before any worktree is created.
2. **Always pass `--no-focus`** so you stay in your own space.
3. **Pin a handle to each agent** right after spawning.
4. **Confirm agents started** on their prompt before waiting for completion.
5. **`blocked` ends every completion wait.** A blocked agent needs you, and
   without it you burn the whole timeout.
6. **Capture and review output** before merging. Do not blindly merge.
7. **Merge one at a time**, waiting for each to finish before the next, to avoid
   conflicts.
8. **Always pass a timeout, in the host's unit.**
9. **Completion is `idle` or `done` after real work.** `unknown`, `error`, and a
   startup `idle` are not.
10. You are a coordinator, not an implementer. Never edit source files directly.
