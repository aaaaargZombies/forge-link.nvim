-- this is will be run if you have installed the plugins
-- you don't need to require("module") in the dot files
local get_link = function()
	local maybeLink = require("forge-link").forge_link()
	vim.fn.setreg("+", maybeLink)
	print(maybeLink)
end

local nav_link = function()
	local maybeLink = require("forge-link").forge_link()
	os.execute("$BROWSER " .. maybeLink)
	print("navigating to " .. maybeLink)
end

local get_snippet = function()
	local maybeCode = require("forge-link").forge_snip()
	vim.fn.setreg("+", maybeCode)
	print(maybeCode)
end

-- generate user commands or keybindings etc for the consumer of the plugins
vim.api.nvim_create_user_command("ForgeLink", get_link, { range = true })
vim.api.nvim_create_user_command("ForgeNav", nav_link, { range = true })
vim.api.nvim_create_user_command("ForgeSnip", get_snippet, { range = true })
