--[[
	General configuration settings for OmniCC
--]]

local OmniCCOptions = OmniCCOptions
local OmniCC = OmniCC
local L = OMNICC_LOCALS

--fun constants!
local BUTTON_SPACING = 0
local SLIDER_SPACING = 24

local GeneralOptions = CreateFrame('Frame', 'OmniCCOptions_General')
GeneralOptions:SetScript('OnShow', function(self)
	self:AddWidgets()
	self:SetScript('OnShow', nil)
end)


--[[
	Startup
--]]

function GeneralOptions:GetGroupSets()
	return OmniCCOptions:GetGroupSets()
end


--[[
	Widgets
--]]

function GeneralOptions:AddWidgets()
	local enableCDText = self:CreateEnableTextCheckbox()
	enableCDText:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -10)
	
	local scaleText = self:CreateScaleTextCheckbox()
	scaleText:SetPoint('TOPLEFT', enableCDText, 'BOTTOMLEFT', 0, -BUTTON_SPACING)

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
	return OmniCCOptions.CheckButton:New(name, self)
end

--scale text
function GeneralOptions:CreateEnableTextCheckbox()
	local parent = self
	local b = self:NewCheckbox('Enable cooldown text')

	b.OnEnableSetting = function(self, enable)
		parent:GetGroupSets().enabled = enable or false
	end

	b.IsSettingEnabled = function(self)
		return parent:GetGroupSets().enabled
	end

	b.tooltip = L.EnableTextTip

	return b
end

--scale text
function GeneralOptions:CreateScaleTextCheckbox()
	local parent = self
	local b = self:NewCheckbox(L.ScaleText)

	b.OnEnableSetting = function(self, enable)
		parent:GetGroupSets().scaleText = enable or false
	end

	b.IsSettingEnabled = function(self)
		return parent:GetGroupSets().scaleText
	end

	b.tooltip = L.ScaleTextTip

	return b
end

--show cooldown models
function GeneralOptions:CreateShowCooldownModelsCheckbox()
	local parent = self
	local b = self:NewCheckbox(L.ShowCooldownModels)

	b.OnEnableSetting = function(self, enable)
		parent:GetGroupSets().showCooldownModels = enable and true or false
	end

	b.IsSettingEnabled = function(self)
		return parent:GetGroupSets().showCooldownModels
	end

	b.tooltip = L.ShowCooldownModelsTip

	return b
end

--[[ Sliders ]]--

function GeneralOptions:NewSlider(name, low, high, step)
	local s = OmniCCOptions.Slider:New(name, self, low, high, step)
	s:SetHeight(s:GetHeight() + 2)

	return s
end

do
	local SECONDS_ABBR = '%.1f' .. (SECONDS_ABBR:match('%%d(.+)'))
	function GeneralOptions:CreateMinDurationSlider()
		local parent = self
		local s = self:NewSlider(L.MinDuration, 0, 30, 0.5)

		s.SetSavedValue = function(self, value)
			parent:GetGroupSets().minDuration = value
		end

		s.GetSavedValue = function(self)
			return parent:GetGroupSets().minDuration or 0
		end

		s.GetFormattedText = function(self, value)
			return SECONDS_ABBR:format(value)
		end

		s.tooltip = L.MinDurationTip

		return s
	end
end

function GeneralOptions:CreateMinFontSizeSlider()
	local parent = self
	local s = self:NewSlider(L.MinFontSize, 2, 64, 1)

	s.SetSavedValue = function(self, value)
		parent:GetGroupSets().minFontSize = value
	end

	s.GetSavedValue = function(self)
		return parent:GetGroupSets().minFontSize or 2
	end

	s.tooltip = L.MinFontSizeTip

	return s
end

function GeneralOptions:CreateMinEffectDurationSlider()
	local parent = self
	local s = self:NewSlider(L.MinEffectDuration, 0, 60, 1)

	s.SetSavedValue = function(self, value)
		parent:GetGroupSets().minEffectDuration = value
	end

	s.GetSavedValue = function(self)
		return parent:GetGroupSets().minEffectDuraton or 0
	end

	s.GetFormattedText = function(self, value)
		return SECONDS_ABBR:format(value)
	end

	s.tooltip = L.MinEffectDurationTip

	return s
end

do
	local MINUTES_ABBR = '%.1f' .. (MINUTES_ABBR:match('%%d(.+)'))
	function GeneralOptions:CreateMMSSSlider()
		local parent = self
		local s = self:NewSlider(L.MMSSDuration, 1, 15, 0.5)

		s.SetSavedValue = function(self, value)
			parent:GetGroupSets().mmSSDuration = value * 60
		end

		s.GetSavedValue = function(self)
			return (parent:GetGroupSets().mmSSDuration or 0) / 60
		end

		s.GetFormattedText = function(self, value)
			if value == 1 then
				return NEVER
			else
				return MINUTES_ABBR:format(value)
			end
		end

		s.tooltip = L.MMSSDurationTip

		return s
	end
end

function GeneralOptions:CreateTenthsSlider()
	local parent = self
	local s = self:NewSlider(L.TenthsDuration, 0, 10, 1)

	s.SetSavedValue = function(self, value)
		parent:GetGroupSets().tenthsDuration = value
	end

	s.GetSavedValue = function(self)
		return parent:GetGroupSets().tenthsDuration or 0
	end

	s.GetFormattedText = function(self, value)
		if value == 0 then
			return NEVER
		else
			return SECONDS_ABBR:format(value)
		end
	end

	s.tooltip = L.TenthsDurationTip

	return s
end



--[[ Dropdown ]]--

function GeneralOptions:CreateFinishEffectPicker()
	local parent = self
	local dd = OmniCCOptions.Dropdown:New(L.FinishEffect, self, 120)

	dd.Initialize = function()
		dd:AddItem(NONE, 'none')

		local effects = OmniCC:ForEachEffect(function(effect) return {effect.name, effect.id} end)
		table.sort(effects, function(e1, e2) return e1[1] < e2[1] end)

		for n, v in ipairs(effects) do
			dd:AddItem(unpack(v))
		end
	end

	dd.SetSavedValue = function(self, value)
		parent:GetGroupSets().effect = value
	end

	dd.GetSavedValue = function(self)
		return parent:GetGroupSets().effect or 'pulse'
	end

	return dd
end

--[[ Load the thing ]]--

OmniCCOptions:AddTab(L.GeneralSettings, GeneralOptions)