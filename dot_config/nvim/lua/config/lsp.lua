vim.lsp.enable("lua_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("oxlint")
vim.lsp.enable("rust_analyzer")
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
		},
	},
})
vim.lsp.enable("hls")

vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
