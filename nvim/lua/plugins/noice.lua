return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          background_colour = "#1f1f28", -- avoids the transparent-bg warning
          timeout = 3000,
          render = "wrapped-compact",
          stages = "fade",
          max_width = 80,
        },
      },
    },
    keys = {
      { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss notifications" },
      { "<leader>nl", "<cmd>Noice last<cr>", desc = "Last message" },
      { "<leader>nh", "<cmd>Noice<cr>", desc = "Message history" },
    },
    opts = {
      presets = {
        command_palette = true,      -- cmdline + completion menu as a centered float
        long_message_to_split = true, -- big messages open in a split
        lsp_doc_border = true,
      },
      lsp = {
        -- Let Noice own LSP markdown rendering + signature (clears the
        -- checkhealth warnings; blink.cmp's signature is disabled to match).
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        signature = { enabled = true },
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)

      -- Noice links the cmdline border to DiagnosticSignInfo, which kanagawa
      -- gives the sign-column background (#2a2a37) — so the border looks like
      -- a gutter-colored strip. Keep the border's fg (the colored line) but
      -- set its bg to the editor (Normal) background so the framed box matches
      -- the cmdline input field.
      local groups = {
        "NoiceCmdlinePopupBorder",
        "NoiceCmdlinePopupTitle",
        "NoiceCmdlinePopupBorderSearch",
      }
      local function blend_borders()
        local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
        for _, g in ipairs(groups) do
          local cur = vim.api.nvim_get_hl(0, { name = g, link = false })
          vim.api.nvim_set_hl(0, g, { fg = cur.fg, bg = normal_bg, bold = cur.bold })
        end
      end
      blend_borders()
      -- Re-apply after a colorscheme change (e.g. the light/dark auto-switch).
      vim.api.nvim_create_autocmd("ColorScheme", { callback = blend_borders })
    end,
  },
}
