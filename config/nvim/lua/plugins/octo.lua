return {
	"pwntester/octo.nvim",
	lazy = true,
	cmd = "Octo",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
	opts = {
		picker = "snacks",
		mappings_disable_default = true,
	},
}
