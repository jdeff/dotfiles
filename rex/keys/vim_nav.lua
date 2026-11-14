-- vim-nav: ctrl+h/j/k/l moves between Rex panes and vim splits, like
-- vim-tmux-navigator, and Herdr's vim-nav mod (herdr-app/mods/vim-nav).
--
-- When the focused terminal's foreground program is vim, nvim or fzf, the
-- function returns false and Rex sends the key on to it unchanged; nvim walks
-- its own splits and runs `rex focus <dir>` at the edge
-- (nvim/after/plugin/mux_nav.lua). Anything else moves pane focus here.

local TERMINAL = "com.superlogical.terminal"

-- vi, vim, nvim, view, vimdiff, gvim..., plus fzf, which uses ctrl+j/k itself.
local VIM = {
  vi = true, vim = true, nvim = true, view = true, vimdiff = true,
  nvimdiff = true, gvim = true, vimx = true, fzf = true,
}

local function runs_vim(block_id)
  local p = rex.block.call(TERMINAL, "process", { block_id = block_id })
  local fg = p and p.foreground
  if not fg then return false end
  -- argv0 is what was typed ("nvim", or "-zsh" for a login shell); name is the
  -- binary, which can be a version string, so it is only the fallback.
  local name = (fg.argv0 or fg.name or ""):match("[^/]*$"):gsub("^%-", "")
  return VIM[name:lower()] == true
end

for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    if ctx.block_id and runs_vim(ctx.block_id) then
      return false -- let vim/fzf have the key
    end
    rex.session.focus_direction({ direction = dir })
    return true
  end)
end
