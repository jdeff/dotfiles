# Herdr cheatsheet (jdeff)

Prefix: **`ctrl+b`** (same as tmux). "prefix X" = press ctrl+b, release, then X.
Everything is also mouse-driven: click to focus, drag borders to resize, right-click
for a context menu, drag-select to copy.

## Start working on tms-api (main)

You're in the `~` space with one shell pane. Fastest path:

1. `cd ~/src/toro/tms-api`
2. `prefix shift+w` → rename this space to `tms-api`
3. `prefix a` → auto-splits **Claude (focused) + shell** (your workmux default layout)

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
| `prefix w` | Space picker |
| `prefix g` | Goto picker (jump to any space / agent) |
| `prefix shift+n` | New space |
| `prefix shift+w` | Rename space |
| `prefix shift+d` | Close space |
| `prefix shift+g` | **New worktree** — creates branch + grouped space, auto Claude+shell |
| `prefix shift+o` | Open an existing worktree |
| right-click space | Remove worktree (safe; prompts if dirty; never deletes branches) |

## Agents / sidebar

| Keys | Action |
|------|--------|
| `prefix shift+j` / `prefix shift+k` | Cycle to next / previous agent |
| `prefix g` | Goto picker (also jumps to agents) |
| `prefix b` | Toggle sidebar |
| click / right-click sidebar | Focus / menu |

States: `working` `blocked` `done` `idle` `unknown`, sorted by priority
(blocked → done → working → idle → unknown). You get an OS notification + sound
when a background agent finishes or needs input.

## Git / tools / session

| Keys | Action |
|------|--------|
| `prefix shift+l` | lazygit (throwaway pane) |
| `prefix q` | Detach (everything keeps running; `herdr` to reattach) |
| `prefix shift+r` | Reload config |
| `prefix ?` | Show all keybindings |
| `prefix s` | Settings |

## Typical loop on tms-api

- Work with Claude in its pane; glance at the sidebar for state.
- Scratch shell: `prefix |`.
- Feature branch off main without leaving: `prefix shift+g`, type a branch name →
  new grouped space with Claude+shell auto-laid-out; `main` stays put.
- Merge/PR: (coming — being added to the jdeff.flow plugin.)
- Done for now: `prefix q`. Reattach later with `herdr`.

## Gotchas

- Run `herdr` in a **plain Ghostty tab, not inside tmux** — both are multiplexers and
  both use `ctrl+b`.
- `ctrl+h` is now "navigate left" (Herdr grabs it), so it no longer sends Backspace
  in a shell — use your normal Backspace key.
- Theme follows macOS light/dark (Kanagawa Lotus/Wave), matching Ghostty.
- Full stop (kills all sessions): `herdr server stop`.
