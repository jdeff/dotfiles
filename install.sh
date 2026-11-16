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

# ~/.config/dev/workspace.toml is the org/team map (see dev/README.md). Seeded,
# not symlinked: the real values are work-specific and this repo is public.
if [[ ! -f "$HOME/.config/dev/workspace.toml" ]]; then
  mkdir -p "$HOME/.config/dev"
  cp "$REPO/dev/workspace.toml.example" "$HOME/.config/dev/workspace.toml"
  echo "  seed  ~/.config/dev/workspace.toml (edit it: set your org/team/prefix)"
else
  echo "  ok    ~/.config/dev/workspace.toml (exists, left untouched)"
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
# Rex (whole config tree: init.lua + the files it requires)
link "$REPO/rex"                    "$HOME/.config/rex"
# Claude Code global guidance (the worktree/agent skills are tracked under
# dev/skills and linked below)
link "$REPO/claude/CLAUDE.md"       "$HOME/.claude/CLAUDE.md"
# Herdr (Herdr.app on herdr-core). Individual symlinks so ~/.config/herdr-app
# stays a real dir: the app rewrites its guide, .d.ts files and shipped mods
# there on every start.
link "$REPO/herdr-app/keys.json"         "$HOME/.config/herdr-app/keys.json"
link "$REPO/herdr-app/settings.json"     "$HOME/.config/herdr-app/settings.json"
for _f in "$REPO"/herdr-app/themes/*.json "$REPO"/herdr-app/layouts/*.json; do
  link "$_f" "$HOME/.config/herdr-app/${_f#"$REPO"/herdr-app/}"
done
for _mod in "$REPO"/herdr-app/mods/*/; do
  link "${_mod%/}" "$HOME/.config/herdr-app/mods/$(basename "$_mod")"
done
# Commands the skills and keybindings run, on PATH.
for _bin in "$REPO"/bin/*; do
  [[ -f "$_bin" && -x "$_bin" ]] || continue
  link "$_bin" "$HOME/.local/bin/$(basename "$_bin")"
done
# Claude Code skills: the worktree/ticket workflow under dev/skills, plus
# muster/skills.
for _root in muster dev; do
  for _skill in "$REPO"/$_root/skills/*/; do
    [[ -d "$_skill" ]] || continue
    link "${_skill%/}" "$HOME/.claude/skills/$(basename "$_skill")"
  done
done

echo "==> Generating Herdr's built-in agent skills"
# `herdr-app --skill` and `hc --skill` print the manuals for driving the window
# and herdr-core. They ship with the binaries, so they're generated (not tracked)
# and regenerated every run: the app updates itself and the skills follow it.
gen_skill() { # <name> <description> <command...>
  local name=$1 desc=$2; shift 2
  if command -v "$1" >/dev/null; then
    mkdir -p "$HOME/.claude/skills/$name"
    { printf -- '---\nname: %s\ndescription: %s\n---\n\n' "$name" "$desc"; "$@"; } \
      > "$HOME/.claude/skills/$name/SKILL.md"
    echo "  gen   ~/.claude/skills/$name/SKILL.md"
  else
    echo "  ($1 not on PATH — install Herdr: brew install --cask herdr-app)"
  fi
}
gen_skill herdr-app "Drive the Herdr window with herdr-app — spaces, tabs, panes, layouts, keys and mods. Use when changing what Herdr shows or editing ~/.config/herdr-app." herdr-app --skill
gen_skill hc "Run, read, message and wait on terminals and coding agents in herdr-core with hc. Use for background agents, slow commands, or another agent's terminal." hc --skill

echo
echo "Done. Start a fresh login shell to load everything:"
echo "    exec zsh -l"
echo
echo "Personal/work overrides (not tracked): ~/.zshenv.local, ~/.zshrc.local, ~/.zprofile.local"
