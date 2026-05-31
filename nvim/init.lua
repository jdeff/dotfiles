-- ~/.config/nvim/init.lua — entry point.
-- Leader must be set before lazy.nvim loads so plugin mappings pick it up.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
