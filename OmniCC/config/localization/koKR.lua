-- OmniCC configuration interface localization - koKR
local L = LibStub("AceLocale-3.0"):NewLocale("OmniCC", "koKR")
if not L then return end

L.GeneralSettings = "표시"
L.FontSettings = "문자 스타일"
L.RuleSettings = "규칙"
L.PositionSettings = "문자 위치"

L.Font = "글꼴"
L.FontSize = "기본 글꼴 크기"
L.FontOutline = "글꼴 외곽선"

L.Outline_NONE = NONE
L.Outline_OUTLINE = "얇게"
L.Outline_THICKOUTLINE = "두껍게"
L.Outline_OUTLINEMONOCHROME = "모노크롬"

L.MinDuration = "문자를 표시할 최소 지속 시간"
L.MinSize = "문자를 표시할 최소 글꼴 크기"
L.ScaleText = "자동으로 문자 크기를 프레임 안에 맞추기"
L.EnableText = "재사용 대기시간 문자 사용"

L.Add = "추가"
L.Remove = "제거"

L.FinishEffect = "마무리 효과"
L.MinEffectDuration = "마무리 효과를 표시할 최소 지속 시간"

L.MMSSDuration = "MM:SS 형식으로 텍스트를 표시할 최소 지속 시간"
L.TenthsDuration = "0.1초 단위로 표시할 최소 지속 시간"

L.ColorAndScale = "색상과 크기"
L.Color_soon = "곧 만료"
L.Color_seconds = "1분 이하"
L.Color_minutes = "1시간 이하"
L.Color_hours = "1시간 이상"
L.Color_charging = "충전량 복원"
L.Color_controlled = "제어 불가 효과"


--text positioning
L.XOffset = "X 위치"
L.YOffset = "Y 위치"

L.Anchor = '위치'
L.Anchor_LEFT = '좌측'
L.Anchor_CENTER = '중앙'
L.Anchor_RIGHT = '우측'
L.Anchor_TOPLEFT = '좌측 상단'
L.Anchor_TOP = '상단'
L.Anchor_TOPRIGHT = '우측 상단'
L.Anchor_BOTTOMLEFT = '좌측 하단'
L.Anchor_BOTTOM = '하단'
L.Anchor_BOTTOMRIGHT = '우측 하단'

--groups
L.Groups = '그룹'
L.Group_default = '기본'
L.Group_action = '행동 단축바'
L.Group_aura = '오라'
L.Group_pet = '소환수 행동 단축바'
L.AddGroup = '그룹 추가...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[활성화하면 프레임이
너무 작을 경우 그 프레임에
맞춰 문자를 축소시킵니다.]]

L.SpiralOpacityTip =
[[재사용 대기 중일 때 버튼에 보이는
검은 나선 소용돌이의 투명도를 설정합니다.]]

L.UseAniUpdaterTip =
[[CPU 성능을 향상시킵니다, 하지만
몇몇 환경에서 오류를 발생할 수 있습니다.
이 옵션을 비활성하면 문제를 해결할 수 있습니다.]]

L.MinDurationTip =
[[재사용 대기시간이 얼마나 길어야
문자를 표시할 지 결정합니다.

이 설정은 보통 전역 재사용 대기시간을
무시하기 위해 사용합니다.]]

L.MinSizeTip =
[[프레임이 얼마나 커야 문자를 표시할 지 결정합니다.
작은 값, 작은 프레임에 문자를 표시할 수 있습니다.
큰 값, 큰 프레임에 표시합니다.

일부 벤치마크 :
100 - 행동 단축바의 크기
80  - 직업이나 소환수 행동 단축바의 크기
55  - 블리자드 대상 프레임 강화 효과의 크기]]

L.MinEffectDurationTip =
[[재사용 대기시간이 얼마나
길어야 마무리 효과를
표시할 지 결정합니다
(예, 맥박/빛남)]]

L.MMSSDurationTip =
[[재사용 대기시간을
MM:SS 형식으로 표시할
시간을 설정합니다.]]

L.TenthsDurationTip =
[[0.1초 단위로 표시할 시간을 결정합니다.]]

L.FontSizeTip =
[[문자 크기를 조절합니다.]]

L.FontOutlineTip =
[[문자 외곽선을 조절합니다.]]

L.UseBlacklistTip =
[[여기를 클릭해서 차단목록 사용을 전환하세요.
활성화하면 차단목록에 있는 항목과
일치하는 이름을 가진 모든 프레임에
재사용 대기시간 문자를 표시하지 않습니다.]]

L.FrameStackTip =
[[마우스오버 시 해당 프레임의
이름 표시 여부를 전환합니다.]]

L.XOffsetTip =
[[문자의 수평 위치를 조절합니다.]]

L.YOffsetTip =
[[문자의 수직 위치를 조절합니다.]]
