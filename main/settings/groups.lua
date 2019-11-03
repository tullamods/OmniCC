-- Groups API
-- Here for compatibility. A group in OmniCC is a 1-1 mapping between a theme and a ruleset

local _, Addon = ...

-- Groups API
-- Here for compatibility
function Addon:AddGroup(id)
	if self:AddTheme(id) and self:AddRuleset(id, id) then
		self:UpdateGroups()
		return true
	end
end

function Addon:RemoveGroup(id)
	if self:RemoveTheme(id) and self:RemoveRuleset(id) then
		self:UpdateGroups()
		return true
	end
end

function Addon:GetGroupSettings(id)
	return self:GetTheme(id)
end

function Addon:GetActiveGroups()
	local groups = {}

	for _, ruleset in Addon:GetActiveRulesets() do
		tinsert(groups, ruleset.theme)
	end

	return ipairs(groups)
end

function Addon:GetGroupRules(id)
	local ruleset = self:GetRuleset(id)
	if ruleset then
		return ruleset.rules
	end
	return {}
end

function Addon:UpdateGroups()
	self.Cooldown:UpdateSettings()
	self.Display:ForActive("UpdateCooldownText")
end

