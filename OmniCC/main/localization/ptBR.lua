local AddonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "ptBR")
if not L then return end

-- effect names
L.Updated = "Atualizado para a versão %s"
L.Pulse = "Pulse"
L.Shine = "Brilhar"
L.Alert = "Alertar"
L.Activate = "Ativar"

-- effect tooltips
L.ActivateTip = [[Imita o efeito padrão que aparece quando uma abilidade é ativada.]]
L.AlertTip = [[Pulses the finished cooldown icon
at the center of the screen.]]
L.PulseTip = [[Pulses the cooldown icon.]]