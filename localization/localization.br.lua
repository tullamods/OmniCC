--[[
	OmniCC configuration interface localization - Portuguese
--]]

local L = OMNICC_LOCALS

L.GeneralSettings = "Display"
L.FontSettings = "Texto"
L.RuleSettings = "Regras"
L.PositionSettings = "Posição do Texto"

L.Font = "Fonte"
L.FontSize = "Tamanho do Texto"
L.FontOutline = "Contorno do Texto"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "Fino"
L.Outline_THICKOUTLINE = "Grosso"

L.MinDuration = "Duração mínima para mostar texto"
L.MinSize = "Tamanho mínimo para mostrar texto"
L.ScaleText = "Redimensionar texto automaticamente"
L.EnableText = "Ativar texto"

L.Add = "Adicionar"
L.Remove = "Remover"

L.FinishEffect = "Efeito Final"
L.MinEffectDuration = "Duração mínima para mostrar o efeito final"

L.MMSSDuration = "Minimum duration to display text as MM:SS"
L.TenthsDuration = "Minimum duration to display tenths of seconds"

L.ColorAndScale = "Cor e Tamanho"
L.Color_soon = "Soon to expire"
L.Color_seconds = "Menos de um minuto"
L.Color_minutes = "Menos de uma hora"
L.Color_hours = "Mais de uma hora"

L.ShowCooldownModels = "Mostrar animação circular padrão"
L.UseAniUpdater = "Otimizar desempenho"

--text positioning
L.XOffset = "X"
L.YOffset = "Y"

L.Anchor = 'Posicionar'
L.Anchor_LEFT = 'À Esquerda'
L.Anchor_CENTER = 'Ao Centro'
L.Anchor_RIGHT = 'À Direita'
L.Anchor_TOPLEFT = 'No Topo Esquerdo'
L.Anchor_TOP = 'No Topo'
L.Anchor_TOPRIGHT = 'No Topo Direito'
L.Anchor_BOTTOMLEFT = 'No Fundo Esquerdo'
L.Anchor_BOTTOM = 'No Fundo'
L.Anchor_BOTTOMRIGHT = 'No Fundo Direito'

--groups
L.Groups = 'Grupos'
L.Group_base = 'Padrão'
L.Group_action = 'Ações'
L.Group_aura = 'Auras'
L.Group_pet = 'Ações do Animal'
L.AddGroup = 'Adicionar Grupo...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[When enabled, this setting will
cause text to shrink to fit within
frames that are too small.]]

L.ShowCooldownModelsTip =
[[Toggles the display of cooldown
models.]]

L.ShowCooldownModelsSmallTip = [[(The dark spiral you normally
see on a button when on cooldown)]]

L.UseAniUpdaterTip =
[[Optimizes CPU performance, but may
cause crashes on some environments.
Disabling this option will solve the issue.]]

L.UseAniUpdaterSmallTip = "|cffff2020Changing requires game reload.|r"

L.MinDurationTip =
[[Determines how long a cooldown
must be in order to show text.

This setting is mainly used to
filter out the GCD.]]

L.MinSizeTip =
[[Determines how big a frame must be to display text.
The smaller the value, smaller things can be to show text.
The larger the value, the bigger things must be.

Some benchmarks:
100 - The size of an action button
80  - The size of a class or pet action button
55  - The size of a Blizzard target frame buff]]

L.MinEffectDurationTip =
[[Determines how long a
cooldown must be in order
to show a finish effect
(ex, pulse/shine)]]

L.MMSSDurationTip =
[[Determines the threshold
for showing a cooldown
in a MM:SS format.]]

L.TenthsDurationTip =
[[Determines the threshold
for showing tenths of seconds.]]

L.FontSizeTip =
[[Controls how large text is.]]

L.FontOutlineTip =
[[Controls the thickness of the
outline around text.]]

L.UseBlacklistTip =
[[Click this to toggle using the blacklist.
When enabled, any frame with a name
that matches an item on the blacklist
will not display cooldown text.]]

L.FrameStackTip =
[[Toggles showing the names
of frames when you hover
over them.]]

L.XOffsetTip =
[[Controls the horizontal
offset of text.]]

L.YOffsetTip =
[[Controls the vertical
offset of text.]]