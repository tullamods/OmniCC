--[[
	General configuration settings for OmniCC
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS

--fun constants!
local BUTTON_SPACING = 6
local SLIDER_SPACING = 24

--a hack panel, this is designed to force open to the general options panel when clicked
local OmniCCOptions = OmniCC.OptionsPanel:New('OmniCC', nil, 'OmniCC')
OmniCCOptions:SetScript('OnShow', function(self)
	InterfaceOptionsFrame_OpenToCategory(OmniCC.GeneralOptions)
	self:Hide()
end)

local GeneralOptions = OmniCC.OptionsPanel:New('OmniCCOptions_General', 'OmniCC', L.GeneralSettings, L.GeneralSettingsTitle)
OmniCC.GeneralOptions = GeneralOptions


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
	local scaleText = self:CreateScaleTextCheckbox()
	scaleText:SetPoint('TOPLEFT', self, 'TOPLEFT', 14, -60)

	local showModels = self:CreateShowCooldownModelsCheckbox()
	showModels:SetPoint('TOPLEFT', scaleText, 'BOTTOMLEFT', 0, -BUTTON_SPACING)

	local finishEffect = self:CreateFinishEffectPicker()
	finishEffect:SetPoint('TOPLEFT', showModels, 'BOTTOMLEFT', -16, -(BUTTON_SPACING + 16))

	--sliders
	local minEffectDuration = self:CreateMinEffectDurationSlider()
	minEffectDuration:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 16, 10)
	minEffectDuration:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 10)

	local mmSSDuration = self:CreateMMSSSlider()
	mmSSDuration:SetPoint('BOTTOMLEFT', minEffectDuration, 'TOPLEFT', 0, SLIDER_SPACING)
	mmSSDuration:SetPoint('BOTTOMRIGHT', minEffectDuration, 'TOPRIGHT', 0, SLIDER_SPACING)

	local tenthsDuration = self:CreateTenthsSlider()
	tenthsDuration:SetPoint('BOTTOMLEFT', mmSSDuration, 'TOPLEFT', 0, SLIDER_SPACING)
	tenthsDuration:SetPoint('BOTTOMRIGHT', mmSSDuration, 'TOPRIGHT', 0, SLIDER_SPACING)

	local minDuration = self:CreateMinDurationSlider()
	minDuration:SetPoint('BOTTOMLEFT', tenthsDuration, 'TOPLEFT', 0, SLIDER_SPACING)
	minDuration:SetPoint('BOTTOMRIGHT', tenthsDuration, 'TOPRIGHT', 0, SLIDER_SPACING)

	local minFontSize = self:CreateMinFontSizeSlider()
	minFontSize:SetPoint('BOTTOMLEFT', minDuration, 'TOPLEFT', 0, SLIDER_SPACING)
	minFontSize:SetPoint('BOTTOMRIGHT', minDuration, 'TOPRIGHT', 0, SLIDER_SPACING)
end


--[[ Checkboxes ]]--

function GeneralOptions:NewCheckbox(name)
	local b = OmniCC.OptionsCheckButton:New(name, self)
	return b
end

--scale text
function GeneralOptions:CreateScaleTextCheckbox()
	local b = self:NewCheckbox(L.ScaleText)
	b.OnEnableSetting = function(self, enable) OmniCC:SetScaleText(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:ScalingText() end

	b.tooltip = L.ScaleTextTip

	return b
end

--show cooldown models
function GeneralOptions:CreateShowCooldownModelsCheckbox()
	local b = self:NewCheckbox(L.ShowCooldownModels)
	b.OnEnableSetting = function(self, enable) OmniCC:SetShowCooldownModels(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:ShowingCooldownModels() end

	b.tooltip = L.ShowCooldownModelsTip

	return b
end

--[[ Sliders ]]--

function GeneralOptions:NewSlider(name, low, high, step)
	local s = OmniCC.OptionsSlider:New(name, self, low, high, step)
	s:SetHeight(s:GetHeight() + 4)
	return s
end

do
	local SECONDS_ABBR = '%.1f' .. (SECONDS_ABBR:match('%%d(.+)'))
	function GeneralOptions:CreateMinDurationSlider()
		local s = self:NewSlider(L.MinDuration, 0, 30, 0.5)
		s.SetSavedValue = function(self, value) OmniCC:SetMinDuration(value) end
		s.GetSavedValue = function(self) return OmniCC:GetMinDuration() end
		s.GetFormattedText = function(self, value) return SECONDS_ABBR:format(value) end

		s.tooltip = L.MinDurationTip

		return s
	end
end

function GeneralOptions:CreateMinFontSizeSlider()
	local s = self:NewSlider(L.MinFontSize, 2, 64, 1)
	s.SetSavedValue = function(self, value) OmniCC:SetMinFontSize(value) end
	s.GetSavedValue = function(self) return OmniCC:GetMinFontSize() end

	s.tooltip = L.MinFontSizeTip

	return s
end

function GeneralOptions:CreateMinEffectDurationSlider()
	local s = self:NewSlider(L.MinEffectDuration, 0, 60, 1)
	s.SetSavedValue = function(self, value) OmniCC:SetMinEffectDuration(value) end
	s.GetSavedValue = function(self) return OmniCC:GetMinEffectDuration() end
	s.GetFormattedText = function(self, value) return SECONDS_ABBR:format(value) end

	s.tooltip = L.MinEffectDurationTip

	return s
end

do
	--now featuring a lot of hacks to get around me wanting to just use a slider to control this setting
	--but also not wanting to have an actual 0 value on the slider
	local MINUTES_ABBR = '%.1f' .. (MINUTES_ABBR:match('%%d(.+)'))
	function GeneralOptions:CreateMMSSSlider()
		local s = self:NewSlider(L.MMSSDuration, 1, 15, 0.5)
		s.SetSavedValue = function(self, value)
			if value > 1 then
				OmniCC:SetMMSSDuration(value * 60)
			else
				OmniCC:SetMMSSDuration(0)
			end
		end
		s.GetSavedValue = function(self)
			local v = OmniCC:GetMMSSDuration()
			if v > 0 then
				return v / 60
			end
			return 1
		end
		s.GetFormattedText = function(self, value)
			if value > 1 then
				return MINUTES_ABBR:format(value)
			end
			return NEVER
		end

		s.tooltip = L.MMSSDurationTip

		return s
	end
end

function GeneralOptions:CreateTenthsSlider()
	local s = self:NewSlider(L.TenthsDuration, 0, 10, 1)
	s.SetSavedValue = function(self, value)
		OmniCC:SetTenthsDuration(value)
	end
	s.GetSavedValue = function(self)
		return OmniCC:GetTenthsDuration()
	end
	s.GetFormattedText = function(self, value)
		if value > 1 then
			return SECONDS_ABBR:format(value)
		end
		return NEVER
	end

	s.tooltip = L.TenthsDurationTip

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