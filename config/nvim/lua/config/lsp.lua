-- vim.lsp.enable() は既存バッファにも遡って適用するため、起動時に開いたファイルには
-- その場でサーバが起動する。共通設定は enable より前に置く
vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("oxlint")
vim.lsp.enable("rust_analyzer")
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
		},
	},
})
vim.lsp.enable("hls")

local function typescript_major(bufnr)
	local root = vim.fs.root(bufnr, "node_modules")
	if not root then return nil end
	local manifest = io.open(vim.fs.joinpath(root, "node_modules/typescript/package.json"))
	if not manifest then return nil end
	local content = manifest:read("*a")
	manifest:close()
	return tonumber(content:match('"version"%s*:%s*"(%d+)'))
end

-- TypeScript 7 は tsserver.js を廃止し公式LSPが tsc --lsp へ移行したため、
-- ts_ls (tsserver ラッパー) と tsc は担当バージョンが排他になる。
-- 両方を無条件に有効化すると対象外のプロジェクトで片方が必ず起動失敗する
local TYPESCRIPT_SERVERS = {
	ts_ls = function(major) return major <= 6 end,
	tsc = function(major) return major >= 7 end,
}

for name, handles_major in pairs(TYPESCRIPT_SERVERS) do
	-- lsp/<name>.lua はアクセスのたびに読み直される。tsc は root_dir が見つけた
	-- バイナリを上位値のキャッシュ経由で cmd へ渡すため、同じ読み込み結果に
	-- 固定しないと cmd がキャッシュを見失い PATH の tsc を起動してしまう
	local default = vim.lsp.config[name]
	vim.lsp.config(name, {
		cmd = default.cmd,
		root_dir = function(bufnr, on_dir)
			local major = typescript_major(bufnr)
			if not (major and handles_major(major)) then return end
			default.root_dir(bufnr, on_dir)
		end,
	})
	vim.lsp.enable(name)
end
