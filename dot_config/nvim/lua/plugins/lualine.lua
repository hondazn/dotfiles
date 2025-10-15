return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = true,
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				-- component_separators = { left = "", right = "" },
				-- section_separators = { left = "", right = "" },
				-- component_separators = { left = "", right = ""},
				component_separators = "",
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				always_show_tabline = false,
				globalstatus = true,
				refresh = {
					statusline = 100,
					tabline = 100,
					winbar = 100,
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{ "filename", file_status = false },
					{ function() return vim.bo.modified and "⚡" or "" end, color = { fg = "#ff9e64" } },
				},
				lualine_x = { "encoding", "fileformat" },
				lualine_y = { "filetype", "lsp_status" },
				lualine_z = { "location", "progress" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			-- tabline = {},
			tabline = {
				lualine_a = { "tabs" },
				lualine_b = {
					function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") end,
				},
				lualine_c = {
					function() return vim.fn.expand("%:t") end,
				},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
