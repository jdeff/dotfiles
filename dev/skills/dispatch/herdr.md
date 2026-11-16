# Dispatch in Herdr

Each worktree gets its own Herdr space: Claude on the left, a shell on the right. The
sidebar nests it under its repo's space by asking git. The `herdr-app` skill covers
the window, and `hc` the terminals.

## Address line

For a prompt that asks for a report back, end it with:

```text
Dispatched from Herdr terminal <$HC_TERMINAL_ID>. Report back with `hc send <$HC_TERMINAL_ID> "<message>"`.
```

## Open

`wt` is the path `worktree-create` printed. `space.new` hands Claude the prompt as its
`task`.

```bash
wt="<path>" f="<prompt file>"
prev=$(herdr-app status | jq -r '.space // empty')
test -s "$f" \
  && made=$(herdr-app do space.new "$(jq -n --arg folder "$wt" --rawfile task "$f" \
              '{folder: $folder, argv: ["claude"], task: $task}')") \
  && rm "$f"
terminal=$(jq -r .terminal <<<"$made")
pane=$(herdr-app ls | jq -r --arg t "$terminal" \
  'first(.. | objects | select(.terminal? == $t) | .pane) // empty')
herdr-app do pane.split "$(jq -n --arg p "$pane" '{direction: "right", pane: $p}')" >/dev/null
herdr-app do pane.focus "$(jq -n --arg p "$pane" '{pane: $p}')" >/dev/null
herdr-app do space.select "$(jq -n --arg id "$prev" '{id: $id}')" >/dev/null   # stay put
echo "$(jq -r .space <<<"$made") $terminal"
```

To show the new space instead, drop the `space.select` line. The agent's handle in
every `hc` command is `$terminal`. The app started it, so it is not your `hc` child:
wait on it by address.
