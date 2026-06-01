return {
  -- Splash screen / dashboard shown on an argument-less `nvim`.
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Custom `jdeff` banner.
      dashboard.section.header.val = {
        [[   _   _     ___ ___ ]],
        [[  |_|_| |___|  _|  _|]],
        [[  | | . | -_|  _|  _|]],
        [[ _| |___|___|_| |_|  ]],
        [[|___|                ]],
      }
      dashboard.section.header.opts.hl = "Function"

      -- Persistent scratch file for quick notes (markdown, survives sessions).
      local scratch = vim.fn.stdpath("cache") .. "/scratch.md"

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
        dashboard.button("n", "  New file", "<cmd>ene <bar> startinsert<cr>"),
        dashboard.button("s", "  Scratch", "<cmd>edit " .. scratch .. "<cr>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<cr>"),
        dashboard.button("e", "  File explorer", "<cmd>Neotree toggle<cr>"),
        dashboard.button("c", "  Config", "<cmd>edit $MYVIMRC<cr>"),
        dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
        dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
      }

      alpha.setup(dashboard.config)
    end,
  },
}
