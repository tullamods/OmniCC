--[[
	General configuration settings for OmniCC
--]]

local OmniCCOptions = OmniCCOptions
local OmniCC = OmniCC
local Timer = OmniCC.Timer
local L = OMNICC_LOCALS

--fun constants!
local BUTTON_SPACING = 0
local SLIDER_SPACING = 24

local ANCHOR_POINTS = {
	'TOPLEFT', 
	'TOP', 
	'TOPRIGHT', 
	'LEFT', 
	'CENTER', 
	'RIGHT',
	'BOTTOMLEFT',
	'BOTTOM',
	'BOTTOMRIGHT',
}

local JUSTIFYH_POINTS = {
	'LEFT',
	'CENTER',
	'RIGHT'
}

local JUSTIFYV_POINTS = {
	'TOP',
	'MIDDLE',
	'BOTTOM'
}

local PositionOptions = CreateFrame('Frame', 'OmniCCOptions_Position')
PositionOptions:SetScript('OnShow', function(self)
	self:AddWidgets()
	self:UpdateValues()
	self:SetScript('OnShow', nil)
end)

function PositionOptions:GetGroupSets()
	return OmniCCOptions:GetGroupSets()
end


--[[ Widgets ]]--

function PositionOptions:AddWidgets()
	--dropdowns
	local anchor = self:CreateAnchorPicker()
	anchor:SetPoint('TOPLEFT', self, 'TOPLEFT', -4, -26)

	local justifyH = self:CreateJustifyHPicker()
	justifyH:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -(BUTTON_SPACING + 16))
	
	local justifyV = self:CreateJustifyVPicker()
	justifyV:SetPoint('TOPLEFT', justifyH, 'BOTTOMLEFT', 0, -(BUTTON_SPACING + 16))
	
	--sliders
	local yOff = self:CreateYOffsetSlider()
	yOff:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 16, 10)
	yOff:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 10)

	local xOff = self:CreateXOffsetSlider()
	xOff:SetPoint('BOTTOMLEFT', yOff, 'TOPLEFT', 0, SLIDER_SPACING)
	xOff:SetPoint('BOTTOMRIGHT', yOff, 'TOPRIGHT', 0, SLIDER_SPACING)
end

function PositionOptions:UpdateValues()
	if self.sliders then
		for i, s in pairs(self.sliders) do
			s:UpdateValue()
		end
	end

	if self.dropdowns then
		for i, dd in pairs(self.dropdowns) do
			dd:UpdateValue()
		end
	end
end


--[[ Checkboxes ]]--

function PositionOptions:NewCheckbox(name)
	local b = OmniCCOptions.CheckButton:New(name, self)

	self.buttons = self.buttons or {}
	table.insert(self.buttons, b)
	return b
end


--[[ Sliders ]]--

function PositionOptions:NewSlider(name, low, high, step)
	local s = OmniCCOptions.Slider:New(name, self, low, high, step)
	s:SetHeight(s:GetHeight() + 2)

	self.sliders = self.sliders or {}
	table.insert(self.sliders, s)
	return s
end

function PositionOptions:CreateXOffsetSlider()
	local parent = self
	local s = self:NewSlider(L.XOffset, -32, 32, 1)

	s.SetSavedValue = function(self, value)
		parent:GetGroupSets().xOff = value
		Timer:ForAll('UpdateTextPosition')
	end

	s.GetSavedValue = function(self)
		return parent:GetGroupSets().xOff
	end

	s.tooltip = L.XOffsetTip

	return s
end

function PositionOptions:CreateYOffsetSlider()
	local parent = self
	local s = self:NewSlider(L.YOffset, -32, 32, 1)

	s.SetSavedValue = function(self, value)
		parent:GetGroupSets().yOff = value
		Timer:ForAll('UpdateTextPosition')
	end

	s.GetSavedValue = function(self)
		return parent:GetGroupSets().yOff
	end

	s.tooltip = L.YOffsetTip

	return s
end


--[[ Dropdowns ]]--

function PositionOptions:NewDropdown(name, width)
	local dd = OmniCCOptions.Dropdown:New(name, self, width)

	self.dropdowns = self.dropdowns or {}
	table.insert(self.dropdowns, dd)

	return dd
end

function PositionOptions:CreateAnchorPicker()
	local parent = self
	local dd = self:NewDropdown(L.Anchor, 120)

	dd.Initialize = function(self)
		for i, v in ipairs(ANCHOR_POINTS) do
			self:AddItem(v, L['Anchor_' .. v])
		end
	end

	dd.SetSavedValue = function(self, value)
		parent:GetGroupSets().anchor = value
		Timer:ForAll('UpdateTextPosition')
	end

	dd.GetSavedValue = function(self)
		return parent:GetGroupSets().anchor
	end

	return dd
end

function PositionOptions:CreateJustifyHPicker()
	local parent = self
	local dd = self:NewDropdown(L.JustifyH, 120)

	dd.Initialize = function(self)
		for i, v in ipairs(JUSTIFYH_POINTS) do
			self:AddItem(v, L['JustifyH_' .. v])
		end
	end

	dd.SetSavedValue = function(self, value)
		parent:GetGroupSets().justifyH = value
		Timer:ForAll('UpdateTextPosition')
	end

	dd.GetSavedValue = function(self)
		return parent:GetGroupSets().justifyH
	end

	return dd
end

function PositionOptions:CreateJustifyVPicker()
	local parent = self
	local dd = self:NewDropdown(L.JustifyV, 120)

	dd.Initialize = function(self)
		for i, v in ipairs(JUSTIFYV_POINTS) do
			self:AddItem(v, L['JustifyV_' .. v])
		end
	end

	dd.SetSavedValue = function(self, value)
		parent:GetGroupSets().justifyV = value
		Timer:ForAll('UpdateTextPosition')
	end

	dd.GetSavedValue = function(self)
		return parent:GetGroupSets().justifyV
	end

	return dd
end



--[[ Load the thing ]]--

OmniCCOptions:AddTab(L.PositionSettings, PositionOptions)