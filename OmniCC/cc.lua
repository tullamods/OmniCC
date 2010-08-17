--[[
	cc.lua
		Displays text for cooldowns on widgets
--]]

--globals!
local Classy = LibStub('Classy-1.0')
local OmniCC = OmniCC

--constants!
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEHALFISH, MINUTEISH, SOONISH = 3600 * 23.5, 60 * 59.5, 89.5, 59.5, 5.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times
local PADDING = 4 --amount of spacing between the timer text and the rest of the cooldown

--local bindings!
local floor = math.floor
local min = math.min
local round = function(x) return floor(x + 0.5) end
local GetTime = GetTime


--[[
	the cooldown timer object:
		displays time remaining for the given cooldown
--]]

local Timer = Classy:New('Frame'); Timer:Hide(); OmniCC.Timer= Timer
local timers = {}

--starts the timer for the given cooldown
function Timer:Start(cooldown, start, duration)
	local timer = self:Get(cooldown) or self:New(cooldown)
	timer.start = start
	timer.duration = duration
	timer.enabled = true
	timer.nextUpdate = 0

	if not self:GetHider(cooldown) then
		self:CreateHider(cooldown)
	end

	if timer.fontSize >= OmniCC:GetMinFontSize() then
		timer:Show()
	end
end

--stops the timer
function Timer:Stop()
	self.enabled = nil
	self.textStyle = nil
	self:Hide()
end

--returns a new timer object
function Timer:New(cooldown)
	local timer = self:Bind(CreateFrame('Frame', nil, cooldown:GetParent())); timer:Hide()
	timer.cooldown = cooldown

	--we set the timer to the center of the cooldown and manually set size information in order to allow me to scale text
	--if we do set all points instead, then timer text tends to move around when the timer itself is scaled
	timer:SetPoint('CENTER', cooldown)
	timer:SetSize(cooldown:GetSize())

	--current theory: if I use toplevel, then people get FPS issues
	timer:SetFrameLevel(cooldown:GetFrameLevel() + 3)

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', 0, 0)
	timer.text = text

	timer:SetScript('OnUpdate', Timer.OnUpdate)
	timer:OnSizeChanged(timer:GetSize())

	timers[cooldown] = timer
	return timer
end

function Timer:Get(cooldown)
	return timers[cooldown]
end

--forces the given timer to update on the next frame
function Timer:ForceUpdate()
	self.nextUpdate = 0
	self:Show()
end

--adjust font size whenever the timer's parent size changes
--hide if it gets too tiny
function Timer:OnSizeChanged(width, height)
	self:SetSize(width, height)
	self:UpdateFont()
end

--update timer text if its time to update again
function Timer:OnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		self:UpdateText()
	end
end

--update timer text
--if forceStyleUpdate is true, then update style information even if the periodStyle has yet to change
function Timer:UpdateText(forceStyleUpdate)
	--if there's time left on the clock, then update the timer text
	--otherwise stop the timer
	local remain = self.duration - (GetTime() - self.start)
	if remain > 0 then
		local time, nextUpdate = self:GetTimeText(remain)
		self.text:SetText(time)

		--update text scale/color info if the time period has changed
		--of we're forcing an update (used for config live updates)
		local textStyle = self:GetPeriodStyle(remain)
		if (textStyle ~= self.textStyle) or forceStyleUpdate then
			local r, g, b, a, s = OmniCC:GetPeriodStyle(textStyle)
			self.text:SetTextColor(r, g, b, a)
			self:SetScale(s)
			self.textStyle = textStyle
		end

		self.nextUpdate = nextUpdate
	else
		self:Stop()

		--if the timer was long enough to trigger a finish effect, then display the effect
		if self.duration >= OmniCC:GetMinEffectDuration() then
			OmniCC:TriggerEffect(self.cooldown)
		end
	end
end

function Timer:UpdateFont(forceFontUpdate)
	--retrieve font info and font size settings
	local font, fontSize, outline = OmniCC:GetFontInfo()
	if OmniCC:ScalingText() then
		fontSize = fontSize * (round(self:GetWidth() - PADDING) / ICON_SIZE)
	end

	--update only if we've changed font or size
	if fontSize ~= self.fontSize or forceFontUpdate then
		self.fontSize = fontSize

		--if font size is less than the minimum font size, then hide the timer, otherwise update the font
		if fontSize < OmniCC:GetMinFontSize() then
			self:Hide()
		else
			local fontSet = self.text:SetFont(font, fontSize, outline)

			--fallback to the standard font if the font we tried to set happens to be invalid
			if not fontSet then
				self.text:SetFont(STANDARD_TEXT_FONT, fontSize, outline)
			end

			--show the timer if it was hidden, but can be shown now
			if self:ShouldShow() and (not self:IsShown()) then
				self:ForceUpdate()
			end
		end
	end
end

--returns true if the timer should be shown
--and false otherwise
function Timer:ShouldShow()
	--the timer should have text to display
	if not self.enabled then
		return false
	end

	--the timer's parent cooldown should be visible
	if not self.cooldown:IsVisible() then
		return false
	end

	--the timer should have text that's large enough to display
	if self.fontSize < OmniCC:GetMinFontSize() then
		return false
	end

	--the cooldown of the timer shouldn't be blacklisted
	if self.cooldown.noCooldownCount then
		return false
	end

	return true
end

--returns both what text to display, and how long until the next update
function Timer:GetTimeText(s)
	--show tenths of seconds below tenths threshold
	local tenths = OmniCC:GetTenthsDuration()
	if s < tenths then
		return format('%.1f', s), (s*100 - floor(s*100)) / 100
	--format text as seconds when at 90 seconds or below
	elseif s < MINUTEHALFISH then
		local seconds = round(s)
		--update more frequently when near the tenths threshold
		if s < (tenths + 0.5) then
			return seconds, (s*10 - floor(s*10)) / 10
		end
		return seconds, s - (seconds - 0.51)
	--format text as MM:SS when below the MM:SS threshold
	elseif s < OmniCC:GetMMSSDuration() then
		return format('%d:%02d', s/MINUTE, s%MINUTE), s - floor(s)
	--format text as minutes when below an hour
	elseif s < HOURISH then
		local minutes = round(s/MINUTE)
		return minutes .. 'm', minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	--format text as hours when below a day
	elseif s < DAYISH then
		local hours = round(s/HOUR)
		return hours .. 'h', hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	--format text as days
	else
		local days = round(s/DAY)
		return days .. 'd', days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

--retrieves the period style id associated with the given time frame
--necessary to retrieve text coloring information from omnicc
function Timer:GetPeriodStyle(s)
	if s < SOONISH then
		return 'soon'
	elseif s < MINUTEISH then
		return 'seconds'
	elseif s <  HOURISH then
		return 'minutes'
	else
		return 'hours'
	end
end

--utility function: applies the function f to all timers
function Timer:ForAllShown(f, ...)
	if type(f) == 'string' then
		f = self[f]
	end

	for _, timer in pairs(timers) do
		if timer:IsShown() then
			f(timer, ...)
		end
	end
end

function Timer:ForAllShownCooldowns(f, ...)
	for cooldown, timer in pairs(timers) do
		if cooldown:IsShown() then
			f(cooldown, ...)
		end
	end
end

--[[
	Hider, an object parented to the cooldown object that controls the sizing/visibility of the timer object
		the reason that we need this is so that we can show the timer, even if the cooldown happens to be completely transparent (the hide cooldown model option)
		the other reason its necessary is that the onsizechanged event doesn't like me :P
--]]
do
	local hiders = {}

	--show the timer when the cooldown is shown and it meets the ShouldShow criteria
	local function Hider_OnShow(self)
		local timer = Timer:Get(self:GetParent())
		if timer:ShouldShow() and (not timer:IsShown()) then
			timer:ForceUpdate()
		end
	end

	--hide the timer when the cooldown hides
	local function Hider_OnHide(self)
		local timer = Timer:Get(self:GetParent())
		timer:Hide()
	end

	--passthrough onsized changed events to the timer associated with the hider/cooldown
	--necessary since OnSizeChanged does not seem to fire when manually hidden
	local function Hider_OnSizeChanged(self, ...)
		local timer = Timer:Get(self:GetParent())
		timer:OnSizeChanged(...)
	end

	function Timer:CreateHider(cooldown)
		local hider = CreateFrame('Frame', nil, cooldown)
		hider:SetAllPoints(cooldown)

		hider:SetScript('OnShow', Hider_OnShow)
		hider:SetScript('OnHide', Hider_OnHide)
		hider:SetScript('OnSizeChanged', Hider_OnSizeChanged)

		hiders[cooldown] = hider
		return hider
	end

	function Timer:GetHider(cooldown)
		return hiders[cooldown]
	end
end


--[[
	the cooldown hook to display the timer
--]]
do
	local function cooldown_IsBlacklisted(self)
		return (OmniCC:UsingBlacklist() and OmniCC:IsBlacklisted(self)) or self.noCooldownCount
	end

	local function cooldown_OnSetCooldown(self, start, duration)
		--hide cooldown model as necessary
		self:SetAlpha(OmniCC:ShowingCooldownModels() and 1 or 0)

		--start timer
		if start > 0 and duration >= OmniCC:GetMinDuration() and (not cooldown_IsBlacklisted(self)) then
			Timer:Start(self, start, duration)
		--stop timer
		else
			local timer = Timer:Get(self)
			if timer then
				timer:Stop()
			end
		end
	end

	hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', cooldown_OnSetCooldown)
end

--bugfix: force update timers when entering an arena
do
	local f = CreateFrame('Frame'); f:Hide()
	f:SetScript('OnEvent', function() Timer:ForAllShown('UpdateText') end)
	f:RegisterEvent('PLAYER_ENTERING_WORLD')
end