local AddonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "ruRU")
if not L then return end

-- timer formats
L.DaysFormat = "%dd"
L.HoursFormat = "%dч"
L.MinutesFormat = "%dм"
L.MMSSFormat = "%d:%02d"
L.SecondsFormat = "%d"
L.TenthsFormat = "%0.1f"

-- effect names
L.Activate = "Активировать"
L.Alert = "Оповещение"
L.Flare = "Вспышка"
L.None = NONE
L.Pulse = "Пульс"
L.Shine = "Сияние"

-- effect tooltips
L.ActivateTip = [[Применяет эффект срабатывания способности к значку перезарядки.]]
L.AlertTip = [[Пульсирует значок завершенного восстановления в центре экрана.]]
L.PulseTip = [[Пульсирует значок восстановления .]]

-- other
L.ConfigMissing = "%s не удалось загрузить, поскольку этот аддон %s"
L.Version = "Вы используете версию |cffFCF75EOmniCC (%s)|r"
