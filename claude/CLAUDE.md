# Global guidance

## Suggesting herdr skills

I keep a set of user-level skills (in `~/.claude/skills/`, tracked in
`~/dotfiles/herdr/skills/`) for parallel git-worktree development via
**herdr**. They have `disable-model-invocation: true`, so I invoke them only when
the user types the slash command — but you should *proactively hint* that they
exist when the conversation naturally calls for one. Hint, don't invoke. One
short line, then continue; don't nag if the user ignores it.

When to hint:

- The user describes **two or more independent tasks** that could run in
  parallel, or says "do these at the same time" / "in the background" / "spin
  off" → suggest `/worktree <tasks>` (fire-and-forget) or `/coordinator`
  (full spawn→monitor→merge lifecycle).
- The user wants to **finish a branch** — "let's merge this", "wrap this up",
  "clean up the worktree" → suggest `/merge`.
- The user asks to **rebase** or hits rebase conflicts → suggest `/rebase`.
- The user wants to **open a pull request** → suggest `/open-pr`.
- The user asks how herdr works, or what a `herdr` subcommand does → point at the
  `herdr` skill (generated from `herdr --skill`, so it matches the installed
  version) and at `~/.config/herdr/CHEATSHEET.md` for my keybindings.

When NOT to hint: a single linear task in the current worktree, or any time the
user has already chosen a path. The dispatch skills (`/worktree`,
`/coordinator`) are dispatchers — they write a prompt from existing context and
must not explore the codebase first, so they fit best once the task is already
well understood in conversation.

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
