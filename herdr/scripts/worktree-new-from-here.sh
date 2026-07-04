#!/usr/bin/env bash
# Create a NEW Herdr worktree based on the CURRENT worktree's branch (stacked
# branches). Herdr's UI/keybinding new-worktree refuses to run from inside a linked
# worktree (error code linked_worktree_source) and always bases on the repo's
# primary/main HEAD. This calls the CLI with --base <current-branch> against the
# repo root, which git allows even when that branch is checked out elsewhere.
#
# Runs in a pane (type=pane); uses $PWD to detect the current branch + repo root.
# The new worktree fires worktree.created → copy-files + layout, same as any other.
set -u
herdr="${HERDR_BIN_PATH:-$HOME/.local/bin/herdr}"
pause() { printf '\n'; read -r -p "— press enter to close — " _; }
here="$PWD"

git -C "$here" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "Not inside a git worktree: $here"; pause; exit 1; }

base=$(git -C "$here" rev-parse --abbrev-ref HEAD)
# First `git worktree list` entry is always the primary working tree (repo root).
repo=$(git -C "$here" worktree list --porcelain | awk '/^worktree /{print $2; exit}')

printf 'New worktree stacked on:\n  base branch : %s\n  repo root   : %s\n\n' "$base" "$repo"
read -r -p "New branch name: " newb
[ -n "$newb" ] || { echo "No name given — aborted."; pause; exit 0; }

echo "Creating '$newb' based on '$base' …"
out=$("$herdr" worktree create --cwd "$repo" --branch "$newb" --base "$base" --focus --json 2>&1)
path=$(printf '%s' "$out" | jq -r '.result.worktree.path // empty' 2>/dev/null)
if [ -n "$path" ]; then
  # Success: focus has moved to the new space (Claude+shell laid out there).
  printf '\342\234\223 Created %s (branch %s ← %s)\n' "$path" "$newb" "$base"
else
  err=$(printf '%s' "$out" | jq -r '.error.message // empty' 2>/dev/null)
  printf '\342\234\227 Failed: %s\n' "${err:-$out}"
  pause
fi
