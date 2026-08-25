-- nvim-treesitter の main ブランチは highlight モジュールを持たず、パーサを入れるだけで
-- 誰も起動しない。パーサは stdpath("data")/site/parser に入り常に runtimepath 上にあるため、
-- 起動も ft の対応付けもプラグインのロードを待たずここで行う
vim.treesitter.language.register("markdown", "octo")

-- 取得を試みた言語。オフライン等で失敗したとき、開くたびに叩きに行かないよう記録する
local attempted = {}

local function install_and_start(buf, ft, lang)
	if attempted[lang] then return end
	attempted[lang] = true

	local nvim_treesitter = require("nvim-treesitter")
	if not vim.list_contains(nvim_treesitter.get_available(), lang) then return end

	nvim_treesitter.install(lang):await(function(err, ok)
		vim.schedule(function()
			-- 黙って捨てるとハイライトが無い理由を追えなくなる
			if err or not ok then
				vim.notify(
					("treesitter: %s の取得に失敗しました (:TSInstall %s で再試行)"):format(lang, lang),
					vim.log.levels.WARN
				)
				return
			end
			if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= ft then return end
			if vim.treesitter.language.add(lang) then vim.treesitter.start(buf, lang) end
		end)
	end)
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("config.treesitter", {}),
	callback = function(ev)
		-- 同梱 ftplugin (lua/markdown/help/query) が先に start 済み。
		-- treesitter.start は既存の highlighter を破棄せず上書きするため二重起動を避ける
		if vim.treesitter.highlighter.active[ev.buf] then return end

		local lang = vim.treesitter.language.get_lang(ev.match)
		if not lang then return end

		-- start はパーサが無いと assert で落ちるため、add の成否で先に弾く
		if vim.treesitter.language.add(lang) then
			vim.treesitter.start(ev.buf, lang)
		else
			install_and_start(ev.buf, ev.match, lang)
		end
	end,
})
