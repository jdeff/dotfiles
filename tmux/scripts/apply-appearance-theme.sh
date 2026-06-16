#!/usr/bin/env bash
# Apply the theme matching the CURRENT macOS appearance, run once at tmux start.
#
# Why this exists: tmux-dark-notify is event-driven — it only re-sources a theme
# when macOS *changes* light/dark. It does not apply the current state on launch.
# The old startup hook sourced the state symlink, whose value is just whatever
# the last change event left behind, so after a reboot/login the bar could stick
# on a stale theme until the next manual toggle. Here we actively detect the
# appearance and hand the mode to the plugin's own setter (which sources the
# theme and refreshes the symlink). Falls back to the symlink if detection or
# the setter is unavailable.
set -o errexit
set -o pipefail

PLUGIN_DIR="$HOME/.config/tmux/plugins/tmux-dark-notify/scripts"
SETTER="$PLUGIN_DIR/tmux-theme-mode.sh"
STATE_LINK="${XDG_STATE_HOME:-$HOME/.local/state}/tmux/tmux-dark-notify-theme.conf"

if command -v defaults >/dev/null 2>&1 && [ -x "$SETTER" ]; then
	mode=light
	if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
		mode=dark
	fi
	exec "$SETTER" "$mode"
fi

# Fallback: source the last-known theme if the symlink exists.
if [ -e "$STATE_LINK" ]; then
	tmux source-file "$STATE_LINK"
fi
