-- To run this file / access the functions you need to require("module")

-- escape naughty pattern characters
-- https://www.lua.org/pil/20.2.html
local function escape(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1")
end

local function get_terminal_output(command)
	local handle = io.popen(command)
	local result = handle:read("l")
	handle:close()
	return result
end

local function trim_remote(remote)
	return remote:gsub(".git", ""):gsub(":", "/")
end

local function current_file()
	buf = vim.api.nvim_get_current_buf()
	file_name = vim.api.nvim_buf_get_name(buf)
	root_dir = vim.fn.getcwd()
	relative_name = string.gsub(file_name, escape(root_dir), "")
	return relative_name
end

local M = {}

local function branch_name()
	return get_terminal_output("git rev-parse --abbrev-ref HEAD")
end

local function git_remote()
	return get_terminal_output("git config --get remote.origin.url")
end

local function base_url(remote)
	return "https://" .. trim_remote(remote)
end

-- for use while in visual mode
M.visual_select_line_nums = function()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	local start_line = start_pos[2]
	local end_line = end_pos[2]

	return start_line, end_line
end

-- for use after leaving visual mode
M.last_selection_line_nums = function()
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")

	local start_line = start_pos[1]
	local end_line = end_pos[1]

	return start_line, end_line
end

-- TODO : see if I can check for different remotes and turn this into forge_link instead of just github
--
-- bitbucket
--  https://bitbucket.org/USER/REPO/annotate/COMMIT_HASH_or_BRANH/FILE_PATH_INCLUDING_NAME#FILE_NAME-3:7
--  https://bitbucket.org/crumbletown/business/annotate/90959bf8a4bbc77d9c326d0a25cd27caebd39f71/re-innovation/elements.md#elements.md-3:7
--
--  codeberg / gittea
--  https://codeberg.org/simonrepp/faircamp/src/branch/main/src/util.rs#L4-L7
--  https://codeberg.org/simonrepp/faircamp/src/commit/75f93a7313a2d9fe380f9e9822d8023f7e482dd6/src/util.rs#L5-L8
--  https://codeberg.org/USER/REPO/src/commit/COMMIT_HASH/FILE_PATH#L5-L8
--  https://codeberg.org/USER/REPO/src/branch/BRANCH/FILE_PATH#L5-L8
M.github_link = function(left, right)
	-- https://github.com/USER/REPO/blob/BRANCH/FILE_PATH?plain=1#L1-L6
	-- https://github.com/USER/REPO/blob/COMMIT_HASH/FILE_PATH?plain=1#L1-L6
	local remote = git_remote()
	if remote ~= nil and string.match(remote, "github") then
		return base_url(remote)
			.. "/blob/"
			.. branch_name()
			.. "/"
			.. current_file()
			.. "?plan=1#L"
			.. left
			.. "-L"
			.. right
	else
		return "oops - not a github repo"
	end
end

return M
