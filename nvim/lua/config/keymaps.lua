local map = vim.keymap.set

-- ── Carried from the long-standing vim setup ────────────────────────────────
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("n", ";", ":", { desc = "Command line without Shift" })
map("n", "/", [[/\v]])
map("n", "?", [[?\v]])

-- ── Search highlight ────────────────────────────────────────────────────────
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- ── Window navigation ───────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ── Buffers ─────────────────────────────────────────────────────────────────
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- ── Quality-of-life editing ─────────────────────────────────────────────────
-- Keep the cursor centered while jumping around.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Move selected lines up/down, reindenting.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the selection after shifting indent.
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Paste over a selection without clobbering the unnamed register.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })

-- Save / quit.
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })

-- Strip trailing whitespace.
map("n", "<F5>", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, { desc = "Strip trailing whitespace" })

-- Edit / reload this config.
map("n", "<leader>`", "<cmd>edit $MYVIMRC<cr>", { desc = "Edit init.lua" })
