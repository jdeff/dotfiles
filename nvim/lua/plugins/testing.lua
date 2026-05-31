return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec", -- Rails backend
      "marilari88/neotest-vitest", -- Vite/React frontend
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run last test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show output" },
      { "<leader>tp", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Watch file" },
      { "[t", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
      { "]t", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rspec")({
            rspec_cmd = function()
              -- Use the project's bundled rspec when a Gemfile is present.
              if vim.fn.filereadable("Gemfile") == 1 then
                return { "bundle", "exec", "rspec" }
              end
              return { "rspec" }
            end,
          }),
          require("neotest-vitest"),
        },
      })
    end,
  },
}
