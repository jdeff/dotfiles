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
brew 'gh'          # GitHub CLI; also the git credential helper for github (see git/gitconfig)
brew 'yq'          # jq for YAML/TOML/XML

# Editor
brew 'neovim'
brew 'tree-sitter-cli' # nvim-treesitter (main branch) compiles parsers with this

# Build toolchain — cargo/rustc, for the Rust tools built from source outside
# brew (`muster`). Needs Rust >= 1.85 for edition 2024.
brew 'rust'

# Runtime version manager (ruby, node) — shims on PATH + interactive activation.
brew 'mise'

# macOS light/dark watcher (event-driven). Powers nvim's dark_notify integration
# so the editor follows the system appearance without polling. (Herdr does its own
# appearance switching — the theme pair in herdr-app/settings.json.)
brew 'cormacrelf/tap/dark-notify'

# Terminal + font (font supplies the glyphs Starship's prompt uses)
cask 'herdr-app' # Herdr: workspaces for coding agents, on herdr-core (`hc`)
cask 'ghostty'
cask 'font-lilex-nerd-font'

# Secrets / credentials
cask '1password-cli' # `op` — pull secrets into .local files / shell env

# Coding agents
cask 'devin-cli' # `devin` — local agent + Devin Cloud sessions

# Desktop apps
cask 'alfred'   # Spotlight replacement
cask 'dash'     # offline documentation browser
cask 'claude'   # Anthropic's Claude desktop app
cask 'shottr'   # screenshot + annotation tool
cask 'bartender' # menu bar icon organizer
