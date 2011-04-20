--[[
	OmniCC localization - zhTW
--]]

if GetLocale() ~= 'zhTW' then return end

local L = OMNICC_LOCALS

L.Updated = "升級至 v%s"
L.None = NONE
L.Pulse = "脈衝"
L.Shine = "閃亮"

--slash command text
L.SetEngine_Classic = '切換到經典計時器的引擎。此設置將在下次登錄時生效.'
L.SetEngine_Animation = '切換到經典計時器的動畫引擎。此設置將在下次登錄時生效.'
L.UnknownEngineName = "未知的計時器引擎 '%s'"
L.SetEngineUsage = '用法: /omnicc setengine <classic | animation>'
L.Commands = '命令 (/omnicc or /occ):'
L.Command_ShowOptionsMenu = '- config - 顯示選項菜單'
L.Command_SetTimerEngine = '- setengine <classic | animation> - 開關計時器的更新引擎'
L.Command_ShowAddonVersion = '- version - 顯示目前插件的版本'
L.UnknownCommandName = "未知的命令 '%s'"