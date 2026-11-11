#!/usr/bin/env bash
# Create a worktree for a dispatched agent: add it where Herdr's own worktree
# mod puts them (~/.herdr/worktrees/<repo>/<branch-slug>, so the sidebar nests
# it and its Open/Remove menus see it), copy the repo's untracked files, then
# open it as a space with Claude and a shell to its right. Claude gets the
# dispatch prompt for the branch (~/.herdr/dispatch/<slug>.md) as its first
# message, and the file is deleted once the space exists.
#
# Usage: worktree-create.sh --cwd <repo> --branch <name> [--base <ref>] [--focus]
# Without --focus the previously shown space is selected again.
# Prints {space, tab, terminal, pane, path} as JSON.

set -euo pipefail

cwd="" branch="" base=HEAD focus=""
while [ $# -gt 0 ]; do
  case "$1" in
    --cwd) cwd=$2; shift 2 ;;
    --branch) branch=$2; shift 2 ;;
    --base) base=$2; shift 2 ;;
    --focus) focus=1; shift ;;
    --no-focus) shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
if [ -z "$cwd" ] || [ -z "$branch" ]; then
  echo "usage: $0 --cwd <repo> --branch <name> [--base <ref>] [--focus]" >&2
  exit 2
fi

common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)
main=${common%/.git}
slug=$(printf '%s' "$branch" | sed -E 's/[^A-Za-z0-9._-]+/-/g; s/^-+|-+$//g')
path="$HOME/.herdr/worktrees/$(basename "$main")/$slug"

if git -C "$main" show-ref --verify --quiet "refs/heads/$branch"; then
  git -C "$main" worktree add "$path" "$branch" >&2
else
  git -C "$main" worktree add -b "$branch" "$path" "$base" >&2
fi
bash "$(dirname "$0")/worktree-copy-files.sh" "$path"

prompt="$HOME/.herdr/dispatch/$(printf '%s' "$branch" | tr -c '[:alnum:]' '-').md"
prev=$(herdr-app status | jq -r '.space // empty')
args=$(jq -n --arg folder "$path" '{folder: $folder, argv: ["claude"]}')
if [ -f "$prompt" ]; then
  args=$(jq --rawfile task "$prompt" '. + {task: $task}' <<<"$args")
fi
made=$(herdr-app do space.new "$args")
rm -f "$prompt"

terminal=$(jq -r .terminal <<<"$made")
pane=$(herdr-app ls | jq -r --arg t "$terminal" \
  'first(.. | objects | select(.terminal? == $t) | .pane) // empty')
if [ -n "$pane" ]; then
  herdr-app do pane.split "$(jq -n --arg p "$pane" '{direction: "right", pane: $p}')" >/dev/null
  herdr-app do pane.focus "$(jq -n --arg p "$pane" '{pane: $p}')" >/dev/null
fi
if [ -z "$focus" ] && [ -n "$prev" ]; then
  herdr-app do space.select "$(jq -n --arg id "$prev" '{id: $id}')" >/dev/null
fi

jq --arg pane "$pane" --arg path "$path" '. + {pane: $pane, path: $path}' <<<"$made"
