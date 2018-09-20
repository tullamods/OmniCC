local ADDON_NAME = ...
local CONFIG_ADDON_NAME = ADDON_NAME .. "_Config"
local L = _G.OMNICC_LOCALS

local Addon = CreateFrame("Frame", ADDON_NAME, _G.InterfaceOptionsFrame)

function Addon:Startup()
	self:SetupCommands()

	self:SetScript("OnEvent", function(f, event, ...)
		f[event](f, event, ...)
	end)

	self:SetScript("OnShow", function(f)
		LoadAddOn(CONFIG_ADDON_NAME)
		f:SetScript("OnShow", nil)
	end)

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_LOGOUT")
end

function Addon:SetupCommands()
	_G[("SLASH_%s1"):format(ADDON_NAME)] = ("/%s"):format(ADDON_NAME:lower())

	_G[("SLASH_%s2"):format(ADDON_NAME)] = "/occ"

	_G.SlashCmdList[ADDON_NAME] = function(...)
		if ... == "version" then
			print(L.Version:format(self:GetVersion()))
		elseif self.ShowOptionsMenu or LoadAddOn(CONFIG_ADDON_NAME) then
			if type(self.ShowOptionsMenu) == "function" then
				self:ShowOptionsMenu()
			end
		end
	end
end

function Addon:SetupHooks()
	local Display = self.Display
	local GetSpellCooldown = _G.GetSpellCooldown
	local GCD_SPELL_ID = 61304

	-- used to keep track of active cooldowns,
	-- and the displays associated with them
	local active = {}

	-- used to keep track of cooldowns that we've hooked
	local hooked = {}

	local cooldown_ShowTimer, cooldown_HideTimer

	local function cooldown_OnSetCooldown(cooldown, start, duration)
        if cooldown.noCooldownCount or cooldown:IsForbidden() then
            return
		end

		start = start or 0
		if start == 0 then
			cooldown_HideTimer(cooldown)
			return
		end

		duration = duration or 0
		if duration == 0 then
			cooldown_HideTimer(cooldown)
			return
		end

		-- stop timers replaced by global cooldown
		local gcdStart, gcdDuration = GetSpellCooldown(GCD_SPELL_ID)
        if start == gcdStart and duration == gcdDuration then
			cooldown_HideTimer(cooldown)
		else
			cooldown_ShowTimer(cooldown, duration)
		end
	end

	local function cooldown_OnSetCooldownDuration(cooldown, duration)
        if cooldown.noCooldownCount or cooldown:IsForbidden() then
            return
		end

		duration = duration or 0

		if duration > 0 then
			cooldown_ShowTimer(cooldown, duration)
		else
			cooldown_HideTimer(cooldown)
		end
	end

	local function cooldown_OnSetDisplayAsPercentage(cooldown)
		if not cooldown.noCooldownCount then
			cooldown.noCooldownCount = true

			cooldown_HideTimer(cooldown)
		end
	end

	local function cooldown_OnShow(cooldown)
		if not active[cooldown] then
			local start, duration = cooldown:GetCooldownTimes()
			if start and duration then
				cooldown_OnSetCooldown(cooldown, start/1000, duration / 1000)
			end
		end
	end

	function cooldown_ShowTimer(cooldown, duration)
		local minDuration

		local settings = Addon:GetGroupSettingsFor(cooldown)
        if settings and settings.enabled then
			minDuration = settings.minDuration or 0
        else
			minDuration = math.huge
		end

		if (duration or 0) > minDuration then
			if not hooked[cooldown] then
				hooked[cooldown] = true
				cooldown:HookScript("OnShow", cooldown_OnShow)
				cooldown:HookScript("OnHide", cooldown_HideTimer)
			end

			-- handle a fun edge case of a cooldown with an already active
			-- display that now belongs to a different parent object
			local oldDisplay = active[cooldown]
			local newDisplay = Display:GetOrCreate(cooldown:GetParent() or cooldown)

			if oldDisplay and oldDisplay ~= newDisplay then
				oldDisplay:HideCooldownText(cooldown)
			end

			if newDisplay then
				newDisplay:ShowCooldownText(cooldown)
			end

			active[cooldown] = newDisplay
		else
			cooldown_HideTimer(cooldown)
		end
	end

	function cooldown_HideTimer(cooldown)
		local display = active[cooldown]

		if display then
			display:HideCooldownText(cooldown)
			active[cooldown] = nil
		end
	end

	local Cooldown_MT = getmetatable(_G.ActionButton1Cooldown).__index
	hooksecurefunc(Cooldown_MT, "SetCooldown", cooldown_OnSetCooldown)
	hooksecurefunc(Cooldown_MT, "SetCooldownDuration", cooldown_OnSetCooldownDuration)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", cooldown_OnSetDisplayAsPercentage)
end

-- Events
function Addon:ADDON_LOADED(event, ...)
	if ADDON_NAME ~= ... then return end

	self:UnregisterEvent(event)
	self:StartupSettings()
	self:SetupHooks()
end

function Addon:PLAYER_ENTERING_WORLD()
	self.Timer:ForActive("Update")
end

function Addon:PLAYER_LOGIN()
	-- disable and preserve the user's blizzard cooldown count setting
	self.countdownForCooldowns = GetCVar("countdownForCooldowns")
	if self.countdownForCooldowns ~= "0" then
		SetCVar('countdownForCooldowns', "0")
	end
end

function Addon:PLAYER_LOGOUT()
	-- return the setting to whatever it was originally on logout
	-- so that the user can uninstall omnicc and go back to what they had
	local countdownForCooldowns = GetCVar("countdownForCooldowns")
	if self.countdownForCooldowns ~= countdownForCooldowns then
		SetCVar('countdownForCooldowns', self.countdownForCooldowns)
	end
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
