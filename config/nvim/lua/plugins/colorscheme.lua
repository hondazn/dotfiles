return {
	{
		"catppuccin/nvim",
		-- リポジトリ名が nvim のため lazy.nvim が主モジュールを解決できない
		main = "catppuccin",
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			transparent_background = true,
		},
	},
	-- 起動時に要るのは catppuccin-mocha だけ。他テーマは <leader>ft の一覧に
	-- 出すため rtp には載せるが、読み込みは起動後で間に合う
	{ "rose-pine/neovim", event = "VeryLazy" },
	{
		"dgox16/oldworld.nvim",
		event = "VeryLazy",
		opts = {
			integrations = {
				navic = true,
				alpha = false,
				rainbow_delimiters = false,
			},
			highlight_overrides = {
				Normal = { bg = 'NONE' },
				NonText = { bg = 'NONE' },
				NormalNC = { bg = 'NONE' },
				-- CursorLine = { bg = '#222128' },
			},
		}
	},
	{ "kvrohit/mellow.nvim", event = "VeryLazy" },
	{ "Yazeed1s/minimal.nvim", event = "VeryLazy" },
	{ "yashguptaz/calvera-dark.nvim", event = "VeryLazy" },
	{ "embark-theme/vim", name = "embark", event = "VeryLazy" },
}
