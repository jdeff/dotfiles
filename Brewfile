# Homebrew dependencies for this shell setup.
# Install with: brew bundle --file=Brewfile  (run by install.sh)

# Prompt
brew 'starship'

# Interactive shell plugins
brew 'zsh-syntax-highlighting'
brew 'zsh-autosuggestions'
brew 'zsh-completions'
brew 'zsh-history-substring-search'

# Navigation / fuzzy finding
brew 'fzf'
brew 'zoxide'

# Modern CLI replacements
brew 'git-delta'   # better git diffs
brew 'eza'         # ls
brew 'bat'         # cat
brew 'fd'          # find
brew 'ripgrep'     # grep
brew 'lazygit'     # terminal git UI (driven by nvim's lazygit.nvim)

# Editor + terminal multiplexer
brew 'neovim'
brew 'tree-sitter-cli' # nvim-treesitter (main branch) compiles parsers with this
brew 'tmux'

# Build toolchain — compiles the workmux fork from source (see workmux/README.md).
# cargo/rustc; workmux is edition 2024, so needs Rust >= 1.85.
brew 'rust'

# macOS light/dark watcher (event-driven). Powers the tmux-dark-notify plugin
# and nvim's dark_notify integration so both follow the system appearance
# without polling.
brew 'cormacrelf/tap/dark-notify'

# Terminal + font (font supplies the glyphs Starship's prompt uses)
cask 'ghostty'
cask 'font-lilex-nerd-font'

# Desktop apps
cask 'alfred'   # Spotlight replacement
cask 'dash'     # offline documentation browser
cask 'claude'   # Anthropic's Claude desktop app
cask 'shottr'   # screenshot + annotation tool
cask 'bartender' # menu bar icon organizer
