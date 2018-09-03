local AddonName = ...
local Addon = CreateFrame("Frame", AddonName, _G.InterfaceOptionsFrame)
local L = _G.OMNICC_LOCALS
local CONFIG_ADDON_NAME = AddonName .. "_Config"

function Addon:Startup()
	self:SetupCommands()

	self:SetScript("OnEvent", function(f, event, ...)
		f[event](f, event, ...)
	end)

	self:SetScript("OnShow", function(f)
		LoadAddOn(CONFIG_ADDON_NAME)
		f:SetScript("OnShow", nil)
	end)

	self:RegisterEvent("VARIABLES_LOADED")
end

function Addon:SetupCommands()
	_G[("SLASH_%s1"):format(AddonName)] = ("/%s"):format(AddonName:lower())

	_G[("SLASH_%s2"):format(AddonName)] = "/occ"

	_G.SlashCmdList[AddonName] = function(...)
		if ... == "version" then
			print(L.Version:format(self:GetVersion()))
		elseif self.ShowOptionsMenu or LoadAddOn(CONFIG_ADDON_NAME) then
			if type(self.ShowOptionsMenu) == "function" then
				self:ShowOptionsMenu()
			end
		end
	end
end

function Addon:SetupEvents()
	self:UnregisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Events
function Addon:PLAYER_ENTERING_WORLD()
	self.Timer:ForActive("Update")
end

function Addon:VARIABLES_LOADED()
	self:StartupSettings()
	self:SetupEvents()
end

-- Utility
function Addon:New(name, module)
	self[name] = module or LibStub("Classy-1.0"):New("Frame")

	return self[name]
end

function Addon:CreateHiddenFrame(...)
	local f = CreateFrame(...)

	f:Hide()

	return f
end

function Addon:GetButtonIcon(frame)
	if frame then
		local icon = frame.icon
		if type(icon) == "table" and icon.GetTexture then
			return icon
		end

		local name = frame:GetName()
		if name then
			icon = _G[name .. "Icon"] or _G[name .. "IconTexture"]

			if type(icon) == "table" and icon.GetTexture then
				return icon
			end
		end
	end
end

Addon:Startup()
