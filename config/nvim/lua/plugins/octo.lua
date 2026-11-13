return {
	"pwntester/octo.nvim",
	lazy = true,
	cmd = "Octo",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-mini/mini.icons" },
	opts = {
		picker = "snacks",
		mappings_disable_default = true,
	},
}
