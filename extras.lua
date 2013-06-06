--[[
	extras.lua
		config and slash commands
--]]

local Config = 'OmniCC_Config'
local L = OMNICC_LOCALS

function OmniCC:SetupConfig()
	local config = CreateFrame('Frame', Config)
	config.name = 'OmniCC'

	config:SetScript('OnShow', function()
		local loaded, reason = LoadAddOn(Config)
		if not loaded then
			local string = config:CreateFontString(nil, nil, 'GameFontHighlight')
			local reason = _G['ADDON_'..reason]:lower()
			
			string:SetText(L.ConfigMissing:format(Config, reason))
			string:SetPoint('RIGHT', -40, 0)
			string:SetPoint('LEFT', 40, 0)
			string:SetHeight(30)
		end 
	end)

	InterfaceOptions_AddCategory(config)
end

function OmniCC:RegisterCommands()
	SLASH_OmniCC1 = '/omnicc'
	SLASH_OmniCC2 = '/occ'
	SlashCmdList['OmniCC'] = function(...)
		self:OnCommand(...)
	end
end

function OmniCC:OnCommand(command)
	if comand == 'version' then
		print(L.Version:format(self:GetVersion()))
	else
		if LoadAddOn(Config) then
			InterfaceOptionsFrame_OpenToCategory('OmniCC')
		end
	end
end

OmniCC:SetupConfig()
OmniCC:RegisterCommands()