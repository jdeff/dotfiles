#!/bin/sh
# Detect the macOS appearance and, when it changes, swap the tmux status theme
# (Kanagawa Wave for dark, Lotus for light). Invoked from the status line via
# #() so it polls on status-interval, and once on load via run-shell. Prints a
# moon/sun glyph for the current mode.

if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
  mode="dark"
else
  mode="light"
fi

# Only re-source when the mode actually changed (avoids needless redraws).
if [ "$mode" != "$(tmux show -gqv @theme_mode)" ]; then
  tmux set -g @theme_mode "$mode"
  if [ "$mode" = "dark" ]; then
    tmux source-file "$HOME/.config/tmux/themes/wave.conf"
  else
    tmux source-file "$HOME/.config/tmux/themes/lotus.conf"
  fi
fi

# Mode indicator:  (dark) /  (light).
if [ "$mode" = "dark" ]; then printf ''; else printf ''; fi
