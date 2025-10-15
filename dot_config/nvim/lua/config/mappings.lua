local map = vim.keymap.set

-- vim keymap
map({ "n", "v" }, ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")
map({ "i", "c" }, "<C-h>", "<BS>")
map({ "i", "c" }, "<C-d>", "<Del>")
map({ "i", "c" }, "<C-f>", "<Right>")
map({ "i", "c" }, "<C-b>", "<Left>")
map({ "i", "c" }, "<C-n>", "<Down>")
map({ "i", "c" }, "<C-p>", "<Up>")
map({ "i", "c" }, "<C-a>", "<Home>")
map({ "i", "c" }, "<C-e>", "<End>")
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<leader>/", "gcc", { desc = "Comment line", remap = true })
map("v", "<leader>/", "gc", { desc = "Comment line", remap = true })

-- plugins keymap
---- oil
map("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

---- bufferline
map("n", "<leader>q", function() Snacks.bufdelete({ force = true }) end, { desc = "Delete current buffer force" })
map("n", "<leader>bd", function() Snacks.bufdelete.delete() end, { desc = "Delete current buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete all buffers except the current one" })
map("n", "<leader>ba", function() Snacks.bufdelete.all() end, { desc = "Delete all buffers" })
map("n", "<leader>bb", function() Snacks.picker.buffers() end, { desc = "List buffers" })

---- luasnip
map("i", "<C-k>", function() require("luasnip").expand() end, { desc = "Luasnip expand or jump" })

---- lsp-config
map("n", "<leader>ld", function() vim.lsp.buf.definition() end, { desc = "LSP go to definition" })
map("n", "<leader>lh", function() vim.lsp.buf.hover() end, { desc = "LSP hover" })
map("n", "<leader>lr", function() vim.lsp.buf.references() end, { desc = "LSP references" })
map("n", "<leader>ls", function() vim.lsp.buf.signature_help() end, { desc = "LSP signature help" })
map("n", "<leader>lf", function() vim.lsp.buf.formatting() end, { desc = "LSP formatting" })
map({ "n", "v" }, "<leader>la", function() vim.lsp.buf.code_action() end, { desc = "LSP code action" })
map("n", "<leader>lw", function() vim.lsp.buf.workspace_symbol() end, { desc = "LSP workspace symbol" })
map("n", "<leader>lD", function() vim.lsp.buf.declaration() end, { desc = "LSP go to declaration" })
map("n", "<leader>li", function() vim.lsp.buf.implementation() end, { desc = "LSP go to implementation" })
map("n", "<leader>lt", function() vim.lsp.buf.type_definition() end, { desc = "LSP go to type definition" })
map("n", "<leader>lR", function() vim.lsp.buf.rename() end, { desc = "LSP rename" })

---- formatting
map("n", "<leader>k", function() require("conform").format({ lsp_fallback = true }) end, { desc = "Format File" })

---- aerial
map("n", "<leader>lm", "<CMD>AerialToggle!<CR>", { desc = "Aerial: Toggle Code Map" })

---- octo
map("n", "<leader>ghi", "<CMD>Octo issue list<CR>", { desc = "Octo: Issue List" })
map("n", "<leader>ghp", "<CMD>Octo pr list<CR>", { desc = "Octo: PullRequest List" })
map("n", "<leader>ghc", "<CMD>Octo comment add<CR>", { desc = "Octo: Comment Add" })
map("n", "<leader>ghn", "<CMD>Octo issue create<CR>", { desc = "Octo: Issue Create" })

---- obsidian
-- map("n", "<leader>oo", "<CMD>ObsidianOpen<CR>", { desc = "Obsidian: Open" })
-- map("n", "<leader>oy", "<CMD>ObsidianYesterday<CR>", { desc = "Obsidian: Open" })
-- map("n", "<leader>od", "<CMD>ObsidianToday<CR>", { desc = "Obsidian: Open" })
-- map("n", "<leader>ot", "<CMD>ObsidianTomorrow<CR>", { desc = "Obsidian: Open" })
-- map("n", "<C-t>", "<CMD>ObsidianToggleCheckbox<CR>", { desc = "Obsidian: Open" })

---- noice
map("n", "<leader>nn", "<CMD>Noice dismiss<CR>", { desc = "Noice" })

---- snacks
--- @module "snacks"

map("n", "<leader>nh", function() Snacks.notifier.show_history() end, { desc = "Notify History" })
map("n", "<C-S-p>", function() Snacks.picker.commands() end, { desc = "Select commands" })
map("n", "<leader>fc", function() Snacks.picker.commands() end, { desc = "Select commands" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Select find files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Select live grep" })
map("n", "<leader>ft", function() Snacks.picker.colorschemes() end, { desc = "Select colorscheme theme" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "List git projects" })
map("n", "<leader>fp", function() Snacks.picker.git_projects() end, { desc = "List git projects" })
map("n", "<leader>cR", function() Snacks.rename.rename_file() end, { desc = "Rename File" })
map({ "n", "v" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse" })
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
map("n", "<leader>gp", function() Snacks.picker.git_projects() end, { desc = "List git projects" })
map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
map("n", "<leader>gf", function() Snacks.lazygit.log_file() end, { desc = "Lazygit Current File History" })
map("n", "<leader>gl", function() Snacks.lazygit.log() end, { desc = "Lazygit Log (cwd)" })
map({ "n", "t" }, "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
map({ "n", "t" }, "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })
map("n", "<leader>t", function() Snacks.terminal() end, { desc = "Open Terminal" })
map("n", "<leader>o", function() Snacks.picker.smart() end, { desc = "Select smart open" })
map("n", "<leader>e", function() Snacks.picker.explorer() end, { desc = "Open Explorer" })
map(
	"n",
	"<leader>p",
	function() Snacks.picker.buffers({ focus = "list", win = { list = { keys = { ["/"] = false } } } }) end,
	{ desc = "Select buffers" }
)
map(
	"n",
	"<leader>N",
	function()
		Snacks.win({
			file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
			width = 0.6,
			height = 0.6,
			wo = {
				spell = false,
				wrap = false,
				signcolumn = "yes",
				statuscolumn = " ",
				conceallevel = 3,
			},
		})
	end,
	{ desc = "Neovim News" }
)

-- Enable <Tab> to indent if no suggestions are available
vim.keymap.set("i", "<C-l>", function()
	if require("copilot.suggestion").is_visible() then
		require("copilot.suggestion").accept()
	else
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
	end
end, { desc = "Super Tab", silent = true })

if vim.g.neovide then
	vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
	vim.keymap.set("v", "<D-c>", '"+y') -- Copy
	vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
	vim.keymap.set({ "n", "v" }, "<D-=>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.05<CR>")
	vim.keymap.set({ "n", "v" }, "<D-+>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.05<CR>")
	vim.keymap.set({ "n", "v" }, "<D-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.05<CR>")
	vim.keymap.set({ "n", "v" }, "<D-0>", ":lua vim.g.neovide_scale_factor = 1<CR>")
end
