local AddonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(AddonName, "koKR")
if not L then return end

-- timer formats
L.DaysFormat = "%d일"
L.HoursFormat = "%d시간"
L.MinutesFormat = "%d분"
L.MMSSFormat = "%d:%02d"
L.SecondsFormat = "%d"
L.TenthsFormat = "%0.1f"

-- effect names
L.Activate = "활성화"
L.Alert = "경보"
L.Flare = "섬광"
L.None = NONE
L.Pulse = "맥박"
L.Shine = "빛남"

-- effect tooltips
L.ActivateTip = [[재사용 대기시간 아이콘에 기술 사용 가능 효과를 적용합니다.]]
L.AlertTip = [[화면 중앙에 재사용 대기시간이 끝난 아이콘이 나타납니다.]]
L.PulseTip = [[재사용 대기시간 아이콘에 맥박 효과를 줍니다.]]

-- other
L.ConfigMissing = "애드온이 %2$s 상태라서 %1$s|1을;를; 불러오지 못했습니다"
L.Version = "|cffFCF75EOmniCC 버전 (%s)|r|1을;를; 사용 중 입니다."
