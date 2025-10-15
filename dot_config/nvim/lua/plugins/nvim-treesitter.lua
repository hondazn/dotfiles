return {
	"nvim-treesitter/nvim-treesitter",
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
	build = ":TSUpdate",
	config = function()
		vim.treesitter.language.register("markdown", "octo")

		require("nvim-treesitter.configs").setup({
			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			-- List of parsers to ignore installing (or "all")
			ignore_install = {},

			modules = {},

			ensure_installed = {
				"lua",
				"luadoc",
				"printf",
				"vim",
				"vimdoc",
				"typescript",
				"markdown",
				"markdown_inline",
			},

			highlight = {
				enable = true,
				use_languagetree = true,
			},

			indent = { enable = true },
		})
	end,
}
