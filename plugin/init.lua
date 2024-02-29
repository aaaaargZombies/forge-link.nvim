-- this is will be run if you have installed the plugins
-- you don't need to require("module")
forge_link = function()
	-- one selection behind on the marks / line nums
	-- example fist usage is alway 0,0 then the next usage is what the first should have been
	-- something to do with the way I trigger this function in my keymaps / nvim config
	--
	-- works
	-- keymap("v", "<leader>l", ":<C-u>ForgeLink<cr>", opts)
	--
	-- problem
	-- keymap("v", "<leader>l", "<cmd>ForgeLink<cr>", opts)

	local maybeLink = require("forge-link").github_link()
	vim.fn.setreg("+", maybeLink)
	print(maybeLink)
end

-- generate user commands or keybindings etc for the consumer of the plugins
vim.api.nvim_create_user_command("ForgeLink", forge_link, {})
