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
		},
	},
}
