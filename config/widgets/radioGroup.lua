local _, Addon = ...

-- a clickable radio button
local RadioButton = LibStub('Classy-1.0'):New('CheckButton')

function RadioButton:New(value, title, parent)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent))
	b.value = value
	b:SetScript('OnClick', b.OnClick)
    b:SetScript('OnEnter', b.OnEnter)
    b:SetScript('OnLeave', b.OnLeave)

	local bg = b:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints(b)

    b.bg = bg
    b:OnLeave()

	local text = b:CreateFontString(nil, 'OVERLAY')
	text:SetFontObject('GameFontNormalLarge')
	text:SetPoint('CENTER')
	text:SetText(title or value)

	b:SetFontString(text)
	b:SetNormalFontObject('GameFontNormalLarge')
	b:SetHighlightFontObject('GameFontHighlightLarge')

	local ct = b:CreateTexture(nil, 'ARTWORK')
	ct:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
	ct:SetSize(24, 24)
	ct:SetPoint('RIGHT', text, 'LEFT', -5, 0)
	b:SetCheckedTexture(ct)

	return b
end

function RadioButton:OnClick()
	self:GetParent():Select(self.value)
end

function RadioButton:OnEnter()
    self.bg:SetColorTexture(1, 1, 1, 0.25)
end

function RadioButton:OnLeave()
    self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.6)
end

Addon.RadioButton = RadioButton


-- a container for radio buttons
local RadioGroup = LibStub('Classy-1.0'):New('Frame')

RadioGroup.columns = 3
RadioGroup.spacing = 2

function RadioGroup:New(title, parent)
	local f = self:Bind(Addon.Group:New(title, parent))

	f.buttons = {}
	f:SetScript('OnShow', f.OnShow)

	return f
end

-- frame events
function RadioGroup:OnShow()
	self:Layout()
	self:UpdateValue()
end

function RadioGroup:OnSelect(value)
	error(format('Undefined method: %s:OnSelect(value)', self:GetName()))
end

function RadioGroup:AddItem(value, text)
	table.insert(self.buttons, RadioButton:New(value, text or value, self))
	if self:IsVisible() then
		self:Layout()
	end
end

-- update methods
function RadioGroup:UpdateValue()
	self:Select(self:GetSelectedValue(), true)
end

function RadioGroup:Select(value, noUpdate)
	if (not noUpdate) and value ~= self:GetSelectedValue() then
		self:OnSelect(value)
	end

	for _, b in pairs(self.buttons) do
		b:SetChecked(b.value == value)
	end
end

function RadioGroup:SetColumns(columns)
	self.columns = columns
	if self:IsVisible() then
		self:Layout()
	end
end

function RadioGroup:Layout()
	local spacing = self.spacing or 0
	local cols = self.columns or 1
	local rows = max(#self.buttons / cols)
	local w, h = (self:GetWidth()-16) / cols, (self:GetHeight()-16) / rows
	local index = 0

	for row = 1, rows do
		for col = 1, cols do
			index = index + 1
			local b = self.buttons[index]
			if b then
				b:SetSize(w - spacing, h - spacing)
				b:SetPoint('TOPLEFT', w*(col-1) + 8, -(h*(row-1) + 8))
			end
		end
	end
end

-- accessors
function RadioGroup:GetSelectedValue()
	error(format('Undefined method: %s:GetSelectedValue()', self:GetName()))
end

-- exports
Addon.RadioGroup = RadioGroup