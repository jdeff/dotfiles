# Vi keybindings, with comfort keys restored in insert mode.
#
# Mode indicator lives in the prompt (Starship): insert = green ❯,
# normal/command = yellow ❮. (zsh can't report visual mode to Starship, so
# visual displays the same as normal — a documented upstream limitation.)

bindkey -v   # enable vi keybindings (KEYTIMEOUT=1 set in 00-options for snappy Esc)

# Keep familiar emacs-style movement/editing in INSERT mode so the prompt
# still feels natural. (Normal mode retains full vi motions.)
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history

# Make backspace and ^H delete past the point where insert mode started.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# Press `v` in NORMAL mode to edit the current command line in $EDITOR (nvim).
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Incremental history search bindings (also available via fzf's Ctrl-R).
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M vicmd '^R' history-incremental-search-backward
