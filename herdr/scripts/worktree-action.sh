#!/usr/bin/env bash
# jdeff.flow action wrapper. A plugin action runs headless (cwd = plugin dir), but
# merge/open-pr are interactive, so open a pane in the target worktree space and run
# the lifecycle script there ($PWD becomes the worktree checkout via new_cwd=follow).
herdr="${HERDR_BIN_PATH:-$HOME/.local/bin/herdr}"
op="${1:?usage: worktree-action.sh <merge|open-pr>}"
script="$HOME/.config/herdr/scripts/worktree-${op}.sh"

# Anchor pane = the focused pane of the space the action was invoked on.
pane=$(printf '%s' "${HERDR_PLUGIN_CONTEXT_JSON:-}" | jq -r '.focused_pane_id // empty' 2>/dev/null)
[ -z "$pane" ] && pane="${HERDR_PANE_ID:-}"
[ -z "$pane" ] && exit 0

new=$("$herdr" pane split "$pane" --direction down --focus 2>/dev/null | jq -r '.result.pane.pane_id // empty')
[ -z "$new" ] && exit 0
"$herdr" pane run "$new" "bash '$script'"
