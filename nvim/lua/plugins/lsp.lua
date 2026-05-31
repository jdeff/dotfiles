return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
    },
    config = function()
      -- Servers to install + their per-server settings. Empty table = defaults.
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              diagnostics = { globals = { "vim" } },
              completion = { callSnippet = "Replace" },
            },
          },
        },
        ruby_lsp = {}, -- Shopify ruby-lsp; surfaces rubocop diagnostics when present
        vtsls = {
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = { enabled = "literals" },
                variableTypes = { enabled = true },
              },
            },
          },
        },
        eslint = {},
        graphql = {
          filetypes = {
            "graphql", "typescript", "typescriptreact", "javascript", "javascriptreact",
          },
        },
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = { enable = false, url = "" },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        },
        html = {},
        cssls = {},
        dockerls = {},
        docker_compose_language_service = {},
        bashls = {},
        sqlls = {},
      }

      -- Completion capabilities from blink.cmp, applied to every server.
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })
      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
      end

      require("mason-tool-installer").setup({
        ensure_installed = { "stylua", "prettier", "rubocop", "sql-formatter" },
      })
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })

      -- Diagnostics presentation.
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = true },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = { spacing = 2, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
      })

      -- Buffer-local keymaps once a server attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local function nmap(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
          end
          local tb = require("telescope.builtin")

          -- Navigation stays on the universal `g` prefix.
          nmap("gd", tb.lsp_definitions, "Definitions")
          nmap("gI", tb.lsp_implementations, "Implementations")
          nmap("gy", tb.lsp_type_definitions, "Type definitions")
          nmap("gD", vim.lsp.buf.declaration, "Declaration")
          nmap("K", vim.lsp.buf.hover, "Hover docs")
          -- ,c<action> code domain.
          nmap("<leader>cc", vim.lsp.buf.code_action, "Code action")
          nmap("<leader>cr", tb.lsp_references, "References") -- gr is ReplaceWithRegister
          nmap("<leader>cn", vim.lsp.buf.rename, "Rename symbol")
          nmap("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          nmap("<leader>cs", tb.lsp_document_symbols, "Document symbols")

          -- Toggle inlay hints if the server supports them.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            nmap("<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
          end

          -- eslint: fix all auto-fixable problems on save.
          if client and client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = buf,
              command = "LspEslintFixAll",
            })
          end
        end,
      })
    end,
  },
}
