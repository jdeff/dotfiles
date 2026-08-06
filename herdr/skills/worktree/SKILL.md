---
name: worktree
description: Dispatch one or more free-form tasks to new git worktrees, one per task, for parallel or background work in this or another repo. Use for a task described in conversation; for a Linear ticket use /ticket, and for the full spawn→monitor→merge lifecycle use /coordinator.
allowed-tools: Bash, Write
---

Tasks: $ARGUMENTS

Use the `dispatch` skill for the contract, the write→verify→create→confirm sequence,
the flags, and the prompt rules. This skill covers only what is specific to
free-form tasks.

## You are a dispatcher, not an implementer

Do NOT explore, read, grep, or search the codebase, and do not send a subagent to.
Your job is to write prompt files and create worktrees — the worktree agents do the
work. If the request has enough context to write a prompt, write it. If it doesn't,
ask; don't go read code to find out.

If a task refers to earlier conversation ("do option 2"), include that context
verbatim in the prompt.

## One worktree per task

Generate a short kebab-case branch name (2–4 words) per task. One prompt and one
worktree each — and one per repository when a task spans repos.

## Target repo

Same repo by default: pass the repo root as `--cwd`. If a task names another
repository or an absolute path, use that as `--cwd`. If you can't tell which repo a
task belongs to, ask.

## Flags

- `--merge` — append to the prompt: "When finished, commit all changes with a clear
  message, rebase onto the base branch, and merge this branch into it."
- `--base <ref>` — pass through to `herdr worktree create`.

This skill is fire-and-forget: report the branches and spaces created, then stop.
For naming agents, waiting on status, sending follow-ups, or merging, use
`/coordinator`.
