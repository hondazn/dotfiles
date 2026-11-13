-- 補完リクエストごとに呼ばれるため、キーチェーンは初回だけ読む
local api_key
local function ollama_api_key()
	if api_key == nil then
		local out = vim.system({ "security", "find-generic-password", "-s", "ollama-api-key", "-w" }):wait()
		api_key = out.code == 0 and vim.trim(out.stdout) or ""
	end
	return api_key
end

return {
	"milanglacier/minuet-ai.nvim",
	lazy = true,
	-- 自動表示の対象は FileType で決まるため、最初のバッファの FileType より前に読み込む
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		provider = "openai_compatible",
		request_timeout = 3,
		provider_options = {
			openai_compatible = {
				name = "Ollama",
				end_point = "https://ollama.com/v1/chat/completions",
				model = "deepseek-v4.1-flash",
				api_key = ollama_api_key,
				optional = {
					max_tokens = 256,
					-- 思考を有効にすると本文が返る前に max_tokens を使い切る
					reasoning_effort = "none",
				},
			},
		},
		-- 手動リクエスト中に自動リクエストを送ると、手動側が打ち切られる
		enable_predicates = {
			function()
				return not package.loaded["config.minuet_blink"] or not require("config.minuet_blink").manual_in_flight
			end,
		},
		-- 自動は virtualtext、手動は blink（<C-q>、config/minuet_blink.lua）
		virtualtext = {
			auto_trigger_ft = { "*" },
			auto_trigger_ignore_ft = { "snacks_picker_input", "snacks_input", "oil" },
			-- 単語入力中はほぼ常に blink のメニューが開くため、開いていても出す
			show_on_completion_menu = true,
		},
	},
	keys = {
		{
			"<C-l>",
			function() require("minuet.virtualtext").action.accept() end,
			mode = "i",
			desc = "Accept completion",
		},
		{
			"<C-g>l",
			function() require("minuet.virtualtext").action.accept_line() end,
			mode = "i",
			desc = "Accept completion line",
		},
		{ "<C-g>n", function() require("minuet.virtualtext").action.next() end, mode = "i", desc = "Next completion" },
		{ "<C-g>p", function() require("minuet.virtualtext").action.prev() end, mode = "i", desc = "Prev completion" },
		{
			"<C-g>e",
			function() require("minuet.virtualtext").action.dismiss() end,
			mode = "i",
			desc = "Dismiss completion",
		},
	},
}
