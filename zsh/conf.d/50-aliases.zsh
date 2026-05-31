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

# ── Prezto-derived alias modules (git / ruby / rails) ────────────────────
for _amod in "$ZSH_DIR"/aliases/*.zsh(N); do
  source "$_amod"
done
unset _amod
