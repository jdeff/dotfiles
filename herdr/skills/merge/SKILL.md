---
name: merge
description: Commit, rebase, and merge the current branch into its base.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep
---

**Arguments:** `$ARGUMENTS`

Check the arguments for flags:

- `--keep`, `-k` → keep the worktree checkout and its Herdr space after merging
- `--no-verify`, `-n` → pass `--no-verify` to `git commit` (skip hooks)

Strip all flags from arguments.

Commit, rebase, and merge the current branch.

This command finishes work on the current branch by:

1. Committing any staged changes
2. Rebasing onto the base branch
3. Merging into the base branch and cleaning up the worktree

## Step 1: Commit

If there are staged changes, commit them. Use lowercase, imperative mood, no
conventional commit prefixes. Skip if nothing is staged. Add `--no-verify` only
if that flag was passed.

## Step 2: Rebase

Determine the base branch — whatever is checked out in the repo's **main**
working tree (the first entry of `git worktree list` is always the main tree):

```bash
main_root=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')
base=$(git -C "$main_root" rev-parse --abbrev-ref HEAD)
```

If that yields nothing usable, default to `main`.

Rebase onto the local base branch (do NOT fetch from origin first):

```bash
git rebase <base-branch>
```

IMPORTANT: Do NOT run `git fetch`. Do NOT rebase onto `origin/<branch>`. Only
rebase onto the local branch name (e.g. `git rebase main`, not
`git rebase origin/main`).

If conflicts occur:

- BEFORE resolving any conflict, understand what changes were made to each
  conflicting file in the base branch
- For each conflicting file, run `git log -p -n 3 <base-branch> -- <file>` to
  see recent changes to that file in the base branch
- The goal is to preserve BOTH the changes from the base branch AND our branch's
  changes
- After resolving each conflict, stage the file and continue with
  `git rebase --continue`
- If a conflict is too complex or unclear, ask for guidance before proceeding

## Step 3: Merge

Refuse to proceed if this *is* the main worktree — there is nothing to merge.
Otherwise merge the branch into its base, in the main working tree:

```bash
git -C "$main_root" merge --no-ff <branch>
```

If the merge hits conflicts, stop and report that they must be resolved in the
main worktree (print its path). Do not attempt to resolve them from here.

## Step 4: Clean up

Unless `--keep` was passed, remove the worktree checkout and its Herdr space.
This keeps the branch — only the checkout and the space go away:

```bash
herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
```

`$HERDR_WORKSPACE_ID` is injected into every Herdr-managed pane. If it is unset
(not running inside Herdr), skip this step and tell the user to remove the
worktree themselves.

Note that removing the space closes the pane you are running in, so make this
the last action and report the merge result before doing it.

## Interactive alternative

The same flow exists as a keybinding for when you'd rather drive it yourself:
`prefix shift+m` (or the "Merge worktree → base" right-click action on a space)
runs `~/.config/herdr/scripts/worktree-merge.sh`, which prompts at each step.
