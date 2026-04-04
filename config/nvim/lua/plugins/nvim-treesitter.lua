return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable" },
	build = ":TSUpdate",
	config = function()
		vim.treesitter.language.register("markdown", "octo")
		require("nvim-treesitter").setup({})

		local ensure = { "lua", "luadoc", "printf", "vim", "vimdoc", "typescript", "markdown", "markdown_inline", "rust" }
		local installed = require("nvim-treesitter").get_installed()
		local to_install = vim.tbl_filter(function(p)
			return not vim.tbl_contains(installed, p)
		end, ensure)
		if #to_install > 0 then
			require("nvim-treesitter.install").install(to_install)
		end
	end,
}
