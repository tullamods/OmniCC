--[[
	font.lua: the OmniCC font styles panel
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS
local LSM = LibStub('LibSharedMedia-3.0')
local BUTTON_SPACING = 6

local FontOptions = OmniCC.OptionsPanel:New('OmniCCOptions_Font', 'OmniCC', L.FontSettings, L.FontSettingsTitle)
FontOptions:SetScript('OnShow', function(self) OmniCC:SetUseDynamicColor(true) end)
FontOptions:SetScript('OnHide', function(self) OmniCC:SetUseDynamicColor(false) end)
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
	local colorPicker = self:CreateColorPickerFrame(L.Color)
	colorPicker:SetPoint('TOPLEFT', fontSelector, 'BOTTOMLEFT', 0, -20)
	colorPicker:SetPoint('TOPRIGHT', fontSelector, 'BOTTOMRIGHT', 0, -20)
	colorPicker:SetHeight(60)

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
	f.SetSavedValue = function(self, value) OmniCC:SetFontID(value) end
	f.GetSavedValue = function(self) return OmniCC:GetFontID() end
	return f
end

--[[ Color Picker ]]--

function FontOptions:CreateColorPickerFrame(name)
	local f = self:Bind(CreateFrame('Frame', self:GetName() .. name, self, 'OptionsBoxTemplate'))
	f:SetBackdropBorderColor(0.4, 0.4, 0.4)
	f:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	_G[f:GetName() .. 'Title']:SetText(name)

	local soon = self:CreateColorPicker('soon', f)
	soon:SetPoint('TOPLEFT', 8, -8)

	local seconds = self:CreateColorPicker('seconds', f)
	seconds:SetPoint('TOPLEFT', f, 'TOP', 0, -8)

	local minutes = self:CreateColorPicker('minutes', f)
	minutes:SetPoint('TOPLEFT', soon, 'BOTTOMLEFT', 0, -BUTTON_SPACING)

	local hours = self:CreateColorPicker('hours', f)
	hours:SetPoint('TOPLEFT', seconds, 'BOTTOMLEFT', 0, -BUTTON_SPACING)
	
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
		return s
	end
end

--[[ color picker ]]--

function FontOptions:CreateColorPicker(timePeriod, parent)
	local picker = OmniCC.OptionsColorSelector:New(L['Color_' .. timePeriod], parent, false)

	picker.OnSetColor = function(self, r, g, b, a)
		OmniCC:SetColor(timePeriod, r, g, b)
	end

	picker.GetColor = function(self)
		local r, g, b = OmniCC:GetColor(timePeriod)
		return r, g, b, 1
	end

	return picker
end

--[[ Load the thing ]]--

FontOptions:Load()