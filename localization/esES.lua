local AddonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "esES") or LibStub("AceLocale-3.0"):NewLocale(AddonName, "esMX")
if not L then return end

-- effect names
L.Pulse = "Pulsar"
L.Shine = "Brillar"
L.Alert = "Avisar"
L.Activate = "Activar"
L.Flare = "Llamear"

-- effect tooltips
L.ActivateTip = [[Imita el efecto predeterminado que se muestra en los botones de acción cuando un facultad "procs".]]
L.AlertTip = [[Pulsa el icono de reutilización completo en el centro de la pantalla.]]
L.PulseTip = [[Pulsa el icono de reutilización.]]

-- other
L.ConfigMissing = "%s no se puede cargar porque el addon está %s"
L.Updated = "Actualizado a la versión %s"
L.Version = "Está utilizando |cffFCF75EOmniCC versión (%s)|r"