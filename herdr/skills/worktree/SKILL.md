---
name: worktree
description: Dispatch free-form tasks to new git worktrees, one per task, for parallel or background work in this or another repo. Use for work described in conversation.
allowed-tools: Bash, Write
---

Tasks: $ARGUMENTS

Mechanics — contract, sequence, flags, prompt rules — are the `dispatch` skill. This
covers what is specific to free-form tasks.

## Dispatch, don't implement

Your whole job is writing prompt files and creating worktrees; the worktree agents
explore and implement. Write each prompt from what the request already gives you, and
ask when that isn't enough. Reading the codebase to fill a gap — directly or through a
subagent — is the one thing this skill never does.

Earlier conversation a task leans on ("do option 2") goes into the prompt verbatim.

## One worktree per task

A short kebab-case branch name (2–4 words) per task, one prompt and one worktree each,
and one per repository when a task spans repos.

## Target repo

The current repo's root as `--cwd` by default; a task naming another repository or an
absolute path uses that instead. Ask when a task's repo is ambiguous.

## Flags

- `--merge` — append to the prompt: "When finished, commit all changes with a clear
  message, rebase onto the base branch, and merge this branch into it."
- `--base <ref>` — pass through to `herdr worktree create`.

Fire-and-forget: report the branches and spaces created, then stop. `/coordinator`
covers naming agents, waiting on status, follow-ups, and merging.
