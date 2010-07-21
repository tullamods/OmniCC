--[[
	font.lua: the OmniCC font styles panel
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS
local BUTTON_SPACING = 6

local FilterOptions = OmniCC.OptionsPanel:New('OmniCCOptions_Filter', 'OmniCC', L.FilterSettings, L.FilterSettingsTitle)
OmniCC.FilterOptions = FilterOptions

function FilterOptions:Load()
	self:AddWidgets()
end

function FilterOptions:AddWidgets()
	--checkboxes
	local useWhitelist = self:CreateUseWhitelistCheckbox()
	useWhitelist:SetPoint('TOPLEFT', self, 'TOPLEFT', 14, -72)
	
	local useBlacklist = self:CreateUseBlacklistCheckbox()
	useBlacklist:SetPoint('TOPLEFT', useWhitelist, 'BOTTOMLEFT', 0, -BUTTON_SPACING)
	
	--add blacklist editor
	local blacklistEditor = self:CreateBlacklistEditor()
	blacklistEditor:SetPoint('TOPLEFT', useBlacklist, 'BOTTOMLEFT', 2, -16)
	blacklistEditor:SetSize(360, 284)
end


--[[ Widgets, yay! ]]--

function FilterOptions:NewCheckbox(name)
	return OmniCC.OptionsCheckButton:New(name, self)
end

--use whitelist
function FilterOptions:CreateUseWhitelistCheckbox()
	local b = self:NewCheckbox(L.UseWhitelist)
	b.OnEnableSetting = function(self, enable) OmniCC:SetUseWhitelist(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:UsingWhitelist() end
	return b
end

--use blacklist
function FilterOptions:CreateUseBlacklistCheckbox()
	local b = self:NewCheckbox(L.UseBlacklist)
	b.OnEnableSetting = function(self, enable) OmniCC:SetUseBlacklist(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:UsingBlacklist() end

	return b
end

function FilterOptions:CreateBlacklistEditor()
	local f = OmniCC.ListEditor:New(L.Blacklist, self)
	
	f.OnAddItem = function(self, value) 
		if OmniCC:AddToBlacklist(value) then
			OmniCC:ClearBlacklistCache()
			return true
		end
		return false
	end
	
	f.OnRemoveItem = function(self, value) 
		if OmniCC:RemoveFromBlacklist(value) then
			OmniCC:ClearBlacklistCache()
			return true
		end
		return false
	end
	
	f.GetItems = function(self) 
		return OmniCC:GetBlacklist() 
	end
	
	f.IsAddButtonEnabled = function(self)
		return not OmniCC:GetBlacklistIndex(self.editFrame:GetValue())
	end

	f.IsRemoveButtonEnabled = function(self)
		return OmniCC:GetBlacklistIndex(self.editFrame:GetValue())
	end

	return f
end

FilterOptions:Load()