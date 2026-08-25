return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
	lazy = true,
	ft = { "markdown", "octo" },
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
