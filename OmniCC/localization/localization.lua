--[[
	OmniCC localization - English
--]]

local L = OMNICC_LOCALS
if (not L) and GetLocale() == "enUS" then
	L = {}
	OMNICC_LOCALS = L
else
	return
end

L.Updated = "Updated to v%s"
L.None = NONE
L.Pulse = "Pulse"
L.Shine = "Shine"