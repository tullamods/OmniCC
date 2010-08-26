--[[
	fontSelector.lua
		Displays a list of fonts registered with LibSharedMedia for the user to pick from
--]]


local LSM = LibStub('LibSharedMedia-3.0')
local Classy = LibStub('Classy-1.0')
local LSM_FONT = LSM.MediaType.FONT
local PADDING = 2
local FONT_HEIGHT = 18
local BUTTON_HEIGHT = 36
local SCROLL_STEP = BUTTON_HEIGHT + PADDING

local function getFontIDs()
	return LSM:List(LSM_FONT)
end

local function fetchFont(fontId)
	if fontId and LSM:IsValid(LSM_FONT, fontId) then
		return LSM:Fetch(LSM_FONT, fontId)
	end
	return LSM:GetDefault(LSM_FONT)
end

local fontTester = nil
local function isValidFont(font)
	if not fontTester then
		fontTester = CreateFont('OmniCCConfig_FontTester')
	end
	return fontTester:SetFont(font, FONT_HEIGHT, 'OUTLINE')
end

--[[
	The Font Button
--]]

local FontButton = Classy:New('CheckButton')

function FontButton:New(parent, useAltColor)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent))
	b:SetHeight(BUTTON_HEIGHT)
	b:SetScript('OnClick', b.OnClick)

	local bg = b:CreateTexture(nil, 'BACKGROUND')
	if useAltColor then
		bg:SetTexture(0.2, 0.2, 0.2, 0.6)
	else
		bg:SetTexture(0.3, 0.3, 0.3, 0.6)
	end
	bg:SetAllPoints(b)

	local text = b:CreateFontString(nil, 'ARTWORK')
	text:SetPoint('BOTTOM', 0, PADDING)
	b:SetFontString(text)
	b:SetNormalFontObject('GameFontNormalSmall')
	b:SetHighlightFontObject('GameFontHighlightSmall')

	local fontText = b:CreateFontString(nil, 'ARTWORK')
	fontText:SetPoint('TOPLEFT', 4, -2)
	fontText:SetPoint('TOPRIGHT', -4, -2)
	fontText:SetPoint('BOTTOM', text, 'TOP', 0, 4)
	b.fontText = fontText

	local ht = b:CreateTexture(nil, 'BACKGROUND')
	ht:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
	ht:SetVertexColor(0.196, 0.388, 0.8)
	ht:SetBlendMode('ADD')
	ht:SetAllPoints(b)
	b:SetHighlightTexture(ht)

	local ct = b:CreateTexture(nil, 'OVERLAY')
	ct:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
	ct:SetSize(24, 24)
	ct:SetPoint('LEFT')
	b:SetCheckedTexture(ct)

	return b
end

function FontButton:SetFontFace(font)
	self.fontText:SetFont(font, FONT_HEIGHT, 'OUTLINE')
	self.fontText:SetText('1234567890')
	
	return self
end

function FontButton:GetFontFace()
	return (self.fontText:GetFont())
end


--[[
	The Font Selector
--]]

local FontSelector = Classy:New('Frame')
OmniCC.FontSelector = FontSelector

function FontSelector:New(title, parent)
	local f = self:Bind(CreateFrame('Frame', parent:GetName() .. title, parent, 'OptionsBoxTemplate'))
	f:SetScript('OnShow', f.Load)
	f:SetBackdropBorderColor(0.4, 0.4, 0.4)
	f:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	_G[f:GetName() .. 'Title']:SetText(title)

	return f
end

do
	local function scrollFrame_OnSizeChanged(self)
		local scrollChild = self:GetParent().scrollChild
		scrollChild:SetWidth(self:GetWidth())
	
		local scrollBar  = self:GetParent().scrollBar
		local scrollMax = max(scrollChild:GetHeight() - self:GetHeight(), 0)
		scrollBar:SetMinMaxValues(0, scrollMax)
		scrollBar:SetValue(0)
	end
	
	local function scrollFrame_OnMouseWheel(self, delta)
		local scrollBar = self:GetParent().scrollBar
		local min, max = scrollBar:GetMinMaxValues()
		local current = scrollBar:GetValue()

		if IsShiftKeyDown() and (delta > 0) then
		   scrollBar:SetValue(min)
		elseif IsShiftKeyDown() and (delta < 0) then
		   scrollBar:SetValue(max)
		elseif (delta < 0) and (current < max) then
		   scrollBar:SetValue(current + SCROLL_STEP)
		elseif (delta > 0) and (current > 1) then
		   scrollBar:SetValue(current - SCROLL_STEP)
		end
	end

	function FontSelector:CreateScrollFrame()
		local scrollFrame = CreateFrame('ScrollFrame', nil, self)
		scrollFrame:EnableMouseWheel(true)
		scrollFrame:SetScript('OnSizeChanged', scrollFrame_OnSizeChanged)
		scrollFrame:SetScript('OnMouseWheel', scrollFrame_OnMouseWheel)

		return scrollFrame
	end
end

do
	local function scrollBar_OnValueChanged(self, value)
		self:GetParent().scrollFrame:SetVerticalScroll(value)
	end

	function FontSelector:CreateScrollBar()
		local scrollBar = CreateFrame('Slider', nil, self)
		scrollBar:SetOrientation('VERTICAL')
		scrollBar:SetScript('OnValueChanged', scrollBar_OnValueChanged)

		local bg = scrollBar:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(true)
		bg:SetTexture(0, 0, 0, 0.5)

		local thumb = scrollBar:CreateTexture(nil, 'OVERLAY')
		thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
		thumb:SetSize(25, 25)
		scrollBar:SetThumbTexture(thumb)

		return scrollBar
	end
end

function FontSelector:CreateScrollChild()
	local scrollChild = CreateFrame('Frame')
	local f_OnClick = function(f) self:Select(f:GetFontFace()) end
	local buttons = {}

	local i = 0
	for _, fontId in ipairs(getFontIDs()) do
		local font = fetchFont(fontId)
		if isValidFont(font) then
			i = i + 1
			local f = FontButton:New(scrollChild, i % 4 == 0 or (i + 1) % 4 == 0)
			f:SetFontFace(font):SetText(fontId)
			f:SetScript('OnClick', f_OnClick)

			if i == 1 then
				f:SetPoint('TOPLEFT')
				f:SetPoint('TOPRIGHT', scrollChild, 'TOP', -PADDING/2, 0)
			elseif i == 2 then
				f:SetPoint('TOPLEFT', scrollChild, 'TOP', PADDING/2, 0)
				f:SetPoint('TOPRIGHT')
			else
				f:SetPoint('TOPLEFT', buttons[i-2], 'BOTTOMLEFT', 0, -PADDING)
				f:SetPoint('TOPRIGHT', buttons[i-2], 'BOTTOMRIGHT', 0, -PADDING)
			end

			table.insert(buttons, f)
		end
	end

	scrollChild:SetWidth(self.scrollFrame:GetWidth())
	scrollChild:SetHeight(ceil(#buttons / 2) * (BUTTON_HEIGHT + PADDING) - PADDING)

	self.buttons = buttons
	return scrollChild
end


function FontSelector:OnShow()
	self:UpdateSelected()
end

function FontSelector:Load()
	local scrollFrame = self:CreateScrollFrame()
	scrollFrame:SetPoint('TOPLEFT', 8, -8)
	self.scrollFrame = scrollFrame

	local scrollChild = self:CreateScrollChild()
	scrollFrame:SetScrollChild(scrollChild)
	self.scrollChild = scrollChild

	local scrollBar = self:CreateScrollBar()
	scrollBar:SetPoint('TOPRIGHT', -8, -8)
	scrollBar:SetPoint('BOTTOMRIGHT', -8, 6)
	scrollBar:SetWidth(16)
	self.scrollBar = scrollBar

	scrollFrame:SetSize(346, 150)

	self:SetScript('OnShow', self.OnShow)
	self:OnShow()
end

function FontSelector:Select(value)
	self:SetSavedValue(value)
	self:UpdateSelected()
end

function FontSelector:SetSavedValue(value)
	assert(false, 'Hey, you forgot to set SetSavedValue for ' .. self:GetName())
end

function FontSelector:GetSavedValue()
	assert(false, 'Hey, you forgot to set GetSavedValue for ' .. self:GetName())
end

function FontSelector:UpdateSelected()
	local selectedValue = self:GetSavedValue()
	for i, button in pairs(self.buttons) do
		button:SetChecked(button:GetFontFace() == selectedValue)
	end
end