# Herdr backend (Herdr.app on herdr-core). See host.sh for the interface.
# A space is Herdr's session; its sidebar nests a worktree's space under its
# repo by asking git, so the checkout's location doesn't matter to it.

host_open() {
  local path=$1 prompt=$3 focus=$4 prev args made terminal pane
  prev=$(herdr-app status | jq -r '.space // empty')
  args=$(jq -n --arg folder "$path" '{folder: $folder, argv: ["claude"]}')
  if [ -f "$prompt" ]; then
    args=$(jq --rawfile task "$prompt" '. + {task: $task}' <<<"$args")
  fi
  made=$(herdr-app do space.new "$args")

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

  jq -n --arg s "$(jq -r .space <<<"$made")" --arg a "$terminal" \
    '{host: "herdr", session: $s, agent: $a}'
}

host_close_session() {
  local space
  space=$(herdr-app ls | jq -r --arg t "$HC_TERMINAL_ID" \
    '.spaces[] | select(any(.tabs[].terminals[]; .terminal == $t)) | .id')
  if [ -z "$space" ]; then
    echo "no Herdr space holds terminal $HC_TERMINAL_ID; close it by hand" >&2
    return 1
  fi
  herdr-app do space.close "$(jq -n --arg id "$space" '{id: $id, confirmed: true}')"
}
