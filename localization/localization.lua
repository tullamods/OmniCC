--[[
	OmniCC localization - English
--]]

OMNICC_LOCALS = {} --should be done in the US locale file, only

local L = OMNICC_LOCALS
--[[
if not GetLocale() == 'enUS' then
	return
end
--]]

L.Updated = "Updated to v%s"
L.None = NONE
L.Pulse = "Pulse"
L.Shine = "Shine"

--slash command text
L.SetEngine_Classic = 'Switched timers to the Classic engine. This setting will take effect the next time you log in.'
L.SetEngine_Animation = 'Switched timers to the Animation engine. This setting will take effect the next time you log in.'
L.UnknownEngineName = "Unknown timer engine '%s'"
L.SetEngineUsage = 'Usage: /omnicc setengine <classic | animation>'
L.Commands = 'Commands (/omnicc or /occ):'
L.Command_ShowOptionsMenu = '- config - Show the options menu'
L.Command_SetTimerEngine = '- setengine <classic | animation> - Switches the timer update engine'
L.Command_ShowAddonVersion = '- version - Displays the current addon version'
L.UnknownCommandName = "Unknown command '%s'"