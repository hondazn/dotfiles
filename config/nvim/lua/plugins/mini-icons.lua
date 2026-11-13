return {
	"nvim-mini/mini.icons",
	lazy = true,
	opts = {},
	init = function()
		-- nvim-web-devicons を要求するプラグインにも mini.icons のアイコンを返す。
		-- require されるまで読み込まないため、遅延読み込みは保たれる
		package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
		end
	end,
}
