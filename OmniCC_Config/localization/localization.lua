--[[
	OmniCC configuration interface localization - English
--]]

local L = OMNICC_LOCALS
if (not L) and GetLocale() == 'enUS' then
	L = {}
	OMNICC_LOCALS = L
else
	return
end

L.GeneralSettings = 'Display'
L.GeneralSettingsTitle = "Hey, don't display text there!"
L.FontSettings = 'Text Style'
L.FontSettingsTitle = 'You know the difference between you and me? I make this look good'

L.UseWhitelist = 'Only display text on registered frames'

L.Font = 'Font'
L.FontSize = 'Base Font Size'
L.FontOutline = 'Font Outline'

L.Outline_NONE = NONE
L.Outline_OUTLINE = 'Thin'
L.Outline_THICKOUTLINE = 'Thick'

L.MinDuration = 'Minimum duration to display text'
L.MinFontSize = 'Minimum font size to display text'
L.ScaleText = 'Automatically scale text to fit within frames'