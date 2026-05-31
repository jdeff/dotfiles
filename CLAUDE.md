# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

A framework-free zsh + git + starship dotfiles repo. Plain config files, organized into modules, deployed to `$HOME` by symlink. No oh-my-zsh / prezto / plugin manager.

## Commands

- `./install.sh` — runs `brew bundle`, seeds untracked local files, then symlinks everything into `$HOME`. Idempotent: skips already-correct links, backs up anything in the way to `<file>.bak.<timestamp>` (gitignored).
- `exec zsh -l` — reload a full login shell to test changes (there is no build/test suite).
- After editing only an interactive module: `source ~/.zshrc`.

## Load order (the core mental model)

zsh sources files in a fixed sequence, and this repo's structure mirrors it. Putting code in the wrong file is the most common mistake:

1. **`zsh/zshenv`** → `~/.zshenv` — every zsh (scripts, ssh commands, non-TTY included). Keep it fast and silent: env vars only, nothing that prints.
2. **`zsh/zprofile`** → `~/.zprofile` — login shells, *after* macOS's `/etc/zprofile` path_helper reorders PATH. This is the only correct place for PATH-mutating tool init (Homebrew `shellenv`, asdf shims) so those tools win.
3. **`zsh/zshrc`** → `~/.zshrc` — interactive shells only. A thin loader that sources `conf.d/*.zsh` in numeric order, then alias modules, then plugins.

Within `zshrc`, **interactive plugins must load last and in a specific order**: zsh-autosuggestions → zsh-syntax-highlighting → zsh-history-substring-search (the last two depend on highlighting being loaded, and the history-search keybindings are bound after sourcing because the widgets must exist first).

`conf.d/` numeric prefixes (`00-options`, `10-completion`, `20-keybindings`, `30-prompt`, `40-tools`, `50-aliases`) encode ordering dependencies — e.g. `00-options` sets `KEYTIMEOUT` before `20-keybindings` enables `bindkey -v`; fpath additions in `10-completion` precede its `compinit`.

## Key architectural decisions

- **Stable-path indirection.** `install.sh` symlinks `~/.config/zsh` → `repo/zsh`, and `zshrc` resolves everything through `ZSH_DIR=${ZDOTDIR:-$HOME/.config/zsh}`. This makes the loader work regardless of where the repo is cloned.
- **`.local` override seam.** Each tracked file sources an untracked sibling if present, where machine-/work-specific values (secrets, TORO_* tokens, identity, internal URLs) go — these are intentionally never committed: `~/.zshenv.local`, `~/.zprofile.local`, `~/.zshrc.local`, `~/.gitconfig.local`. The git case uses git's native `[include]` of `~/.gitconfig.local` (a later include always wins); `install.sh` seeds it from `git/gitconfig.local.example` if missing.
- **Vendored prezto aliases/functions.** `zsh/aliases/{git,ruby,rails}.zsh` are reproduced verbatim from prezto. The function-backed aliases (`gcl`, `gRb`, `gsX`, etc.) work only because their helpers are vendored under `zsh/functions/`, where **filename = function name** and each is autoloaded via `autoload -Uz "$ZSH_DIR"/functions/*(:t)`. To add an alias module, drop a `*.zsh` in `aliases/` (auto-sourced); to add a helper, add a file in `functions/` named for the function.
- **Deliberate non-aliasing.** `cat`→`bat` and `ls`→`eza` are aliased (bat detects non-TTY and acts like cat, so it's pipe-safe), but `find`/`grep` are deliberately *not* aliased to `fd`/`rg` because their flags differ and would surprise scripts.

## Tooling

Dependencies are pinned in `Brewfile`. Runtime versions (ruby, node) are managed by **asdf** (Go rewrite, 0.16+: shims on PATH, no `asdf.sh`) via `~/.tool-versions`. Git is configured for SSH commit/tag signing and git-delta as the pager.

`nvim/init.lua` is a deliberately minimal neovim config (options + keymaps, no plugin manager or colorscheme yet) — a fuller setup is planned, so keep additions small until then. `ghostty/config` sets the terminal theme (Kanagawa Wave) and Lilex Nerd Font. Both are linked into `~/.config/` by `install.sh` like the other configs.
