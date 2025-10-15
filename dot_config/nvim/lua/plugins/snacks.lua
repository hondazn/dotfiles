--- @module "snacks"
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		dashboard = {
			enabled = true,
			width = 80,
			preset = {
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = function() Snacks.dashboard.pick("live_grep") end,
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = function() Snacks.dashboard.pick("oldfiles") end,
					},
					{
						icon = "󰊢 ",
						key = "p",
						desc = "Git Projects",
						action = function() Snacks.dashboard.pick("git_projects") end,
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function() Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") }) end,
					},
					{
						icon = " ",
						key = ".",
						desc = "Dotfiles",
						action = function() require("oil").open_float("~/.config") end,
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{
						icon = "󰒲 ",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ header = vim.fn.system("bash -c '~/.config/nvim/scripts/kakugen.bash'") },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},
		debug = { enabled = false },
		dim = { enabled = true },
		git = { enabled = true },
		gitbrowse = { enabled = true },
		health = { enabled = true },
		image = { enabled = true },
		indent = { enabled = false },
		input = { enabled = false },
		notifier = { enabled = true },
		notify = { enabled = true },
		quickfile = { enabled = false },
		rename = { enabled = true },
		scope = { enabled = true },
		scratch = { enabled = false },
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		terminal = { enabled = true, win = { style = "terminal" }, shell = "fish" },
		toggle = { enabled = false },
		words = { enabled = true },
		lazygit = { enabled = true, configure = true },
		--- @class snacks.picker.Config
		picker = {
			enabled = true,
			sources = {
				files = { hidden = true },
				git_projects = {
					icon = "󰊢 ",
					key = "p",
					desc = "Git Projects",
					finder = function()
						return Snacks.picker({
							cwd = "~",
							finder = "proc",
							cmd = "ghq",
							args = { "list", "--full-path" },
							transform = function(item)
								item.file = item.text
								item.dir = true
							end,
						})
					end,
					confirm = function(picker, item)
						picker:close()
						require("oil").open_float(item.text)
					end,
				},
			},
		},
	},
}
