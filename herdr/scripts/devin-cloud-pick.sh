#!/usr/bin/env bash
# Pick one of your Devin Cloud sessions with fzf and open it as a Herdr workspace
# running `devin --cloud -r <id>`, which streams the cloud session into the pane.
# If a pane is already attached to that session, focus its workspace instead.
#
# Bound to a key (type=pane). In fzf: enter opens, ctrl-o opens the session in the
# browser, ctrl-r reloads the list.
#
# The workspace starts in the local checkout of the session's first repo (found via
# Herdr's workspace list, else ~/src/<repo> or ~/src/*/<repo>, else $HOME), so
# /pickup lands somewhere useful. devin asks once per directory whether to trust it.
#
# Not restored by Herdr after a server restart: the devin integration would resume
# with `devin --resume <id>`, which opens an empty *local* session for a cloud id, so
# these panes deliberately report no session. Re-run the picker to reattach.
set -u
herdr="${HERDR_BIN_PATH:-$HOME/.local/bin/herdr}"
scripts="$HOME/.config/herdr/scripts"
pause() { printf '\n'; read -r -p "— press enter to close — " _; }

cache=$(mktemp "${TMPDIR:-/tmp}/devin-cloud.XXXXXX")
trap 'rm -f "$cache"' EXIT

list="python3 '$scripts/devin-cloud-sessions.py' '$cache'"
preview="jq -r --arg id {1} '.[\$id] | ._meta as \$m |
  \"\(.title // \"(untitled)\")\",
  \"\",
  \"status   \(\$m[\"cognition.ai/sessionStatus\"]) (\(\$m[\"cognition.ai/statusReason\"] // \"-\"))\",
  \"origin   \(\$m[\"cognition.ai/sessionOrigin\"] // \"-\")\",
  \"repos    \([\$m[\"cognition.ai/sessionRepos\"][]?.name] | join(\", \"))\",
  \"url      \(\$m[\"cognition.ai/url\"])\",
  \"\",
  (\$m[\"cognition.ai/sessionPRs\"][]? | \"PR [\(.state)] \(.title)\n   \(.url)\"),
  \"\",
  (\$m[\"cognition.ai/messageExcerpts\"] // \"\" | .[0:1500])' '$cache'"

rows=$(eval "$list") || { pause; exit 1; }
[ -n "$rows" ] || { echo "No Devin Cloud sessions."; pause; exit 0; }

pick=$(printf '%s\n' "$rows" | fzf --ansi --delimiter='\t' --with-nth=2 --no-sort \
  --prompt='devin cloud> ' --header='enter: open · ctrl-o: browser · ctrl-r: reload' \
  --preview="$preview" --preview-window='right,55%,wrap,<120(down,50%,wrap)' \
  --bind="ctrl-o:execute-silent(jq -r --arg id {1} '.[\$id]._meta[\"cognition.ai/url\"]' '$cache' | xargs open)" \
  --bind="ctrl-r:reload($list)")
[ -n "$pick" ] || exit 0
id=${pick%%$'\t'*}

# Already attached somewhere? Focus that workspace.
while IFS=$'\t' read -r pane ws; do
  if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
    | jq -e --arg id "$id" 'any(.result.process_info.foreground_processes[]; .argv | index($id) != null)' >/dev/null; then
    "$herdr" workspace focus "$ws" >/dev/null
    exit 0
  fi
done < <("$herdr" pane list 2>/dev/null | jq -r '.result.panes[] | select(.agent == "devin") | [.pane_id, .workspace_id] | @tsv')

title=$(jq -r --arg id "$id" '.[$id].title // "devin"' "$cache")
repo=$(jq -r --arg id "$id" '.[$id]._meta["cognition.ai/sessionRepos"][0].name // empty | split("/") | last' "$cache")
cwd=""
if [ -n "$repo" ]; then
  cwd=$("$herdr" workspace list 2>/dev/null | jq -r --arg r "$repo" \
    'first(.result.workspaces[].worktree | select(.repo_name == $r and .is_linked_worktree == false) | .checkout_path) // empty')
  if [ -z "$cwd" ]; then
    for d in "$HOME/src/$repo" "$HOME"/src/*/"$repo"; do
      [ -d "$d" ] && { cwd=$d; break; }
    done
  fi
fi
[ -n "$cwd" ] || cwd="$HOME"

out=$("$herdr" workspace create --cwd "$cwd" --label "☁ ${title:0:40}" --focus 2>&1)
pane=$(printf '%s' "$out" | jq -r '.result.root_pane.pane_id // empty' 2>/dev/null)
if [ -z "$pane" ]; then
  printf 'Failed to create workspace: %s\n' "$out"; pause; exit 1
fi
"$herdr" pane run "$pane" "devin --cloud -r $id" >/dev/null
