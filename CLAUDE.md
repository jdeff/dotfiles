# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

A framework-free zsh + git + starship dotfiles repo. Plain config files, organized into modules, deployed to `$HOME` by symlink. No oh-my-zsh / prezto / plugin manager.

`CHEATSHEET.md` is the human-facing quick reference (new-machine setup + the keymaps/aliases worth remembering). It is intentionally **not** exhaustive. When a change adds or renames something a person would reach for from memory — a new keymap domain, a changed leader binding, an install step, a headline alias — update the relevant `CHEATSHEET.md` section in the same change. Don't mirror every binding there; if it's only discoverable via which-key or the config, it doesn't need a cheatsheet line.

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

`nvim/` is a modular neovim config managed by **lazy.nvim** — deliberately *not* a distro (LazyVim/NvChad), so every plugin is an explicit, editable spec. `init.lua` sets the leader (`,`) and loads `lua/config/{options,keymaps,autocmds,lazy}.lua`; `lua/config/lazy.lua` then `import`s every file under `lua/plugins/`, one file per concern. To add/remove a plugin, add/delete a spec file (or a table in one) — no central registry. The whole `nvim/` dir is symlinked to `~/.config/nvim`. LSP servers and formatters install on demand via **Mason** (`:Mason`), so a fresh machine self-provisions on first launch. Treesitter is on the **`main`** branch (the `master` branch is frozen and crashes on Neovim 0.11+/0.12 with a `range (nil)` injection error). The `main` API differs: no `nvim-treesitter.configs`, parsers are installed via `require('nvim-treesitter').install()` and highlighting is started per buffer in a `FileType` autocmd, and it **compiles parsers with the `tree-sitter` CLI** (the `tree-sitter-cli` Brewfile formula — not the library-only `tree-sitter` formula). The textobjects plugin is also on `main` (manual keymaps); endwise is `tpope/vim-endwise` since the treesitter-endwise plugin needed the dead `configs` API. Tuned for the Toro stack: Ruby/Rails + GraphQL + Postgres backend, TypeScript/React/Vite frontend.

`ghostty/config` sets the terminal theme (light/dark Kanagawa) and Lilex Nerd Font, linked into `~/.config/` by `install.sh` like the other configs.

`tmux/tmux.conf` (symlinked to `~/.config/tmux/`) uses the default `C-b` prefix and manages plugins with **TPM**, which `install.sh` bootstraps (clones to `~/.config/tmux/plugins/tpm` and runs `install_plugins`) the same way it bootstraps lazy.nvim. Plugins: tmux-sensible, tmux-yank, tmux-fzf, resurrect + continuum (auto save/restore), and vim-tmux-navigator. That last one is paired with the `christoomey/vim-tmux-navigator` nvim plugin (`nvim/lua/plugins/tmux.lua`) so `C-h/j/k/l` moves seamlessly across tmux panes and nvim splits — which is why nvim's `keymaps.lua` does **not** map `C-hjkl` itself. The status bar is hand-rolled (no theme plugin) and **follows the macOS appearance** like Ghostty/nvim: `tmux/scripts/theme.sh` reads `defaults read -g AppleInterfaceStyle`, and when the mode changes it sources `tmux/themes/wave.conf` (dark) or `lotus.conf` (light). It runs once on load (`run-shell`) and polls from a `#()` in the status line on `status-interval`; tmux can't subscribe to appearance changes, so polling is the mechanism. Colors/segment formats live in the theme files; only structure (position, lengths) lives in `tmux.conf`.
