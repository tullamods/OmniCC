--[[
	General.lua
		General Bagnon settings
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS

--a hack panel, this is designed to force open to the general options panel when clicked
local OmniCCOptions = OmniCCOptions.OptionsPanel:New('OmniCC', nil, 'OmniCC')
OmniCCOptions:SetScript('OnShow', function(self)
	InterfaceOptionsFrame_OpenToCategory(OmniCC.GeneralOptions)
	self:Hide()
end)

local GeneralOptions = OmniCC.OptionsPanel:New('OmniCCOptions_General', 'OmniCC', L.GeneralSettings, L.GeneralSettingsTitle)
OmniCC.GeneralOptions = GeneralOptions

local SPACING = 6


--[[
	Startup
--]]

function GeneralOptions:Load()
	self:AddWidgets()
end


--[[
	Widgets
--]]

function GeneralOptions:AddWidgets()
	--checkboxes
	local showWhitelist = self:CreateUseWhitelistCheckbox()
	showWhitelist:SetPoint('TOPLEFT', self, 'TOPLEFT', 14, -72)
	
	local scaleText = self:CreateScaleTextCheckbox()
	scaleText:SetPoint('TOPLEFT', showWhitelist, 'BOTTOMLEFT', 0, -SPACING)
	
	--sliders
	local minDuration = self:CreateMinDurationSlider()
	minDuration:SetWidth(180)
	minDuration:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 10)

	local minFontSize = self:CreateMinFontSizeSlider()
	minFontSize:SetPoint('BOTTOMLEFT', minDuration, 'TOPLEFT', 0, 20)
	minFontSize:SetPoint('BOTTOMRIGHT', minDuration, 'TOPRIGHT', 0, 20)
end

function GeneralOptions:UpdateWidgets()
	if not self:IsVisible() then
		return
	end
	
	for _, checkbox in pairs(self.checkboxes) do
		checkbox:UpdateChecked()
	end
end


--[[ Checkboxes ]]--

GeneralOptions.checkboxes = {}

function GeneralOptions:NewCheckbox(name)
	local b = OmniCC.OptionsCheckButton:New(name, self)
	table.insert(self.checkboxes, b)
	return b
end

--use whitelist
function GeneralOptions:CreateUseWhitelistCheckbox()
	local b = self:NewCheckbox(L.UseWhitelist)
	b.OnEnableSetting = function(self, enable) OmniCC.Settings:SetUseWhitelist(enable) end
	b.IsSettingEnabled = function(self) return OmniCC.Settings:UsingWhitelist() end
	return b
end

--scale text
function GeneralOptions:CreateScaleTextCheckbox()
	local b = self:NewCheckbox(L.ScaleText)
	b.OnEnableSetting = function(self, enable) OmniCC.Settings:SetScaleText(enable) end
	b.IsSettingEnabled = function(self) return OmniCC.Settings:ScalingText() end
	return b
end

--[[ Sliders ]]--

GeneralOptions.sliders = {}

function GeneralOptions:NewSlider(name, low, high, step)
	local s = OmniCC.OptionsSlider:New(name, parent, low, high, step, self)
	table.insert(self.sliders, s)
	return s
end

function GeneralOptions:CreateMinDurationSlider()
	local s = self:NewSlider(L.MinDuration, 0, 30, 0.5)
	s.SetSavedValue = function(self, value) OmniCC:SetMinDuration(value) end
	s.GetSavedValue = function(self) return OmniCC:GetMinDuration() end
	s.GetFormattedText = function(self, value) return floor(value * 100 + 0.5) .. SECONDS_ABBR end
	return s
end

function GeneralOptions:CreateMinFontSizeSlider()
	local s = self:NewSlider(L.MinFontSize, 2, 64, 1)
	s.SetSavedValue = function(self, value) OmniCC:SetMinFontSize(value) end
	s.GetSavedValue = function(self) return OmniCC:GetMinFontSize() end
	return s
end

--[[ Load the thing ]]--

GeneralOptions:Load()