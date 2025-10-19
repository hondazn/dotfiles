return {
	"catppuccin/nvim",
	"rose-pine/neovim",
	{"dgox16/oldworld.nvim", opts = {
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
	}},
	"kvrohit/mellow.nvim",
	"Yazeed1s/minimal.nvim",
	"yashguptaz/calvera-dark.nvim",
	{ "embark-theme/vim", name = "embark" },
}
