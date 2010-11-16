--[[
	OmniCC configuration interface localization - koKR
--]]

if GetLocale() ~= 'koKR' then return end

local L = OMNICC_LOCALS

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

L.MinDuration = "문자를 표시할 최소 지속 시간"
L.MinSize = "문자를 표시할 최소 글꼴 크기"
L.ScaleText = "자동으로 문자 크기를 프레임 안에 맞추기"
L.EnableText = "재사용 대시기간 문자 사용"

L.Add = "추가"
L.Remove = "제거"

L.FinishEffect = "마지막 효과"
L.MinEffectDuration = "마지막 효과를 표시할 최소 지속 시간"

L.MMSSDuration = "MM:SS 형식으로 텍스트를 표시할 최소 지속 시간"
L.TenthsDuration = "0.1초 단위로 표시할 최소 지속 시간"

L.ColorAndScale = "색상과 크기"
L.Color_soon = "곧 만료"
L.Color_seconds = "1분 이하"
L.Color_minutes = "1시간 이하"
L.Color_hours = "1시간 또는 이상"

L.ShowCooldownModels = "재사용 대기시간 모델 표시"

--text positioning
L.XOffset = "X 간격"
L.YOffset = "Y 간격"

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
L.Group_base = '기본'
L.Group_action = '행동 단축바'
L.Group_aura = '오라'
L.Group_pet = '소환수 행동 단축바'
L.AddGroup = '그룹 추가...'

--[[ Tooltips ]]--

L.ScaleTextTip =
[[활성화 되면, 프레임이 너무 작을 경우 그 프레임에 맞춰 문자를 축소시킵니다.]]

L.ShowCooldownModelsTip =
[[재사용 대기시간 모델을 표시합니다.
(재사용 대기시간일때 어두운 나선형 버튼이 표시됩니다.)]]

L.MinDurationTip =
[[재사용 대기시간 문자 표시시간을 설정합니다.

이 설정은 대부분 글로벌 재사용 대기시간 필터링에 사용됩니다.]]

L.MinSizeTip =
[[얼마나 큰 프레임 문자를 표시할지 결정합니다.
작은 값, 작은 문자를 표시합니다.
큰 값, 큰 문자를 표시합니다.

일부 벤치마크 :
100 - 행동 단축바의 크기
80  - 직업이나 소환수 행동 단축바의 크기
55  - 블리자드 대상 프레임 버프의 크기]]

L.MinEffectDurationTip =
[[마무리 효과의 재사용 대기시간을
얼마동안 표시할지 결정합니다. (예, 맥박/반짝임)]]

L.MMSSDurationTip =
[[재사용 대기시간의 남은 시간을
MM:SS 형태로 표시할 시간을 결정합니다.]]

L.TenthsDurationTip =
[[0.1초 단위로 표시할 시간을 결정합니다.]]

L.FontSizeTip =
[[문자 크기를 조절합니다.]]

L.FontOutlineTip =
[[문자 외곽선을 조절합니다.]]

L.UseBlacklistTip =
[[이걸 클릭해서 블랙리스트 사용을 토글하세요.
활성화 되면, 블랙리스트에 포함된 문자와 일치하는
프레임의 문자는 표시하지 않습니다.]]

L.FrameStackTip =
[[마우스오버 시 해당 프레임의
이름을 표시할 지를 토글합니다.]]

L.XOffsetTip =
[[문자의 수평 간격을 조절합니다.]]

L.YOffsetTip =
[[문자의 수직 간격을 조절합니다.]]