#!/usr/bin/env bash
# Copy per-repo untracked files into a freshly created Herdr worktree — the
# herdr-native replacement for workmux's `files:` copy/symlink (git does not
# populate untracked files like .env.local or .muster.yaml in new worktrees).
#
# Wired to the `worktree.created` event in the jdeff.flow plugin. Reads a
# `.worktree-files` manifest from the worktree's MAIN checkout; each non-blank,
# non-comment line is:
#     copy <path>      # copy main/<path> → worktree/<path> (skip if dest exists)
#     link <path>      # symlink worktree/<path> → main/<path>
# Paths are relative to the repo root. Idempotent and non-destructive.
#
# Robust to the event schema: the new worktree path comes from the event's
# worktree.path if present, else from the created workspace's first pane cwd.
# Set HERDR_COPY_DEBUG=1 to log decisions to ~/.herdr/worktree-copy.log.

set -u
herdr="${HERDR_BIN_PATH:-$HOME/.local/bin/herdr}"
ev="${HERDR_PLUGIN_EVENT_JSON:-}"
log() { [ "${HERDR_COPY_DEBUG:-}" = "1" ] && printf '%s %s\n' "$(date +%H:%M:%S)" "$*" >>"$HOME/.herdr/worktree-copy.log"; return 0; }

log "event: $ev"

# 1) Resolve the new worktree's checkout path and its repo's MAIN checkout from
#    the event. The `worktree.created` payload nests these under `.data`; older/
#    other shapes are tolerated via fallbacks.
q() { printf '%s' "$ev" | jq -r "$1 // empty" 2>/dev/null; }
wt=$(q '.data.worktree.path // .worktree.path // .data.worktree.checkout_path // .worktree.checkout_path')
main=$(q '.data.workspace.worktree.repo_root // .workspace.worktree.repo_root')

if [ -z "$wt" ]; then
  # Last resort: the created workspace's first pane cwd.
  ws=$(q '.data.worktree.open_workspace_id // .data.workspace.workspace_id // .worktree.open_workspace_id // .workspace.workspace_id')
  [ -n "$ws" ] && wt=$("$herdr" pane list --workspace "$ws" 2>/dev/null | jq -r '.result.panes[0].cwd // empty')
fi
[ -n "$wt" ] && [ -d "$wt" ] || { log "no worktree path resolved; exiting"; exit 0; }

# Fall back to `git worktree list` for the main checkout if the event lacked it.
if [ -z "$main" ]; then
  main=$(git -C "$wt" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}')
fi
[ -n "$main" ] || { log "could not resolve main checkout for $wt"; exit 0; }
if [ "$main" = "$wt" ]; then log "worktree is the main checkout ($wt); nothing to copy"; exit 0; fi

manifest="$main/.worktree-files"
[ -f "$manifest" ] || { log "no manifest at $manifest"; exit 0; }
log "worktree=$wt main=$main manifest=$manifest"

# 3) Apply each directive.
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|'#'*) continue ;; esac
  mode=${line%% *}; rel=${line#* }
  # trim surrounding whitespace from rel
  rel=$(printf '%s' "$rel" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  [ -n "$rel" ] || continue
  src="$main/$rel"; dst="$wt/$rel"
  case "$mode" in
    copy)
      if [ -e "$dst" ]; then log "skip copy (exists): $rel"
      elif [ -e "$src" ]; then mkdir -p "$(dirname "$dst")" && cp -R "$src" "$dst" && log "copied $rel"
      else log "skip copy (no source): $rel"; fi
      ;;
    link)
      if [ -e "$dst" ] || [ -L "$dst" ]; then log "skip link (exists): $rel"
      elif [ -e "$src" ]; then mkdir -p "$(dirname "$dst")" && ln -s "$src" "$dst" && log "linked $rel"
      else log "skip link (no source): $rel"; fi
      ;;
    *) log "unknown directive: $line" ;;
  esac
done < "$manifest"
log "done"
