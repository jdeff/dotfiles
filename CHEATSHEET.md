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
- macOS: set Appearance (light/dark — Ghostty, herdr, and nvim follow it), and
  remap Alfred's hotkey to ⌘Space (disable Spotlight's under Keyboard Shortcuts).
- Install **herdr** (the multiplexer — not in the Brewfile) and register its
  plugins/integration once. `install.sh` only symlinks the config, so do the
  bootstrap in `herdr/README.md`: `curl -fsSL https://herdr.dev/install.sh | sh`,
  then `herdr plugin link`/`install` and `herdr integration install claude`.
  Re-run `./install.sh` afterwards to generate `~/.claude/skills/herdr/SKILL.md`.

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
- `herdr` is the multiplexer — deliberately un-aliased (nested subcommands, and you drive it by keybinding, not from the shell). `herdr update` self-updates; delete `~/.local/share/zsh/site-functions/_herdr` afterwards to regenerate completions.
- Per-machine extras (not tracked): `~/.zshrc.local`, `~/.zshenv.local`, `~/.zprofile.local`

## Git aliases (gitconfig)

`git st` status · `git co` checkout · `git ci` commit · `git br` branch ·
`git hist` graph log · `git filter` linear first-parent log

## Herdr (the multiplexer)

Mouse-first and agent-aware; it replaced tmux + workmux, so there's no tmux
config here. Prefix is **`C-b`**. Theme follows the macOS appearance (Kanagawa
Wave/Lotus) natively. Full reference: `herdr/CHEATSHEET.md`; setup and the
one-time bootstrap: `herdr/README.md`.

| Key | Action |
|-----|--------|
| `C-h/j/k/l` | Move between panes **and** nvim splits (seamless) |
| `prefix \|` / `prefix -` | Split right / down |
| `alt+1..9` / `alt+j`/`k` | Jump to / cycle spaces (either Option = Alt) |
| `prefix shift+g` | New worktree off main (branch + grouped space, auto Claude+shell) |
| `prefix shift+b` | New worktree stacked on the current branch (from inside a worktree) |
| `prefix a` | Apply Claude+shell layout to current space |
| `prefix shift+j` / `shift+k` | Cycle agents in the sidebar |
| `prefix shift+l` | lazygit (throwaway pane) |
| `prefix shift+m` / `prefix ctrl+p` | Merge worktree / open PR (also right-click a space) |
| `prefix ctrl+x` | Remove this worktree after merge (checkout + space; keeps branch) |
| `prefix alt+d/m/u/x/s/k` | muster: dashboard / menu / up / down / status / lazydocker |
| `prefix q` | Detach (reattach with `herdr`) |
| `prefix ?` | Show all keybindings |

Slash commands (tracked in `herdr/skills/`): `/worktree <tasks>` dispatches a
worktree per task, `/coordinator` runs the whole spawn→monitor→merge lifecycle,
`/merge`, `/rebase`, `/open-pr`. Herdr's own agent-control skill is generated by
`install.sh` from `herdr --skill`.

## Terminal (Ghostty)

- Theme follows macOS appearance: Kanagawa **Lotus** (light) / **Wave** (dark).
- Reload config: ⌘⇧, — but the light/dark theme split only re-binds on a full
  relaunch (⌘Q) or an OS appearance change, not on reload.
- Font: Lilex Nerd Font Mono, Medium.
