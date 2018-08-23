local OmniCC = CreateFrame("Frame", ..., InterfaceOptionsFrame)
local L = _G.OMNICC_LOCALS

function OmniCC:Startup()
	self:SetupCommands()

	self:SetScript(
		"OnEvent",
		function(f, event, ...)
			f[event](f, event, ...)
		end
	)

	self:SetScript(
		"OnShow",
		function(f)
			LoadAddOn("OmniCC_Config")

			f:SetScript("OnShow", nil)
		end
	)

	SetCVar("countdownForCooldowns", 0)

	self:RegisterEvent("VARIABLES_LOADED")
end

function OmniCC:SetupCommands()
	_G.SLASH_OmniCC1 = "/omnicc"

	_G.SLASH_OmniCC2 = "/occ"

	_G.SlashCmdList["OmniCC"] = function(...)
		if ... == "version" then
			print(L.Version:format(self:GetVersion()))
		elseif self.ShowOptionsMenu or LoadAddOn("OmniCC_Config") then
			if type(self.ShowOptionsMenu) == "function" then
				self:ShowOptionsMenu()
			end
		end
	end
end

function OmniCC:SetupEvents()
	self:UnregisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function OmniCC:SetupHooks()
	-- local Cooldown_MT = getmetatable(_G.ActionButton1Cooldown).__index
	-- local hidden = {}
	-- hooksecurefunc(
	-- 	Cooldown_MT,
	-- 	"SetCooldown",
	-- 	function(cooldown, start, duration, modRate)
	-- 		if cooldown.noCooldownCount or cooldown:IsForbidden() or hidden[cooldown] then
	-- 			return
	-- 		end
	-- 		self.Cooldown.Start(cooldown, start, duration, modRate)
	-- 	end
	-- )
	-- hooksecurefunc(Cooldown_MT, "Clear", self.Cooldown.Stop)
	-- hooksecurefunc(
	-- 	Cooldown_MT,
	-- 	"SetHideCountdownNumbers",
	-- 	function(cooldown, hide)
	-- 		if hide then
	-- 			hidden[cooldown] = true
	-- 			self.Cooldown.Stop(cooldown)
	-- 		else
	-- 			hidden[cooldown] = nil
	-- 		end
	-- 	end
	-- )
	-- hooksecurefunc(
	-- 	"CooldownFrame_SetDisplayAsPercentage",
	-- 	function(cooldown)
	-- 		hidden[cooldown] = true
	-- 		self.Cooldown.Stop(cooldown)
	-- 	end
	-- )
	-- self.Meta = Cooldown_MT
end

-- Events
function OmniCC:PLAYER_ENTERING_WORLD()
	-- self.Timer:ForAll("UpdateText")
end

function OmniCC:VARIABLES_LOADED()
	self:StartupSettings()
	self:SetupEvents()
	self:SetupHooks()
end

-- Utility
function OmniCC:New(name, module)
	self[name] = module or LibStub("Classy-1.0"):New("Frame")
	return self[name]
end

OmniCC:Startup()
