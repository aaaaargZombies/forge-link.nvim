-- To run this file / access the functions you need to require("module")

---@class Deetz
---@field branch string
---@field commit string
---@field file_path string
---@field line_end number
---@field line_start number
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

local M = {}

---@type Forges
M.forges = require("forge-link.forges")

--- Add user's custom forges to the module forges array,
--- placing them at the front to give higher priority so
--- defaults can be over written
---@param user_forges Forges
M.setup = function(user_forges)
	if user_forges == nil then
		user_forges = {}
	end
	for _, v in ipairs(M.forges) do
		table.insert(user_forges, v)
	end
	M.forges = user_forges
end

M.forge_link = function()
	local details = deetz()
	for _, forge in ipairs(M.forges) do
		if forge.test(details.remote) then
			return forge.link(details)
		end
	end
	return "oops - I can't build a link for this file"
end

---grab a code snippet to build a markdown codeblock
---@param line_start number
---@param line_end number
---@return string
local function getLines(line_start, line_end)
	if line_start > line_end then
		local tmp = line_start
		line_start = line_end
		line_end = tmp
	end
	local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
	local code = table.concat(lines, "\n")
	return code
end

M.forge_snip = function()
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local top = "```" .. filetype .. "\n"
	local bottom = "\n```\n\n[view code in context](" .. M.forge_link() .. ")"
	local details = deetz()
	local code = getLines(details.line_start, details.line_end)

	return (top .. code .. bottom)
end

return M
