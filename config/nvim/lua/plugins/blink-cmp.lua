local function mini_lsp_icon(ctx) return require("mini.icons").get("lsp", ctx.kind) end

return {
	"saghen/blink.cmp",
	version = "1.*",
	-- 通常は config/lsp.lua の require で起動直後に読み込まれる
	lazy = true,
	event = "InsertEnter",
	opts = {
		keymap = {
			preset = "default",
			-- preset の <C-k> は signature ヘルプ切替。<C-k> は LuaSnip expand に譲る
			["<C-k>"] = false,
			["<C-d>"] = { "scroll_documentation_up", "fallback" },
			["<C-c>"] = { "hide", "fallback" },
			["<CR>"] = { "select_and_accept", "fallback" },
			["<C-j>"] = { "snippet_forward", "fallback" },
			["<S-C-j>"] = { "snippet_backward", "fallback" },
		},
		completion = {
			menu = {
				border = "rounded",
				draw = {
					components = {
						kind_icon = {
							text = function(ctx) return (mini_lsp_icon(ctx)) end,
							highlight = function(ctx)
								local _, hl = mini_lsp_icon(ctx)
								return hl
							end,
						},
					},
				},
			},
			documentation = {
				auto_show = true,
				window = { border = "rounded" },
			},
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		snippets = { preset = "luasnip" },
		signature = {
			enabled = true,
			window = { border = "rounded" },
		},
		cmdline = { enabled = false },
	},
}
