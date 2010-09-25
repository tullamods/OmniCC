--[[
	cc.lua
		Displays text for cooldowns on widgets

	cases when font size should be updated:
		frame is resized
		font is changed

	cases when text should be hidden:
		scale * fontSize < MIN_FONT_SIE
--]]

--globals!
local Classy = LibStub('Classy-1.0')
local OmniCC = OmniCC

--constants!
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEHALFISH, MINUTEISH, SOONISH = 3600 * 23.5, 60 * 59.5, 89.5, 59.5, 5.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times
local PADDING = 0 --amount of spacing between the timer text and the rest of the cooldown

--local bindings!
local floor = math.floor
local min = math.min
local round = function(x) return floor(x + 0.5) end
local GetTime = GetTime

--[[
	the cooldown timer object:
		displays time remaining for the given cooldown
--]]

local Timer = Classy:New('Frame'); Timer:Hide(); OmniCC.Timer = Timer
local timers = {}

--[[ Constructorish ]]--

function Timer:New(cooldown)
	local timer = Timer:Bind(CreateFrame('Frame', nil, cooldown:GetParent())); timer:Hide()
	timer.cooldown = cooldown

	--current theory: if I use toplevel, then people get FPS issues
--	timer:SetToplevel(true)
	timer:SetFrameLevel(cooldown:GetFrameLevel() + 5)

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', 0, 0)
	text:SetJustifyH('CENTER')
	timer.text = text

	timer:SetScript('OnUpdate', timer.OnUpdate)

	--we set the timer to the center of the cooldown and manually set size information in order to allow me to scale text
	--if we do set all points instead, then timer text tends to move around when the timer itself is scaled
	timer:SetPoint('CENTER', cooldown)

	timer:Size(cooldown:GetSize())

	timers[cooldown] = timer
	return timer
end

function Timer:Get(cooldown)
	return timers[cooldown]
end

--update timer text if its time to update again
function Timer:OnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		self:UpdateText()
	end
end


--[[ Updaters ]]--

--starts the timer for the given cooldown
function Timer:Start(start, duration)
	self.start = start
	self.duration = duration
	self.enabled = true
	self.visible = true
	self.textStyle = nil
	self.nextUpdate = 0

	self:UpdateShown()
	return self
end

--stops the timer
function Timer:Stop()
	self.start = nil
	self.duration = nil
	self.enabled = nil
	self.visible = nil
	self.textStyle = nil
	self.nextUpdate = nil

	self:Hide()
	return self
end

--adjust font size whenever the timer's parent size changes
--hide if it gets too tiny
function Timer:Size(width, height)
	self:SetSize(width, height)
	self:UpdateFont()

	return self
end

--set font to the given settings
function Timer:UpdateFont()
	local font, size, outline = OmniCC:GetFontInfo()
	if OmniCC:ScalingText() then
		size = size * (self:GetWidth() / ICON_SIZE)
	end

	--fallback to the standard font if the font we tried to set happens to be invalid
	if size > 0 then
		local fontSet = self.text:SetFont(font, size, outline)
		if not fontSet then
			self.text:SetFont(STANDARD_TEXT_FONT, size, outline)
		end
	end

	self.fontSize = size
	self:UpdateShown()

	return self
end

--update timer text
--if forceStyleUpdate is true, then update style information even if the periodStyle has yet to change
function Timer:UpdateText(forceStyleUpdate)
	--if there's time left on the clock, then update the timer text
	--otherwise stop the timer
	local remain = self.duration - (GetTime() - self.start)
	if remain > 0 then
		--hide text if it's too small to display
		--check again in one second
		if (self:GetEffectiveScale() * self.fontSize / UIParent:GetScale()) < OmniCC:GetMinFontSize() then
			self.text:Hide()
			self.nextUpdate = 1
		else
			--update font text
			local time, nextUpdate = self:GetTimeText(remain)
			self.text:SetText(time)
			self.text:Show()

			--update text scale/color info if the time period has changed
			--of we're forcing an update (used for config live updates)
			local period = self:GetPeriodStyle(remain)
			if (period ~= self.textStyle) or forceStyleUpdate then
				self.textStyle = period
				self.text:SetTextColor(OmniCC:GetPeriodColor(period))
				self:SetScale(OmniCC:GetPeriodScale(period))
				self.textStyle = textStyle
			end

			self.nextUpdate = nextUpdate
		end
	else
		--if the timer was long enough to, and text is still visible
		--then trigger a finish effect
		if self.duration >= OmniCC:GetMinEffectDuration() and self.text:IsShown() then
			OmniCC:TriggerEffect(self.cooldown, self.duration)
		end
		self:Stop()
	end

	return self
end

function Timer:UpdateShown()
	if self:ShouldShow() then
		self:Show()
	else
		self:Hide()
	end

	return self
end


--[[ Accessors ]]--

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

--returns both what text to display, and how long until the next update
function Timer:GetTimeText(s)
	--show tenths of seconds below tenths threshold
	local tenths = OmniCC:GetTenthsDuration()
	if s < tenths then
		return format('%.1f', s), (s*10 - floor(s*10)) / 10
	--format text as seconds when at 90 seconds or below
	elseif s < MINUTEISH then
		local seconds = round(s)

		--prevent 0 seconds from displaying
		if seconds == 0 then
			return '', s
		end
		--update more frequently when near the tenths threshold
		if s < (tenths + 0.5) then
			return seconds, (s*10 - floor(s*10)) / 10
		end

		return seconds, s - (seconds - 0.51)
	--format text as MM:SS when below the MM:SS threshold
	elseif s < OmniCC:GetMMSSDuration() then
		local seconds = round(s)
		return format('%d:%02d', seconds/MINUTE, seconds%MINUTE), s - (seconds - 0.51)
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

--returns true if the timer should be shown
--and false otherwise
function Timer:ShouldShow()
	--the timer should have text to display and also have its cooldown be visible
	if not (self.enabled and self.visible) then
		return false
	end

	--the timer should have text that's large enough to display
	if self.fontSize < OmniCC:GetMinFontSize() then
		return false
	end

	if self.duration < OmniCC:GetMinDuration() then
		return false
	end

	--the cooldown of the timer shouldn't be blacklisted
	if OmniCC:IsBlacklisted(self.cooldown) then
		return false
	end

	return true
end


--[[ Meta Functions ]]--

function Timer:ForAll(f, ...)
	if type(f) == 'string' then
		f = self[f]
	end

	for _, timer in pairs(timers) do
		f(timer, ...)
	end
end

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
	cooldown display
--]]

--show the timer if the cooldown is shown
local function cooldown_OnShow(self)
--	print('onshow', self:GetName())

	local timer = Timer:Get(self)
	if timer then
		timer.visible = true
		timer:UpdateShown()
	end
end

--hide the timer if the cooldown is hidden
local function cooldown_OnHide(self)
--	print('onhide', self:GetName())

	local timer = Timer:Get(self)
	if timer then
		timer.visible = nil
		timer:UpdateShown()
	end
end

--adjust the size of the timer when the cooldown's size changes
local function cooldown_OnSizeChanged(self, ...)
--	print('onsizechanged', self:GetName(), ...)

	local timer = Timer:Get(self)
	if timer then
		timer:Size(...)
	end
end

--apply some extra functionality to the cooldown
local function cooldown_Init(self)
--	print('init', self:GetName())

	self:HookScript('OnShow', cooldown_OnShow)
	self:HookScript('OnHide', cooldown_OnHide)
	self:HookScript('OnSizeChanged', cooldown_OnSizeChanged)
	self.omnicc = true

	return self
end

local function cooldown_OnSetCooldown(self, start, duration)
--	print('onsetcooldown', self:GetName(), start, duration)

	--don't display cooldown info if the timer is blacklisted
	if OmniCC:IsBlacklisted(self) then
		return
	end

	--create timer if it does not exist yet
	if(not self.omnicc) then
		cooldown_Init(self)
	end

	--hide cooldown model as necessary
	self:SetAlpha(OmniCC:ShowingCooldownModels() and 1 or 0)

	--start timer if duration is over the min duration
	if start > 0 and duration >= OmniCC:GetMinDuration() then
		(Timer:Get(self) or Timer:New(self)):Start(start, duration)
	--stop timer
	else
		local timer = Timer:Get(self)
		if timer then
			timer:Stop()
		end
	end
end

hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', cooldown_OnSetCooldown)

--bugfix: force update timers when entering an arena
do
	local f = CreateFrame('Frame'); f:Hide()
	f:SetScript('OnEvent', function() Timer:ForAllShown('UpdateText') end)
	f:RegisterEvent('PLAYER_ENTERING_WORLD')
end