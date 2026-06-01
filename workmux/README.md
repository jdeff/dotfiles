# workmux

[workmux](https://github.com/raine/workmux) pairs **one git worktree per task**
with a **tmux window** running an AI agent (Claude Code) plus a shell — the
parallel-agent workflow this setup is built around. `wm add <name>` spins up a
worktree + window; `wm merge` merges the branch and tears the whole thing down.

These dotfiles **don't vendor workmux's source** — they track only the global
config and build the binary from a personal fork, so the tool itself can evolve
independently of the dotfiles.

## What lives where

| Thing | Location |
|-------|----------|
| Fork (source checkout) | `~/src/workmux` (clone of `jdeff/workmux`, `upstream` → `raine/workmux`) |
| Built binary | `~/.local/bin/workmux` (already on `PATH` via `zsh/zprofile`) |
| Global config | `workmux/config.yaml` → symlinked to `~/.config/workmux/config.yaml` |
| `wm` alias + `workmux-update` | `zsh/conf.d/50-aliases.zsh` |
| tmux status segment | `tmux/themes/{wave,lotus}.conf` (`@workmux_status`) |
| Build/bootstrap script | `workmux/install.sh` |

## Install (handled by the top-level `install.sh`)

`./install.sh` runs `brew bundle` (which installs `rust`), symlinks the config,
then runs `workmux/install.sh`, which clones the fork to `~/src/workmux` and
builds it into `~/.local/bin`. To do just the workmux part by hand:

```sh
brew install rust              # if not already present
./workmux/install.sh           # clone fork + cargo install --root ~/.local
exec zsh -l                    # pick up the binary on PATH
workmux --version
```

Override the defaults with env vars, e.g. a different checkout dir or an HTTPS
remote:

```sh
WORKMUX_SRC=~/code/workmux WORKMUX_REMOTE=https://github.com/jdeff/workmux.git ./workmux/install.sh
```

## Rebuild a new version ("ready to go")

After committing to the fork or pulling changes, rebuild with one command:

```sh
workmux-update        # git pull --ff-only in ~/src/workmux, then cargo install
```

`workmux-update` is a shell function defined next to the `wm` alias in
`zsh/conf.d/50-aliases.zsh`. Or just re-run `./workmux/install.sh` (it rebuilds
whatever is checked out).

## Sync with upstream

The clone has an `upstream` remote pointing at `raine/workmux`:

```sh
cd ~/src/workmux
git fetch upstream
git rebase upstream/main      # or merge; resolve, then:
workmux-update                # rebuild
git push                      # update your fork
```

## tmux status integration

workmux can rewrite `window-status-format` to show per-agent status icons. We
**disable** that with `status_format: false` in `config.yaml` so the hand-rolled
Kanagawa status bar stays in control. workmux then only sets the
`@workmux_status` window user-option, and the theme files render it themselves:

```tmux
#{?@workmux_status, #{@workmux_status},}
```

The glyphs (working/waiting/done) are defined as **bare** Nerd Font characters in
`config.yaml` — no color codes — so the tmux themes can color them per
appearance (yellow on non-current windows in `wave`/`lotus`). Tweak the glyphs in
`config.yaml`; tweak their color in the theme files.

## Removing a prior install (other machines)

If a machine has the upstream workmux from Homebrew or crates.io, remove it
before/while switching to this from-source build so the right binary wins on
`PATH`:

```sh
brew uninstall workmux 2>/dev/null; brew untap raine/workmux 2>/dev/null   # if installed via brew
cargo uninstall workmux 2>/dev/null                                        # if installed via cargo
```
