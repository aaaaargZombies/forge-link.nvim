# forge-link.nvim

A simple neovim plugin for sharing specific sections of code. Handy for writing documentation and collaboration.

## Features

- Visually highlight lines of code then generate [link](https://github.com/aaaaargZombies/forge-link.nvim/blob/c93d9643ce0f61542674ed4abfd51d556ae8194b/plugin/init.lua#L22-L22) to that code in the repository with `:ForgeLink`
- Navigate directly to that link with `:ForgeNav`
- Generate a markdown snippet for pasting into chat or adding to documentation with `:ForgeSnip` like this:

```lua
local get_snippet = function()
	local maybeCode = require("forge-link").forge_snip()
	vim.fn.setreg("+", maybeCode)
	print("copied snippet to clipboard")
end
```

[view code in context](https://github.com/aaaaargZombies/forge-link.nvim/blob/6f29dbeb0401287f3b7e2be355de5581ea7324c8/plugin/init.lua#L15-L19)


## Supported forges

- github
- gitlab
- codeberg
- sourcehut
- bitbucket


## Installation

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "aaaaargZombies/forge-link.nvim"
}
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "aaaaargZombies/forge-link.nvim"
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'aaaaargZombies/forge-link.nvim'
```

## Setup

You don't need to do anything after installation but I added the following keymaps

```lua
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }

-- FORGE-LINK
keymap("v", "<leader>ll", "<cmd>ForgeLink<cr>", opts)
keymap("v", "<leader>ln", "<cmd>ForgeNav<cr>", opts)
keymap("v", "<leader>ls", "<cmd>ForgeSnip<cr>", opts)
keymap("n", "<leader>ll", "<cmd>ForgeLink<cr>", opts)
```

## Configuration

You can pass in new forge options that I haven't written support for and overwrite the defaults I provide.

A `Forge` is an table that consists of a test function and a function to generate a link. The setup function takes an array of `Forge`.

### `test`

```lua
---@param remote string
---@return boolean
local function github_test(remote)
	return (remote ~= nil and string.match(remote, "github"))
end
```

[view code in context](https://github.com/aaaaargZombies/forge-link.nvim/blob/6f29dbeb0401287f3b7e2be355de5581ea7324c8/lua/forge-link/forges.lua#L137-L133)

Here's an example for github, it gets the git remote origin as a string and returns true if it contains "github". If you have a repo hosted on gitlab and you called it github you can write your own test to handle that.

### `link`

```lua
---@param details Deetz
---@return string
local function github_link(details)
	-- https://github.com/aaaaargZombies/forge-link.nvim/blob/db392d4ad20bec89ca2f165fce468c7a33e98877/lua/forge-link/forges.lua#L97-L98
	-- https://github.com/USER/REPO/blob/BRANCH/FILE_PATH?plain=1#L1-L6
	-- https://github.com/USER/REPO/blob/COMMIT_HASH/FILE_PATH?plain=1#L1-L6
	return (
		base_url(details.remote)
		.. "/blob/"
		.. details.commit
		.. details.file_path
		.. "#L"
		.. details.line_start
		.. "-L"
		.. details.line_end
	)
end
```

[view code in context](https://github.com/aaaaargZombies/forge-link.nvim/blob/6f29dbeb0401287f3b7e2be355de5581ea7324c8/lua/forge-link/forges.lua#L115-L131)

An example for generating a github link. It is passed a table with the following options so you can build your link

```lua
---@class Deetz
---@field branch string
---@field commit string
---@field file_path string
---@field line_end number
---@field line_start number
---@field remote string
```

[view code in context](https://github.com/aaaaargZombies/forge-link.nvim/blob/6f29dbeb0401287f3b7e2be355de5581ea7324c8/lua/forge-link/init.lua#L3-L9)

### `Forge`

Combine these into a table.

```lua
--- A function that takes the git remote.origin.url and is used decide if the accompanying link function should be run.
---@alias Test fun(remote: string): boolean

--- A function that takes useful file and git info that can be used to produce a link to the git forges website at a specific point in the code.
---@alias Link fun(details: Deetz): string

---@class Forge
---@field test Test
---@field link Link
```

[view code in context](https://github.com/aaaaargZombies/forge-link.nvim/blob/6f29dbeb0401287f3b7e2be355de5581ea7324c8/lua/forge-link/init.lua#L19-L11)

```lua
---@type Forge
local github = {
	link = github_link,
	test = github_test,
}
```

[view code in context](https://github.com/aaaaargZombies/forge-link.nvim/blob/6f29dbeb0401287f3b7e2be355de5581ea7324c8/lua/forge-link/forges.lua#L163-L167)

### Register custom forges

The `setup` function takes the array of forges and prepends it to the defaults giving your custom forges priority.

```lua
require("forge-link").setup({
	custom_github_forge,
	my_selfhosted_gittea,
})
```

## Caveats

This is only tested on linux, it will probably work on macos, it might work on windows with WSL
