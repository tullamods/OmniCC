-- OmniCC configuration interface localization - Russian
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "ruRU")
if not L then return end

L.Anchor = 'Якорь'
L.Anchor_BOTTOM = 'Внизу'
L.Anchor_BOTTOMLEFT = 'ВнизуСлева'
L.Anchor_BOTTOMRIGHT = 'ВнизуСправа'
L.Anchor_CENTER = 'По центру'
L.Anchor_LEFT = 'Слева'
L.Anchor_RIGHT = 'Справа'
L.Anchor_TOP = 'Вверху'
L.Anchor_TOPLEFT = 'ВверхуСлева'
L.Anchor_TOPRIGHT = 'ВверхуСправа'
L.ColorAndScale = 'Цвет и масштаб'
L.ColorAndScaleDesc = 'Настройте цвет и масштаб для различных состояний восстановления.'
L.CooldownOpacity = 'Непрозрачность'
L.CooldownOpacityDesc = 'Изменить степень непрозрачности'
L.CooldownText = 'Текст восстановления'
L.CreateTheme = 'Создать тему'
L.Display = DISPLAY
L.DisplayGroupDesc = 'Настройте, какие биты информации отображать при перезарядке и когда.'
L.Duration = 'Продолжительность'
L.EnableCooldownSwipes = 'Отрисовка перезарядок'
L.EnableCooldownSwipesDesc = 'Свайпы перезарядки — это темный фон, показывающий время, оставшееся до конца перезарядки'
L.EnableText = 'Отображать текста восстановления'
L.EnableTextDesc = 'Отображение оставшегося времени восстановления.'
L.FinishEffect = 'Завершающий эффект'
L.FinishEffectDesc = 'Настройте эффект, который будет срабатывать по окончании восстановления.'
L.FinishEffects = 'Завершающие эффекты'
L.FontFace = 'Шрифт'
L.FontOutline = 'Контур шрифта'
L.FontSize = 'Размер шрифта'
L.HorizontalOffset = 'Горизонтальное смещение'
L.MinDuration = 'Минимальная продолжительность восстановления'
L.MinDurationDesc = 'Как долго (в секундах) должно быть время восстановления для отображения текста восстановления.'
L.MinEffectDuration = 'Минимальная продолжительность восстановления'
L.MinEffectDurationDesc = 'Каким должно быть время восстановления, чтобы сработал финишный эффект.'
L.MinSize = 'Минимальный размер восстановления'
L.MinSizeDesc =
    'Насколько большим должно быть что-то, чтобы отображался текст восстановления. 100 - это размер кнопки обычного действия, 80 - размер кнопки действия питомца, а 47 - размер дебаффа на кадре цели Blizzard.'
L.MMSSDuration = 'Порог отображения MM:SS'
L.MMSSDurationDesc = 'Когда начинать отображение оставшегося времени восстановления в формате MM:SS.'
L.Outline_NONE = NONE
L.Outline_OUTLINE = 'Тонкий'
L.Outline_OUTLINEMONOCHROME = 'Одноцветный'
L.Outline_THICKOUTLINE = 'Толстый'
L.Preview = PREVIEW
L.RuleAdd = 'Добавить правило'
L.RuleAddDesc = 'Создание нового правила.'
L.RuleEnable = ENABLE
L.RuleEnableDesc = 'Включает это правило. Если правило отключено, OmniCC пропустит его проверку. '
L.RulePatterns = 'Шаблоны'
L.RulePatternsDesc =
    'Имена или части имен элементов пользовательского интерфейса, к которым должно применяться это правило. Каждый шаблон следует вводить в отдельной строке.'
L.RulePriority = 'Приоритет'
L.RulePriorityDesc =
    'Правила оцениваются по возрастанию. Первое совпадение будет применено к перезарядке.'
L.RuleRemove = REMOVE
L.RuleRemoveDesc = 'Удаление правила.'
L.Rules = 'Правила'
L.RulesDesc =
    'Правила можно использовать для применения тем к определенным элементам вашего пользовательского интерфейса. Если для определенного элемента пользовательского интерфейса нет правил, то он будет использовать тему по умолчанию.'
L.Rulesets = 'Наборы правил'
L.RuleTheme = 'Тема'
L.RuleThemeDesc = 'Какую тему применить к элементам пользовательского интерфейса, которые соответствуют этому правилу.'
L.ScaleText = 'Измените размер текста восстановления, чтобы он помещался в кадры'
L.ScaleTextDesc = 'Автоматически настраивать размер текста шрифта восстановления в зависимости от того, насколько велико время восстановления.'
L.State_charging = 'Восстановление зарядов'
L.State_controlled = 'Потеря контроля'
L.State_days = 'Остался день'
L.State_hours = 'Остался час'
L.State_minutes = 'Осталось менее часа'
L.State_seconds = 'Осталось менее минуты'
L.State_soon = 'Скоро истечет'
L.TenthsDuration = 'Порог отображения десятых секунды'
L.TenthsDurationDesc = 'Когда запускать отображения оставшегося времени восстановления в формате 0.1.'
L.TextColor = 'Цвет текста'
L.TextFont = 'Шрифт текста'
L.TextPosition = 'Расположение текста'
L.TextShadow = 'Тень текста'
L.TextShadowColor = COLOR
L.TextSize = 'Размер текста'
L.Theme = 'Тема'
L.ThemeAdd = 'Добавить тему'
L.ThemeAddDesc = 'Создание новой темы.'
L.ThemeRemove = REMOVE
L.ThemeRemoveDesc = 'Удаление темы.'
L.Themes = 'Темы'
L.ThemesDesc =
    "Тема - это набор настроек внешнего вида OmniCC. Темы можно использовать в сочетании с правилами для изменения OmniCC в определенных частях вашего пользовательского интерфейса."
L.Typography = 'Типография'
L.TypographyDesc = 'Настройте внешний вид текста с задержкой, например, какой шрифт использовать.'
L.VerticalOffset = 'Вертикальное смещение'

L.TimerOffset = 'Смещение таймера (ms)'
L.TimerOffsetDesc =
    'Отнимает количество времени из отображения текста таймера восстановления. Вы можете использовать это, например, чтобы закончить текст таймера, когда вы можете поставить в очередь способность.'
