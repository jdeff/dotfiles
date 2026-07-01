# herdr

Config, layout plugin, and worktree dispatch skill for [Herdr](https://herdr.dev)
— a terminal workspace manager for AI coding agents (a mouse-first, agent-aware
tmux alternative). Run **standalone, not inside tmux** (both use `ctrl+b`). This
coexists with the tmux + workmux setup; it does not replace it.

## What's tracked here

| Path | Linked to | Purpose |
|------|-----------|---------|
| `config.toml` | `~/.config/herdr/config.toml` | Keys, theme (Kanagawa, macOS light/dark), worktrees, notifications |
| `CHEATSHEET.md` | `~/.config/herdr/CHEATSHEET.md` | Personal keybinding + workflow reference |
| `scripts/layout-agent-shell.sh` | `~/.config/herdr/scripts/` | Lays out Claude + shell; also launches dispatched prompts |
| `plugins/jdeff-flow/` | `~/.config/herdr/plugins/jdeff-flow` | Local plugin: auto-layout on `worktree.created` |
| `skills/worktree-herdr/` | `~/.claude/skills/worktree-herdr` | `/worktree-herdr` — spawn worktrees running Claude on a prompt |

`install.sh` symlinks these individually (unlike tmux/nvim which link a whole
dir) so `~/.config/herdr` stays a **real** directory — Herdr writes runtime state
there (`herdr.sock`, `*.log`, `plugins.json`, `plugins/config`, `plugins/github`,
`session.json`), which must not land in the repo.

## One-time bootstrap (per machine)

`install.sh` only creates the symlinks. Herdr itself and its runtime plugin
registrations are machine state (like `gh auth`), set up once:

```sh
# 1. Install Herdr (not via brew)
curl -fsSL https://herdr.dev/install.sh | sh

# 2. Start it once so the server exists, then (from another shell) register:
herdr plugin link "$HOME/.config/herdr/plugins/jdeff-flow"   # the local auto-layout plugin
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes # C-hjkl pane<->nvim nav
herdr integration install claude                             # authoritative agent state + claude --resume
```

Verify: `herdr plugin list` shows `jdeff.flow` and `vim-herdr-navigation`
enabled; `herdr integration status` shows claude `current`.

## Navigation pairing (nvim)

`C-h/j/k/l` crosses nvim splits ↔ Herdr panes via `vim-herdr-navigation`. The
editor side lives in the nvim config, not here:
`nvim/after/plugin/herdr_nav.lua` owns the mappings and `nvim/lua/plugins/tmux.lua`
loads vim-tmux-navigator mapping-free (it's still the fallback when inside tmux).

## Worktrees vs workmux

Herdr worktrees are native (`prefix shift+g`, or the `/worktree-herdr` skill) and
live under `~/.herdr/worktrees/<repo>/<branch-slug>`. workmux worktrees live under
`<repo>__worktrees/` — different locations, no collisions. Use whichever
multiplexer you're currently in.
