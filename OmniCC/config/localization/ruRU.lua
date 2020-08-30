-- OmniCC configuration interface localization - Russian
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "ruRU")
if not L then return end

L.GeneralSettings = "Отображение"
L.FontSettings = "Стиль текста"
L.RuleSettings = "Правила"
L.PositionSettings = "Позиция текста"

L.Font = "Шрифт"
L.FontSize = "Размер шрифта"
L.FontOutline = "Контур шрифта"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "Тонкий"
L.Outline_THICKOUTLINE = "Толстый"

L.MinDuration = "Мин. длительность для отображения текста"
L.MinSize = "Минимальный размер для отображения текста"
L.ScaleText = "Автом-масштабировать текст для вписывания во фреймы"
L.EnableText = "Включить текст Восстановления"

L.Add = "Добавить"
L.Remove = "Удалить"

L.FinishEffect = "Эффект окончания"
L.MinEffectDuration = "Мин. длительность для отображения эффекта окончания"

L.MMSSDuration = "Мин. длительность для отображения текста в MM:SS"
L.TenthsDuration = "Мин. длительность для отображения десятых долях секунд"

L.ColorAndScale = "Окраска и масштаб"
L.Color_soon = "Скоро истекает"
L.Color_seconds = "Меньше чем за минуту"
L.Color_minutes = "Меньше чем за час"
L.Color_hours = "Один час или более"

--text positioning
L.XOffset = "Смещение по X"
L.YOffset = "Смещение по Y"

L.Anchor = 'Якорь'
L.Anchor_LEFT = 'Слева'
L.Anchor_CENTER = 'По центру'
L.Anchor_RIGHT = 'Справа'
L.Anchor_TOPLEFT = 'ВверхуСлева'
L.Anchor_TOP = 'Вверху'
L.Anchor_TOPRIGHT = 'ВверхуСправа'
L.Anchor_BOTTOMLEFT = 'ВнизуСлева'
L.Anchor_BOTTOM = 'Внизу'
L.Anchor_BOTTOMRIGHT = 'BottomСправа'

--groups
L.Groups = 'Группы'
L.Group_default = 'По умолчанию'
L.Group_action = 'Действия'
L.Group_aura = 'Ауры'
L.Group_pet = 'Действия питомца'
L.AddGroup = 'Добавить группу...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[При включении, данная настройка
автоматически сократит текст до
вписывания в фрейм,
если он слишком мал]]

L.MinDurationTip =
[[Определяет, какая длина восстановления
должна быть, чтобы отобразить текст.

Этот параметр используется в основном для
отфильтровываня GCD]]

L.MinSizeTip =
[[Определяет, насколько большой должен быть фрейм чтобы отобразить текст.
Чем меньше значение, тем мелше вещий будут отображать текст.
Чем больше значение, тем больше вещей будут отображать текст.

Some benchmarks:
100 - Размер кнопок действия
80  - Размер классовых кнопок действия или питомца
55  - Размер Blizzard фрейма баффов цели]]

L.MinEffectDurationTip =
[[Определяет, как долго должно длиться
Восстановление перед отображением
эффекта окончания
(Например, импульс / блеск)]]

L.MMSSDurationTip =
[[Определяет порог для
отображения восстановления
в формате MM:SS]]

L.TenthsDurationTip =
[[Определяет порог для
показа десятых долях секунды]]

L.FontSizeTip =
[[Регулировка размера шрифта]]

L.FontOutlineTip =
[[Управление толщины контура вокруг текста]]

L.UseBlacklistTip =
[[Щелкните здесь, чтобы переключить использование черного списка.
Когда включен, любой фрейм с названием,
которое соответствует пункту в черном списке,
не будет отображать текста восстановления.]]

L.FrameStackTip =
[[Переключение отображения названия
фреймов при наведении
на них]]

L.XOffsetTip =
[[Регулировка смещения текста по горизонтале]]

L.YOffsetTip =
[[Регулировка смещения текста по вертикале]]