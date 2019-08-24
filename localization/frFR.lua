local AddonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "frFR")
if not L then return end


-- effect names
L.Pulse = "Pulsation"
L.Shine = "Brillance"
L.Alert = "Alerte"
L.Activate = "Activation"

-- effect tooltip text
L.ActivateTip = [[Imite l'effet par défaut qui apparaît quand un sort est activé.]]
L.AlertTip = [[Affiche une pulsation au centre de l'écran lorsque le sort est prêt.]]
L.PulseTip = [[Affiche une pulsation lorsque le sort est prêt.]]