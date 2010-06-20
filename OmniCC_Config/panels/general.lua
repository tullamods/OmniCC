--[[
	General configuration settings for OmniCC
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS

--a hack panel, this is designed to force open to the general options panel when clicked
local OmniCCOptions = OmniCC.OptionsPanel:New('OmniCC', nil, 'OmniCC')
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
	minDuration:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 16, 10)
	minDuration:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 10)

	local minFontSize = self:CreateMinFontSizeSlider()
	minFontSize:SetPoint('BOTTOMLEFT', minDuration, 'TOPLEFT', 0, 20)
	minFontSize:SetPoint('BOTTOMRIGHT', minDuration, 'TOPRIGHT', 0, 20)
end


--[[ Checkboxes ]]--

function GeneralOptions:NewCheckbox(name)
	local b = OmniCC.OptionsCheckButton:New(name, self)
	return b
end

--use whitelist
function GeneralOptions:CreateUseWhitelistCheckbox()
	local b = self:NewCheckbox(L.UseWhitelist)
	b.OnEnableSetting = function(self, enable) OmniCC:SetUseWhitelist(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:UsingWhitelist() end
	return b
end

--scale text
function GeneralOptions:CreateScaleTextCheckbox()
	local b = self:NewCheckbox(L.ScaleText)
	b.OnEnableSetting = function(self, enable) OmniCC:SetScaleText(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:ScalingText() end
	return b
end

--[[ Sliders ]]--

function GeneralOptions:NewSlider(name, low, high, step)
	local s = OmniCC.OptionsSlider:New(name, self, low, high, step)
	return s
end

function GeneralOptions:CreateMinDurationSlider()
	local s = self:NewSlider(L.MinDuration, 0, 30, 0.5)
	s.SetSavedValue = function(self, value) OmniCC:SetMinDuration(value) end
	s.GetSavedValue = function(self) return OmniCC:GetMinDuration() end
	s.GetFormattedText = function(self, value) return ('%.1f Sec'):format(value) end
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