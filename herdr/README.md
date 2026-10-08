# herdr

Config, layout plugin, and Claude Code skills for [Herdr](https://herdr.dev)
— a terminal workspace manager for AI coding agents (mouse-first and
agent-aware). This is **the** multiplexer for this setup: it replaced tmux +
workmux outright, so there is no tmux config here any more and nothing to run
herdr "inside".

## What's tracked here

| Path | Linked to | Purpose |
|------|-----------|---------|
| `config.toml` | `~/.config/herdr/config.toml` | Keys, theme (Kanagawa, macOS light/dark), worktrees, notifications |
| `CHEATSHEET.md` | `~/.config/herdr/CHEATSHEET.md` | Personal keybinding + workflow reference |
| `scripts/layout-agent-shell.sh` | `~/.config/herdr/scripts/` | Lays out Claude + shell; also launches dispatched prompts |
| `scripts/devin-cloud-pick.sh` | `~/.config/herdr/scripts/` | `prefix shift+c`: fzf over Devin Cloud sessions → a space streaming one |
| `plugins/jdeff-flow/` | `~/.config/herdr/plugins/jdeff-flow` | Local plugin: auto-layout on `worktree.created` |
| `skills/*/` | `~/.claude/skills/<name>` | Claude Code slash commands (see below) |

`install.sh` symlinks these individually (unlike the whole-dir `nvim` link) so
`~/.config/herdr` stays a **real** directory — Herdr writes runtime state
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
herdr integration install devin                              # devin session identity + devin --resume
devin auth login                                             # the Devin Cloud picker rides this login
```

Verify: `herdr plugin list` shows `jdeff.flow` and `vim-herdr-navigation`
enabled; `herdr integration status` shows claude and devin `current`.

`muster` (dev-server switcher, `~/src/muster`) is linked the same way —
`herdr plugin link ~/src/muster` — and its actions are bound in `config.toml`
under `prefix+alt+…`. It lives in its own repo, like herdr itself.

## Claude Code skills

Tracked under `skills/`, linked into `~/.claude/skills/` by `install.sh`. All are
`disable-model-invocation: true` — they run only when typed as a slash command.

| Skill | What it does |
|-------|--------------|
| `/worktree <tasks>` | Fire-and-forget: write a prompt per task, spawn a worktree space running Claude on it |
| `/coordinator` | Full lifecycle: spawn, name, monitor, send follow-ups, merge |
| `/merge` | Commit → rebase onto base → merge in the main tree → remove the worktree |
| `/rebase` | Rebase with careful conflict resolution (tool-agnostic) |
| `/open-pr` | Write a PR description from context, push, open `gh pr create --web` |

One more is **generated, not tracked**: `install.sh` runs `herdr --skill` into
`~/.claude/skills/herdr/SKILL.md`. That's Herdr's own official skill for driving
panes/agents over the socket API, and it ships with the binary — so it stays
pinned to the installed version. Delete the file and re-run `install.sh` to
refresh it after `herdr update`.

The dispatch contract shared by `/worktree` and `/coordinator`: the prompt goes to
`~/.herdr/dispatch/<slug>.md` (slug = branch through `tr -c '[:alnum:]' '-'`), and
`scripts/layout-agent-shell.sh` consumes it when it launches Claude in the new
worktree.

## Navigation pairing (nvim)

`C-h/j/k/l` crosses nvim splits ↔ Herdr panes via `vim-herdr-navigation`. The
editor side lives in the nvim config, not here: `nvim/after/plugin/herdr_nav.lua`
owns the mappings (which is why `nvim/lua/config/keymaps.lua` does *not* map
`C-hjkl` itself).

## Worktrees

Native: `prefix shift+g` (off main), `prefix shift+b` (stacked on the current
branch), or the `/worktree` skill. They live under
`~/.herdr/worktrees/<repo>/<branch-slug>` — set by `[worktrees] directory` in
`config.toml`. Merge with `prefix shift+m`, open a PR with `prefix ctrl+p`, and
remove the checkout + space with `prefix ctrl+x` (the branch survives).
