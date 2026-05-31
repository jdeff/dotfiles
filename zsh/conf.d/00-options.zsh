# Shell options: history, directory navigation, globbing, misc.

# ── History ──────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000        # lines kept in memory
SAVEHIST=50000        # lines persisted to $HISTFILE

setopt EXTENDED_HISTORY        # record timestamp + duration
setopt SHARE_HISTORY           # share history live across sessions
setopt INC_APPEND_HISTORY      # append as commands run, not at shell exit
setopt HIST_IGNORE_ALL_DUPS    # drop older duplicate of a repeated command
setopt HIST_IGNORE_SPACE       # don't record commands prefixed with a space
setopt HIST_REDUCE_BLANKS      # tidy up superfluous whitespace
setopt HIST_VERIFY             # expand !! etc. onto the line before running

# ── Directory navigation ─────────────────────────────────────────────────
setopt AUTO_CD                 # `foo` cds into ./foo if it's a directory
setopt AUTO_PUSHD              # cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS       # no duplicate entries on the stack
setopt PUSHD_SILENT            # don't print the stack after pushd/popd

# ── Completion / globbing / misc ─────────────────────────────────────────
setopt COMPLETE_IN_WORD        # complete from both ends of the word
setopt ALWAYS_TO_END           # move cursor to end after completion
setopt EXTENDED_GLOB           # ^ ~ # glob operators
setopt INTERACTIVE_COMMENTS    # allow # comments at the interactive prompt
setopt NO_BEEP                 # override the system /etc/zshrc BEEP

# Snappy vi-mode: shrink the wait for multi-key sequences to 0.1s.
export KEYTIMEOUT=1
