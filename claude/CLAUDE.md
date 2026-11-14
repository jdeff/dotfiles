# Global guidance

## Worktree and ticket skills

Tracked in `~/dotfiles/dev/skills/`; their descriptions
say when each fires. Confirm before creating a worktree unless I typed the command or
already asked for parallel or background work.

`/merge`, `/rebase`, `/merged` (a PR landed upstream; retire its worktree) and
`/discard` (throw away an unmerged worktree and its branch) carry no description,
so name them when they'd fit rather than waiting to be asked.

Herdr is the desktop app (Herdr.app) on herdr-core. For the window — spaces, tabs,
panes, layouts, keys, mods — use the `herdr-app` skill; for running, reading,
messaging and waiting on terminals and agents, the `hc` skill. Both are generated
from the installed binaries. My keybindings are in the Herdr section of
`~/dotfiles/CHEATSHEET.md`.

I also run Rex (the `rex` skill). The worktree skills work in either: the scripts
they call in `~/dotfiles/bin/` detect the multiplexer and load its backend from
`bin/lib/host-<name>.sh`. Keep Herdr- and Rex-specific mechanics in those
backends, not in the skills.

## Dotfiles

My dotfiles are a git repo at `~/dotfiles`. It manages most of my
config — including `~/.config`, shell rc files, git, nvim, ghostty, and
Herdr — via **symlinks** created by `~/dotfiles/install.sh` (its `link()`
helper runs `ln -sfn <repo-path> <home-path>`).

Key consequence: paths like `~/.config/nvim`, `~/.config/herdr-app/keys.json`, and
`~/.claude/skills/worktree` are symlinks *into* `~/dotfiles`. So editing a managed
config file through its `~/.config/...` path edits the repo's working tree
directly (same inode) — there is nothing to copy. To persist a change, just
**commit it in `~/dotfiles`** (don't `git add` in the home dir). Don't push
unless I ask.

When changing a managed config:
- Confirm the path is actually managed (`ls -ld` it, or check `install.sh`). New
  files need a `link()` line added there — except skills, which `install.sh`
  picks up automatically from `dev/skills/*/`, and executables in `bin/`, which it
  links into `~/.local/bin`.
- Herdr reloads its config on save; after editing it, check `herdr-app status`
  for `errors`.
- Group commits sensibly and write clear messages; ask before pushing.

`~/.config/herdr-app/` is deliberately a **real directory** with individual files
symlinked into it (not a whole-dir link), because Herdr rewrites its guide, type
files and shipped mods there on every start and keeps runtime state beside them.

**hc gotchas:** `--timeout` values are **seconds**. `hc wait` takes a **single**
terminal — loop with `&` + `wait` to block on several. Agents the app launched are
not your `hc` children, so `hc wait --children` never covers them.
