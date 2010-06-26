--[[
	font.lua: the OmniCC font styles panel
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS

local BlacklistOptions = OmniCC.OptionsPanel:New('OmniCCOptions_Blacklist', 'OmniCC', L.BlacklistSettings, L.BlacklistSettingsTitle)
OmniCC.BlacklistOptions = BlacklistOptions

function BlacklistOptions:Load()
	self:AddWidgets()
end

function BlacklistOptions:AddWidgets()
	--checkboxes
	local useBlacklist = self:CreateUseBlacklistCheckbox()
	useBlacklist:SetPoint('TOPLEFT', self, 'TOPLEFT', 14, -72)
	
	--add blacklist editor
	local blacklistEditor = self:CreateBlacklistEditor()
	blacklistEditor:SetPoint('TOPLEFT', useBlacklist, 'BOTTOMLEFT', 2, -16)
	blacklistEditor:SetSize(360, 284)
end


--[[ Widgets, yay! ]]--

function BlacklistOptions:NewCheckbox(name)
	return OmniCC.OptionsCheckButton:New(name, self)
end

--use whitelist
function BlacklistOptions:CreateUseBlacklistCheckbox()
	local b = self:NewCheckbox(L.UseBlacklist)
	b.OnEnableSetting = function(self, enable) OmniCC:SetUseBlacklist(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:UsingBlacklist() end

	return b
end

function BlacklistOptions:CreateBlacklistEditor()
	local f = OmniCC.ListEditor:New(L.Blacklist, self)
	f.OnAddItem = function(self, value) OmniCC:AddToBlacklist(value) end
	f.OnRemoveItem = function(self, value) return OmniCC:RemoveFromBlacklist(value) end
	f.GetItems = function(self) return OmniCC:GetBlacklist() end

	return f
end

BlacklistOptions:Load()