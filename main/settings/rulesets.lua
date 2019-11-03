-- Rulesets API
-- In OmniCC, a ruleset is used to customize

local _, Addon = ...

-- local Ruleset = {}
-- local Ruleset_MT = {__index = Ruleset}

-- function Ruleset:New(id)
-- 	local o = {
-- 		id = id,
-- 		settings = Addon.db.profile.rulesets[id]
-- 	}

-- 	return setmetatable(o, Ruleset_MT)
-- end

-- function Ruleset:SetEnabled(enabled)
-- 	self.settings.enabled = enabled and true
-- end

-- function Ruleset:GetEnabled()
-- 	return self.settings.enabled
-- end

-- function Ruleset:SetPriority(priority)
-- 	self.settings.priority = tonumber(priority) or math.huge
-- end

-- function Ruleset:GetPriority()
-- 	return self.settings.priority
-- end

-- function Ruleset:AddRule(rule)
-- end

-- function Ruleset:RemoveRule(rule)
-- end

-- function Ruleset:SetRules(...)
-- 	self.settings.rules = {...}
-- end

-- function Ruleset:GetRules()
-- 	return pairs(self.settings.rules)
-- end

-- function Ruleset:AddFrame(frame)
-- 	self.frames = self.frames or {}

-- 	self.frames[frame] = true
-- end

-- function Ruleset:RemoveFrame(frame)
-- 	self.frames[frame] = nil
-- end

-- function Ruleset:IsMatch(frame)
-- 	if self.frames and self.frames[frame] then
-- 		return true
-- 	end


-- end

function Addon:AddRuleset(id, theme)
	local rulesets = self.db.profile.rulesets

	-- skip if the ruleset already exists
	for _, ruleset in pairs(rulesets) do
		if ruleset.id == id then
			return false
		end
	end

	local ruleset = {
		id = id,
		theme = theme or self:GetDefaultThemeID(),
		enabled = true,
		priority = #rulesets + 1,
		rules = { }
	}

	tinsert(rulesets, ruleset)
	return ruleset, #rulesets
end

function Addon:SetRulesetPriority(id, priority)
	local updated = false

	for _, ruleset in pairs(self.db.profile.rulesets) do
		if ruleset.id == id and ruleset.priority ~= priority then
			ruleset.priority = priority
			updated = true
			break
		end
	end

	if updated then
		self:ReorderRulesets()
	end

	return updated
end

function Addon:ReorderRulesets()
	table.sort(self.db.profile.rulesets, function(l, r)
		return l.priority < (r.priority or math.huge)
	end)

	for i, ruleset in pairs(self.db.profile.rulesets) do
		ruleset.priority = i
	end
end

function Addon:EnableRuleset(id)
	for _, ruleset in pairs(self.db.profile.rulesets) do
		if ruleset.id == id and not ruleset.enabled then
			ruleset.enabled = true
			return true
		end
	end
end

function Addon:DisableRuleset(id)
	for _, ruleset in pairs(self.db.profile.rulesets) do
		if ruleset.id == id and ruleset.enabled then
			ruleset.enabled = false
			return true
		end
	end
end

function Addon:RemoveRuleset(id)
	for i, ruleset in pairs(self.db.profile.rulesets) do
		if ruleset.id == id then
			tremove(self.db.profile.rulesets, i)
			return true
		end
	end
end

function Addon:GetRuleset(id)
	for _, ruleset in pairs(self.db.profile.rulesets) do
		if ruleset.id == id then
			return ruleset
		end
	end
end

function Addon:RulesetExists(id)
	for _, ruleset in pairs(self.db.profile.rulesets) do
		if ruleset.id == id then
			return true
		end
	end
end

function Addon:GetRulesets()
	return ipairs(self.db.profile.rulesets)
end

function Addon:NumRulesets()
	return #self.db.profile.rulesets
end

do
	local function nextActiveRuleset(rulesets, index)
		if not rulesets then return end

		for i = index + 1, #rulesets do
			local ruleset = rulesets[i]
			if ruleset.enabled then
				return i, ruleset
			end
		end
	end

	function Addon:GetActiveRulesets()
		return nextActiveRuleset, self.db.profile.rulesets, 0
	end
end

function Addon:FindRuleset(name)
	if name then
		for _, ruleset in self:GetActiveRulesets() do
			for _, pattern in pairs(ruleset.rules) do
				if name:match(pattern) then
					return ruleset
				end
			end
		end
	end

	return false
end