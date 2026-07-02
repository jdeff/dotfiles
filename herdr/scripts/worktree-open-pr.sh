#!/usr/bin/env bash
# Push the current Herdr worktree's branch and open a PR with gh, interactively,
# from a pane inside the worktree. Bound to a key (type=pane) and to the jdeff.flow
# "open-pr" action. Uses $PWD, so it must run in a pane cwd'd to the worktree.
set -u

pause() { printf '\n'; read -r -p "— press enter to close — " _; }
here="$PWD"

git -C "$here" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "Not inside a git worktree: $here"; pause; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "gh CLI not found on PATH."; pause; exit 1; }

branch=$(git -C "$here" rev-parse --abbrev-ref HEAD)
printf 'Worktree: %s\nBranch  : %s\n\n' "$here" "$branch"

read -r -p "Push '$branch' to origin and open a PR? [y/N] " go
case "$go" in y|Y) ;; *) echo "Aborted."; pause; exit 0 ;; esac

if ! git -C "$here" push -u origin "$branch"; then
  echo "push failed"; pause; exit 1
fi

# Run gh from inside the worktree so it targets the right repo/branch.
( cd "$here" && gh pr create --fill ) || echo "gh pr create failed (already open? try: gh pr view --web)"
pause
