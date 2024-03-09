-- To run this file / access the functions you need to require("module")

---@class Deetz
---@field branch string
---@field commit string
---@field file_path string
---@field line_end string
---@field line_start string
---@field remote string

--- A function that takes the git remote.origin.url and is used decide if the accompanying link function should be run.
---@alias Test fun(remote: string): boolean

--- A function that takes useful file and git info that can be used to produce a link to the git forges website at a specific point in the code.
---@alias Link fun(details: Deetz): string

---@class Forge
---@field test Test
---@field link Link

---@alias Forges Forge[]

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

-- for use while in visual mode
local function visual_select_line_nums()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	local start_line = start_pos[2]
	local end_line = end_pos[2]

	return start_line, end_line
end

-- for use after leaving visual mode
local function last_selection_line_nums()
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")

	local start_line = start_pos[1]
	local end_line = end_pos[1]

	return start_line, end_line
end

local function file_path()
	local buf = vim.api.nvim_get_current_buf()
	local absolute_path = vim.api.nvim_buf_get_name(buf)
	local root_dir = vim.fn.getcwd()
	local relative_name = string.gsub(absolute_path, escape(root_dir), "")
	return relative_name
end

local function branch_name()
	return get_terminal_output("git rev-parse --abbrev-ref HEAD")
end

local function git_remote()
	return get_terminal_output("git config --get remote.origin.url")
end

local function commit_hash()
	return get_terminal_output("git rev-parse HEAD")
end

local function line_nums()
	local mode = vim.api.nvim_get_mode().mode
	local left, right = 0, 0
	if mode == "V" then
		left, right = visual_select_line_nums()
	else
		left, right = last_selection_line_nums()
	end
	return left, right
end

---@return Deetz
local function deetz()
	local left, right = line_nums()
	return {
		branch = branch_name(),
		commit = commit_hash(),
		file_path = file_path(),
		remote = git_remote(),
		line_end = right,
		line_start = left,
	}
end

-- TODO : see if I can check for different remotes and turn this into forge_link instead of just github
--
--  bitbucket
--  https://bitbucket.org/USER/REPO/annotate/COMMIT_HASH_or_BRANH/FILE_PATH_INCLUDING_NAME#FILE_NAME-3:7
--  https://bitbucket.org/crumbletown/business/annotate/90959bf8a4bbc77d9c326d0a25cd27caebd39f71/re-innovation/elements.md#elements.md-3:7
--
--  codeberg / gittea
--  https://codeberg.org/simonrepp/faircamp/src/branch/main/src/util.rs#L4-L7
--  https://codeberg.org/simonrepp/faircamp/src/commit/75f93a7313a2d9fe380f9e9822d8023f7e482dd6/src/util.rs#L5-L8
--  https://codeberg.org/USER/REPO/src/commit/COMMIT_HASH/FILE_PATH#L5-L8
--  https://codeberg.org/USER/REPO/src/branch/BRANCH/FILE_PATH#L5-L8
--
--  gitlab
--  https://gitlab.com/spritely/goblins/blob/master/goblins/core.rkt?#L10-14
--  https://gitlab.com/USER/REPO/blob/BRANCH/FILE_PATH?#L10-14
--  https://gitlab.com/USER/REPO/blob/COMMIT_HASH/FILE_PATH?#L10-14

---@param details Deetz
---@return string
local function github_link(details)
	-- things that take a remote probably need to handle http and ssh links
	local function trim_remote(remote)
		return remote:gsub(".git", ""):gsub(":", "/")
	end

	local function base_url(remote)
		return "https://" .. trim_remote(remote)
	end

	-- https://github.com/USER/REPO/blob/BRANCH/FILE_PATH?plain=1#L1-L6
	-- https://github.com/USER/REPO/blob/COMMIT_HASH/FILE_PATH?plain=1#L1-L6
	return (
		base_url(details.remote)
		.. "/blob/"
		.. details.branch -- should I default to the commit??? either that or a i need to check if the branch is on head
		.. "/"
		.. details.file_path
		.. "#L"
		.. details.line_start
		.. "-L"
		.. details.line_end
	)
end

---@param remote string
---@return boolean
local function github_test(remote)
	return (remote ~= nil and string.match(remote, "github"))
end

---@type Forge
local git_forge = {
	link = github_link,
	test = github_test,
}

local M = {}

---@type Forges
M.forges = {}

table.insert(M.forges, git_forge)

--- Add user's custom forges to the module forges array, placing them at the front to give higher priority
---@param user_forges Forges
M.setup = function(user_forges)
	-- TODO Add user's custom forges to the module forges array, placing them at the front to give higher priority
end

M.forge_link = function()
	local details = deetz()
	for _, forge in ipairs(M.forges) do
		if forge.test(details.remote) then
			return forge.link(deetz())
		end
	end
	return "oops - I can't build a link for this file"
end

return M
