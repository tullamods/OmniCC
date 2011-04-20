--[[
	OmniCC localization - zhCN
--]]

if GetLocale() ~= 'zhCN' then return end

local L = OMNICC_LOCALS

L.Updated = "升级至 v%s"
L.None = NONE
L.Pulse = "脉冲"
L.Shine = "闪亮"

--slash command text
L.SetEngine_Classic = '切换到经典计时器的引擎。此设置将在下次登录时生效.'
L.SetEngine_Animation = '切换到经典计时器的动画引擎。此设置将在下次登录时生效.'
L.UnknownEngineName = "未知的计时器引擎 '%s'"
L.SetEngineUsage = '用法: /omnicc setengine <classic | animation>'
L.Commands = '命令 (/omnicc or /occ):'
L.Command_ShowOptionsMenu = '- config - 显示选项菜单'
L.Command_SetTimerEngine = '- setengine <classic | animation> - 开关计时器的更新引擎'
L.Command_ShowAddonVersion = '- version - 显示目前插件的版本'
L.UnknownCommandName = "未知的命令 '%s'"