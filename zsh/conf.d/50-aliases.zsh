# General aliases + modern-CLI swaps, then load the prezto-derived modules.

# ── Modern CLI replacements ──────────────────────────────────────────────
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
fi

if command -v bat >/dev/null; then
  # bat auto-detects when output isn't a TTY and behaves like cat, so this is
  # safe in pipes/scripts. Override theme in ~/.zshrc.local if desired.
  alias cat='bat'
  export BAT_THEME='ansi'
fi

# fd (find) and rg (ripgrep) are used by their own names — intentionally NOT
# aliased over `find`/`grep`, whose flags differ and would surprise scripts.

# workmux: git-worktree + tmux-window manager (single binary in ~/.local/bin,
# built from the jdeff fork — see workmux/README.md).
if command -v workmux >/dev/null; then
  alias wm='workmux'

  # Common subcommands (worktree lifecycle + open/close + dashboard).
  alias wma='workmux add'       # create a worktree + tmux window
  alias wmr='workmux remove'    # remove worktree/window/branch (no merge)
  alias wmm='workmux merge'     # merge branch, then clean up
  alias wml='workmux list'      # list worktrees
  alias wmo='workmux open'      # open a window for an existing worktree
  alias wmc='workmux close'     # close the window (keep worktree + branch)
  alias wmd='workmux dashboard' # TUI dashboard of active agents

  # Pull the fork and rebuild the binary in one step ("ready to go").
  workmux-update() {
    emulate -L zsh
    local src="${WORKMUX_SRC:-$HOME/src/workmux}"
    git -C "$src" pull --ff-only && cargo install --path "$src" --root "$HOME/.local" --force --locked
  }
fi

# ── Prezto-derived alias modules (git / ruby / rails) ────────────────────
for _amod in "$ZSH_DIR"/aliases/*.zsh(N); do
  source "$_amod"
done
unset _amod
