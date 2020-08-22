-- OmniCC configuration localization - Spanish
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "esES") or LibStub("AceLocale-3.0"):NewLocale("OmniCC", "esMX")
if not L then return end

L.GeneralSettings = "General"
L.FontSettings = "Aspecto del Texto"
L.RuleSettings = "Reglas"
L.PositionSettings = "Posición del Texto"

L.Font = "Fonte"
L.FontSize = "Tamaño del Texto"
L.FontOutline = "Contorno del Texto"

L.Outline_OUTLINE = "Fino"
L.Outline_THICKOUTLINE = "Grueso"
L.Outline_OUTLINEMONOCHROME = "Monocromo"

L.MinDuration = "Duración mínima para mostrar texto"
L.MinSize = "Tamaño mínimo para mostrar texto"
L.ScaleText = "Redimensionar texto automáticamente"
L.EnableText = "Activar texto"

L.Add = "Añadir"
L.Remove = "Eliminar"

L.FinishEffect = "Efecto final"
L.MinEffectDuration = "Duración mínima para mostrar un efecto final"

L.MMSSDuration = "Duración mínima para mostrar texto en MM:SS"
L.TenthsDuration = "Duración mínima para mostrar las décimas de segundo"

L.ColorAndScale = "Color y Escala"
L.Color_soon = "Cerca a expirar"
L.Color_seconds = "Menos de un minuto"
L.Color_minutes = "Menos de una hora"
L.Color_hours = "Más de una hora"

L.SpiralOpacity = "Transparencia de los espirales"
L.UseAniUpdater = "Optimizar rendimiento"

--text positioning
L.XOffset = "X"
L.YOffset = "Y"

L.Anchor = 'Posición'
L.Anchor_LEFT = 'Izquierda'
L.Anchor_CENTER = 'Centro'
L.Anchor_RIGHT = 'Derecha'
L.Anchor_TOPLEFT = 'Arriba a la Izquierda'
L.Anchor_TOP = 'Arriba'
L.Anchor_TOPRIGHT = 'Arriba a la Derecha'
L.Anchor_BOTTOMLEFT = 'Abajo a la Izquierda'
L.Anchor_BOTTOM = 'Abajo'
L.Anchor_BOTTOMRIGHT = 'Abajo a la Derecha'

--groups
L.Groups = 'Grupos'
L.Group_default = 'Defecto'
L.Group_action = 'Acciónes'
L.Group_pet = 'Acciónes del Animal'
L.AddGroup = 'Añadir Grupo...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[Cuando está activada, esta opción
hace reducir el tamaño del texto para
que quepa en pequeños elementos.]]

L.SpiralOpacityTip =
[[Establece la transparencia de los espirales negros que por lo
general se visualizan en botones en tiempo de reutilización.]]

L.UseAniUpdaterTip =
[[Optimiza el rendimiento del procesador, pero puede
causar bloqueos en algunos sistemas.
Desactivar esta opción va a resolver el problema.]]

L.MinDurationTip =
[[Determina el tiempo mínimo que un tiempo de reutilización
debe tener a fin de mostrar el texto.

Esta configuración se utiliza principalmente para
filtrado del GCD.]]

L.MinSizeTip =
[[Determina el tamaño mínimo que un elemento debe tener para mostrar texto.

Algunos ejemplos:
100 - El tamaño de un botón de acción
80 - El tamaño de un botón de clase o de acción de animal
55 - El tamaño de un aficionado de ventana del enimigo]]

L.MinEffectDurationTip =
[[Determina el tiempo mínimo para un tiempo
de reutilización mostrar el efecto final.]]

L.MMSSDurationTip =
[[Determina el tiempo mínimo para mostrar
un tiempo de reutilización en MM:SS.]]

L.TenthsDurationTip =
[[Determina el tiempo mínimo para
mostrar décimas de segundo.]]

L.FontSizeTip =
[[Controla el tamaño del texto.]]

L.FontOutlineTip =
[[Controla a espessura do
contorno à volta do texto.]]

L.UseBlacklistTip =
[[Activa el uso de la lista negra.
Cuando está activado, cualquier elemento con un nombre
que coincide con un elemento de la lista negra
no mostrará texto.]]

L.FrameStackTip =
[[Si activado, muestran los nombres
de los elementos cuando se pasan
el puntero del ratón sobre ellos.]]

L.XOffsetTip =
[[Controles de desplazamiento
horizontal del texto.]]

L.YOffsetTip =
[[Controla de desplazamiento
vertical del texto.]]
