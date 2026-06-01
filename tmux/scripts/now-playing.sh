#!/usr/bin/env bash
# now-playing.sh — emit the current Apple Music track for the tmux status bar.
#
# Prints "  Artist — Title " (leading nerd-font note, trailing space) when
# Music.app is BOTH running and playing; prints nothing otherwise. The
# `is running` guard means we poll only when Music is already open — we never
# launch it. macOS 15.4+ locked down the system-wide MediaRemote framework that
# universal tools (nowplaying-cli) read, so this talks to Music.app directly via
# AppleScript, which still works. Wired into status-right in
# tmux/themes/{wave,lotus}.conf and refreshed every status-interval (5s).

max=45   # truncate the "Artist — Title" string past this many chars

now="$(osascript 2>/dev/null <<'APPLESCRIPT'
if application "Music" is running then
  tell application "Music"
    if player state is playing then
      return (artist of current track) & " — " & (name of current track)
    end if
  end tell
end if
APPLESCRIPT
)"

[ -z "$now" ] && exit 0

if [ "${#now}" -gt "$max" ]; then
  now="${now:0:max}…"
fi

# Leading glyph is nf-fa-music (U+F001 -> UTF-8 EF 80 81), in the Lilex Nerd
# Font. Emitted via octal escapes so the byte sequence is unambiguous in the
# source and survives editors that would mangle a literal private-use glyph.
printf '\357\200\201 %s ' "$now"
