return {
	"sphamba/smear-cursor.nvim",
	cond = not vim.g.neovide and not os.getenv("TERM") == "xterm-ghostty",
	lazy = true,
	event = "VeryLazy",
	opts = {},
}
