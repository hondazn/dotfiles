return {
	"windwp/nvim-autopairs",
	lazy = true,
	event = "InsertEnter",
	opts = {
		fast_wrap = {},
		disable_filetype = { "snack_picker_input", "vim" },
	},
}
