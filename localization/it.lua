--[[OmniCC Localization - Italian]]

if GetLocale() ~= 'itIT' then return end
local L = OMNICC_LOCALS

-- effect names
L.None = NONE
L.Pulse = "Pulsante"
L.Shine = "Splendente"
L.Alert = "Avviso"
L.Activate = "Attivato"
L.Flare = "Bagliore"

-- effect tooltips
L.ActivateTip = [[Mima l'effetto predefinito, che viene mostrato nelle barre delle azioni, quando un'abilità "procca".]]
L.AlertTip = [[Terminato il periodo di recupero, l'icona pulsa al centro dello schermo.]]
L.PulseTip = [[Concluso il periodo di recupero l'icona pulsa.]]

-- other
L.ConfigMissing = "%s non può essere caricato perché l'addon è %s"
L.Version = 'Stai utilizzando la versione |cffFCF75EOmniCC (%s)|r'
