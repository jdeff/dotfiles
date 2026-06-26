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
        -- Shopify ruby-lsp; surfaces rubocop diagnostics when present.
        -- Run via the mise shim (NOT Mason): Mason bakes a fixed Ruby interpreter
        -- into the launcher's shebang, which breaks per-project Ruby switching.
        -- The shim resolves each project's .ruby-version at exec time. Install
        -- per-Ruby with: `gem install ruby-lsp && mise reshim`.
        ruby_lsp = {
          cmd = { vim.fn.expand("~/.local/share/mise/shims/ruby-lsp") },
        },
        vtsls = {
          settings = {
            -- Drive tsserver from the workspace's own TypeScript (node_modules/
            -- typescript/lib) so diagnostics match tsc/CI, instead of vtsls's
            -- bundled copy. Falls back to the bundled version when a project has
            -- none. vtsls itself runs on the mise-shimmed node via its `env node`
            -- shebang, so the Node version already tracks the project.
            vtsls = {
              autoUseWorkspaceTsdk = true,
            },
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
        -- rubocop intentionally excluded: conform runs the project's bundled
        -- rubocop via `bundle exec` (see plugins/formatting.lua).
        ensure_installed = { "stylua", "prettier", "sql-formatter" },
      })
      -- ruby-lsp is intentionally excluded from Mason management (see ruby_lsp
      -- above); we let Mason install/enable everything else and enable ruby-lsp
      -- ourselves so it runs through the mise shim.
      local mason_servers = vim.tbl_filter(function(name)
        return name ~= "ruby_lsp"
      end, vim.tbl_keys(servers))

      require("mason-lspconfig").setup({
        ensure_installed = mason_servers,
        automatic_enable = true,
      })

      vim.lsp.enable("ruby_lsp")

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
