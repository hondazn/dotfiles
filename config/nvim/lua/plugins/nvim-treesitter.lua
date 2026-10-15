return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable" },
	build = ":TSUpdate",
	config = function()
		-- install 先を rtp の先頭に置く。plugin ディレクトリに落ちた parser/*.so より
		-- こちらを先に読ませる（setup は install_dir を渡したときだけ rtp を足す）
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		local ensure =
			{ "lua", "luadoc", "printf", "vim", "vimdoc", "typescript", "markdown", "markdown_inline", "rust" }
		local installed = require("nvim-treesitter").get_installed()
		local to_install = vim.tbl_filter(function(p) return not vim.tbl_contains(installed, p) end, ensure)
		if #to_install > 0 then require("nvim-treesitter.install").install(to_install) end
	end,
}
