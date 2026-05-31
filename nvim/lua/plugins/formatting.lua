return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format buffer/selection",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        ruby = { "rubocop" },
        sql = { "sql_formatter" },
        -- Frontend: prefer the project's oxfmt, fall back to prettier.
        javascript = { "oxfmt", "prettier", stop_after_first = true },
        javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
        typescript = { "oxfmt", "prettier", stop_after_first = true },
        typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
        graphql = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
      },
      -- Format on save, but never block the write if a formatter is slow/missing.
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
      formatters = {
        -- oxc's formatter; project-local, so resolved from the project's bin.
        oxfmt = {
          command = "oxfmt",
          args = { "$FILENAME" },
          stdin = false,
        },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      -- :FormatToggle [global] — flip autoformat off for this buffer (or all).
      vim.api.nvim_create_user_command("FormatToggle", function(args)
        if args.bang then
          vim.g.disable_autoformat = not vim.g.disable_autoformat
        else
          vim.b.disable_autoformat = not vim.b.disable_autoformat
        end
      end, { bang = true, desc = "Toggle format-on-save" })
    end,
  },
}
