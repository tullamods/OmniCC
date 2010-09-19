--[[
	dropdown.lua
		A bagnon dropdown menu
--]]

local OptionsCheckButton = LibStub('Classy-1.0'):New('CheckButton')
OmniCC.OptionsCheckButton = OptionsCheckButton

function OptionsCheckButton:New(name, parent)
	local b = self:Bind(CreateFrame('CheckButton', parent:GetName() .. name, parent, 'InterfaceOptionsCheckButtonTemplate'))
	_G[b:GetName() .. 'Text']:SetText(name)

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnShow', b.OnShow)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)

	return b
end

function OptionsCheckButton:SetDisabled(disable)
	if disable then
		self:Disable()
		_G[self:GetName() .. 'Text']:SetFontObject('GameFontDisable')
	else
		self:Enable()
		_G[self:GetName() .. 'Text']:SetFontObject('GameFontHighlight')
	end
end

function OptionsCheckButton:OnClick()
	self:EnableSetting(self:GetChecked())
end

function OptionsCheckButton:OnShow()
	self:UpdateChecked()
end

function OptionsCheckButton:OnEnter()
	if not GameTooltip:IsOwned(self) and self.tooltip then
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip:SetText(self.tooltip)
	end
end

function OptionsCheckButton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function OptionsCheckButton:UpdateChecked()
	self:SetChecked(self:IsSettingEnabled())
end

function OptionsCheckButton:EnableSetting(enable)
	self:OnEnableSetting(enable and true or false)
	self:UpdateChecked()
end

function OptionsCheckButton:OnEnableSetting(enable)
	assert(false, 'Hey you forgot to implement OnEnableSetting for ' .. self:GetName())
end

function OptionsCheckButton:IsSettingEnabled()
	assert(false, 'Hey you forgot to implement IsSettingEnabled for ' .. self:GetName())
end