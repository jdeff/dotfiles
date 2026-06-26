# Completion system: fpath sources, compinit (cached), and styling.

# Completion sources: zsh-completions, Homebrew formulae (incl. mise's _mise),
# workmux. Must precede compinit.
fpath=(
  /opt/homebrew/share/zsh-completions
  /opt/homebrew/share/zsh/site-functions
  "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
  $fpath
)

# workmux is built from a fork in ~/.local/bin (not brew), so generate its
# completion here if missing — regenerate after a rebuild.
if command -v workmux >/dev/null && [[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions/_workmux" ]]; then
  mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
  workmux completions zsh > "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions/_workmux"
fi

# Initialize completion, rebuilding the dump cache at most once a day for speed.
autoload -Uz compinit
if [[ -n "$HOME"/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ── Completion styling ───────────────────────────────────────────────────
# Menu selection: arrow-key navigable completion menu.
zstyle ':completion:*' menu select
# Case-insensitive, then partial-word, matching.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
# Colorize file/dir completions to match LS_COLORS.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Group results under descriptive headers.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
# Cache slow completions (e.g. brew, apt).
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
