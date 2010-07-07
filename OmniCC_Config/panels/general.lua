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
	local useWhitelist = self:CreateUseWhitelistCheckbox()
	useWhitelist:SetPoint('TOPLEFT', self, 'TOPLEFT', 14, -72)
	
	local scaleText = self:CreateScaleTextCheckbox()
	scaleText:SetPoint('TOPLEFT', useWhitelist, 'BOTTOMLEFT', 0, -SPACING)
	
	local finishEffect = self:CreateFinishEffectPicker()
	finishEffect:SetPoint('TOPLEFT', scaleText, 'BOTTOMLEFT', -16, -(SPACING + 12))
	
	--sliders
	local minEffectDuration = self:CreateMinEffectDurationSlider()
	minEffectDuration:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 16, 10)
	minEffectDuration:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 10)
	
	local minDuration = self:CreateMinDurationSlider()
	minDuration:SetPoint('BOTTOMLEFT', minEffectDuration, 'TOPLEFT', 0, 20)
	minDuration:SetPoint('BOTTOMRIGHT', minEffectDuration, 'TOPRIGHT', 0, 20)

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

function GeneralOptions:CreateMinEffectDurationSlider()
	local s = self:NewSlider(L.MinEffectDuration, 0, 60, 1)
	s.SetSavedValue = function(self, value) OmniCC:SetMinEffectDuration(value) end
	s.GetSavedValue = function(self) return OmniCC:GetMinEffectDuration() end
	return s
end


--[[ Dropdown ]]--

function GeneralOptions:CreateFinishEffectPicker()
	local dd = OmniCC.OptionsDropdown:New(L.FinishEffect, self, 120)
	
	dd.Initialize = function()
		dd:AddItem(NONE, 'none')
	
		local effects = OmniCC:ForEachEffect(function(effect) return {effect.name, effect.id} end)
		table.sort(effects, function(e1, e2) return e1[1] < e2[1] end)
	
		for n, v in ipairs(effects) do
			dd:AddItem(unpack(v))
		end
	end
	
	dd.SetSavedValue = function(self, value)
		OmniCC:SetEffect(value)
	end
	
	dd.GetSavedValue = function(self)
		return OmniCC:GetSelectedEffectID()
	end
	
	return dd
end

--[[ Load the thing ]]--

GeneralOptions:Load()