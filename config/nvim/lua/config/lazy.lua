return {
	defaults = { lazy = true },
	ui = {
		icons = {
			ft = "",
			lazy = "󰂠 ",
			loaded = "",
			not_loaded = "",
		},
	},
	performance = {
		rtp = {
			-- $VIMRUNTIME/plugin/ のファイル名と照合するため Vim 由来の名前は効かない。
			-- matchit は % の拡張マッチに必要なので無効化しない
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"rplugin",
				"spellfile",
				"tarPlugin",
				"tutor",
				"zipPlugin",
			},
		},
	},
}
