return {
	"notjedi/nvim-rooter.lua",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		rooter_patterns = { ".git", ".hg", ".svn" },
		trigger_patterns = { "*" },
		manual = false,
		fallback_to_parent = false,
		cd_scope = "smart",
	},
}
