return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	lazy = true,
	event = "InsertEnter",
	opts = {
		suggestion = {
			auto_trigger = true,
		},
		filetypes = {
			yaml = true,
			markdown = true,
		},
	},
}
