return {
	"folke/lazydev.nvim",
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			-- See the configuration section for more details
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
