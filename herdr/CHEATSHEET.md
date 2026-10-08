# Herdr cheatsheet (jdeff)

Prefix: **`ctrl+b`**. "prefix X" = press ctrl+b, release, then X.
Everything is also mouse-driven: click to focus, drag borders to resize, right-click
for a context menu, drag-select to copy.

## Start working on tms-api (main)

You're in the `~` space with one shell pane. Fastest path:

1. `cd ~/src/toro/tms-api`
2. `prefix shift+w` → rename this space to `tms-api`
3. `prefix a` → auto-splits **Claude (focused) + shell** (the default layout)

Claude now appears in the **agents** sidebar with live state. (If the space already
has >1 pane, `prefix a` no-ops — just type `claude` in a pane.)

Alternatively, from any shell:
`herdr workspace create --cwd ~/src/toro/tms-api --label tms-api --focus` then `prefix a`.

## Navigation (prefix-free — vim-aware)

| Keys | Action |
|------|--------|
| `ctrl+h/j/k/l` | Move focus between panes **and nvim splits** (seamless) |
| `prefix h/j/k/l` | Focus pane (fallback) |
| `prefix tab` / `prefix shift+tab` | Cycle panes |

## Panes

| Keys | Action |
|------|--------|
| `prefix \|` | Split right (side-by-side) |
| `prefix -` | Split down (stacked) |
| `prefix z` | Zoom pane (toggle fullscreen) |
| `prefix x` | Close pane |
| `prefix r` | Resize mode → then `h/j/k/l`, `esc` to exit |
| `prefix a` | Apply Claude+shell layout to current space |
| `prefix e` | Edit scrollback |

## Tabs

| Keys | Action |
|------|--------|
| `prefix c` | New tab |
| `prefix n` / `prefix p` | Next / previous tab |
| `prefix 1..9` | Jump to tab |
| `prefix shift+t` | Rename tab |
| `prefix shift+x` | Close tab |

## Spaces (workspaces) & worktrees

| Keys | Action |
|------|--------|
| `alt+1..9` | Jump to space 1..9 (either Option) |
| `alt+j` / `alt+k` | Next / previous space (either Option) |
| `prefix w` | Space picker |
| `prefix g` | Goto picker (jump to any space / agent) |
| `prefix shift+n` | New space |
| `prefix shift+w` | Rename space |
| `prefix shift+d` | Close space |
| `prefix shift+g` | **New worktree** — creates branch + grouped space, auto Claude+shell (bases on main) |
| `prefix shift+b` | New worktree **stacked on the current branch** (run from inside a worktree) |
| `prefix shift+o` | Open an existing worktree |
| `prefix ctrl+x` | **Remove** this worktree (checkout + space; cleanup after a PR merge) — confirms, keeps the branch |
| right-click space | Remove worktree (same as above, via mouse) |

## Agents / sidebar

| Keys | Action |
|------|--------|
| `prefix shift+j` / `prefix shift+k` | Cycle to next / previous agent |
| `prefix g` | Goto picker (also jumps to agents) |
| `prefix shift+c` | Devin Cloud picker: open a cloud session as a `☁` space (or focus it) |
| `prefix b` | Toggle sidebar |
| click / right-click sidebar | Focus / menu |

States: `working` `blocked` `done` `idle` `unknown`, sorted by priority
(blocked → done → working → idle → unknown). You get an OS notification + sound
when a background agent finishes or needs input.

Devin Cloud spaces stream the session via `devin --cloud -r <id>` (needs
`devin auth login`). They aren't restored after a Herdr server restart — re-pick.
In the picker: `ctrl-o` opens the session in the browser, `ctrl-r` reloads.

## Git / tools / session

| Keys | Action |
|------|--------|
| `prefix shift+l` | lazygit (throwaway pane) |
| `prefix shift+m` | Merge this worktree's branch → base (interactive pane) |
| `prefix ctrl+p` | Push branch + open PR via `gh` (interactive pane) |
| `prefix q` | Detach (everything keeps running; `herdr` to reattach) |
| `prefix shift+r` | Reload config |
| `prefix ?` | Show all keybindings |
| `prefix s` | Settings |

Merge / Open-PR are also on the **right-click menu** of a worktree space. Run them
from inside the worktree you want to act on; both prompt before doing anything.

## muster (one feature's dev stack at a time)

| Keys | Action |
|------|--------|
| `prefix alt+d` | Dashboard (persistent right-hand split, cross-project) |
| `prefix alt+m` | Menu (fzf: restart / logs / per-service) |
| `prefix alt+u` | Up — this feature takes the ports |
| `prefix alt+x` | Down — free the ports |
| `prefix alt+s` | Status |
| `prefix alt+k` | lazydocker |

`up`/`down`/`status`/`docker` infer the project and occupant from the pane's cwd —
run them from inside a project repo or worktree. `menu`/`dashboard` work anywhere.

## Claude Code slash commands

| Command | Action |
|---------|--------|
| `/worktree <tasks>` | Spawn a worktree space per task, each running Claude on a prompt |
| `/coordinator` | Spawn → monitor → follow up → merge, driven from one session |
| `/merge` | Commit, rebase onto base, merge, remove the worktree |
| `/rebase` / `/open-pr` | Rebase with conflict care / write a PR and open it |

## Typical loop on tms-api

- Work with Claude in its pane; glance at the sidebar for state.
- Scratch shell: `prefix |`.
- Feature branch off main without leaving: `prefix shift+g`, type a branch name →
  new grouped space with Claude+shell auto-laid-out; `main` stays put.
- Merge when done: from a pane in the worktree, `prefix shift+m` (merge into base)
  or `prefix ctrl+p` (push + open PR). Then right-click the space to remove it.
- Done for now: `prefix q`. Reattach later with `herdr`.

## Gotchas

- `ctrl+h` is now "navigate left" (Herdr grabs it), so it no longer sends Backspace
  in a shell — use your normal Backspace key.
- Theme follows macOS light/dark (Kanagawa Lotus/Wave), matching Ghostty.
- Full stop (kills all sessions): `herdr server stop`.
