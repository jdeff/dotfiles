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
				command_palette = true, -- cmdline + completion menu as a centered float
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
			-- The cmdline border color is re-pointed in the kanagawa overrides
			-- (lua/plugins/colorscheme.lua): Noice links those groups with
			-- default=true, so a theme override wins and needs no autocmd here.
		},
	},
}
