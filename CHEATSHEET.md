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
- Open `nvim` once and wait: lazy.nvim installs plugins, treesitter compiles
  parsers (via the `tree-sitter` CLI from the Brewfile), and Mason installs LSP
  servers + formatters. `:Lazy` and `:Mason` show progress; `:checkhealth` flags
  anything missing (e.g. `node` for vtsls).
- macOS: set Appearance (light/dark — Ghostty + nvim follow it), and remap
  Alfred's hotkey to ⌘Space (disable Spotlight's under Keyboard Shortcuts).
- `install.sh` also builds **workmux** from the `jdeff/workmux` fork into
  `~/.local/bin` (needs `rust` from the Brewfile + SSH access to the fork). If
  that step was skipped because SSH keys weren't ready yet, re-run
  `./workmux/install.sh` once they are. See `workmux/README.md`.

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
- `wm` → workmux (git-worktree + tmux-window manager, built from the fork). Subcommand shorthands: `wma` add (new worktree+window with a Claude pane), `wmr` remove, `wmm` merge + tear down, `wml` list, `wmo` open, `wmc` close, `wmd` dashboard; `wm init` scaffolds `.workmux.yaml`. `workmux-update` rebuilds the fork after a pull (see `workmux/README.md`).
- Per-machine extras (not tracked): `~/.zshrc.local`, `~/.zshenv.local`, `~/.zprofile.local`

## Git aliases (gitconfig)

`git st` status · `git co` checkout · `git ci` commit · `git br` branch ·
`git hist` graph log · `git filter` linear first-parent log

## tmux

Prefix is **`C-b`** (default). Plugins via TPM (auto-installed by `install.sh`;
if needed, open tmux and press `prefix + I`). Sessions auto-save/restore
(resurrect + continuum). Status bar follows the macOS appearance — Kanagawa
Wave (dark) / Lotus (light) — switched live by the tmux-dark-notify plugin, and
shows the currently playing Apple Music track (` Artist — Title`, blank when
nothing's playing) to the left of the clock.

| Key | Action |
|-----|--------|
| `C-h/j/k/l` | Move between panes **and** nvim splits (seamless) |
| `prefix \|` / `prefix -` | Split right / down (inherits cwd) |
| `prefix c` | New window (inherits cwd) |
| `prefix H/J/K/L` | Resize pane (repeatable) |
| `prefix r` | Reload config |
| `prefix F` | Fuzzy session/window picker (tmux-fzf) |
| `prefix [` then `v`/`y` | Copy mode: select / yank to clipboard |
| `prefix C-s` / `C-r` | Save / restore session manually |

## Terminal (Ghostty)

- Theme follows macOS appearance: Kanagawa **Lotus** (light) / **Wave** (dark).
- Reload config: ⌘⇧, — but the light/dark theme split only re-binds on a full
  relaunch (⌘Q) or an OS appearance change, not on reload.
- Font: Lilex Nerd Font Mono, Medium.
