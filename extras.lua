--[[
	extras.lua
		config and slash commands
--]]


--[[ Config ]]--

local ConfigAddon = 'OmniCC_Config'
local Config = CreateFrame('Frame', Config)
Config.name = 'OmniCC'

Config:SetScript('OnShow', function()
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

InterfaceOptions_AddCategory(Config)


--[[ Slash Commands ]]--

SLASH_OmniCC1 = '/omnicc'
SLASH_OmniCC2 = '/occ'
SlashCmdList['OmniCC'] = function(...)
	OnCommand(...)
end

local function OnCommand(command)
	if comand == 'version' then
		print(L.Version:format(OmniCC:GetVersion()))
	else
		if LoadAddOn(Config) then
			InterfaceOptionsFrame_OpenToCategory(Config)
		end
	end
end