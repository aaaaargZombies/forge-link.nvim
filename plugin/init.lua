-- this is will be run if you have installed the plugins
-- you don't need to require("module") in the dot files
local get_link = function()
	local maybeLink = require("forge-link").forge_link()
	vim.fn.setreg("+", maybeLink)
	print(maybeLink)
end

-- generate user commands or keybindings etc for the consumer of the plugins
vim.api.nvim_create_user_command("ForgeLink", get_link, { range = true })
