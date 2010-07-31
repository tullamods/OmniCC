--[[
	OmniCC configuration interface localization - zhCN
--]]

if GetLocale() ~= 'zhCN' then return end

local L = OMNICC_LOCALS

L.GeneralSettings = "一般"
L.GeneralSettingsTitle = "一般的设定"
L.FontSettings = "设定字形"
L.FontSettingsTitle = "你知道你和我之间的差别？我令这个看起来更好看"
L.BlacklistSettings = "黑名单设定"
L.BlacklistSettingsTitle = "嘿，不要在这里显示文字!"

L.UseWhitelist = "只在注册了的框格显示文字"
L.UseBlacklist = "只在框格但不在黑名单上显示文字"
L.Blacklist = "黑名单"

L.Font = "字形"
L.FontSize = "字形大小"
L.FontOutline = "字形轮廓"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "幼线"
L.Outline_THICKOUTLINE = "粗线"

L.MinDuration = "最少时间的时值"
L.MinFontSize = "最小的字体大小来显示文字"
L.ScaleText = "使用自动缩放令文字保持在框格之内"

L.Add = "新增"
L.Remove = "移除"

L.FinishEffect = "完成的效果"
L.MinEffectDuration = "完成的效果最少时间的时值"

L.MMSSDuration = "最少时间的时值以 MM:SS 格式来显示"
L.TenthsDuration = "以十分之一秒为单位显示"

L.Color = "颜色"
L.Color_soon = "即将到期"
L.Color_seconds = "少于1分钟"
L.Color_minutes = "少于1小时"
L.Color_hours = "1小时或以上"