--[[
	OmniCC configuration localization - Italian
--]]

if GetLocale() ~= 'itIT' then return end
local L = OMNICC_LOCALS

L.GeneralSettings = "Visualizzazione"
L.FontSettings = "Stile Testo"
L.RuleSettings = "Regole"
L.PositionSettings = "Posizione Testo"

L.Font = "Carattere"
L.FontSize = "Dimensione Carattere Base"
L.FontOutline = "Bordo CarattereFont Outline"

L.Outline_OUTLINE = "Sottile"
L.Outline_THICKOUTLINE = "Spesso"
L.Outline_OUTLINEMONOCHROME = "Monocromatico"

L.MinDuration = "Durata minima di visualizzazione testo"
L.MinSize = "Dimensione minima di visualizzazione testo"
L.ScaleText = "Scala automaticamente il testo per adattarlo tra i frames"
L.EnableText = "Abilita testo recupero"

L.Add = "Aggiungi"
L.Remove = "Rimuovi"

L.FinishEffect = "Effetto Chiusura"
L.MinEffectDuration = "Durata minima per visualizzare l'effetto di chiusura"

L.MMSSDuration = "Durata minima per mostrare il testo come MM:SS"
L.TenthsDuration = "Durata minima per mostrare decimi di secondo"

L.ColorAndScale = "Colore & Scalatura"
L.Color_soon = "Sta per scadere tra poco"
L.Color_seconds = "In meno di un minuto"
L.Color_minutes = "In meno di un'ora"
L.Color_hours = "Un'ora o più"
L.Color_charging = "Ripristina cambiamenti"

L.SpiralOpacity = "Trasparenza spirale"
L.UseAniUpdater = "Ottimizza performance"

--text positioning
L.XOffset = "X Offset"
L.YOffset = "Y Offset"

L.Anchor = 'Ancoraggio'
L.Anchor_LEFT = 'Sinistra'
L.Anchor_CENTER = 'Centro'
L.Anchor_RIGHT = 'Destra'
L.Anchor_TOPLEFT = 'Alto Sinistra'
L.Anchor_TOP = 'Alto'
L.Anchor_TOPRIGHT = 'Alto Destra'
L.Anchor_BOTTOMLEFT = 'Basso Sinistra'
L.Anchor_BOTTOM = 'Basso'
L.Anchor_BOTTOMRIGHT = 'Basso Destra'

--groups
L.Groups = 'Gruppi'
L.Group_base = 'Predefibito'
L.Group_action = 'Azioni'
L.Group_aura = 'Auree'
L.Group_pet = 'Azioni Famiglio'
L.AddGroup = 'Aggiungi Gruppo...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[Quando abilitata, questa opzione restringerà 
il testo per ridurlo in modo da stare 
dentro frames che sono troppo piccoli.]]

L.SpiralOpacityTip =
 [[Imposta l'opacità delle spirali oscure che vedresti
 sui pulsanti quando c'é un recupero.]]

L.UseAniUpdaterTip =
[[Ottimizza le performances della performance, ma
potrebbe generare crash in alcune configurazioni.
Disabilitare questa opzione risolverà i problemi.]]

L.MinDurationTip =
[[Determina quanto deve essere lungo 
un recupero per mostrare un testo.

Questa impostazione è usata principalmente
per filtrare il recupero globale.]]

L.MinSizeTip =
[[Determina quanto deve essere grande un frame per mostrare il testo.
Più piccolo è il valore, meno cose sono mostrate come testo.
Più grande è il valore, più cose sono mostrate come testo.

Alcuni benchmarks:
100 - Dimensione di un pulsante azione
80  - Dimensione di una classe o di un pulsante d'azione di un famiglio
55  - Dimensione di un beneficio per il frame di un target]]

L.MinEffectDurationTip =
[[Determina quanto deve essere lungo un recupero
perché mostri un effetto finale.
(es, pulsazione/risplendenza)]]

L.MMSSDurationTip =
[[Determina il limite per mostrare
il recupero nel formato MM:SS.]]

L.TenthsDurationTip =
[[Determina il limite per mostrare
i decimi di secondo.]]

L.FontSizeTip =
[[Controlla la larghezza del testo.]]

L.FontOutlineTip =
[[Controlla lo spessore del bordo
attorno al testo.]]

L.UseBlacklistTip =
[[Clicca questo per attivare la lista nera.
Quando attiva, qualsiasi frame che ha come nome uno inserito
nella lista nera non mostrerà nessun recupero.]]

L.FrameStackTip =
[[Attiva la visualizzazione dei nomi
dei frames quando punti il mouse sopra di loro.]]

L.XOffsetTip =
[[Controlla l'offset orizzzontale
del testo.]]

L.YOffsetTip =
[[Controlla l'offset verticale
del testo.]]