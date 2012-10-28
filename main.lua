--[[
	startup.lua
		initializes OmniCC
--]]

local OmniCC = CreateFrame('Frame', 'OmniCC')
local Classy = LibStub('Classy-1.0')
local L = OMNICC_LOCALS


--[[ Startup ]]--

function OmniCC:Startup()
	self:SetScript('OnEvent', function(self, event)
		self[event](self)
	end)
	
	self:RegisterEvent('ADDON_LOADED')
	self.effects = {}
end

function OmniCC:ADDON_LOADED()
	self:StartupSettings()
	
	self.Actions:AddDefaults()
	self:SetupEvents()
	self:SetupHooks()
end


--[[ Callbacks ]]--

function OmniCC:SetupHooks()
	local class = getmetatable(ActionButton1Cooldown).__index
	
	hooksecurefunc(class, 'SetCooldown', self.Cooldown.Show)
	hooksecurefunc('SetActionUIButton', self.Actions.Add)
end

function OmniCC:SetupEvents()
	self:UnregisterEvent('ADDON_LOADED')
	self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

function OmniCC:ACTIONBAR_UPDATE_COOLDOWN()
	self.Actions:Update()
end

function OmniCC:PLAYER_ENTERING_WORLD()
	self.Timer:ForAllShown('UpdateText')
end


--[[ Modules ]]--

function OmniCC:New(name, module)
	self[name] = module or Classy:New('Frame')
	return self[name]
end

OmniCC:Startup()