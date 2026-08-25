return {
	"kylechui/nvim-surround",
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	lazy = true,
	-- ys/cs/ds は normal モードの操作。InsertEnter だと初回挿入までキーマップが存在しない
	event = "VeryLazy",
	opts = {},
}
