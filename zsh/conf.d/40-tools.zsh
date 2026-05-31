# Shell integrations for fzf and zoxide.

# ── fzf — fuzzy finder ───────────────────────────────────────────────────
# Provides: Ctrl-R (history), Ctrl-T (files), Alt-C (cd into subdir), and
# fuzzy tab-completion (**<tab>). `fzf --zsh` is supported on fzf 0.48+.
if command -v fzf >/dev/null; then
  source <(fzf --zsh)

  # Use fd for file/dir traversal so .gitignore is respected and it's fast.
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
fi

# ── zoxide — smarter cd ──────────────────────────────────────────────────
# `z foo` jumps to the most-frecent dir matching foo; `zi` picks interactively.
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi
