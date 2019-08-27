-- OmniCC configuration localization - French
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "frFR")
if not L then return end

L.GeneralSettings = "Affichage"
L.FontSettings = "Style du texte"
L.RuleSettings = "Règles"
L.PositionSettings = "Position du texte"

L.Font = "Police"
L.FontSize = "Taille des caractères"
L.FontOutline = "Contours"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "Fin"
L.Outline_THICKOUTLINE = "Epais"
L.Outline_OUTLINEMONOCHROME = "Monochrome"

L.MinDuration = "Durée minimale d'affichage du texte"
L.MinSize = "Taille minimale d'affichage du texte"
L.ScaleText = "Mettre automatiquement le texte à l'échelle du cadre"
L.EnableText = "Activer le texte du cooldown"

L.Add = "Ajouter"
L.Remove = "Supprimer"

L.FinishEffect = "Effet final"
L.MinEffectDuration = "Durée minimale d'affichage de l'effet final"

L.MMSSDuration = "Durée minimale d'affichage du texte (min:sec)"
L.TenthsDuration = "Durée minimale pour afficher les dixièmes de secondes"

L.ColorAndScale = "Coleur et échelle"
L.Color_soon = "Point d'expiration"
L.Color_seconds = "En dessous d'une minute"
L.Color_minutes = "En dessous d'une heure"
L.Color_hours = "Une heure ou plus"

L.SpiralOpacity = "Transparence des modèles de cooldown"
L.UseAniUpdater = "Optimiser la performance"

--text positioning
L.XOffset = "Positionnement horizontal"
L.YOffset = "Positionnement vertical"

L.Anchor = 'Ancrage'
L.Anchor_LEFT = 'Gauche'
L.Anchor_CENTER = 'Centre'
L.Anchor_RIGHT = 'Droite'
L.Anchor_TOPLEFT = 'Haut Gauche'
L.Anchor_TOP = 'Haut'
L.Anchor_TOPRIGHT = 'Haut droit'
L.Anchor_BOTTOMLEFT = 'Bas Gauche'
L.Anchor_BOTTOM = 'Bas'
L.Anchor_BOTTOMRIGHT = 'Bas Droite'

--groups
L.Groups = 'Groupes'
L.Group_default = 'Défaut'
L.Group_action = 'Actions'
L.Group_aura = 'Auras'
L.Group_pet = 'Sorts des familiers'
L.AddGroup = 'Ajouter Groupe...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[Lorsqu'il est activé, ce paramètre
force le texte à s'adapter aux cadres
qui sont trop petits.]]

L.SpiralOpacityTip = [[Définit la transparence du spirale sombre que vous voyez
normalement sur les boutons de sorts pendant un cooldown.]]

L.UseAniUpdaterTip =
[[Optimise la performance du processeur, mais peut
faire planter le client sur certains environnements.
La désactivation de cette option corrigera le problème.]]

L.UseAniUpdaterSmallTip = "|cffff2020Ce changement nécéssite de relancer le client.|r"

L.MinDurationTip =
[[Détermine la durée minimale qu'un cooldown
doit avoir pour afficher le texte.

Cette option est principalement utilisée
pour filtrer les cooldowns globaux.]]

L.MinSizeTip =
[[Détermine la taille que doit avoir un cadre pour afficher du texte.
Plus cette valeur sera petite, plus les cadres pouront être petits.
Plus cette valeur sera grande, plus les cadres devront être gros.

Quelques repères:
100 - Taille d'un bouton d'action
80  - Taille d'un sort de classe ou d'un bouton de sorts de familier
55  - Taille d'une icône de buff]]

L.MinEffectDurationTip =
[[Détermine quelle durée minimale
doit avoir un cooldown pour
l'affichage de l'effet final
(ex: Pulsation/Brillance)]]

L.MMSSDurationTip =
[[Détermine le seuil pour l'affichage
du texte d'un cooldown au format
Min:Sec.]]

L.TenthsDurationTip =
[[Détermine le seuil pour l'affichage
des dixièmes de secondes.]]

L.FontSizeTip =
[[Contrôle la taille du texte.]]

L.FontOutlineTip =
[[Contrôle l'épaisseur
des contours du texte.]]

L.UseBlacklistTip =
[[Cliquez sur cette option pour
envoyer l'élément dans la blacklist.
Lorsqu'elle est activée, chaque sort avec
une concordance de nom dans la blacklist
n'affichera pas de texte de cooldown.]]

L.FrameStackTip =
[[Active l'affichage du nom des
cadres quand vous les survolez.]]

L.XOffsetTip =
[[Contrôle du positionnement
horizontal du texte.]]

L.YOffsetTip =
[[Contrôle du positionnement
vertical du texte.]]