vim.diagnostic.config({
	update_in_insert = false,
	-- 行番号の左側にアイコンを表示する (お好みで)
	signs = true,
	-- エラー箇所に下線を引く
	underline = true,
	-- 浮動ウィンドウでエラー詳細を表示する
	float = {
		-- source = "always", -- ソース元（clippyなど）を常に表示
		source = "if_many",
	},
	-- 行の右側にエラー内容を仮想テキストとして表示する。
	-- カーソル行は virtual_lines が全文を出すため、virtual_text を重ねない
	virtual_text = { current_line = false },
	virtual_lines = {
		current_line = true, -- カーソル行のみに表示
	},
})
