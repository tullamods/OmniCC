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
local DAYISH, HOURISH, MINUTEISH, SOONISH = 3600 * 23.5, 60 * 59.5, 59.5, 5.5 --used for formatting text at transition points
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
	local timer = Timer:Bind(CreateFrame('Frame', nil, cooldown:GetParent())); timer.cooldown = cooldown
	timer:SetFrameLevel(cooldown:GetFrameLevel() + 5)
	timer:Hide()

	timer.text = timer:CreateFontString(nil, 'OVERLAY')

	--we set the timer to the center of the cooldown and manually set size information in order to allow me to scale text
	--if we do set all points instead, then timer text tends to move around when the timer itself is scale)
	timer:SetPoint('CENTER', cooldown)
	timer:Size(cooldown:GetSize())

	timers[cooldown] = timer
	return timer
end

function Timer:Get(cooldown)
	return timers[cooldown]
end

function Timer:OnScheduledUpdate()
	--print('Timer:OnScheduledUpdate')
	
	self:UpdateText()
end


--[[ Updaters ]]--

--starts the timer for the given cooldown
function Timer:Start(start, duration)
	self.start = start
	self.duration = duration
	self.enabled = true
	self.visible = self.cooldown:IsVisible()
	self.textStyle = nil

	self:UpdateShown()
end

--stops the timer
function Timer:Stop()
	self.start = nil
	self.duration = nil
	self.enabled = nil
	self.visible = nil
	self.textStyle = nil

	self:CancelUpdate()
	self:Hide()
end

--adjust font size whenever the timer's parent size changes
--hide if it gets too tiny
function Timer:Size(width, height)
	self.abRatio = round(width) / ICON_SIZE

	self:SetSize(width, height)
	self:UpdateTextPosition()

	if self.enabled and self.visible then
		self:UpdateText(true)
	end
end

function Timer:UpdateText(forceStyleUpdate)
	--print('Timer:UpdateText', forceStyleUpdate)
	
	--handle deathknight runes, which have timers that start in the future
	if self.start > GetTime() then
		self:ScheduleUpdate(self.start - GetTime())
		return
	end

	--if there's time left on the clock, then update the timer text
	--otherwise stop the timer
	local remain = self:GetRemain()
	if remain > 0 then
		local overallScale = self.abRatio * (self:GetEffectiveScale()/UIParent:GetScale()) --used to determine text visibility

		--hide text if it's too small to display
		--check again in one second
		if overallScale < self:GetSettings().minSize then
			self.text:Hide()
			self:ScheduleUpdate(1)
		else
			--update text style based on time remaining
			local styleId = self:GetTextStyleId(remain)
			if (styleId ~= self.textStyle) or forceStyleUpdate then
				self.textStyle = styleId
				self:UpdateTextStyle()
			end

			--make sure that we have text, and then set text
			if self.text:GetFont() then
				self.text:SetFormattedText(self:GetTimeText(remain))
				self.text:Show()
			end
			self:ScheduleUpdate(self:GetNextUpdate(remain))
		end
	else
		--if the timer was long enough to, and text is still visible
		--then trigger a finish effect
		if self.duration >= self:GetSettings().minEffectDuration then
			OmniCC:TriggerEffect(self:GetSettings().effect, self.cooldown, self.duration)
		end
		self:Stop()
	end
end

function Timer:UpdateTextStyle()
	--print('Timer:UpdateTextStyle')
	
	local sets = self:GetSettings()
	local font, size, outline = sets.fontFace, sets.fontSize, sets.fontOutline
	local style = sets.styles[self.textStyle]
	if sets.scaleText then
		size = size * style.scale * (self.abRatio or 1)
	else
		size = size * style.scale
	end

	--fallback to the standard font if the font we tried to set happens to be invalid
	if size > 0 then
		local fontSet = self.text:SetFont(font, size, outline)
		if not fontSet then
			self.text:SetFont(STANDARD_TEXT_FONT, size, outline)
		end
	end
	self.text:SetTextColor(style.r, style.g, style.b, style.a)
end

function Timer:UpdateTextPosition()
	local sets = self:GetSettings()
	local abRatio = self.abRatio or 1

	local text = self.text
	text:ClearAllPoints()
	text:SetPoint(sets.anchor, sets.xOff * abRatio, sets.yOff * abRatio)
end

function Timer:UpdateShown()
	if self:ShouldShow() then
		self:Show()
		self:UpdateText()
	else
		self:Hide()
	end
end

function Timer:UpdateCooldownShown()
	self.cooldown:SetAlpha(self:GetSettings().showCooldownModels and 1 or 0)
end


--[[ Update Scheduling ]]--

function Timer:ScheduleUpdate(delay)
	--print('Timer:ScheduleUpdate', delay)
	OmniCC:ScheduleUpdate(self, delay)
end

function Timer:CancelUpdate()
	--print('Timer:CancelUpdate')
	OmniCC:CancelUpdate(self)
end


--[[ Accessors ]]--

function Timer:GetRemain()
	return self.duration - (GetTime() - self.start)
end

--retrieves the period style id associated with the given time frame
--necessary to retrieve text coloring information from omnicc
function Timer:GetTextStyleId(s)
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

--return the time until the next text update
function Timer:GetNextUpdate(remain)
	local sets = self:GetSettings()

	if remain < (sets.tenthsDuration + 0.5) then
		return 0.1
	elseif remain < MINUTEISH then
		return remain - (round(remain) - 0.51)
	elseif remain < sets.mmSSDuration then
		return remain - (round(remain) - 0.51)
	elseif remain < HOURISH then
		local minutes = round(remain/MINUTE)
		if minutes > 1 then
			return remain - (minutes*MINUTE - HALFMINUTEISH)
		end
		return remain - (MINUTEISH - 0.01)
	elseif remain < DAYISH then
		local hours = round(remain/HOUR)
		if hours > 1 then
			return remain - (hours*HOUR - HALFHOURISH)
		end
		return remain - (HOURISH - 0.01)
	else
		local days = round(remain/DAY)
		if days > 1 then
			return remain - (days*DAY - HALFDAYISH)
		end
		return remain - (DAYISH - 0.01)
	end
end

--returns a format string, as well as any args for text to display
function Timer:GetTimeText(remain)
	local sets = self:GetSettings()

	--show tenths of seconds below tenths threshold
	if remain < sets.tenthsDuration then
		return '%.1f', remain
	--format text as seconds when at 90 seconds or below
	elseif remain < MINUTEISH then
		--prevent 0 seconds from displaying
		local seconds = round(remain)
		return (seconds == 0 and '') or seconds
	--format text as MM:SS when below the MM:SS threshold
	elseif remain < sets.mmSSDuration then
		local seconds = round(remain)
		return '%d:%02d', seconds/MINUTE, seconds%MINUTE
	--format text as minutes when below an hour
	elseif remain < HOURISH then
		return '%dm', round(remain/MINUTE)
	--format text as hours when below a day
	elseif remain < DAYISH then
		return '%dh', round(remain/HOUR)
	--format text as days
	else
		return '%dd', round(remain/DAY)
	end
end

--returns true if the timer should be shown
--and false otherwise
function Timer:ShouldShow()
	--the timer should have text to display and also have its cooldown be visible
	if not (self.enabled and self.visible) or self.cooldown.noCooldownCount then
		return false
	end

	local sets = self:GetSettings()
	if self.duration < sets.minDuration then
		return false
	end

	--the cooldown of the timer shouldn't be blacklisted
	return sets.enabled
end

function Timer:GetSettings()
	return OmniCC:GetGroupSettings(OmniCC:CDToGroup(self.cooldown))
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


--[[ cooldown display ]]--

--show the timer if the cooldown is shown
local function cooldown_OnShow(self)
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		if timer:GetRemain() > 0 then
			timer.visible = true
			timer:UpdateShown()
		else
			timer:Stop()
		end
	end
end

--hide the timer if the cooldown is hidden
local function cooldown_OnHide(self)
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer.visible = nil
		timer:Hide()
	end
end

--adjust the size of the timer when the cooldown's size changes
--facts to know:
--OnSizeChanged occurs more frequently than you would think
--so I've added a check to only resize timers when a cooldown's width changes
local function cooldown_OnSizeChanged(self, ...)
	local width = ...
	if self.omniccw ~= width then
		self.omniccw = width
		local timer = Timer:Get(self)
		if timer then
			timer:Size(...)
		end
	end
end

local function cooldown_StopTimer(self)
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer:Stop()
	end
end

--apply some extra functionality to the cooldown
--so that we can track hide/show/and size changes
local function cooldown_Init(self)
	self:HookScript('OnShow', cooldown_OnShow)
	self:HookScript('OnHide', cooldown_OnHide)
	self:HookScript('OnSizeChanged', cooldown_OnSizeChanged)
end


local function cooldown_OnSetCooldown(self, start, duration)
	--don't do anything if there's no timer to display, or the timer has been blacklisted
	if self.noCooldownCount or not(start and duration) then
		cooldown_StopTimer(self)
		return
	end

	local sets = OmniCC:GetGroupSettings(OmniCC:CDToGroup(self))

	--hide/show cooldown model as necessary
	self:SetAlpha(sets.showCooldownModels and 1 or 0)

	--start timer if duration is over the min duration & the timer is enabled
	if start > 0 and duration >= sets.minDuration and sets.enabled then
		--apply methods to the cooldown frame if they do not exist yet
		if not self.omnicc then
			cooldown_Init(self)
			self.omnicc = true
		end

		--hide cooldown model if necessary and start the timer
		local timer = Timer:Get(self) or Timer:New(self)
		timer:Start(start, duration)
	--stop timer
	else
		cooldown_StopTimer(self)
	end
end

--bugfix: force update timers when entering an arena
do
	local addonName = ...

	local f = CreateFrame('Frame'); f:Hide()
	f:SetScript('OnEvent', function(self, event, ...)
		--update visible timers on player_entering_world (arena update hack)
		if event == 'PLAYER_ENTERING_WORLD' then
			Timer:ForAllShown('UpdateText')
		--hook cooldown stuff only after the addon is actually loaded
		elseif event == 'ADDON_LOADED' then
			local name = ...
			if name == addonName then
				hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', cooldown_OnSetCooldown)
				self:UnregisterEvent('ADDON_LOADED')
			end
		end
	end)
	f:RegisterEvent('PLAYER_ENTERING_WORLD')
	f:RegisterEvent('ADDON_LOADED')
end