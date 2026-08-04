#!/usr/bin/env bash
# Lay out a workspace the default way: Claude focused + a shell beside it.
# Called two ways:
#   1) keybinding  (prefix+a) — lays out the focused workspace on demand
#   2) plugin event (worktree.created) — auto-lays-out each new worktree workspace
#
# Dispatch integration: if a dispatch prompt exists for the new worktree's branch
# (written by the /worktree-herdr skill to $HERDR_DISPATCH_DIR/<slug>.md, where
# slug = branch piped through `tr -c '[:alnum:]' '-'`), Claude launches with that
# prompt as its first message instead of starting bare. The prompt file is removed
# after it is read.
#
# Idempotent: only acts when the workspace still has a single pane.
# POSIX-portable (macOS /bin/bash 3.2 has no mapfile); no `set -e` (avoids
# the `test && cmd` early-exit foot-gun). Set HERDR_LAYOUT_DRYRUN=1 to print the
# resolved workspace/pane and agent command instead of acting.

herdr="${HERDR_BIN_PATH:-$HOME/.local/bin/herdr}"

# worktree.created events arrive wrapped as {"event":..,"data":{..}}; the manual
# `layout` action / keybinding pass a flat payload. `(.data // .)` handles both.

# Resolve target workspace id, most-specific source first.
ws=""
if [ -n "${HERDR_PLUGIN_EVENT_JSON:-}" ]; then
  ws=$(printf '%s' "$HERDR_PLUGIN_EVENT_JSON" \
    | jq -r '(.data // .) | .workspace.workspace_id // .worktree.open_workspace_id // .workspace_id // empty' 2>/dev/null)
fi
if [ -z "$ws" ]; then ws="${1:-}"; fi
if [ -z "$ws" ]; then ws="${HERDR_WORKSPACE_ID:-}"; fi
if [ -z "$ws" ]; then
  ws=$("$herdr" workspace list 2>/dev/null \
    | jq -r '.result.workspaces[] | select(.focused==true) | .workspace_id' | head -n1)
fi
if [ -z "$ws" ]; then exit 0; fi

# Only lay out an untouched (single-pane) workspace.
panes=$("$herdr" pane list --workspace "$ws" 2>/dev/null | jq -r '.result.panes[].pane_id')
count=$(printf '%s\n' "$panes" | grep -c '[^[:space:]]')
if [ "$count" -ne 1 ]; then exit 0; fi
first=$(printf '%s\n' "$panes" | head -n1)

# Prompted (dispatch) or bare Claude? Only worktree.created events carry a branch.
dispatch_dir="${HERDR_DISPATCH_DIR:-$HOME/.herdr/dispatch}"
prompt_file=""
branch=$(printf '%s' "${HERDR_PLUGIN_EVENT_JSON:-}" | jq -r '(.data // .) | .worktree.branch // empty' 2>/dev/null)
if [ -n "$branch" ]; then
  slug=$(printf '%s' "$branch" | tr -c '[:alnum:]' '-')
  [ -f "$dispatch_dir/$slug.md" ] && prompt_file="$dispatch_dir/$slug.md"
fi

if [ -n "$prompt_file" ]; then
  # Read the prompt in the pane's shell, delete it, then start Claude with it.
  agent_cmd="p=\$(cat '$prompt_file'); rm -f '$prompt_file'; claude \"\$p\""
else
  agent_cmd="claude"
fi

if [ "${HERDR_LAYOUT_DRYRUN:-}" = "1" ]; then
  echo "ws=$ws first=$first branch=${branch:-} prompt_file=${prompt_file:-}"
  echo "agent_cmd=$agent_cmd"
  exit 0
fi

# Shell to the right (unfocused), Claude in the original pane (stays focused).
"$herdr" pane split "$first" --direction right --no-focus >/dev/null 2>&1
"$herdr" pane run "$first" "$agent_cmd" >/dev/null 2>&1
