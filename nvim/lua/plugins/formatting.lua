-- Prefer the project's own oxfmt, falling back to prettier for projects that
-- don't ship it. oxfmt covers everything prettier does here, so every web
-- filetype gets the same pair.
local web = { "oxfmt", "prettier", stop_after_first = true }

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
        javascript = web,
        javascriptreact = web,
        typescript = web,
        typescriptreact = web,
        graphql = web,
        json = web,
        jsonc = web,
        yaml = web,
        css = web,
        scss = web,
        html = web,
        markdown = web,
      },
      -- Format on save, but never block the write if a formatter is slow/missing.
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
      formatters = {
        -- oxc's formatter. Resolved from the project's node_modules rather than
        -- $PATH: it is never installed globally, so a bare command would always
        -- miss and silently fall through to Mason's prettier. Deferred into a
        -- function because conform.util is not on the rtp when this spec loads.
        oxfmt = {
          command = function(self, ctx)
            return require("conform.util").from_node_modules("oxfmt")(self, ctx)
          end,
          args = { "$FILENAME" },
          stdin = false,
        },
        -- Run the project's bundled RuboCop (via Bundler) rather than Mason's
        -- standalone copy, so project plugins like rubocop-rails load. Inherits
        -- the base formatter's args (--server -a --stdin …) via prepend_args.
        rubocop = {
          command = "bundle",
          prepend_args = { "exec", "rubocop" },
          cwd = function(_, ctx)
            return vim.fs.root(ctx.dirname, { "Gemfile" })
          end,
          require_cwd = true,
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
