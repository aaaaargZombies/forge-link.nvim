-- this is will be run if you have installed the plugins
-- you don't need to require("module")

print("automatically run")

forge_link = function()
	-- todo copy to clipboard and print a message
	print(require("forge-link").github_link())
end

-- generate user commands or keybindings etc for the consumer of the plugins
-- getting no range allowed?
vim.api.nvim_create_user_command("ForgeLink", forge_link, {})
