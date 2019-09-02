-- OmniCC configuration interface localization - deDE
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "deDE")
if not L then return end

L.GeneralSettings = "Anzeige"
L.FontSettings = "Textstil"
L.RuleSettings = "Regeln"
L.PositionSettings = "Textposition"

L.Font = "Schriftart"
L.FontSize = "Basis-Schriftgröße"
L.FontOutline = "Schriftumriss"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "Dünn"
L.Outline_THICKOUTLINE = "Dick"
L.Outline_OUTLINEMONOCHROME = "Einfarbig"

L.MinDuration = "Minimaldauer zur Anzeige von Text"
L.MinSize = "Minimalgröße zur Anzeige von Text"
L.ScaleText = "Text automatisch skalieren, damit dieser in Frames passt"
L.EnableText = "Abklingzeittext aktivieren"

L.Add = "Hinzufügen"
L.Remove = "Entfernen"

L.FinishEffect = "Abschlusseffekt"
L.MinEffectDuration = "Minimaldauer zur Anzeige eines Abschlusseffekts"

L.MMSSDuration = "Minimaldauer zur Anzeige des Texts im Format MM:SS"
L.TenthsDuration = "Minimaldauer zur Anzeige von Zehntelsekunden"

L.ColorAndScale = "Farbe und Skalierung"
L.Color_soon = "Läuft bald ab"
L.Color_seconds = "Unter einer Minute"
L.Color_minutes = "Unter einer Stunde"
L.Color_hours = "Eine Stunde oder mehr"
L.Color_charging = "Aufladungen wiederherstellen"
L.Color_controlled = "Kontrollverlust"

L.SpiralOpacity = "Spiraltransparenz"
L.UseAniUpdater = "Leistung optimieren"

--text positioning
L.XOffset = "X-Versatz"
L.YOffset = "Y-Versatz"

L.Anchor = 'Anker'
L.Anchor_LEFT = 'Links'
L.Anchor_CENTER = 'Mittig'
L.Anchor_RIGHT = 'Rechts'
L.Anchor_TOPLEFT = 'Oben links'
L.Anchor_TOP = 'Oben'
L.Anchor_TOPRIGHT = 'Oben rechts'
L.Anchor_BOTTOMLEFT = 'Unten links'
L.Anchor_BOTTOM = 'Unten'
L.Anchor_BOTTOMRIGHT = 'Unten rechts'

--groups
L.Groups = 'Gruppen'
L.Group_default = 'Standard'
L.Group_action = 'Aktionen'
L.Group_aura = 'Auren'
L.Group_pet = 'Begleiteraktionen'
L.AddGroup = 'Gruppe hinzufügen...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[Verkleinert den Text,
sodass er auch in Frames
passt, die zu klein sind.]]

L.SpiralOpacityTip =
[[Legt die Deckkraft der dunklen Spiralen
fest, die du normalerweise auf Buttons siehst,
wenn die Fähigkeit abklingt.]]

L.UseAniUpdaterTip =
[[Optimiert die CPU-Leistung, aber könnte in manchen Fällen
zu Fehlern führen.
Das Deaktivieren dieser Option behebt das Problem.]]

L.MinDurationTip =
[[Bestimmt, wie groß die Abklingzeit sein muss,
damit ein Text angezeigt wird.
Diese Einstellung wird hauptsächlich verwendet,
um die globale Abklingzeit auszublenden.]]

L.MinSizeTip =
[[Bestimmt, wie groß ein Frame sein muss,
damit ein Text angezeigt wird.
Je kleiner der Wert, desto kleiner können
Elemente sein, um Text anzuzeigen.
Je größer der Wert, desto größer müssen Elemtente sein.
Ein paar Richtwerte:
100 – Die Größe eines Aktionsbuttons
80  – Die Größe eines Klassen- oder Begleiteraktionsbuttons
55  – Die Größe eines Buffs auf dem Zielfenster]]

L.MinEffectDurationTip =
[[Legt fest, wie lang eine Abklingzeit sein muss,
damit ein Abschlusseffekt angezeigt wird
(ex, pulse/shine)]]

L.MMSSDurationTip =
[[Bestimmt, bis zu welcher
verbleibenden Dauer die Abklingzeit
im Format MM:SS angezeigt wird.]]

L.TenthsDurationTip =
[[Bestimmt, ab welcher verbleibenden
Dauer Zehntelsekunden angezeigt werden.]]

L.FontSizeTip =
[[Bestimmt, wie groß der Text ist.]]

L.FontOutlineTip =
[[Bestimmt die Dicke der Kontur um den Text.]]

L.UseBlacklistTip =
[[Klicke hier, um die Verwendung der
Ignorierliste ein- oder auszuschalten.
Wenn aktiv, werden alle Frames, deren
Name auf der Ignorierliste vorkommt,
keinen Abklingzeittext anzeigen.]]

L.FrameStackTip =
[[Aktiviert/Deaktiviert die Anzeige
der Namen von Frames, wenn Du mit der
Maus über sie fährst.]]

L.XOffsetTip =
[[Legt den horizontalen
Versatz des Texts fest.]]

L.YOffsetTip =
[[Legt den vertikalen
Versatz des Texts fest.]]
