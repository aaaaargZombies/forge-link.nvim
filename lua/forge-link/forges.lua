local function base_url(remote)
	if string.match(remote, "@") then
		-- shh remote
		return "https://" .. remote:gsub("^git@", ""):gsub("%.git", ""):gsub(":", "/")
	else
		-- https remote
		return remote:gsub("%.git", "")
	end
end

---@param details Deetz
---@return string
local function bitbucket_link(details)
	--  bitbucket
	--  https://bitbucket.org/USER/REPO/annotate/COMMIT_HASH_or_BRANH/FILE_PATH_INCLUDING_NAME#FILE_NAME-3:7
	--  https://bitbucket.org/tortoisehg/tortoisehg.bitbucket.io/src/81dafd29546e41851fcc6220d9c2236d7415b611/js/common.js#lines-3:7
	--  https://bitbucket.org/tortoisehg/tortoisehg.bitbucket.io/src/81dafd29546e41851fcc6220d9c2236d7415b611/ja/js/common.js#lines5:7
	return (
		base_url(details.remote)
		.. "/src/"
		.. details.commit
		.. details.file_path
		.. "#lines-"
		.. details.line_start
		.. ":"
		.. details.line_end
	)
end

---@param remote string
---@return boolean
local function bitbucket_test(remote)
	return (remote ~= nil and string.match(remote, "bitbucket"))
end

---@param details Deetz
---@return string
local function sourcehut_link(details)
	-- sourcehut
	-- https://git.sr.ht/~gtf/culture-vulture/tree/20603c65a955cdbaa416226cd15c6a91e20c5763/item/src/frontend/ts/EventListFilter.ts#L6-13
	-- https://git.sr.ht/USER/REPO/tree/COMMIT_HASH/item/FILE_PATH_INCLUDING_NAME#L6-13
	return (
		base_url(details.remote)
		.. "/tree/"
		.. details.commit
		.. "/item"
		.. details.file_path
		.. "#L"
		.. details.line_start
		.. "-"
		.. details.line_end
	)
end

---@param remote string
---@return boolean
local function sourcehut_test(remote)
	return (remote ~= nil and string.match(remote, "sr%.ht"))
end

---@param details Deetz
---@return string
local function codeberg_link(details)
	--  codeberg / forgejo
	--  https://codeberg.org/simonrepp/faircamp/src/branch/main/src/util.rs#L4-L7
	--  https://codeberg.org/simonrepp/faircamp/src/commit/75f93a7313a2d9fe380f9e9822d8023f7e482dd6/src/util.rs#L5-L8
	--  https://codeberg.org/USER/REPO/src/commit/COMMIT_HASH/FILE_PATH#L5-L8
	--  https://codeberg.org/USER/REPO/src/branch/BRANCH/FILE_PATH#L5-L8
	return (
		base_url(details.remote)
		.. "/src/commit/"
		.. details.commit
		.. details.file_path
		.. "#L"
		.. details.line_start
		.. "-L"
		.. details.line_end
	)
end

---@param remote string
---@return boolean
local function codeberg_test(remote)
	return (remote ~= nil and string.match(remote, "codeberg"))
end

---@param details Deetz
---@return string
local function gitlab_link(details)
	--  gitlab
	--  https://gitlab.com/spritely/goblins/blob/master/goblins/core.rkt?#L10-14
	--  git@gitlab.com:spritely/goblins.git
	--  https://gitlab.com/spritely/goblins.git
	--  https://gitlab.com/USER/REPO/blob/BRANCH/FILE_PATH?#L10-14
	--  https://gitlab.com/USER/REPO/blob/COMMIT_HASH/FILE_PATH?#L10-14
	--
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

---@param remote string
---@return boolean
local function gitlab_test(remote)
	return (remote ~= nil and string.match(remote, "gitlab"))
end

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

---@param remote string
---@return boolean
local function github_test(remote)
	return (remote ~= nil and string.match(remote, "github"))
end

---@type Forge
local bitbucket = {
	link = bitbucket_link,
	test = bitbucket_test,
}

---@type Forge
local sourcehut = {
	link = sourcehut_link,
	test = sourcehut_test,
}

---@type Forge
local codeberg = {
	link = codeberg_link,
	test = codeberg_test,
}

---@type Forge
local gitlab = {
	link = gitlab_link,
	test = gitlab_test,
}

---@type Forge
local github = {
	link = github_link,
	test = github_test,
}

return { github, gitlab, codeberg, sourcehut, bitbucket }
