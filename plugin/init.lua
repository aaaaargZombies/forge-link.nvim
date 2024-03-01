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

-- example visual selection marks issue for reddit help post
-- https://www.reddit.com/r/neovim/comments/1b3uarv/trouble_getting_start_and_end_position_of_a/
local function visual_select_line_nums()
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")

	local start_line = start_pos[1]
	local end_line = end_pos[1]

	print(start_line, end_line)
end

vim.api.nvim_create_user_command("VLines", visual_select_line_nums, {})

vim.api.nvim_set_keymap("v", "<leader>vl", "<cmd>VLines<cr>", { noremap = true })
