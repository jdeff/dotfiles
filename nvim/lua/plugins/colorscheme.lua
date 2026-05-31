return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000, -- load before other plugins so highlights are ready
    opts = {
      compile = true,
      dimInactive = true,
      -- Variant chosen by background: Lotus (light) / Wave (dark), matching Ghostty.
      background = { dark = "wave", light = "lotus" },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("kanagawa")
    end,
  },

  -- Follow the macOS system appearance and flip the kanagawa variant to match.
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 999,
    opts = {
      set_dark_mode = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme("kanagawa")
      end,
      set_light_mode = function()
        vim.o.background = "light"
        vim.cmd.colorscheme("kanagawa")
      end,
      update_interval = 3000,
    },
  },
}
