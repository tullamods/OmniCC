if GetLocale() ~= 'koKR' then return end
local L = OMNICC_LOCALS

-- timer formats 
L.TenthsFormat = '%.1f' 
L.MMSSFormat = '%d:%02d' 
L.MinuteFormat = '%d분' 
L.HourFormat = '%d시간' 
L.DayFormat = '%d일' 
 
-- effect names 
L.None = NON E
L.Pulse = '맥박' 
L.Shine = '빛남' 
L.Alert = '경보' 
L.Activate = '활성화' 
L.Flare = '섬광' 

-- effect tooltips 
L.ActivateTip = [[재사용 대기시간 아이콘에 기술 발생 효과를 줍니다.]] 
L.AlertTip = [[화면 중앙에 종료된
재사용 대기시간 아이콘을 고동칩니다.]] 
L.PulseTip = [[재사용 대기시간 아이콘을 고동칩니다.]] 

-- other 
L.ConfigMissing = '애드온이 %2$s 상태여서 %1$s|1을;를; 불러올 수 없습니다' 
L.Version = '|cffFCF75EOmniCC 버전 (%s)|r|1을;를; 사용 중입니다'
