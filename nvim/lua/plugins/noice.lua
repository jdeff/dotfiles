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
        -- blink.cmp already renders the signature popup; let it own that.
        signature = { enabled = false },
      },
    },
  },
}
