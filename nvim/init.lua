-- ~/.config/nvim/init.lua — minimal neovim config: core options + keymaps.
-- No plugin manager, LSP, or colorscheme yet; a fuller setup comes next.

-- Leader must be set before any mapping that uses it.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

local o = vim.opt

-- ── Display ───────────────────────────────────────────────────────────────
o.number = true
o.ruler = true
o.textwidth = 78
o.colorcolumn = "81"
o.termguicolors = true     -- true color; ready for kanagawa
o.autoread = true          -- reload files changed outside nvim

-- ── Search ────────────────────────────────────────────────────────────────
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true         -- case-sensitive once you type an uppercase letter
o.gdefault = true          -- :s substitutes all matches on a line by default

-- ── Indentation ─────────────────────────────────────────────────────────--
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.autoindent = true

-- ── Folding (open by default) ───────────────────────────────────────────--
o.foldmethod = "indent"
o.foldlevelstart = 99
o.foldenable = false

-- ── Keymaps ─────────────────────────────────────────────────────────────--
local map = vim.keymap.set

map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("n", ";", ":", { desc = "Enter command line without Shift" })

-- Very-magic search: `/` starts a \v pattern, so regex behaves sanely.
map("n", "/", [[/\v]])
map("n", "?", [[?\v]])

map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<C-n>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

map("n", "<F5>", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, { desc = "Strip trailing whitespace" })

-- Window navigation with Ctrl + h/j/k/l.
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<leader>`", "<cmd>edit $MYVIMRC<cr>", { desc = "Edit init.lua" })
