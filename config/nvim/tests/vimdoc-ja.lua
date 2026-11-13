-- Run from the repository root: NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -l config/nvim/tests/vimdoc-ja.lua
local data = vim.fn.stdpath("data")
local temp = vim.fn.tempname()
local root = temp .. "/lazy"
local plugin_dir = root .. "/vimdoc-ja"
vim.env.XDG_STATE_HOME = temp .. "/state"
vim.env.XDG_CACHE_HOME = temp .. "/cache"
vim.go.loadplugins = true

local function run(args, cwd)
	local result = vim.system(args, { cwd = cwd, text = true }):wait()
	assert(result.code == 0, result.stderr)
	return result.stdout
end

local function check_tasks(plugin)
	for _, task in ipairs(plugin._.tasks or {}) do
		assert(not task:has_errors(), task:output())
	end
end

local ok, err = xpcall(function()
	vim.fn.mkdir(plugin_dir, "p")
	run({ "cp", "-R", data .. "/lazy/vimdoc-ja/doc", plugin_dir })
	local tags = run({ "git", "show", "HEAD:doc/tags-ja" }, data .. "/lazy/vimdoc-ja")
	vim.fn.writefile(vim.split(tags, "\n"), plugin_dir .. "/doc/tags-ja", "b")
	run({ "git", "init", "--quiet" }, plugin_dir)
	run({ "git", "add", "doc" }, plugin_dir)
	run({
		"git",
		"-c",
		"user.name=Test",
		"-c",
		"user.email=test@example.invalid",
		"-c",
		"commit.gpgsign=false",
		"commit",
		"--quiet",
		"-m",
		"fixture",
	}, plugin_dir)

	vim.opt.rtp:prepend(data .. "/lazy/lazy.nvim")
	require("lazy").setup({ dofile("config/nvim/lua/plugins/vimdoc-ja.lua") }, {
		root = root,
		lockfile = temp .. "/lazy-lock.json",
		state = temp .. "/state.json",
		install = { missing = false },
		pkg = { enabled = false },
		readme = { enabled = false },
		checker = { enabled = false },
		change_detection = { enabled = false },
	})
	local plugin = require("lazy.core.config").plugins["vimdoc-ja"]
	local manager = require("lazy.manage")
	for cycle = 1, 2 do
		plugin._.dirty = true
		manager.run({ pipeline = { "plugin.docs", "plugin.build", "git.status" } }, {
			plugins = { "vimdoc-ja" },
			show = false,
			wait = true,
		})
		check_tasks(plugin)
		assert(run({ "git", "diff", "--name-only" }, plugin_dir) == "", "helptags left tracked changes")
		print("PASS: helptags/build/update status cycle " .. cycle)
	end
	vim.opt.rtp:append(plugin_dir)
	vim.opt.helplang = "ja"
	vim.cmd("help help")
	assert(vim.api.nvim_buf_get_name(0):match("%.jax$"), "Japanese help did not open")
	print("PASS: Japanese help opens")
end, debug.traceback)

vim.fn.delete(temp, "rf")
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
end
