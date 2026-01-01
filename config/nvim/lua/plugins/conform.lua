return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			typescript = { "biome-check", stop_after_first = true },
			javascript = { "biome-check", stop_after_first = true },
			typescriptreact = { "biome-check", stop_after_first = true },
			javascriptreact = { "biome-check", stop_after_first = true },
			json = { "biome" },
			jsonc = { "biome" },
			html = { "biome-check" },
			rust = { "rustfmt" },
		},
		format_on_save = function(bufnr)
			if vim.bo[bufnr].filetype == "rust" then return { timeout_ms = 500, lsp_format = "fallback" } end
			return -- rust以外は無効
		end,
	},
}
