return {
  -- Seamless C-h/j/k/l between nvim splits and the surrounding multiplexer.
  -- The mappings live in after/plugin/herdr_nav.lua: they move between nvim splits
  -- and, at a split edge, cross into a herdr pane (when $HERDR_PANE_ID is set) or a
  -- tmux pane otherwise. We keep vim-tmux-navigator for the tmux-edge case (its
  -- TmuxNavigate* commands are the fallback), lazy-loaded on first use, but disable
  -- its own key mappings so herdr_nav.lua owns C-h/j/k/l.
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
