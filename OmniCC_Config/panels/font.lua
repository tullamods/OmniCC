--[[
	font.lua: the OmniCC font styles panel
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS
local LSM = LibStub('LibSharedMedia-3.0')
local BUTTON_SPACING = 24

local FontOptions = OmniCC.OptionsPanel:New('OmniCCOptions_Font', 'OmniCC', L.FontSettings, L.FontSettingsTitle)
OmniCC.FontOptions = FontOptions


--[[ Events ]]--

function FontOptions:Load()
	self:AddWidgets()
end

function FontOptions:AddWidgets()
	--add font selector
	local fontSelector = self:CreateFontSelector(L.Font)
	fontSelector:SetPoint('TOPLEFT', self, 'TOPLEFT', 16, -72)
	fontSelector:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 96*2)

	--add color picker
	local colorPicker = self:CreateColorPickerFrame(L.ColorAndScale)
	colorPicker:SetPoint('TOPLEFT', fontSelector, 'BOTTOMLEFT', 0, -16)
	colorPicker:SetPoint('TOPRIGHT', fontSelector, 'BOTTOMRIGHT', 0, -16)
	colorPicker:SetHeight(20 + BUTTON_SPACING*3)

	--add font outline picker
	local outlinePicker = self:CreateFontOutlinePicker()
	outlinePicker:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 16, 10)
	outlinePicker:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 10)

	--add font size slider
	local fontSize = self:CreateFontSizeSlider()
	fontSize:SetPoint('BOTTOMLEFT', outlinePicker, 'TOPLEFT', 0, 20)
	fontSize:SetPoint('BOTTOMRIGHT', outlinePicker, 'TOPRIGHT', 0, 20)
end


--[[ Font Selector ]]--

function FontOptions:CreateFontSelector(name)
	local f = OmniCC.FontSelector:New(name, self)
	f.SetSavedValue = function(self, value) OmniCC:SetFontFace(value) end
	f.GetSavedValue = function(self) return OmniCC:GetFontFace() end
	return f
end


--[[ Color Picker ]]--

function FontOptions:CreateColorPickerFrame(name)
	local f = self:Bind(CreateFrame('Frame', self:GetName() .. name, self, 'OptionsBoxTemplate'))
	f:SetBackdropBorderColor(0.4, 0.4, 0.4)
	f:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	_G[f:GetName() .. 'Title']:SetText(name)

	local soon = self:CreateStylePicker('soon', f)
	soon:SetPoint('TOPLEFT', 8, -(BUTTON_SPACING + 4))
	soon:SetPoint('TOPRIGHT', f, 'TOP', -4, -(BUTTON_SPACING + 4))

	local seconds = self:CreateStylePicker('seconds', f)
	seconds:SetPoint('TOPLEFT', f, 'TOP', 4,  -(BUTTON_SPACING + 4))
	seconds:SetPoint('TOPRIGHT', -8, -(BUTTON_SPACING + 4))

	local minutes = self:CreateStylePicker('minutes', f)
	minutes:SetPoint('TOPLEFT', soon, 'BOTTOMLEFT', 0, -BUTTON_SPACING)
	minutes:SetPoint('TOPRIGHT', soon, 'BOTTOMRIGHT', 0, -BUTTON_SPACING)

	local hours = self:CreateStylePicker('hours', f)
	hours:SetPoint('TOPLEFT', seconds, 'BOTTOMLEFT', 0, -BUTTON_SPACING)
	hours:SetPoint('TOPRIGHT', seconds, 'BOTTOMRIGHT', 0, -BUTTON_SPACING)

	return f
end


--[[ Sliders ]]--

function FontOptions:NewSlider(name, low, high, step)
	local s = OmniCC.OptionsSlider:New(name, self, low, high, step)
	return s
end

function FontOptions:CreateFontSizeSlider()
	local s = self:NewSlider(L.FontSize, 2, 48, 1)
	s.SetSavedValue = function(self, value) OmniCC:SetFontSize(value) end
	s.GetSavedValue = function(self) return OmniCC:GetFontSize() end
	s.tooltip = L.FontSizeTip
	return s
end

do
	local fontOutlines = {'NONE', 'OUTLINE', 'THICKOUTLINE'}
	local function toIndex(fontOutline)
		for i, outline in pairs(fontOutlines) do
			if outline == fontOutline then
				return i
			end
		end
	end

	local function toOutline(index)
		return fontOutlines[index]
	end

	function FontOptions:CreateFontOutlinePicker()
		local s = self:NewSlider(L.FontOutline, 1, #fontOutlines, 1)
		s.SetSavedValue = function(self, value) OmniCC:SetFontOutline(toOutline(value)) end
		s.GetSavedValue = function(self) return toIndex(OmniCC:GetFontOutline()) end
		s.GetFormattedText = function(self, value) return L['Outline_' .. toOutline(value or 1)] end
		s.tooltip = L.FontOutlineTip

		return s
	end
end


--[[ color picker ]]--


function FontOptions:CreateStylePicker(timePeriod, parent)
	--scale slider
	local slider = OmniCC.OptionsSlider:New(L['Color_' .. timePeriod], parent, 0.5, 2, 0.05)
	 _G[slider:GetName() .. 'Text']:Hide()

	slider.SetSavedValue = function(self, value)
		OmniCC:SetPeriodScale(timePeriod, value)
	end

	slider.GetSavedValue = function(self)
		return OmniCC:GetPeriodScale(timePeriod)
	end

	slider.GetFormattedText = function(self, value)
		return floor(value * 100 + 0.5) .. '%'
	end

	--color picker
	local picker = OmniCC.OptionsColorSelector:New(L['Color_' .. timePeriod], slider, true)
	picker:SetPoint('BOTTOMLEFT', slider, 'TOPLEFT')

	picker.OnSetColor = function(self, r, g, b, a)
		OmniCC:SetPeriodColor(timePeriod, r, g, b, a)
	end

	picker.GetColor = function(self)
		return OmniCC:GetPeriodColor(timePeriod)
	end

	picker.text:ClearAllPoints()
	picker.text:SetPoint('BOTTOMLEFT', picker, 'BOTTOMRIGHT', 4, 0)

	return slider
end


--[[ Load the thing ]]--

FontOptions:Load()