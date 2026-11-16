# Dispatch in Rex

Each worktree gets its own Rex session, labelled `<repo>/<slug>`: Claude on the left,
a shell on the right. The `rex` skill covers anything beyond these commands.

## Address line

For a prompt that asks for a report back, end it with:

```text
Dispatched from Rex session <$REX_SESSION>, block <$REX_BLOCK>. Report back with the rex-messaging skill.
```

## Open

`wt` is the path `worktree-create` printed. Claude takes the prompt as its argument, so
the session holds its prompt from the moment it exists.

```bash
wt="<path>" f="<prompt file>"
test -s "$f" \
  && made=$(rex new "${wt#"$HOME"/src/.worktrees/}" -c "$wt" --window claude --json \
              -- claude "$(cat "$f")") \
  && rm "$f"
session=$(jq -r .session_id <<<"$made")
agent=$(jq -r '.initial_windows[0].block_ids[0]' <<<"$made")
rex split -s "$session" -b "$agent" --split=right -c "$wt" --focus=false
rex session move "$session" --after "$REX_SESSION"   # list it beside yours
echo "$session $agent"
```

Rex sessions are a flat list; the label and the move stand in for nesting under the
repo.

To show it in the app instead of staying put:
`rex do session.select session_id="$session"`. It is a client action, so it needs the
app's Remote Control setting; when it refuses, tell the user the session is in the
sidebar.
