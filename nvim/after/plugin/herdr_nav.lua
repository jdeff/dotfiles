-- Seamless <C-h/j/k/l> navigation between Neovim splits and herdr panes. Move
-- between Neovim splits; at a split edge, cross into the neighbouring herdr pane.
-- In the herdr TUI ($HERDR_PANE_ID) that's `herdr pane focus`; in Herdr Desktop
-- ($HC_TERMINAL_ID, a herdr-core terminal) it's `herdr-app do pane.go`, which
-- acts on the app's focused pane, i.e. this one. The desktop side of the
-- handoff is the vim-nav mod (herdr-app/mods/vim-nav), which presses the keys in.
--
-- Vendored from paulbkim-dev/vim-herdr-navigation (editor/nvim.lua). Loaded from
-- after/plugin so it wins over any other <C-h/j/k/l> mappings.

local function bin(env, name)
  local path = vim.env[env]
  return (path and path ~= "") and path or name
end

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return -- moved within Neovim
  end
  -- At a split edge: cross into the surrounding herdr pane.
  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    vim.fn.system({ bin("HERDR_BIN_PATH", "herdr"), "pane", "focus", "--direction", dir, "--current" })
  elseif vim.env.HC_TERMINAL_ID and vim.env.HC_TERMINAL_ID ~= "" then
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
