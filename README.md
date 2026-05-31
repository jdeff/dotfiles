# dotfiles

A modern, framework-free zsh configuration (no oh-my-zsh / prezto / plugin
manager). Plain zsh files, organized into modules, deployed by symlink.

## What's inside

```
zsh/
  zshenv      -> ~/.zshenv      env vars (loads for ALL shells, incl. scripts)
  zprofile    -> ~/.zprofile    login-shell PATH setup (Homebrew, asdf shims)
  zshrc       -> ~/.zshrc        interactive loader
  conf.d/     -> sourced in order by zshrc
    00-options.zsh      history, dir navigation, globbing, KEYTIMEOUT
    10-completion.zsh   fpath + cached compinit + completion styling
    20-keybindings.zsh  vi keybindings (bindkey -v) + comfort keys
    30-prompt.zsh       Starship init
    40-tools.zsh        fzf + zoxide integration
    50-aliases.zsh      eza/bat swaps; sources aliases/*.zsh
  aliases/    -> prezto-derived alias modules (git, ruby, rails)
  functions/  -> autoloaded helper functions the aliases depend on
git/
  gitconfig          -> ~/.gitconfig          identity, SSH signing, git-delta
  gitignore_global   -> ~/.gitignore_global
starship/
  starship.toml      -> ~/.config/starship.toml
Brewfile             tool dependencies
install.sh           backs up existing files, then symlinks everything
```

The support tree is reached at the stable path `~/.config/zsh` (symlinked to
`zsh/`), so the loader works regardless of where this repo lives.

## Install

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh        # brew bundle + symlinks (backs up anything in the way)
exec zsh -l         # load it
```

## Tools

Prompt **starship** · plugins **zsh-syntax-highlighting**, **zsh-autosuggestions**,
**zsh-completions**, **zsh-history-substring-search** (↑/↓ search history for
lines containing the typed text; `k`/`j` in vi normal mode) · navigation **fzf**
(Ctrl-R / Ctrl-T / Alt-C), **zoxide** (`z`) · modern CLI **git-delta**, **eza**,
**bat**, **fd**, **ripgrep**.

Runtime versions (ruby, node) are managed by **asdf** via `~/.tool-versions`.

## Aliases

The `git`, `ruby`, and `rails` aliases are reproduced verbatim from
[prezto](https://github.com/sorin-ionescu/prezto)'s modules (e.g. `g`, `gws`,
`gco`, `glo`, `gp`, `rb`, `rbbe`, `ror`, `rorc`, `rorg`). The handful of
function-backed aliases (`gcl`, `gRb`, `gsX`, `gsL`, `gsr`, `gSm`, `gSx`,
`rorl`) work because their helper functions are vendored under `zsh/functions/`.

## Vi mode

`bindkey -v` is on. The prompt character indicates the mode:

| Mode   | Symbol         |
|--------|----------------|
| insert | green `❯`      |
| normal | yellow `❮`     |

Visual mode isn't separately shown — zsh can't report it to Starship (upstream
limitation), so it displays like normal mode. Comfort keys (`^A`, `^E`, `^R`,
`^W`, …) are kept in insert mode; press `v` in normal mode to edit the command
line in `$EDITOR`.

## Personal / work overrides (not tracked)

These are sourced if present and are intentionally **not** committed — put
machine- or work-specific values (secrets, tokens, internal URLs) here:

- `~/.zshenv.local`    — env vars for all shells
- `~/.zprofile.local`  — login-shell setup
- `~/.zshrc.local`     — interactive overrides (aliases, prompt tweaks)
- `~/.gitconfig.local` — git identity: name, email, SSH signing-key path

For git this uses git's native `[include]` directive: the tracked `gitconfig`
holds portable preferences (delta, signing prefs, defaults) and pulls in
`~/.gitconfig.local` for the machine-specific identity. `install.sh` seeds that
file from `git/gitconfig.local.example` if it's missing. The example also shows
the `includeIf "gitdir:…"` pattern for auto-switching work vs. personal identity
by repo location.

## Adding an alias module

Drop a new `*.zsh` file in `zsh/aliases/`; it's auto-sourced. Add a helper
function as a file in `zsh/functions/` (filename = function name); it's
autoloaded.
