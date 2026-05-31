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
# Starship
link "$REPO/starship/starship.toml" "$HOME/.config/starship.toml"

echo
echo "Done. Start a fresh login shell to load everything:"
echo "    exec zsh -l"
echo
echo "Personal/work overrides (not tracked): ~/.zshenv.local, ~/.zshrc.local, ~/.zprofile.local"
