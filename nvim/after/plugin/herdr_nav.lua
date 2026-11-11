-- Seamless <C-h/j/k/l> navigation between Neovim splits and Herdr panes. Move
-- between Neovim splits; at a split edge, cross into the neighbouring Herdr pane
-- with `herdr-app do pane.go`, which acts on the app's focused pane, i.e. this
-- one. The other half is the vim-nav mod (herdr-app/mods/vim-nav), which presses
-- the keys into nvim instead of moving Herdr's focus.
--
-- Adapted from paulbkim-dev/vim-herdr-navigation (editor/nvim.lua). Loaded from
-- after/plugin so it wins over any other <C-h/j/k/l> mappings.

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return -- moved within Neovim
  end
  -- At a split edge: cross into the surrounding Herdr pane ($HC_TERMINAL_ID is
  -- set in every Herdr terminal).
  if vim.env.HC_TERMINAL_ID and vim.env.HC_TERMINAL_ID ~= "" then
    vim.fn.system({ "herdr-app", "do", "pane.go", "--direction", dir })
  end
end

local function map(lhs, wincmd, dir, desc)
  vim.keymap.set("n", lhs, function()
    nav(wincmd, dir)
  end, { silent = true, noremap = true, desc = desc })
end

map("<C-h>", "h", "left", "Navigate left (vim/herdr)")
map("<C-j>", "j", "down", "Navigate down (vim/herdr)")
map("<C-k>", "k", "up", "Navigate up (vim/herdr)")
map("<C-l>", "l", "right", "Navigate right (vim/herdr)")
