---
name: merge
description: Commit, sync the base, rebase, and merge the current branch into its base.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
---

**Arguments:** `$ARGUMENTS`

Check the arguments for flags:

- `--keep`, `-k` → keep the worktree checkout and its Herdr space after merging
- `--no-verify`, `-n` → pass `--no-verify` to `git commit` (skip hooks)

Strip all flags from arguments.

Finish work on the current branch: commit what is staged, bring the base up to
date, rebase onto it, merge into it, and clean up the worktree.

## Step 1: Commit

If there are staged changes, commit them. Use lowercase, imperative mood, no
conventional commit prefixes. Skip if nothing is staged. Add `--no-verify` only
if that flag was passed.

## Step 2: Sync the base

The base branch is whatever the repo's **main** working tree has checked out
(the first entry of `git worktree list` is always the main tree); default to
`main` if that yields nothing usable. Fetch its upstream and compare:

```bash
main_root=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')
base=$(git -C "$main_root" rev-parse --abbrev-ref HEAD)
upstream=$(git -C "$main_root" rev-parse --abbrev-ref "$base@{upstream}")   # e.g. origin/main
git fetch "${upstream%%/*}"
git rev-parse "$base" "$upstream"
```

This step is done when both hashes match. Otherwise stop before touching
anything and ask what to do, reporting how the base relates to its upstream
(`git rev-list --left-right --count "$base...$upstream"` gives ahead/behind
counts) with these choices:

- **Fast-forward the base and continue** — offer only when the base is strictly
  behind and the main working tree is clean: `git -C "$main_root" merge --ff-only "$upstream"`
- **Continue against the stale base**
- **Abort**

A base with no upstream configured, an ahead or diverged base, or a dirty main
working tree is the user's call; present the situation and wait.

## Step 3: Rebase

Rebase onto the local base. The merge in step 4 lands in the main working tree,
so the branch must sit on the tip that tree has checked out:

```bash
git rebase "$base"
```

If the rebase drops every commit as already upstream, the branch's work has
already landed; carry on, since the merge will report "Already up to date" and
the worktree still needs cleaning up.

On conflicts, understand the base's side first: run
`git log -p -n 3 "$base" -- <file>` for each conflicting file, resolve so both
the base's changes and this branch's survive, stage the file, and
`git rebase --continue`. Ask for guidance when a conflict is unclear.

## Step 4: Merge

This step needs a non-main worktree; in the main tree there is nothing to merge,
so stop and say so. Otherwise merge the branch into its base, in the main working
tree:

```bash
git -C "$main_root" merge --no-ff "$(git branch --show-current)"
```

If the merge hits conflicts, stop and report that they must be resolved in the
main worktree (print its path). Do not attempt to resolve them from here.

## Step 5: Clean up

Unless `--keep` was passed, remove the worktree checkout and its Herdr space.
This keeps the branch; only the checkout and the space go away:

```bash
herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
```

`$HERDR_WORKSPACE_ID` is injected into every Herdr-managed pane. If it is unset
(not running inside Herdr), skip this step and tell the user to remove the
worktree themselves.

Removing the space closes the pane you are running in, so make this the last
action and report the merge result before doing it.

## Interactive alternative

The same flow exists as a keybinding for when you'd rather drive it yourself:
`prefix shift+m` (or the "Merge worktree → base" right-click action on a space)
runs `~/.config/herdr/scripts/worktree-merge.sh`, which prompts at each step but
does not fetch first.
