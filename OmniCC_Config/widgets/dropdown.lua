--[[
	dropdown.lua
		A bagnon dropdown menu
--]]

OmniCCOptions = OmniCCOptions or {}

local Dropdown = LibStub('Classy-1.0'):New('Frame'); Dropdown:Hide()
OmniCCOptions.Dropdown = Dropdown

function Dropdown:New(name, parent, width)
	local f = self:Bind(CreateFrame('Frame', parent:GetName() .. name, parent, 'UIDropDownMenuTemplate'))
	f.width = width

	local text = f:CreateFontString(nil, 'BACKGROUND', 'GameFontNormalSmall')
	text:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 21, 0)
	text:SetText(name)
	f.titleText = text

	f:SetScript('OnShow', f.OnShow)
	return f
end


--[[ Frame Evnets ]]--

function Dropdown:OnShow()
--	print('onshow', self:GetName())
	UIDropDownMenu_SetWidth(self, self.width)
	UIDropDownMenu_Initialize(self, self.Initialize)
	UIDropDownMenu_SetSelectedValue(self, self:GetSavedValue())
end


--[[ Update Methods ]]--

function Dropdown:Initialize()
	assert(false, 'Hey you forgot to implement Initialize for ' .. self:GetName())
end

function Dropdown:SetSavedValue(value)
	assert(false, 'Hey you forgot to implement SetSavedValue for ' .. self:GetName())
end

function Dropdown:GetSavedValue()
	assert(false, 'Hey you forgot to implement GetSavedValue for ' .. self:GetName())
end

function Dropdown:UpdateValue()
	UIDropDownMenu_SetSelectedValue(self, self:GetSavedValue())
end


--[[ Item Adding ]]--

function Dropdown:AddItem(name, value)
	local parent = self
--	print('add item', parent:GetName(), name, value)
	
	local info = UIDropDownMenu_CreateInfo()
	info.text = name
	info.value = value or name
	info.arg1 = self
	info.checked = (self:GetSavedValue() == info.value)
	info.func = function(self, parent) 
		parent:SetSavedValue(self.value)
		UIDropDownMenu_SetSelectedValue(parent, self.value)
	end
	
	UIDropDownMenu_AddButton(info)
end