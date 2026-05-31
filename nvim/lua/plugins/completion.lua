return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*", -- uses the prebuilt Rust fuzzy matcher
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    opts = {
      keymap = {
        preset = "default", -- <C-y> accept, <C-n>/<C-p> select, <C-space> toggle
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      snippets = { preset = "luasnip" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- vim-dadbod-completion registers the "dadbod" source for SQL buffers.
        per_filetype = { sql = { "dadbod", "buffer" } },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        },
      },
      signature = { enabled = true },
    },
  },
}
