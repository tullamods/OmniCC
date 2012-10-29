--[[
	groups.lua
		manages group behaviour
--]]

local Cache = {}


--[[ Queries ]]--

function OmniCC:GetGroup(cooldown)
	local id = Cache[cooldown]
	if not id then
		id = self:FindGroup(cooldown)
		Cache[cooldown] = id
	end

	return id
end

function OmniCC:FindGroup(cooldown)
	local name = cooldown:GetName()
	if name then
		local groups = self.sets.groups
		for i = #groups, 1, -1 do
			local group = groups[i]
			if group.enabled then
				for _, pattern in pairs(group.rules) do
					if name:match(pattern) then
						return group.id
					end
				end
			end
		end
	end
	return 'base'
end

function OmniCC:GetGroupSettingsFor(cooldown)
	local group = self:GetGroup(cooldown)
	return self:GetGroupSettings(group)
end

function OmniCC:GetGroupSettings(group)
	return self.sets.groupSettings[group]
end

function OmniCC:GetGroupIndex(id)
	for i, group in pairs(self.sets.groups) do
		if group.id == id then
			return i
		end
	end
end


--[[ Modifications ]]--

function OmniCC:AddGroup(id)
	if not self:GetGroupIndex(id) then
		local sets = self.sets
		sets.groupSettings[id] = CopyTable(sets.groupSettings['base'])
		tinsert(sets.groups, {id = id, rules = {}, enabled = true})

		self:UpdateGroups()
		return true
	end
end

function OmniCC:RemoveGroup(id)
	local index = self:GetGroupIndex(id)
	if index then
		self.sets.groupSettings[id] = nil
		tremove(self.sets.groups, index)

		self:UpdateGroups()
		return true
	end
end

function OmniCC:UpdateGroups()
	for cooldown, group in pairs(Cache) do
		local newGroup = self:FindGroup(cooldown)
		if group ~= newGroup then
			Cache[cooldown] = newGroup

			local timer = self.Timer:Get(cooldown)
			if timer and timer.visible then
				timer:UpdateText(true)
				timer:UpdateCooldownShown()
			end
		end
	end
end