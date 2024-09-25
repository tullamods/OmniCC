local AddonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "frFR")
if not L then return end

-- timer formats
L.TenthsFormat = "%0.1f"
L.SecondsFormat = "%d"
L.MMSSFormat = "%d:%02d"
L.MinutesFormat = "%dm"
L.HoursFormat = "%dh"
L.DaysFormat = "%dd"

-- Noms des effects
L.None = NONE
L.Pulse = "Pulsation"
L.Shine = "Éclat"
L.Alert = "Alerte"
L.Activate = "Activation"
L.Flare = "Éclater"

-- Info-bulles d'effet
L.ActivateTip = [[Applique l'effet déclencheur de capacité à l'icône de temps de recharge.]]
L.AlertTip = [[Affiche une pulsation au centre de l'écran lorsque le sort est prêt.]]
L.PulseTip = [[Affiche une pulsation lorsque le sort est prêt.]]

-- other
L.ConfigMissing = "%s n'a pas pu être chargé car l'addon est %s"
L.Version = "Vous utilisez |cffFCF75EOmniCC Version (%s)|r"
