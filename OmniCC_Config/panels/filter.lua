--[[
	Filter.lua, the OmniCC blacklist panel
--]]

local OmniCC = OmniCC
local L = OMNICC_LOCALS

local FilterOptions = OmniCC.OptionsPanel:New('OmniCCOptions_Filter', 'OmniCC', L.FilterSettings, L.FilterSettingsTitle)
OmniCC.FilterOptions = FilterOptions

function FilterOptions:Load()
	self:AddWidgets()
end

function FilterOptions:AddWidgets()
	--checkboxes
	local useBlacklist = self:CreateUseBlacklistCheckbox()
	useBlacklist:SetPoint('TOPLEFT', self, 'TOPLEFT', 14, -60)

	--add blacklist editor
	local blacklistEditor = self:CreateBlacklistEditor()
	blacklistEditor:SetPoint('TOPLEFT', useBlacklist, 'BOTTOMLEFT', 2, -18)
	blacklistEditor:SetSize(360, 284)

	--add framestack toggle
	local frameStack = self:CreateFrameStackButton()
	frameStack:SetPoint('TOPLEFT', blacklistEditor, 'BOTTOMLEFT', 0, -6)
end


--[[ Widgets, yay! ]]--

function FilterOptions:NewCheckbox(name)
	return OmniCC.OptionsCheckButton:New(name, self)
end

--use blacklist
function FilterOptions:CreateUseBlacklistCheckbox()
	local b = self:NewCheckbox(L.UseBlacklist)
	b.OnEnableSetting = function(self, enable) OmniCC:SetUseBlacklist(enable) end
	b.IsSettingEnabled = function(self) return OmniCC:UsingBlacklist() end
	b.tooltip = L.UseBlacklistTip

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

--framestack toggle
function FilterOptions:CreateFrameStackButton()
	local b = CreateFrame('Button', self:GetName() .. 'FrameStack', self, 'UIPanelButtonTemplate')
	b:SetSize(140, 21)
	b:SetText(DEBUG_FRAMESTACK)
	b:SetScript('OnClick', function(self)
		UIParentLoadAddOn("Blizzard_DebugTools")
		FrameStackTooltip_Toggle()
	end)

	b.tooltip = L.FrameStackTip

	b:SetScript('OnEnter', function(self)
		if not GameTooltip:IsOwned(self)  and self.tooltip then
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetText(self.tooltip)
		end
	end)

	b:SetScript('OnLeave', function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	return b
end



FilterOptions:Load()