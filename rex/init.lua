-- Rex config, ported from ~/.config/herdr-app/keys.json (tmux-style, prefix ctrl+b).
-- Only keys with a direct Rex action are bound so far, plus vim-nav. Herdr
-- features without one (agents, lazygit/worktree splits, space-by-number, pane
-- swap, help, layouts, paste-image) are deliberately left out for now.
--
-- Layout: each require loads a file beside this one; a dot is a folder.
--   keys/global.lua   single keys: cmd, alt and function keys
--   keys/prefix.lua   ctrl+b sequences
--   keys/vim_nav.lua  ctrl+h/j/k/l across panes and nvim splits
-- Put custom actions (rex.action) in actions/<name>.lua and require them
-- before the key files that bind them; modes go in modes/<name>.lua.
--
-- Lives in ~/dotfiles/rex, linked whole to ~/.config/rex by install.sh.
-- Apply changes with: rex config check && rex config reload

require("actions.new_task")

require("keys.global")
require("keys.prefix")
require("keys.vim_nav")
