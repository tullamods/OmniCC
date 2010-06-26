--[[
	listEditor.lua
		Displays an editable list
--]]


local PADDING = 2
local BUTTON_HEIGHT = 18
local SCROLL_STEP = BUTTON_HEIGHT + PADDING

--[[
	a list button
--]]

local ListButton = OmniCC.Classy:New('CheckButton')

function ListButton:New(parent)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent))
	b:SetHeight(BUTTON_HEIGHT)
	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnHide', b.OnHide)	
	
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

	local text = b:CreateFontString(nil, 'ARTWORK')
	text:SetPoint('LEFT', ct, 'RIGHT', 4, 0)
	b:SetFontString(text)

	b:SetNormalFontObject('GameFontNormalSmall')
	b:SetHighlightFontObject('GameFontHighlightSmall')

	return b
end

function ListButton:OnHide()
	self:SetChecked(false)
end

function ListButton:OnClick()
	self:GetParent():Select(self:GetValue())
end

function ListButton:SetValue(value)
	self:SetText(value)
end

function ListButton:GetValue()
	return self:GetText()
end


--[[
	The list panel
--]]

local ListEditor = OmniCC.Classy:New('Frame')
OmniCC.ListEditor = ListEditor

function ListEditor:New(title, parent)
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

	function ListEditor:CreateScrollFrame()
		local scrollFrame = CreateFrame('ScrollFrame', nil, self)
		scrollFrame:EnableMouseWheel(true)
		scrollFrame:SetScript('OnSizeChanged', scrollFrame_OnSizeChanged)
		scrollFrame:SetScript('OnMouseWheel', scrollFrame_OnMouseWheel)

		return scrollFrame
	end
end

do
	local function scrollBar_OnValueChanged(self, value)
		local scrollFrame = self:GetParent().scrollFrame
		scrollFrame:SetVerticalScroll(value)
	end

	function ListEditor:CreateScrollBar()
		local scrollBar = CreateFrame('Slider', nil, self)

		local bg = scrollBar:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(true)
		bg:SetTexture(0, 0, 0, 0.5)

		local thumb = scrollBar:CreateTexture(nil, 'OVERLAY')
		thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
		thumb:SetSize(25, 25)
		scrollBar:SetThumbTexture(thumb)

		scrollBar:SetOrientation('VERTICAL')

		scrollBar:SetScript('OnValueChanged', scrollBar_OnValueChanged)
		return scrollBar
	end
end

function ListEditor:CreateScrollChild()
	local scrollChild = CreateFrame('Frame')
	scrollChild:SetWidth(self.scrollFrame:GetWidth())
	self.scrollFrame:AddChild(scrollChild)

	return scrollChild
end


function ListEditor:OnShow()
	self:UpdateList()
	self:UpdateSelected()
end

function ListEditor:Load()
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
	
	self.buttons = setmetatable({}, {__index = function(t, k)
		local button = ListButton:New(scrollChild)
		if k == 1 then
			f:SetPoint('TOPLEFT')
			f:SetPoint('TOPRIGHT')
		else
			local prevButton = t[k-1]
			button:SetPoint('TOPLEFT', prevButton, 'BOTTOMLEFT', 0, -PADDING)
			button:SetPoint('TOPRIGHT', prevButton, 'BOTTOMRIGHT', 0, -PADDING)
		end	
		t[k] = button
		return button
	end})

	scrollFrame:SetSize(346, 244)

	self:SetScript('OnShow', self.OnShow)
	self:OnShow()
end

function ListEditor:UpdateList()
	local items = self:GetItems()
	
	for i, v in pairs(items) do
		local b = self.buttons[i]
		b:SetValue(v)
		b:Show()
	end

	for i = #items + 1, #self.buttons do
		self.buttons[i]:Hide()
	end

	local scrollHeight = #self.buttons * (BUTTON_HEIGHT + PADDING) - PADDING
	local scrollMax = max(scrollHeight - self.scrollFrame:GetHeight(), 0)
	
	local scrollBar = self.scrollBar
	scrollBar:SetMinMaxValues(0, scrollMax)
	scrollBar:SetValue(min(scrollMax, scrollBar:GetValue())

	self.scrollChild:SetHeight(scrollHeight)
	
	self:UpdateSelected()
end

function ListEditor:Select(index)
	self.selected = index
	self:UpdateSelected()
end

function ListEditor:UpdateSelected()
	local selectedValue = self:GetSavedValue()
	for i, button in pairs(self.buttons) do
		if button:IsShown() then
			button:SetChecked(button:GetFontID() == selectedValue)
		end
	end
end

function ListEditor:AddItem(value)
	self:OnAddItem(value)
	self:UpdateList()
end

function ListEditor:RemoveItem(value)
	self:OnRemoveItem(value)
	self:UpdateList()
end

function ListEditor:OnAddItem()
	assert(false, 'Hey, you forgot to set OnAddItem for ' .. self:GetName())
end

function ListEditor:OnRemoveItem()
	assert(false, 'Hey, you forgot to set OnRemoveItem for ' .. self:GetName())
end

function ListEditor:GetItems()
	assert(false, 'Hey, you forgot to set GetItems for ' .. self:GetName())
end