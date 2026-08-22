return {
	"neovim/nvim-lspconfig",
	-- config/lsp.lua が起動直後に vim.lsp.config[...] でサーバ定義を解決するため、
	-- lsp/ を runtimepath に載せるのを遅延させられない
	lazy = false,
}
