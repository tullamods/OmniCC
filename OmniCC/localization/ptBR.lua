local AddonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "ptBR")
if not L then return end

-- effect names
L.Activate = "Ativar"
L.Alert = "Alertar"
L.Flare = "Sinalizar"
L.None = NONE
L.Pulse = "Pulse"
L.Shine = "Brilhar"

-- effect tooltips
L.ActivateTip = [[Imita o efeito padrão que aparece quando uma abilidade é ativada.]]
L.AlertTip = [[Pulsa o ícone de tempo de recarga concluído no centro da tela.]]
L.PulseTip = [[Pulsa o ícone de tempo de recarga.]]

-- other
L.ConfigMissing = "%s não pôde ser carregado porque o addon está %s"
L.Version = "Você está usando a |cffFCF75EOmniCC Versão (%s)|r"
