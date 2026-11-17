# Cheatsheet

The basics, for when I set up a new machine or forget a binding. Not exhaustive —
see the config files for the full story.

## New machine

```sh
git clone git@github.com:jdeff/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh            # brew bundle + symlinks (backs up anything in the way)
exec zsh -l             # load the new shell
```

Then:

- Edit `~/.gitconfig.local` — set name, email, SSH signing key (seeded from the example).
- `gh auth login` — pick HTTPS and answer "yes" to authenticating git. This caches
  a token in the keychain; the tracked gitconfig already routes github HTTPS auth
  through `gh`. (SSH commit signing is separate — that's the key in `~/.gitconfig.local`.)
- Open `nvim` once and wait: lazy.nvim installs plugins, treesitter compiles
  parsers (via the `tree-sitter` CLI from the Brewfile), and Mason installs LSP
  servers + formatters. `:Lazy` and `:Mason` show progress; `:checkhealth` flags
  anything missing (e.g. `node` for vtsls).
- macOS: set Appearance (light/dark — Ghostty, Herdr, and nvim follow it), and
  remap Alfred's hotkey to ⌘Space (disable Spotlight's under Keyboard Shortcuts).
- Open **Herdr** (the `herdr-app` cask) and go through its welcome until
  `hc --version` works (herdr-core runs every terminal), then re-run `./install.sh`:
  it links the config into `~/.config/herdr-app` and generates the `herdr-app` and
  `hc` Claude skills from the installed binaries.
- Connect **Linear** — one user-scoped `mcp-remote` server per workspace, since the
  official MCP is single-workspace per auth context. Commands in `dev/README.md`, then
  `/mcp` to authenticate each. Fill in `~/.config/dev/workspace.toml` (seeded from
  `dev/workspace.toml.example`; the real one is work-specific and never tracked, like
  `~/.gitconfig.local`).

## Neovim

Leader is `,`. Keymaps follow `,<domain><action>`; the **doubled** key is the
most common action (`,gg`, `,tt`, `,cc`, `,ff`). `g`-prefix = "go to". Press `,`
and wait — **which-key** shows the menu.

**Files & search**

| Key | Action |
|-----|--------|
| `<space><space>` | Toggle file explorer |
| `,ff` | Find files |
| `,,` | Live grep |
| `,/` | Fuzzy find in current buffer |
| `,fr` / `,fb` | Recent files / open buffers |
| `,fy` / `,ft` | Yank history / TODOs |

**Navigation (`g`) & code (`,c`)**

| Key | Action |
|-----|--------|
| `gd` `gI` `gy` `gD` | Definition / implementation / type / declaration |
| `K` | Hover docs |
| `s` | Flash jump (label-based motion) |
| `,cc` | Code action |
| `,cr` / `,cn` | References / rename |
| `,cf` | Format buffer |
| `,cd` / `,cs` | Line diagnostics / document symbols |
| `,xx` | Diagnostics list (Trouble) · `[d` `]d` to step |

**Test (`,t`)** — RSpec / Vitest via neotest

| Key | Action |
|-----|--------|
| `,tt` | Run nearest test |
| `,tf` / `,tl` | Run file / last |
| `,ts` / `,to` | Summary / output |
| `,tw` | Watch file · `[t` `]t` jump to failed |

**Git (`,g`)**

| Key | Action |
|-----|--------|
| `,gg` | lazygit (full TUI) |
| `]c` `[c` | Next / previous hunk |
| `,gs` / `,gr` | Stage / reset hunk |
| `,gp` / `,gb` | Preview hunk / blame line |
| `,gv` / `,gl` | Diffview / log |

**Rails (`,r`) & DB** — `,ra` alternate file (impl↔spec) · `,rr` related · `,D` toggle dadbod-ui

**Editing**

| Key | Action |
|-----|--------|
| `gr` / `grr` / visual `gr` | Replace with register (ReplaceWithRegister) |
| `<C-p>` / `<C-n>` | Cycle older / newer yank after a put |
| `ys` `cs` `ds` | Add / change / delete surround |
| `gc` | Toggle comment (motion or visual) |
| `jj` | Escape · `;` for `:` · `,h` clear highlight |

`,d` (debug) is reserved for when DAP is added.

## Shell

- `ls`/`ll`/`la`/`lt` → eza · `cat` → bat
- `z <dir>` jump (zoxide) · `zi` pick interactively
- `^R` history · `^T` files · `⌥C` cd (fzf) · `**<tab>` fuzzy completion
- Up/Down — substring-search history; `,` git/ruby/rails aliases from prezto (`g`, `gco`, `glo`, `gp`, …)
- Per-machine extras (not tracked): `~/.zshrc.local`, `~/.zshenv.local`, `~/.zprofile.local`

## Git aliases (gitconfig)

`git st` status · `git co` checkout · `git ci` commit · `git br` branch ·
`git hist` graph log · `git filter` linear first-parent log

## Herdr

Herdr.app, with terminals in herdr-core (`hc`): spaces → tabs → panes, and agents'
state in the sidebar. Config in `herdr-app/` (`keys.json`, `settings.json`, Kanagawa
themes, the `jdeff` layout). Prefix chords use **`C-b`** (`C-b C-b` sends a literal
`C-b`); the app's own Cmd keys stay on top.

| Key | Action |
|-----|--------|
| `C-h/j/k/l` | Move between panes **and** nvim splits (the `vim-nav` mod; `jdeff` layout only). Same keys in Rex (`rex/keys/vim_nav.lua`) |
| `C-b \|` / `C-b -` | Split right / down |
| `alt+1..9` / `alt+j`/`k` | Jump to / cycle spaces |
| `C-b shift+j` / `shift+k` | Cycle agents |
| `C-b shift+l` | lazygit (split below) |
| `C-b shift+m` / `C-b ctrl+p` | Merge worktree / open PR (from inside the worktree) |
| `cmd-p` / `cmd-shift-p` | Picker / command palette |
| `cmd-/` | Show all keybindings |
| `ctrl-alt-shift-escape` | Reset the layout and keys if a bad edit locks you out |

Worktrees: the space's right-click and `+` menus (New / Open / Remove worktree).

In Rex, `C-b t` (or *New Task…* in the palette) floats a Claude in `~/src`: type a
task or a ticket key and it dispatches worktrees to any repo, then closes itself
(`rex/actions/new_task.lua`, instructions in `rex/new-task.md`).

After a Rex server restart, Rex brings back sessions and panes but not the agents in
them: `rex-session restore` resumes each pane's Claude (`-n` to preview, `list` to see
what's recorded).

Slash commands (tracked in `dev/skills/`, working in Herdr or Rex): `/worktree <tasks>`
dispatches a worktree per task into `~/src/.worktrees`, `/ticket ABC-123` works a
Linear ticket, `/open-pr` opens PRs
(stack-aware, fills the repo's template), `/pr-watch` keeps an open PR or stack
healthy, plus `/merge`, `/merged`, `/discard`, and `/rebase` — both merge skills close
the Linear tickets the branch completes, via the shared `ticket-close` skill, and
`/discard` throws away an unmerged worktree and its branch after showing what would
be lost. All three tear down through the shared `worktree-retire` skill. Dispatch
mechanics live once in the shared `dispatch` skill. The `herdr-app` and `hc` skills
are generated by `install.sh` from `herdr-app --skill` and `hc --skill`.

## Terminal (Ghostty)

- Theme follows macOS appearance: Kanagawa **Lotus** (light) / **Wave** (dark).
- Reload config: ⌘⇧, — but the light/dark theme split only re-binds on a full
  relaunch (⌘Q) or an OS appearance change, not on reload.
- Font: Lilex Nerd Font Mono, Medium.
