--[[
	General configuration settings for OmniCC
--]]

local OmniCCOptions = OmniCCOptions
local OmniCC = OmniCC
local L = OMNICC_LOCALS

--fun constants!
local BUTTON_SPACING = 0
local SLIDER_SPACING = 24

local GroupOptions = CreateFrame('Frame', 'OmniCCOptions_Groups')
GroupOptions:SetScript('OnShow', function(self)
	self:AddWidgets()
	self:UpdateValues()
	self:SetScript('OnShow', nil)
end)

function GroupOptions:GetGroupSets()
	return OmniCCOptions:GetGroupSets()
end


--[[ Widgets ]]--

function GroupOptions:AddWidgets()
	--need a way to create groups
	--need a way to reorder groups
	--need a way to remove groups
	--need basic checking to make sure that the group id/name does not already exist
	
	--need a way to add patterns to groups
	--need a way to remove patterns from groups
	--need basic checking to make sure that the pattern does not already exist
end

function GroupOptions:UpdateValues()

end


--[[ Checkboxes ]]--

function GroupOptions:NewCheckbox(name)
	local b = OmniCCOptions.CheckButton:New(name, self)

	self.buttons = self.buttons or {}
	table.insert(self.buttons, b)
	return b
end


--[[ Sliders ]]--

function GroupOptions:NewSlider(name, low, high, step)
	local s = OmniCCOptions.Slider:New(name, self, low, high, step)
	s:SetHeight(s:GetHeight() + 2)

	self.sliders = self.sliders or {}
	table.insert(self.sliders, s)
	return s
end


--[[ Load the thing ]]--

OmniCCOptions:AddTab(L.GroupSettings, GroupOptions)