return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- master is frozen and breaks on Neovim 0.11+/0.12
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
      local parsers = {
        -- Backend
        "ruby", "embedded_template", "graphql", "sql",
        -- Frontend
        "typescript", "tsx", "javascript", "jsdoc", "css", "html", "scss",
        -- Config / infra / docs
        "json", "jsonc", "yaml", "toml", "dockerfile", "bash",
        "lua", "luadoc", "vim", "vimdoc", "markdown", "markdown_inline",
        "regex", "diff", "gitcommit", "git_rebase", "gitignore", "query",
      }
      require("nvim-treesitter").install(parsers)

      -- On `main`, highlighting is started per buffer rather than via a config
      -- table. Start it wherever a parser exists; skip filetypes without one.
      local nt = require("nvim-treesitter")
      local has_indent = type(nt.indentexpr) == "function"
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim_treesitter_start", { clear = true }),
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            if has_indent then
              vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end
        end,
      })

      -- Textobjects (main-branch API): select + move, wired up by hand.
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local select = require("nvim-treesitter-textobjects.select").select_textobject
      local move = require("nvim-treesitter-textobjects.move")
      local function tmap(mode, lhs, fn, desc)
        vim.keymap.set(mode, lhs, fn, { desc = desc })
      end
      tmap({ "x", "o" }, "af", function() select("@function.outer", "textobjects") end, "a function")
      tmap({ "x", "o" }, "if", function() select("@function.inner", "textobjects") end, "inner function")
      tmap({ "x", "o" }, "ac", function() select("@class.outer", "textobjects") end, "a class")
      tmap({ "x", "o" }, "ic", function() select("@class.inner", "textobjects") end, "inner class")
      tmap({ "x", "o" }, "aa", function() select("@parameter.outer", "textobjects") end, "a parameter")
      tmap({ "x", "o" }, "ia", function() select("@parameter.inner", "textobjects") end, "inner parameter")
      -- Method-style motions (]c/[c are gitsigns hunks, so functions use ]f/[f).
      tmap({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, "Next function")
      tmap({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, "Prev function")
    end,
  },
}
