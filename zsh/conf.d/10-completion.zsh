# Completion system: fpath sources, compinit (cached), and styling.

# Completion sources: zsh-completions, Homebrew formulae, asdf, workmux. Must precede compinit.
fpath=(
  /opt/homebrew/share/zsh-completions
  /opt/homebrew/share/zsh/site-functions
  "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
  $fpath
)

# Regenerate the asdf completion if it's missing (e.g. after an asdf upgrade).
if [[ ! -f "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf" ]]; then
  mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
fi

# Same for workmux (built from a fork in ~/.local/bin — regenerate after a rebuild).
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
