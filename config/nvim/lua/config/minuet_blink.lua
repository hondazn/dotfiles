-- blink の補完元 minuet.blink を包み、手動呼び出しでは出力上限を上げる
local MANUAL_MAX_TOKENS = 512
-- 長い出力は 3 秒では返りきらないことがある。blink 側の timeout_ms もこれに合わせる
local MANUAL_TIMEOUT_SEC = 8

local Base = require("minuet.blink")
local M = setmetatable({}, { __index = Base })

-- minuet は新しいリクエストのたびに実行中のリクエストを全て打ち切る。
-- 手動リクエスト中は virtualtext の自動リクエストを止めるため、minuet の enable_predicates から参照する
M.manual_in_flight = false

function M.new(...) return setmetatable(Base.new(...), { __index = M }) end

-- blink の keymap から呼ぶ。応答までの 1〜2 秒に押し直すと前のリクエストが打ち切られるため、
-- 実行中は何もしない
function M.request(cmp)
	if M.manual_in_flight then return true end
	return cmp.show({ providers = { "minuet" } })
end

local NOTIFY_ID = "minuet_manual"

-- blink は打ちかけの単語で候補を絞り込み、確定時にその単語を置き換える。
-- minuet は候補が英数字で始まるときしか単語を前置しないため、"(" などで始まる続きも前置する
local function prepend_keyword(ctx, callback)
	local keyword = ctx.line:sub(1, ctx.cursor[2]):match("[%w_-]+$")
	if not keyword then return callback end
	return function(response)
		for _, item in ipairs(response and response.items or {}) do
			if item.insertText:sub(1, #keyword) ~= keyword then
				item.insertText = keyword .. item.insertText
				item.label = keyword .. item.label
			end
		end
		return callback(response)
	end
end

function M:get_completions(ctx, callback)
	callback = prepend_keyword(ctx, callback)
	if ctx.trigger.kind ~= "manual" then return Base.get_completions(self, ctx, callback) end

	M.manual_in_flight = true
	vim.notify("AI 補完: 問い合わせ中…", vim.log.levels.INFO, { id = NOTIFY_ID, timeout = false })
	local function release() M.manual_in_flight = false end
	-- 応答が来なかった場合も、打ち切りの後には自動リクエストを戻す
	vim.defer_fn(release, (MANUAL_TIMEOUT_SEC + 1) * 1000)

	-- 手動呼び出しはその場でリクエスト（curl の引数を含む）を組み立てる。
	-- そのため呼び出しの間だけ設定を書き換えればよい
	local config = require("minuet").config
	local optional = config.provider_options.openai_compatible.optional
	local auto_tokens, auto_timeout = optional.max_tokens, config.request_timeout
	optional.max_tokens, config.request_timeout = MANUAL_MAX_TOKENS, MANUAL_TIMEOUT_SEC
	Base.get_completions(self, ctx, function(response)
		release()
		-- 候補が無いと blink はメニューを開かないため、待っていても何も起きないように見える
		if response and response.items and #response.items > 0 then
			Snacks.notifier.hide(NOTIFY_ID)
		else
			vim.notify("AI 補完: 候補なし", vim.log.levels.INFO, { id = NOTIFY_ID, timeout = 3000 })
		end
		return callback(response)
	end)
	optional.max_tokens, config.request_timeout = auto_tokens, auto_timeout
end

return M
