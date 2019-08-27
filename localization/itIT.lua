-- OmniCC Config Localization - Italian
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "itIT")
if not L then return end

L.GeneralSettings = "Visualizzazione"
L.FontSettings = "Stile del testo"
L.RuleSettings = "Regole"
L.PositionSettings = "Posizione del testo"

L.Font = "Carattere"
L.FontSize = "Dimensione del carattere"
L.FontOutline = "Bordo del carattere"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "Sottile"
L.Outline_THICKOUTLINE = "Spesso"
L.Outline_OUTLINEMONOCHROME = "Monocromatico"

L.MinDuration = "Durata minima per mostrare il testo"
L.MinSize = "Dimensione minima per mostrare il testo"
L.ScaleText = "Scala automaticamente il testo per adattarlo ai riquadri"
L.EnableText = "Abilita il testo di recupero"

L.Add = "Aggiungi"
L.Remove = "Rimuovi"

L.FinishEffect = "Effetto conclusivo"
L.MinEffectDuration = "Durata minima per mostrare l'effetto conclusivo"

L.MMSSDuration = "Durata minima per mostrare il testo come MM:SS"
L.TenthsDuration = "Durata minima per mostrare i decimi di secondo"

L.ColorAndScale = "Colore & Proporzione"
L.Color_soon = "Prossimo alla scadenza"
L.Color_seconds = "Meno di un minuto"
L.Color_minutes = "Meno di un'ora"
L.Color_hours = "Un'ora o più"
L.Color_charging = "Ripristina cambiamenti"
L.Color_controlled = "Perdita del controllo"

L.SpiralOpacity = "Trasparenza della spirale"
L.UseAniUpdater = "Ottimizza le prestazioni"

--text positioning
L.XOffset = "Asse X"
L.YOffset = "Asse Y"

L.Anchor = 'Fissare'
L.Anchor_LEFT = 'a Sinistra'
L.Anchor_CENTER = 'al Centro'
L.Anchor_RIGHT = 'a Destra'
L.Anchor_TOPLEFT = 'in Alto a Sinistra'
L.Anchor_TOP = 'in Alto'
L.Anchor_TOPRIGHT = 'in Alto a Destra'
L.Anchor_BOTTOMLEFT = 'in Basso a Sinistra'
L.Anchor_BOTTOM = 'in Basso'
L.Anchor_BOTTOMRIGHT = 'in Basso a Destra'

--groups
L.Groups = 'Gruppi'
L.Group_default = 'Predefinito'
L.Group_action = 'Azioni'
L.Group_aura = 'Aure'
L.Group_pet = 'Azioni del famiglio'
L.AddGroup = 'Aggiungi un gruppo...'

--[[ Tooltips ]]--

L.ScaleTextTip = [[Quando abilitata, questa opzione causerà il restringimento
del testo per adattarlo ai riquadri che sono troppo piccoli.]]

L.SpiralOpacityTip = [[Imposta l'opacità delle spirali scure, che normalmente vedi
quando un'abilità ha un tempo di recupero.]]

L.UseAniUpdaterTip = [[Ottimizza le prestazioni del processore, ma questo può causare instabilità su alcuni sistemi.
Disabilitare questa opzione potrebbe risolvere il problema.]]

L.MinDurationTip = [[Determina quanto deve essere lungo un tempo di recupero al fine di mostrare il testo.
Principalmente questa opzione viene utilizzata per filtrare il tempo di recupero globale.]]

L.MinSizeTip = [[Determina quanto deve essere grande un riquadro per mostrare il testo.
Minore è il valore, minore saranno le cose mostrate come testo.
Maggiore è il valore, maggiori sono le cose mostrate.

Alcuni valori:
100 - La grandezza di un bottone della barra azione
80  - La grandezza della barra azione di classe o del famiglio
55  - La grandezza delle aure nel riquadro dell'obiettivo]]

L.MinEffectDurationTip = [[Determina quanto deve essere lungo un tempo di recupero
per poter mostrare l'effetto conclusivo (es: Pulsante, Splendente)]]

L.MMSSDurationTip = [[Determina la soglia per mostrare il tempo di recupero nel formato MM:SS.]]

L.TenthsDurationTip = [[Determina la soglia per mostrare i decimi di secondo.]]

L.FontSizeTip = [[Controlla quanto deve essere largo il testo.]]

L.FontOutlineTip = [[Controlla lo spessore dei bordi attorno al testo.]]

L.UseBlacklistTip = [[Clicca qui per abilitare l'ausilio della lista nera.
Quando attivo, qualsiasi riquadro con il nome corrispondente, inserito nella lista nera, non verrà mostrato il tempo di recupero sotto forma di testo.]]

L.FrameStackTip = [[Attiva la visualizzazione dei nomi nei riquadri al passaggio del mouse.]]

L.XOffsetTip = [[Controlla l'asse orizzontale del testo.]]

L.YOffsetTip = [[Controlla l'asse verticale del testo.]]
