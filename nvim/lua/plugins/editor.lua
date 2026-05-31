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

  -- Yank history (the modern YankRing): cycle older/newer yanks after a put
  -- with <C-p>/<C-n>, plus a Telescope picker.
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      ring = { storage = "shada" }, -- persists across sessions, no native dep
      highlight = { timer = 200 },
    },
    keys = {
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after (cursor moves)" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before (cursor moves)" },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank" },
      { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Cycle to older yank" },
      { "<C-n>", "<Plug>(YankyNextEntry)", desc = "Cycle to newer yank" },
      { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Yank history" },
    },
    config = function(_, opts)
      require("yanky").setup(opts)
      pcall(require("telescope").load_extension, "yank_history")
    end,
  },

  -- ReplaceWithRegister, modern reimplementation: gr{motion}, grr (line),
  -- and gr in visual mode replace the target with the register's contents.
  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    config = function()
      local sub = require("substitute")
      sub.setup()
      -- Free the `gr` prefix: drop Neovim 0.11+ default gr* LSP maps (our LSP
      -- keymaps live elsewhere — see lsp.lua).
      for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt", "grl" }) do
        pcall(vim.keymap.del, "n", lhs)
        pcall(vim.keymap.del, "x", lhs)
      end
      vim.keymap.set("n", "gr", sub.operator, { desc = "Replace with register" })
      vim.keymap.set("n", "grr", sub.line, { desc = "Replace line with register" })
      vim.keymap.set("x", "gr", sub.visual, { desc = "Replace with register" })
    end,
  },
}
