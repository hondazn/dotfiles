return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			typescript = { "oxfmt", stop_after_first = true },
			javascript = { "oxfmt", stop_after_first = true },
			typescriptreact = { "oxfmt", stop_after_first = true },
			javascriptreact = { "oxfmt", stop_after_first = true },
			json = { "oxfmt" },
			jsonc = { "oxfmt" },
			html = { "oxfmt" },
			css = { "oxfmt" },
			yaml = { "oxfmt" },
			toml = { "oxfmt" },
			markdown = { "oxfmt" },
			rust = { "rustfmt" },
		},
		format_on_save = function(bufnr)
			if vim.bo[bufnr].filetype == "rust" then return { timeout_ms = 500, lsp_format = "fallback" } end
			return -- rust以外は無効
		end,
	},
}
