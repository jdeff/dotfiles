---
name: worktree-herdr
description: Launch one or more tasks in new git worktrees using Herdr (the workmux /worktree analog).
disable-model-invocation: true
allowed-tools: Bash, Write
---

Launch one or more tasks in new git worktrees using Herdr.

Tasks: $ARGUMENTS

## You are a dispatcher, not an implementer

**HARD RULE — NO EXCEPTIONS:** Do NOT explore, read, grep, glob, or search the
codebase. Do NOT use the Task/Explore agent. Do NOT investigate the problem. You
are a thin dispatcher — your ONLY job is to write prompt files and run
`herdr worktree create`. The worktree agent will do all the exploration and
implementation.

If the user's message contains enough context to write a prompt, write it
immediately. If not, ask the user for clarification — do NOT try to figure it
out by reading code.

If tasks reference earlier conversation (e.g., "do option 2"), include all
relevant context in each prompt you write.

If tasks reference a markdown file (e.g., a plan or spec), re-read the file to
ensure you have the latest version before writing prompts.

## How dispatch works with Herdr

`herdr worktree create` opens the new worktree as its own Herdr space, grouped
under the source repo. The `jdeff.flow` layout plugin fires on `worktree.created`
and lays out **Claude (focused) + a shell**. If a dispatch prompt exists for the
new branch, that Claude launches with the prompt as its first message; otherwise
it starts bare.

The contract: write the prompt to `~/.herdr/dispatch/<slug>.md`, where
`slug` is the branch run through `tr -c '[:alnum:]' '-'` (the layout script uses
the exact same transform to find it). Then create the worktree with that branch.
The file is consumed and deleted when Claude launches.

Because each dispatched Claude starts fresh with only the prompt you write, it has
no `/worktree-herdr` context and will not recursively dispatch — no guard needed.

## Requirements

- The Herdr server must be running (the user is inside `herdr`).
- The `jdeff.flow` plugin must be enabled: `herdr plugin list` should show it.
  (Without it, the worktree is created but Claude is not auto-launched.)

## For each task

1. Generate a short, descriptive branch name (2-4 words, kebab-case).
2. Write a detailed implementation prompt to `~/.herdr/dispatch/<slug>.md`.
3. Create the worktree (which auto-launches the prompted Claude).

The prompt should:

- Include the full task description.
- Use RELATIVE paths only (each worktree has its own root directory).
- Be specific about what the agent should accomplish.

## Skill delegation

If the user passes a skill reference (e.g., `/auto`, `/plan-review`), the prompt
should instruct the agent to use that skill instead of writing out manual steps.

**Skills can have flags.** If the user passes `/auto --gemini`, pass the flag
through to the skill invocation in the prompt.

Example prompt body:
```
[Task description here]

Use the skill: /skill-name [flags if any] [task description]
```

Do NOT write detailed implementation steps when a skill is specified.

## Flags

**`--merge`**: Append a merge instruction to the prompt. Only when explicitly
requested:
```
When finished, commit all changes with a clear message, rebase onto the base
branch, and merge this branch into it.
```

**`--base <ref>`**: Pass `--base <ref>` to `herdr worktree create` to branch from
`<ref>` instead of the repo's current HEAD.

(There is no `--fork` — Herdr has no conversation-copy. Put any needed context
directly into the prompt instead.)

## Target repository

- **Same repo (default):** capture the repo root and pass it as `--cwd`. Do not
  `cd`. The worktree branches from that repo's current HEAD (or `--base`).
- **Cross-project:** if a task names another repository or absolute path, use that
  path as `--cwd`. No session setup is needed — Herdr groups the worktree under
  the target repo automatically. One prompt + one worktree per repository.

If the request lacks enough information to identify the target repo, ask instead
of searching.

## Workflow

Write ALL prompt files first, THEN run all `herdr worktree create` commands.

Step 1 — write every prompt file (in parallel). Compute the slug with the SAME
transform the layout script uses:

```bash
mkdir -p ~/.herdr/dispatch
branch="feature-x"                                   # your kebab-case name
slug=$(printf '%s' "$branch" | tr -c '[:alnum:]' '-')
cat > ~/.herdr/dispatch/"$slug".md << 'EOF'
Implement feature X...
(relative paths only)
EOF
```

Step 2 — after ALL files are written, create the worktrees (in parallel). Use the
repo root for `--cwd`:

```bash
repo="$(git rev-parse --show-toplevel)"              # same-repo; or an absolute path cross-project
herdr worktree create --cwd "$repo" --branch feature-x --no-focus
herdr worktree create --cwd "$repo" --branch feature-y --no-focus
```

After creating the worktrees, tell the user which branches/spaces were created and
that each has a Claude working on its task (visible in the sidebar).

**Remember:** Your task is COMPLETE once the worktrees are created. Do NOT
implement anything yourself.
