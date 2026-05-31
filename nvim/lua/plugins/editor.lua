return {
  -- Auto-insert/close pairs; integrates with treesitter.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },

  -- Surround text objects: ys / cs / ds.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Jump anywhere with `s` + label; great for big Rails/TS files.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- Highlight + search TODO/FIXME/HACK comments.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    },
    opts = {},
  },

  -- Auto-close/rename HTML/JSX tags.
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    ft = { "html", "javascriptreact", "typescriptreact", "eruby", "xml" },
    opts = {},
  },
}
