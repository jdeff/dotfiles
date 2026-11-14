# Rex backend. See host.sh for the interface. Rex's sessions are a flat,
# ordered list, so the label carries the repo and a new session is placed after
# the one that dispatched it.

host_open() {
  local path=$1 label=$2 prompt=$3 focus=$4 made session block
  # The prompt rides in argv, so a session that exists has its prompt.
  local argv=(claude)
  if [ -f "$prompt" ]; then
    argv+=("$(cat "$prompt")")
  fi
  made=$(rex new "$label" -c "$path" --window claude --json -- "${argv[@]}")
  session=$(jq -r .session_id <<<"$made")
  block=$(jq -r '.initial_windows[0].block_ids[0]' <<<"$made")

  rex split -s "$session" -b "$block" --split=right -c "$path" --focus=false --json >/dev/null
  rex session move "$session" --after "$REX_SESSION" >/dev/null 2>&1 || true
  if [ -n "$focus" ]; then
    # A client action: needs the app's Remote Control setting on.
    rex do session.select session_id="$session" >/dev/null 2>&1 \
      || echo "could not show $label in the app (is Remote Control on?)" >&2
  fi

  jq -n --arg s "$session" --arg a "$block" '{host: "rex", session: $s, agent: $a}'
}

host_close_session() {
  rex kill "$REX_SESSION"
}
