return {
	"MeanderingProgrammer/render-markdown.nvim",
	-- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
	-- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	ft = { "markdown", "Avante", "octo", "codecompanion" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		preset = "obsidian",
		checkbox = {
			unchecked = { icon = "󰄰 ", highlight = "RenderMarkdownUnchecked", scope_highlight = nil },
			checked = { icon = "󰄴 ", highlight = "RenderMarkdownChecked", scope_highlight = nil },
			custom = {
				todo = { raw = "", rendered = "", highlight = "" },
				forward = {
					raw = "[>]",
					rendered = " ",
					highlight = "RenderMarkdownInfo",
					scope_highlight = nil,
				},
				incomplete = {
					raw = "[/]",
					rendered = " ",
					highlight = "RenderMarkdownInfo",
					scope_highlight = nil,
				},
				warn = { raw = "[!]", rendered = " ", highlight = "RenderMarkdownWarn", scope_highlight = nil },
				canceled = {
					raw = "[-]",
					rendered = "󰍴 ",
					highlight = "RenderMarkdownDash",
					scope_highlight = "@markup.strikethrough",
				},
				scheduled = {
					raw = "[<]",
					rendered = " ",
					highlight = "RenderMarkdownInfo",
					scope_highlight = nil,
				},
				question = {
					raw = "[?]",
					rendered = " ",
					highlight = "RenderMarkdownInfo",
					scope_highlight = nil,
				},
				star = {
					raw = "[*]",
					rendered = "󰓎 ",
					highlight = "RenderMarkdownInfo",
					scope_highlight = nil,
				},
				pros = {
					raw = "[p]",
					rendered = " ",
					highlight = "RenderMarkdownInfo",
					scope_highlight = nil,
				},
				cons = {
					raw = "[c]",
					rendered = " ",
					highlight = "RenderMarkdownInfo",
					scope_highlight = nil,
				},
			},
		},
	},
}
