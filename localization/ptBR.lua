-- OmniCC configuration localization - Portuguese
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "ptBR")
if not L then return end

L.GeneralSettings = "Geral"
L.FontSettings = "Aspecto do Texto"
L.RuleSettings = "Regras"
L.PositionSettings = "Posição do Texto"

L.Font = "Fonte"
L.FontSize = "Tamanho do Texto"
L.FontOutline = "Contorno do Texto"

L.Outline_OUTLINE = "Fino"
L.Outline_THICKOUTLINE = "Espesso"
L.Outline_OUTLINEMONOCHROME = "Monocromático"

L.MinDuration = "Duração mínima para exibir texto"
L.MinSize = "Tamanho mínimo para exibir texto"
L.ScaleText = "Redimensionar texto automaticamente"
L.EnableText = "Ativar texto"

L.Add = "Adicionar"
L.Remove = "Remover"

L.FinishEffect = "Efeito Final"
L.MinEffectDuration = "Duração mínima para exibir o efeito final"

L.MMSSDuration = "Duração mínima para exibir o texto como MM:SS"
L.TenthsDuration = "Duração mínima para mostrar décimos de segundo"

L.ColorAndScale = "Cor e Tamanho"
L.Color_soon = "Perto de expirar"
L.Color_seconds = "Menos de um minuto"
L.Color_minutes = "Menos de uma hora"
L.Color_hours = "Mais de uma hora"

L.SpiralOpacity = "Transparência das espirais"
L.UseAniUpdater = "Otimizar desempenho"

--text positioning
L.XOffset = "X"
L.YOffset = "Y"

L.Anchor = 'Posicionar'
L.Anchor_LEFT = 'Esquerda'
L.Anchor_CENTER = 'Centro'
L.Anchor_RIGHT = 'Direita'
L.Anchor_TOPLEFT = 'Topo Esquerdo'
L.Anchor_TOP = 'Topo'
L.Anchor_TOPRIGHT = 'Topo Direito'
L.Anchor_BOTTOMLEFT = 'Fundo Esquerdo'
L.Anchor_BOTTOM = 'Fundo'
L.Anchor_BOTTOMRIGHT = 'Fundo Direito'

--groups
L.Groups = 'Grupos'
L.Group_default = 'Padrão'
L.Group_action = 'Ações'
L.Group_pet = 'Ações do Animal'
L.AddGroup = 'Adicionar Grupo...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[Quando ativada, esta opção faz o
texto a encolher para caber dentro de
elementos que sejam pequenos.]]

L.SpiralOpacityTip =
[[Define a transparência das espirais negras que normalmente
são exibidas em botões em cooldown.]]

L.UseAniUpdaterTip =
[[Otimiza o desempenho do processador, mas pode
causar falhas em alguns sistemas.
Desativar esta opção irá resolver o problema.]]

L.MinDurationTip =
[[Determina o tempo mínimo que um cooldown
tem de ter a fim de mostrar o texto.

Esta configuração é usada maioritariamente para
filtrar o GCD.]]

L.MinSizeTip =
[[Determina o tamanho mínimo que elementos têm de ter para exibir texto.

Alguns exemplos:
100 - O tamanho de um botão de ação
80 - O tamanho de um botão de classe ou de ação do pet
55 - O tamanho de um buff da janela do alvo]]

L.MinEffectDurationTip =
[[Determina o tempo mínimo para
um cooldown mostrar o efeito final]]

L.MMSSDurationTip =
[[Determina o limite
para mostrar um cooldown
em MM:SS.]]

L.TenthsDurationTip =
[[Determina o limite para
mostrar décimos de segundos.]]

L.FontSizeTip =
[[Controla o tamanho do texto]]

L.FontOutlineTip =
[[Controla a espessura do
contorno à volta do texto.]]

L.UseBlacklistTip =
[[Ativa o uso de lista negra.
Quando ativada, qualquer elemento com um nome
que corresponda a um item na lista negra
não mostrará texto.]]

L.FrameStackTip =
[[Se ativado, mostra os nomes
dos elementos quando você passa
com o rato sobre eles.]]

L.XOffsetTip =
[[Controla o deslocamento
horizontal do texto.]]

L.YOffsetTip =
[[Controla o deslocamento
vertical do texto.]]