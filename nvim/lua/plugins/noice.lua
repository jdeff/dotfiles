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
		},
		config = function(_, opts)
			require("noice").setup(opts)

			-- Noice links the cmdline border to DiagnosticSignInfo — the
			-- sign-column variant, which carries the gutter background (#2a2a37),
			-- so the border read as a gutter-colored strip. Re-point it at the
			-- plain Diagnostic groups: same fg, no bg, so the border inherits the
			-- popup's Normal background. (Noice re-asserts its default links on
			-- ColorScheme, so re-apply there too — covers the Lotus/Wave switch.)
			local relinks = {
				NoiceCmdlinePopupBorder = "DiagnosticInfo",
				NoiceCmdlinePopupTitle = "DiagnosticInfo",
				NoiceCmdlinePopupBorderSearch = "DiagnosticWarn",
			}
			local function relink()
				for group, target in pairs(relinks) do
					vim.api.nvim_set_hl(0, group, { link = target })
				end
			end
			relink()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = relink })
		end,
	},
}
