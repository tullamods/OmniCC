--[[
	font.lua: the OmniCC font styles panel
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS
local LSM = LibStub('LibSharedMedia-3.0')
local SPACING = 6

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
	fontSelector:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -16, 96)	
	
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

--[[ Load the thing ]]--

FontOptions:Load()