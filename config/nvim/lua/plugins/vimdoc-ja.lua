return {
	"vim-jp/vimdoc-ja",
	event = "VeryLazy",
	-- lazy.nvim の helptags が書き換える日本語索引は配布版を使う。
	build = "git restore -- doc/tags-ja",
}
