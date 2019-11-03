-- general configuration settings for OmniCC
local _, Addon = ...
local OmniCC = _G.OmniCC
local L = LibStub("AceLocale-3.0"):GetLocale("OmniCC")

local RuleOptions = CreateFrame('Frame', 'OmniCCGroupRulesOptionsPanel')

RuleOptions:SetScript('OnShow', function(self)
	self:AddWidgets()
	self:SetScript('OnShow', nil)
end)

function RuleOptions:GetGroupRules()
	return OmniCC:GetGroupRules(Addon:GetGroupID())
end

function RuleOptions:AddWidgets()
	self.rules = self:AddRulesEditor()
	self.rules:SetPoint('TOPLEFT', 12, -12)
	self.rules:SetPoint('TOPRIGHT', -12, -12)
	self.rules:SetHeight(332)
	self.rules:Load()
end

function RuleOptions:UpdateValues()
	self.rules:UpdateList()
end

function RuleOptions:AddRulesEditor()
	local parent = self
	local editor = Addon.ListEditor:New('List', parent)

	editor.OnAddItem = function(_, ruleToAdd)
		table.insert(parent:GetGroupRules(), ruleToAdd)
		OmniCC:UpdateGroups()
		return true
	end

	editor.OnRemoveItem = function(_, ruleToRemove)
		local rules = parent:GetGroupRules()
		for i, rule in pairs(rules) do
			if rule == ruleToRemove then
				table.remove(rules, i)
				OmniCC:UpdateGroups()
				return true
			end
		end
	end

	editor.GetItems = function()
		local rules = parent:GetGroupRules()
		table.sort(rules)
		return rules
	end

	return editor
end

Addon:AddTab('rules', L.RuleSettings, RuleOptions)