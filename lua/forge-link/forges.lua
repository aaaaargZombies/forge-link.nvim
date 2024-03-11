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
--  git@gitlab.com:spritely/goblins.git
--  https://gitlab.com/spritely/goblins.git
--  https://gitlab.com/USER/REPO/blob/BRANCH/FILE_PATH?#L10-14
--  https://gitlab.com/USER/REPO/blob/COMMIT_HASH/FILE_PATH?#L10-14

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
local function github_link(details)
	-- https://github.com/USER/REPO/blob/BRANCH/FILE_PATH?plain=1#L1-L6
	-- https://github.com/USER/REPO/blob/COMMIT_HASH/FILE_PATH?plain=1#L1-L6
	return (
		base_url(details.remote)
		.. "/blob/"
		.. details.commit
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
local github = {
	link = github_link,
	test = github_test,
}

return { github }
