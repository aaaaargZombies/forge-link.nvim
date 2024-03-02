-- this is will be run if you have installed the plugins
-- you don't need to require("module") in the dot files
get_link = function()
	local forge_link = require("forge-link")
	local mode = vim.api.nvim_get_mode().mode
	local left, right = 0, 0
	if mode == "V" then
		print("in visual mode")
		left, right = forge_link.visual_select_line_nums()
	else
		print("not in visual mode")
		left, right = forge_link.last_selection_line_nums()
	end

	local maybeLink = forge_link.github_link(left, right)
	vim.fn.setreg("+", maybeLink)
	print(maybeLink)
end

-- generate user commands or keybindings etc for the consumer of the plugins
vim.api.nvim_create_user_command("ForgeLink", get_link, { range = true })
