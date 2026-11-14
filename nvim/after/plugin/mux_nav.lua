-- Seamless <C-h/j/k/l> navigation between Neovim splits and multiplexer panes,
-- in Herdr or Rex. Move between Neovim splits; at a split edge, cross into the
-- neighbouring pane:
--   Herdr: `herdr-app do pane.go`, which acts on the app's focused pane, i.e.
--          this one. The other half is the vim-nav mod (herdr-app/mods/vim-nav),
--          which presses the keys into nvim instead of moving Herdr's focus.
--   Rex:   `rex focus <dir>`, which moves from the session's focused block, i.e.
--          this one. The other half is rex/keys/vim_nav.lua, which passes the
--          keys through to nvim instead of moving Rex's focus.
-- If both are set (one launched from inside the other), Herdr wins.
--
-- Adapted from paulbkim-dev/vim-herdr-navigation (editor/nvim.lua). Loaded from
-- after/plugin so it wins over any other <C-h/j/k/l> mappings.

local function set(v)
  return v ~= nil and v ~= ""
end

local function cross(dir)
  if set(vim.env.HC_TERMINAL_ID) then -- set in every Herdr terminal
    vim.fn.system({ "herdr-app", "do", "pane.go", "--direction", dir })
  elseif set(vim.env.REX_SESSION) then -- set in every Rex terminal
    vim.fn.system({ "rex", "focus", dir, "-s", vim.env.REX_SESSION })
  end
end

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return -- moved within Neovim
  end
  cross(dir)
end

local function map(lhs, wincmd, dir, desc)
  vim.keymap.set("n", lhs, function()
    nav(wincmd, dir)
  end, { silent = true, noremap = true, desc = desc })
end

map("<C-h>", "h", "left", "Navigate left (vim/mux)")
map("<C-j>", "j", "down", "Navigate down (vim/mux)")
map("<C-k>", "k", "up", "Navigate up (vim/mux)")
map("<C-l>", "l", "right", "Navigate right (vim/mux)")
