# Sourced by the worktree scripts. Detects which multiplexer this terminal runs
# in and loads its backend from host-<name>.sh, which defines:
#
#   host_open PATH LABEL PROMPT_FILE FOCUS
#       Open a session at PATH running Claude, with PROMPT_FILE's contents as
#       its first message when the file exists, and a shell to its right.
#       FOCUS is 1 to show the new session, empty to stay put.
#       Prints {host, session, agent} as JSON; agent is the terminal Claude
#       runs in (a Herdr terminal address, a Rex block id).
#
#   host_close_session
#       Close the session holding this terminal, which ends this terminal too.
#
# Everything multiplexer-specific lives in the backends; nothing else in bin/
# or the skills should name Herdr or Rex.

if [ -n "${REX_SESSION:-}" ]; then
  WT_HOST=rex
elif [ -n "${HC_TERMINAL_ID:-}" ]; then
  WT_HOST=herdr
else
  WT_HOST=none
fi

# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")/host-$WT_HOST.sh"
