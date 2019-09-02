-- the omnicc groups API

local _, Addon = ...

local function getFirstAncestorWithName(cooldown)
	local frame = cooldown
	repeat
		local name = frame:GetName()
		if name then
			return name
		end
		frame = frame:GetParent()
	until not frame
end

local function nextActiveGroup(profile, index)
	if not profile then return end

	for i = index + 1, #profile.groupOrder do
		local groupId = profile.groupOrder[i]
		local groupSettings = profile.groupSettings[groupId]

		if groupSettings.active then
			return i, groupId, groupSettings
		end
	end
end

function Addon:GetCooldownSettings(cooldown)
	local id = self:GetCooldownGroupID(cooldown)
	if id then
		return self:GetGroupSettings(id)
	end
end

function Addon:GetCooldownGroupID(cooldown)
	local name = getFirstAncestorWithName(cooldown)

	if name then
		for _, id, settings in self:GetActiveGroups() do
			for _, pattern in pairs(settings.rules) do
				if name:match(pattern) then
					return id
				end
			end
		end
	end

	return "default"
end

function Addon:GetGroupSettings(id)
	return self.db.profile.groupSettings[id]
end

function Addon:GetGroupIndex(id)
	for i, groupId in pairs(self.db.profile.groupOrder) do
		if groupId == id then
			return i
		end
	end
end

function Addon:GetActiveGroups()
	return nextActiveGroup, self.db.profile, 0
end

function Addon:GetAllGroups()
	return next, self.db.profile.groupSettings, nil
end


-- modifications
function Addon:AddGroup(id)
	if not self:GetGroupIndex(id) then
		tinsert(self.db.profile.groupOrder, id)
		self.db.profile.groupSettings[id] = CopyTable(self.db.profile.groupSettings.default)
	end

	self:UpdateGroups()
	return true
end

function Addon:RemoveGroup(id)
	for i, groupId in pairs(self.db.profile.groupOrder) do
		if groupId == id then
			tremove(self.db.profile.groupOrder, i)
			break
		end
	end

	self.db.profile.groupSettings[id] = nil
	return true
end

function Addon:GetGroupRules(id)
	return self.db.profile.groupSettings[id].rules
end

function Addon:UpdateGroups()
	self.Cooldown:UpdateSettings()
	self.Display:ForActive("UpdateCooldownText")
end
