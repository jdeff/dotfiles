#!/usr/bin/env bash
# Merge the current Herdr worktree's branch into its base (the branch checked out
# in the repo's MAIN working tree), interactively, from a pane inside the worktree.
# Bound to a key (type=pane) and to the jdeff.flow "merge" action. Uses $PWD, so it
# must run in a pane whose cwd is the worktree checkout.
set -u

pause() { printf '\n'; read -r -p "— press enter to close — " _; }
here="$PWD"

git -C "$here" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "Not inside a git worktree: $here"; pause; exit 1; }

branch=$(git -C "$here" rev-parse --abbrev-ref HEAD)
# First entry of `git worktree list` is always the main working tree.
main_root=$(git -C "$here" worktree list --porcelain | awk '/^worktree /{print $2; exit}')
base=$(git -C "$main_root" rev-parse --abbrev-ref HEAD)

printf 'Worktree : %s\n' "$here"
printf 'Branch   : %s\n' "$branch"
printf 'Base     : %s  (%s)\n\n' "$base" "$main_root"

if [ "$here" = "$main_root" ]; then
  echo "This is the main worktree, not a feature worktree — nothing to merge."; pause; exit 1
fi

# Handle uncommitted work in the feature worktree.
if ! git -C "$here" diff --quiet || ! git -C "$here" diff --cached --quiet; then
  echo "⚠ Uncommitted changes in $branch:"; git -C "$here" status --short; echo
  read -r -p "Commit them all now? [y/N] " a
  case "$a" in
    y|Y)
      read -r -p "Commit message: " msg
      git -C "$here" add -A && git -C "$here" commit -m "$msg" \
        || { echo "commit failed"; pause; exit 1; } ;;
    *) echo "Aborting — commit or stash first."; pause; exit 1 ;;
  esac
fi

read -r -p "Merge '$branch' into '$base'? [y/N] " go
case "$go" in y|Y) ;; *) echo "Aborted."; pause; exit 0 ;; esac

if git -C "$main_root" merge --no-ff "$branch"; then
  printf '\n✓ Merged %s into %s.\n' "$branch" "$base"
  echo "Remove this worktree from the sidebar (right-click the space) when you're done."
else
  printf '\n✗ Merge hit conflicts. Resolve them in the main worktree:\n  %s\n' "$main_root"
fi
pause
