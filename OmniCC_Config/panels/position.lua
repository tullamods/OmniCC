--[[
	General configuration settings for OmniCC
--]]

local OmniCCOptions = OmniCCOptions
local OmniCC = OmniCC
local L = OMNICC_LOCALS

--fun constants!
local BUTTON_SPACING = 0
local SLIDER_SPACING = 24

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
	--add way to adjust anchor
	--add way to adjust x offset
	--add way to adjust y offset
	--add way to adjust justifyH.  Remove if not actually useful :P
	--add way to adjust justifyV.  Remove if not actually useful :P
end

function PositionOptions:UpdateValues()

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


--[[ Load the thing ]]--

OmniCCOptions:AddTab(L.PositionSettings, PositionOptions)