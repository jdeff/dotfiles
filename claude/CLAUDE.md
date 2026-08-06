# Global guidance

## herdr worktree skills

Parallel worktree development runs through user-level skills tracked in
`~/dotfiles/herdr/skills/` and `~/dotfiles/dev/skills/`. The `dispatch` skill holds
the shared mechanics — prompt contract, write→verify→create→confirm — and
`/worktree` (free-form tasks), `/ticket` (a Linear key) and `/coordinator` (full
spawn→monitor→merge lifecycle) all build on it.

Those are model-invocable: reason about them yourself and propose one when it fits.
But **confirm before creating any worktree** unless I invoked a slash command or
already asked for parallel or background work. The dispatchers must not explore the
codebase first, so they fit best once a task is already well understood in
conversation.

Still slash-command only, so hint that they exist rather than waiting to be asked:
`/merge` (finish a branch) and `/rebase`.

For herdr itself — subcommands, socket API — use the `herdr` skill (generated from
`herdr --skill`, so it matches the installed version). My keybindings are in
`~/.config/herdr/CHEATSHEET.md`.

## Ticket keys

A bare ticket key like `ABC-123` is a **Linear issue**. The identity / org / team map
— which team owns a prefix, which muster project it maps to, how a branch is named
— is `~/.config/dev/workspace.toml` (untracked; this repo is public), and the
`workspace` skill is the procedure that reads it. Resolve repos through muster's own
config, never by guessing from a repo name. If Linear MCP tools aren't available,
the machine isn't bootstrapped: see `~/dotfiles/dev/README.md`.

## Dotfiles

My dotfiles are a git repo at `~/dotfiles`. It manages most of my
config — including `~/.config`, shell rc files, git, nvim, ghostty, and
herdr — via **symlinks** created by `~/dotfiles/install.sh` (its `link()`
helper runs `ln -sfn <repo-path> <home-path>`).

Key consequence: paths like `~/.config/nvim`, `~/.config/herdr/config.toml`, and
`~/.claude/skills/worktree` are symlinks *into* `~/dotfiles`. So editing a managed
config file through its `~/.config/...` path edits the repo's working tree
directly (same inode) — there is nothing to copy. To persist a change, just
**commit it in `~/dotfiles`** (don't `git add` in the home dir). Don't push
unless I ask.

When changing a managed config:
- Confirm the path is actually managed (`ls -ld` it, or check `install.sh`). New
  files need a `link()` line added there — except skills, which `install.sh`
  picks up automatically from `herdr/skills/*/`.
- After editing herdr config, reload with `herdr server reload-config`.
- Group commits sensibly and write clear messages; ask before pushing.

`~/.config/herdr/` is deliberately a **real directory** with individual files
symlinked into it (not a whole-dir link), because herdr writes runtime state
there — sockets, logs, plugin state — that must not land in the repo.

**herdr is not installed by `install.sh`.** It comes from
`curl -fsSL https://herdr.dev/install.sh | sh` and self-updates via
`herdr update`; plugin and integration registration is one-time per-machine
state. See `~/dotfiles/herdr/README.md`.

**herdr CLI gotchas:** `--timeout` values are **milliseconds**, not seconds. And
`herdr agent wait` takes a **single** target — loop with `&` + `wait` to block on
several agents at once.
