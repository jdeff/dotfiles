# Global guidance

## Suggesting workmux skills

I keep a set of user-level skills (in `~/.claude/skills/`) for parallel
git-worktree development via the **workmux** CLI. They have
`disable-model-invocation: true`, so I invoke them only when the user types the
slash command — but you should *proactively hint* that they exist when the
conversation naturally calls for one. Hint, don't invoke. One short line, then
continue; don't nag if the user ignores it.

When to hint:

- The user describes **two or more independent tasks** that could run in
  parallel, or says "do these at the same time" / "in the background" / "spin
  off" → suggest `/worktree <tasks>` (fire-and-forget) or `/coordinator`
  (full spawn→monitor→merge lifecycle).
- The user wants to **finish a branch** — "let's merge this", "wrap this up",
  "clean up the worktree" → suggest `/merge`.
- The user asks to **rebase** or hits rebase conflicts → suggest `/rebase`.
- The user wants to **open a pull request** → suggest `/open-pr`.
- The user asks how workmux works, or what a `wm`/`workmux` command does →
  point at `/workmux` (the reference skill).

When NOT to hint: a single linear task in the current worktree, or any time the
user has already chosen a path. The dispatch skills (`/worktree`,
`/coordinator`) are dispatchers — they write a prompt from existing context and
must not explore the codebase first, so they fit best once the task is already
well understood in conversation.

## Dotfiles

My dotfiles are a git repo at `~/dotfiles`. It manages most of my
config — including `~/.config`, shell rc files, git, nvim, ghostty, tmux, and
workmux — via **symlinks** created by `~/dotfiles/install.sh` (its `link()`
helper runs `ln -sfn <repo-path> <home-path>`).

Key consequence: directories like `~/.config/tmux`, `~/.config/nvim`,
`~/.config/workmux` are symlinks *into* `~/dotfiles`. So editing a managed
config file through its `~/.config/...` path edits the repo's working tree
directly (same inode) — there is nothing to copy. To persist a change, just
**commit it in `~/dotfiles`** (don't `git add` in the home dir). Don't push
unless I ask.

When changing a managed config:
- Confirm the path is actually managed (`ls -ld` the parent dir to see the
  symlink, or check `install.sh`). New files need a `link()` line added there.
- After editing tmux config, reload with
  `tmux source-file ~/.config/tmux/tmux.conf`.
- Group commits sensibly and write clear messages; ask before pushing.

`~/.config/workmux/config.yaml` is my global workmux defaults (panes, sidebar,
hooks), also managed by this repo.

**tmux + workmux PATH gotcha:** the tmux server's inherited PATH does not
include `~/.local/bin`, where `workmux` lives. Bare `workmux` in a tmux
keybinding (`run-shell` / `display-popup`) fails with exit 127. Use the
absolute path `$HOME/.local/bin/workmux` in bindings (`/bin/sh` expands `$HOME`
at runtime, so it stays portable).
