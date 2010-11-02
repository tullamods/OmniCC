--[[
	font.lua: the OmniCC font styles panel
--]]

local OmniCCOptions = OmniCCOptions
local OmniCC = OmniCC
local Timer = OmniCC.Timer
local L = OMNICC_LOCALS
local LSM = LibStub('LibSharedMedia-3.0')

local BUTTON_SPACING = 24

local FontOptions = CreateFrame('Frame', 'OmniCCOptions_Font')
FontOptions:SetScript('OnShow', function(self) self:AddWidgets(); self:SetScript('OnShow', nil) end)

function FontOptions:GetGroupSets()
	return OmniCCOptions:GetGroupSets()
end

--[[ Events ]]--

function FontOptions:AddWidgets()
	--add font selector
	local fontSelector = self:CreateFontSelector(L.Font)
	fontSelector:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20)
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
	local parent = self
	local f = OmniCCOptions.FontSelector:New(name, self)

	f.SetSavedValue = function(self, value)
		parent:GetGroupSets().fontFace = value
		Timer:ForAllShown('UpdateText', true)
	end

	f.GetSavedValue = function(self)
		return parent:GetGroupSets().fontFace
	end

	return f
end


--[[ Color Picker ]]--

function FontOptions:CreateColorPickerFrame(name)
	local parent = self

	local f = OmniCCOptions.Group:New(name, parent)
	f.GetGroupSets = function(self) return parent:GetGroupSets() end

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
	local s = OmniCCOptions.Slider:New(name, self, low, high, step)
	return s
end

function FontOptions:CreateFontSizeSlider()
	local parent = self
	local s = self:NewSlider(L.FontSize, 2, 48, 1)

	s.SetSavedValue = function(self, value)
		parent:GetGroupSets().fontSize = value
		Timer:ForAllShown('UpdateText', true)
	end

	s.GetSavedValue = function(self)
		return parent:GetGroupSets().fontSize
	end

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
		local parent = self
		local s = self:NewSlider(L.FontOutline, 1, #fontOutlines, 1)

		s.SetSavedValue = function(self, value)
			parent:GetGroupSets().fontOutline = toOutline(value)
			Timer:ForAllShown('UpdateText', true)
		end

		s.GetSavedValue = function(self)
			return toIndex(parent:GetGroupSets().fontOutline)
		end

		s.GetFormattedText = function(self, value)
			return L['Outline_' .. toOutline(value or 1)]
		end

		s.tooltip = L.FontOutlineTip

		return s
	end
end


--[[ color picker ]]--


function FontOptions:CreateStylePicker(timePeriod, parent)
	local slider = OmniCCOptions.Slider:New(L['Color_' .. timePeriod], parent, 0.5, 2, 0.05)

	 _G[slider:GetName() .. 'Text']:Hide()

	slider.SetSavedValue = function(self, value)
		parent:GetGroupSets().styles[timePeriod].scale = value
		Timer:ForAllShown('UpdateText', true)
	end

	slider.GetSavedValue = function(self)
		return parent:GetGroupSets().styles[timePeriod].scale
	end

	slider.GetFormattedText = function(self, value)
		return floor(value * 100 + 0.5) .. '%'
	end

	--color picker
	local picker = OmniCCOptions.ColorSelector:New(L['Color_' .. timePeriod], slider, true)
	picker:SetPoint('BOTTOMLEFT', slider, 'TOPLEFT')

	picker.OnSetColor = function(self, r, g, b, a)
		local style = parent:GetGroupSets().styles[timePeriod]
		style.r, style.g, style.b, style.a = r, g, b, a
		Timer:ForAllShown('UpdateText', true)
	end

	picker.GetColor = function(self)
		local style = parent:GetGroupSets().styles[timePeriod]
		return style.r, style.g, style.b, style.a
	end

	picker.text:ClearAllPoints()
	picker.text:SetPoint('BOTTOMLEFT', picker, 'BOTTOMRIGHT', 4, 0)

	return slider
end


--[[ Load the thing ]]--

OmniCCOptions:AddTab('font', L.FontSettings, FontOptions)