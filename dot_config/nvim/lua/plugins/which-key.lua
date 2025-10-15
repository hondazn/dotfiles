return {
	"folke/which-key.nvim",
	opts = {
		delay = 0,
		defer = function(ctx)
			if vim.list_contains({ "d", "y", "c" }, ctx.operator) then return true end
			return vim.list_contains({ "<C-V>", "V" }, ctx.mode)
		end,
	},
}
