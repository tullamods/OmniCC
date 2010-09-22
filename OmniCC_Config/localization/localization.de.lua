--[[
	OmniCC configuration interface localization - deDE
--]]

if GetLocale() ~= 'deDE' then return end

local L = OMNICC_LOCALS

L.GeneralSettings = "Allgemein"
L.GeneralSettingsTitle = "Die allgemeinen Sachen"

L.FontSettings = "Schriftart"
L.FontSettingsTitle = "Gib den Cooldowns neues Leben"

L.FilterSettings = "Filter"
L.FilterSettingsTitle = "Hey! Keinen Text dort anzeigen!"

L.UseWhitelist = "Zeige Text nur auf registrierten Frames"
L.UseBlacklist = "Zeige Text nur auf Frames, die nicht auf der Schwarzen Liste sind"
L.Blacklist = "Schwarze Liste"

L.Font = "Schrift"
L.FontSize = "Basis Schriftgr\195\182\195\159e"
L.FontOutline = "Schriftkontur"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "D\195\188nn"
L.Outline_THICKOUTLINE = "Dick"

L.MinDuration = "Kleinste Dauer um Text anzuzeigen"
L.MinFontSize = "Kleinste Schriftgr\195\182\195\159e um Text anzuzeigen"
L.ScaleText = "Text automatisch an Frames anpassen"

L.Add = "Hinzuf\195\188gen"
L.Remove = "Entfernen"

L.FinishEffect = 'Abschlusseffekt'
L.MinEffectDuration = 'Kleinste Dauer um Abschlusseffekt anzuzeigen'

L.MMSSDuration = "Kleinste Dauer um Text als MM:SS anzuzeigen"
L.TenthsDuration = "Kleinste Dauer f\195\188r Zehntelsekunden im Text"

L.ColorAndScale = "Farbe und Gr\195\182\195\159e"
L.Color_soon = "L\195\164uft bald ab"
L.Color_seconds = "Unter einer Minute"
L.Color_minutes = "Unter einer Stunde"
L.Color_hours = "Eine Stunde und mehr"

L.ShowCooldownModels = "Zeige Cooldown Spirale"

L.Sec = " Sek."

--[[ Tooltips ]]--

L.ScaleTextTip =
[[Verkleinert den Text, so
dass er auch in Frames passt,
die zu klein sind.]]

L.ShowCooldownModelsTip =
[[Zeigt die dunkle Spirale,
die man normalerweise sieht,
wenn etwas Cooldown hat.]]

L.MinDurationTip =
[[Bestimmt, wie lang ein Cooldown
sein muss, damit er angezeigt wird.

Das wird hauptsächlich verwendet,
um den GCD auszublenden.]]

L.MinFontSizeTip =
[[Bestimmt, wie groß der Cooldown-
Text mindestens sein muss, damit er
angezeigt wird.

Das wird hauptsächlich verwendet,
um unlesbaren Text auszublenden, und um
keinen Text auf Buffs anzuzeigen.]]

L.MinEffectDurationTip =
[[Bestimmt, wie lang ein Cooldown
sein muss, damit ein Abschlusseffekt
angezeigt wird (Pulse/Shine).]]

L.MMSSDurationTip =
[[Bestimmt, bis zu welcher verbleibenden
Dauer ein Cooldown im MM:SS Format
angezeigt wird.]]

L.TenthsDurationTip =
[[Bestimmt, ab wann Zehntelsekunden
angezeigt werden.]]

L.FontSizeTip =
[[Bestimmt, wie groß der Text ist.]]

L.FontOutlineTip =
[[Bestimmt die Dicke der Kontur um den Text.]]

L.UseBlacklistTip =
[[Aktiviert die Schwarze Liste.
Wenn aktiv, werden alle Frames, deren
Name in der Schwarzen Liste vorkommt,
keinen Cooldown-Text anzeigen.]]

L.FrameStackTip =
[[Aktiviert bzw. deaktiviert die Anzeige
der Namen von Frames, wenn die Maus
darüber ist.]]