--[[
	General configuration settings for OmniCC
--]]

local OmniCCOptions = OmniCCOptions
local OmniCC = OmniCC
local L = OMNICC_LOCALS

--fun constants!
local BUTTON_SPACING = 0
local SLIDER_SPACING = 24

local function getGroupById(groupId)
	for i, group in pairs(OmniCC.db.groups) do
		if group.id == groupId then
			return group
		end
	end
	return nil
end

local GroupOptions = CreateFrame('Frame', 'OmniCCOptions_Groups')
GroupOptions:SetScript('OnShow', function(self)
	self:AddWidgets()
	self:SetScript('OnShow', nil)
end)

function GroupOptions:GetGroupSets()
	return OmniCCOptions:GetGroupSets()
end


--[[ Widgets ]]--

function GroupOptions:AddWidgets()
	self.groups = self:AddGroupEditor()
	self.groups:SetPoint('TOPLEFT', 12, -24)
	self.groups:SetPoint('TOPRIGHT', self, 'TOP', -6, -24)
	self.groups:SetHeight(332)

	self.rules = self:AddRulesEditor()
	self.rules:SetPoint('TOPLEFT', self.groups, 'TOPRIGHT', 8, 0)
	self.rules:SetPoint('TOPRIGHT', -12, -24)
	self.rules:SetHeight(332)
end

function GroupOptions:AddGroupEditor(onSelect)
	local parent = self
	local editor = OmniCCOptions.ListEditor:New(L.Groups, parent, true)
	
	editor.OnAddItem = function(self, groupId, index)
		local index = index or (#OmniCC.db.groups + 1)
		for i, group in pairs(OmniCC.db.groups) do
			if group.id == groupId then
				return false
			end
		end
		table.insert(OmniCC.db.groups, index, {id = groupId, name = groupId, rules = {}, enabled = true})
		OmniCC.db.groupSettings[groupId] = {}
		return true
	end

	editor.OnRemoveItem = function(self, groupId)
		for i, group in pairs(OmniCC.db.groups) do
			if group.id == groupId then
				table.remove(OmniCC.db.groups, i)
				OmniCC.db.groupSettings[group.id] = nil
				return true
			end
		end
	end

	editor.OnSetIndex = function(self, groupId, newIndex)
		for i, group in pairs(OmniCC.db.groups) do
			if group.id == groupId then
				table.remove(OmniCC.db.groups, k)
				table.insert(OmniCC.db.groups, newIndex, group)
				return true
			end
		end
	end
	
	editor.OnSelect = function(self, groupId)
		parent.rules.groupId = groupId
		parent.rules:UpdateList()
	end

	local items = {}
	editor.GetItems = function(self)
		for i, v in pairs(OmniCC.db.groups) do
			items[i] = v.id
		end
		for i = #OmniCC.db.groups + 1, #items do
			items[i] = nil
		end
		return items
	end
	
	return editor
end

function GroupOptions:AddRulesEditor()
	local editor = OmniCCOptions.ListEditor:New('Rules', self)
	editor.groupId = 'action'

	editor.OnAddItem = function(self, ruleToAdd, index)
		local group = getGroupById(editor.groupId)
		table.insert(group.rules, index, ruleToAdd)
		return true
	end

	editor.OnRemoveItem = function(self, ruleToRemove)
		local group = getGroupById(editor.groupId)
		for i, rule in pairs(group.rules) do
			if rule == ruleToRemove then
				table.remove(group.rules, index)
				return true
			end
		end
	end

	editor.GetItems = function(self)
		local group = getGroupById(editor.groupId)
		if group then
			table.sort(group.rules)
			return group.rules
		end
		return {}
	end

	return editor
end


--[[ Load the thing ]]--

OmniCCOptions:AddTab(L.GroupSettings, GroupOptions)