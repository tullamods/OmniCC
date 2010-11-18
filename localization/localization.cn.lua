--[[
	OmniCC configuration interface localization - zhCN
--]]

if GetLocale() ~= 'zhCN' then return end

local L = OMNICC_LOCALS

L.GeneralSettings = "一般"
L.FontSettings = "设定字形"
L.RuleSettings = "规则"
L.PositionSettings = "文字位置"

--L.GeneralSettingsTitle = "一般的设定"
--L.FontSettingsTitle = "你知道你和我之间的差别？我令这个看起来更好看"
--L.BlacklistSettings = "黑名单设定"
--L.BlacklistSettingsTitle = "嘿，不要在这里显示文字!"
--L.UseWhitelist = "只在注册了的框格显示文字"
--L.UseBlacklist = "只在框格但不在黑名单上显示文字"
--L.Blacklist = "黑名单"

L.Font = "字形"
L.FontSize = "字形大小"
L.FontOutline = "字形轮廓"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "幼线"
L.Outline_THICKOUTLINE = "粗线"

L.MinDuration = "最少时间的时值"
L.MinSize = "最小的字体大小来显示文字"
L.ScaleText = "使用自动缩放令文字保持在框格之内"
L.EnableText = "启用冷却文字"

L.Add = "新增"
L.Remove = "移除"

L.FinishEffect = "完成的效果"
L.MinEffectDuration = "完成的效果最少时间的时值"

L.MMSSDuration = "最少时间的时值以 MM:SS 格式来显示"
L.TenthsDuration = "以十分之一秒为单位显示"

L.ColorAndScale = "颜色 & 比例"
L.Color_soon = "即将到期"
L.Color_seconds = "少于1分钟"
L.Color_minutes = "少于1小时"
L.Color_hours = "1小时或以上"

L.ShowCooldownModels = "冷却时间显示模式"

-- 文字定位
L.XOffset = "X 偏移"
L.YOffset = "Y 偏移"

L.Anchor = '锚点'
L.Anchor_LEFT = '左'
L.Anchor_CENTER = '中'
L.Anchor_RIGHT = '右'
L.Anchor_TOPLEFT = '左上'
L.Anchor_TOP = '上'
L.Anchor_TOPRIGHT = '右上'
L.Anchor_BOTTOMLEFT = '左下'
L.Anchor_BOTTOM = '下'
L.Anchor_BOTTOMRIGHT = '右下'

--群组
L.Groups = '群组'
L.Group_base = '预设'
L.Group_action = '动作'
L.Group_aura = '光环'
L.Group_pet = '宠物动作'
L.AddGroup = '新增群组...'

--[[ 提示贴]]--

L.ScaleTextTip =
[[当启用时，此设置 
会令文字缩小来适应
太细小的框架]]

L.ShowCooldownModelsTip =
[[控制冷却模组的显示方式
（你通常在冷却的按钮看到
的黑暗螺旋]]

L.MinDurationTip =
[[确定多长的冷却时间才显示文字. 
此设置主要用于筛选出GCD]]

L.MinSizeTip =
[[确定多大的框架能显示文字. 
该值越小,可以展示的东西越小. 
值越大, 可以展示的东西越大.

一些基准:
100 - 动作按钮的大小
80  - 职业或宠物动作按钮的大小
55  - 暴雪目标增益框的大小]]

L.MinEffectDurationTip =
[[确定须要多长的冷却
时间来显示一个完成的效果 
(例如, 脉冲 /闪亮)]]

L.MMSSDurationTip =
[[确定用于显示冷却时间的界限点
 以 MM:SS 格式来显示]]

L.TenthsDurationTip =
[[确定用于显示冷却时间的界限点
以十份一秒格式来显示]]

L.FontSizeTip =
[[控制文字的大小]]

L.FontOutlineTip =
[[控制文字周围的轮廓厚度]]

L.UseBlacklistTip =
[[点击此切换使用黑名单. 
当启用时，任何框架的名称 
与黑名单上的项目相同时 
将不会显示冷却时间.]]

L.FrameStackTip =
[[切换当鼠标悬停
在框架时显示的名称]]

L.XOffsetTip =
[[控制文字的水平偏移]]

L.YOffsetTip =
[[控制文字的垂直偏移]]