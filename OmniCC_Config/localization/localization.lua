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

L.GeneralSettings = 'General Settings'
L.GeneralSettingsTitle = 'General configuration settings for OmniCC'

L.UseWhitelist = 'Only display text on registered frames'

L.Font = 'Text Font'
L.Size = 'Base Text Size'
L.Outline = 'Text Outline'

L.Outline_NONE = NONE
L.Outline_OUTLINE = 'Thin'
L.Outline_THICKOUTLINE = 'Thick'

L.MinDuration = 'Minimum duration to display text'
L.MinFontSize = 'Minimum font size to display text'
L.ScaleText = 'Scale cooldown text'