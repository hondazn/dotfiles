vim.diagnostic.config({
	update_in_insert = false,
	signs = true,
	underline = true,
	float = { source = "if_many" },
	-- カーソル行は virtual_lines が全文を出すため、virtual_text を重ねない
	virtual_text = { current_line = false },
	virtual_lines = { current_line = true },
})
