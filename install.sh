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
# Neovim (whole config tree: init.lua + lua/)
link "$REPO/nvim"                   "$HOME/.config/nvim"
# Ghostty
link "$REPO/ghostty/config"         "$HOME/.config/ghostty/config"
# tmux (whole config dir; TPM is bootstrapped below)
link "$REPO/tmux"                   "$HOME/.config/tmux"
# workmux (global config only; the fork is built from source below)
link "$REPO/workmux/config.yaml"    "$HOME/.config/workmux/config.yaml"

echo "==> Bootstrapping tmux plugin manager (TPM)"
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  git clone --quiet --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  echo "  clone  $TPM_DIR"
else
  echo "  ok    $TPM_DIR (exists)"
fi
# Install/update the plugins headlessly so a fresh machine is ready to go.
if command -v tmux >/dev/null; then
  "$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 && echo "  tmux plugins installed" \
    || echo "  (open tmux and press prefix + I to finish installing plugins)"
fi

echo "==> Building workmux (jdeff fork) from source"
# Clones ~/src/workmux on first run and cargo-installs it into ~/.local/bin.
# Re-runnable; also available as `workmux-update` once the binary is on PATH.
"$REPO/workmux/install.sh" || echo "  (workmux build skipped/failed — see workmux/README.md)"

echo
echo "Done. Start a fresh login shell to load everything:"
echo "    exec zsh -l"
echo
echo "Personal/work overrides (not tracked): ~/.zshenv.local, ~/.zshrc.local, ~/.zprofile.local"
