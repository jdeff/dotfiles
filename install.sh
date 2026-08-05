#!/usr/bin/env bash
#
# Dotfiles installer. Idempotent: backs up any pre-existing real files
# (timestamped) before symlinking, and skips links that are already correct.
#
# Usage:  ./install.sh
#
set -euo pipefail

# Absolute path to this repo (the dir containing this script).
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  # link <source-in-repo> <target-in-home>
  local src="$1" dst="$2"

  # Already pointing where we want? Nothing to do.
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "  ok    $dst"
    return
  fi

  # Back up an existing real file or wrong symlink.
  if [[ -e "$dst" || -L "$dst" ]]; then
    local bak="${dst}.bak.${STAMP}"
    mv "$dst" "$bak"
    echo "  backup $dst -> $bak"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  link  $dst -> $src"
}

echo "==> Installing Homebrew packages (brew bundle)"
brew bundle --file="$REPO/Brewfile"

echo "==> Seeding untracked local files"
# ~/.gitconfig.local holds machine-specific identity + signing key (see
# git/gitconfig.local.example). Seed it from the template if absent so that
# commit.gpgsign always has a signingkey to use.
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  cp "$REPO/git/gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "  seed  ~/.gitconfig.local (edit it: set your name/email/signingkey)"
else
  echo "  ok    ~/.gitconfig.local (exists, left untouched)"
fi

echo "==> Linking dotfiles"
# Top-level zsh dotfiles
link "$REPO/zsh/zshrc"            "$HOME/.zshrc"
link "$REPO/zsh/zshenv"           "$HOME/.zshenv"
link "$REPO/zsh/zprofile"         "$HOME/.zprofile"
# Support tree (conf.d, aliases, functions) reached at a stable path
link "$REPO/zsh"                  "$HOME/.config/zsh"
# Git
link "$REPO/git/gitconfig"        "$HOME/.gitconfig"
link "$REPO/git/gitignore_global" "$HOME/.gitignore_global"
# mise (global runtime pins + idiomatic-version-file settings)
link "$REPO/mise/config.toml"     "$HOME/.config/mise/config.toml"
# Starship
link "$REPO/starship/starship.toml" "$HOME/.config/starship.toml"
# Neovim (whole config tree: init.lua + lua/)
link "$REPO/nvim"                   "$HOME/.config/nvim"
# Ghostty
link "$REPO/ghostty/config"         "$HOME/.config/ghostty/config"
# Claude Code global guidance (the worktree/agent skills are tracked under
# herdr/skills and linked below)
link "$REPO/claude/CLAUDE.md"       "$HOME/.claude/CLAUDE.md"
# Herdr (terminal workspace manager for AI agents). Individual symlinks so
# ~/.config/herdr stays a real dir for runtime sockets/logs/plugin state. Herdr
# itself is installed via curl and its plugins/integration registered once —
# see herdr/README.md for that one-time bootstrap.
link "$REPO/herdr/config.toml"           "$HOME/.config/herdr/config.toml"
link "$REPO/herdr/CHEATSHEET.md"         "$HOME/.config/herdr/CHEATSHEET.md"
link "$REPO/herdr/scripts"               "$HOME/.config/herdr/scripts"
link "$REPO/herdr/plugins/jdeff-flow"    "$HOME/.config/herdr/plugins/jdeff-flow"
# Claude Code skills: the worktree/agent workflow (slash commands) under
# herdr/skills, plus muster/skills (the dev-stack skill agents load themselves).
for _root in herdr muster; do
  for _skill in "$REPO"/$_root/skills/*/; do
    [[ -d "$_skill" ]] || continue
    link "${_skill%/}" "$HOME/.claude/skills/$(basename "$_skill")"
  done
done

echo "==> Generating Herdr's built-in agent skill"
# `herdr --skill` prints the official skill for driving Herdr over its socket
# API. It ships with the binary, so it's generated (not tracked) — that keeps it
# pinned to the installed version. Delete the file to refresh it after an update.
if command -v herdr >/dev/null; then
  if [[ ! -f "$HOME/.claude/skills/herdr/SKILL.md" ]]; then
    mkdir -p "$HOME/.claude/skills/herdr"
    herdr --skill > "$HOME/.claude/skills/herdr/SKILL.md"
    echo "  gen   ~/.claude/skills/herdr/SKILL.md ($(herdr --version))"
  else
    echo "  ok    ~/.claude/skills/herdr/SKILL.md (exists)"
  fi
else
  echo "  (herdr not on PATH — see herdr/README.md for the one-time install)"
fi

echo
echo "Done. Start a fresh login shell to load everything:"
echo "    exec zsh -l"
echo
echo "Personal/work overrides (not tracked): ~/.zshenv.local, ~/.zshrc.local, ~/.zprofile.local"
