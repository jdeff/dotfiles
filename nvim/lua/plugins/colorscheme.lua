return {
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000, -- load before other plugins so highlights are ready
		opts = {
			compile = true, -- cache compiled highlights for faster startup (run :KanagawaCompile after opts changes)
			dimInactive = true,
			-- Variant chosen by background: Lotus (light) / Wave (dark), matching Ghostty.
			background = { dark = "wave", light = "lotus" },
			-- Re-point noice's cmdline border off the sign-column groups (which
			-- carry the gutter bg) to the plain Diagnostic groups (no bg → inherit
			-- the popup's Normal). Applied during :colorscheme, before noice's
			-- ColorScheme handler, which links with default=true and won't clobber.
			overrides = function()
				return {
					NoiceCmdlinePopupBorder = { link = "DiagnosticInfo" },
					NoiceCmdlinePopupTitle = { link = "DiagnosticInfo" },
					NoiceCmdlinePopupBorderSearch = { link = "DiagnosticWarn" },
					NoiceCmdlineIcon = { link = "DiagnosticInfo" },
					NoiceCmdlineIconSearch = { link = "DiagnosticWarn" },
				}
			end,
		},
		config = function(_, opts)
			require("kanagawa").setup(opts)
			-- Pick the variant synchronously so the FIRST paint already matches the
			-- system. dark-notify (below) reads the mode asynchronously, so without
			-- this the hardcoded default paints first and you get a dark→light flash
			-- in light mode. `dark-notify --exit` prints the current mode and exits;
			-- fall back to dark if it's missing (fresh machine / non-macOS).
			local mode = vim.trim(vim.fn.system("dark-notify --exit"))
			vim.o.background = (mode == "light" or mode == "dark") and mode or "dark"
			vim.cmd.colorscheme("kanagawa")
		end,
	},

	-- Follow the macOS system appearance and flip the kanagawa variant to match.
	-- Event-driven (no polling): dark-notify (brew) pushes changes over a pipe,
	-- and kanagawa picks wave/light from `background` (set in the spec above).
	{
		"cormacrelf/dark-notify",
		lazy = false,
		priority = 999, -- after kanagawa (1000), so the colorscheme exists
		config = function()
			require("dark_notify").run({
				schemes = { dark = "kanagawa", light = "kanagawa" },
			})
		end,
	},
}
