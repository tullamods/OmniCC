--[[
	timer.lua
		Displays text for cooldowns on widgets
--]]

local Timer = LibStub('Classy-1.0'):New('Frame')
local OmniCC = OmniCC
local Addon = ...

local IconSize = 36
local Padding = 0 
local timers = {}

local Day, Hour, Minute = 86400, 3600, 60
local Dayish, Hourish, Minuteish, Soonish = 3600 * 23.5, 60 * 59.5, 59.5, 5.5
local HalfDayish, HalfHourish, HalfMinuteish = Day/2 + 0.5, Hour/2 + 0.5, Minute/2 + 0.5

local floor, min, type = floor, min, type
local round = function(x) return floor(x + 0.5) end
local GetTime = GetTime


--[[ Constructor ]]--

function Timer:New(cooldown)
	local timer = Timer:Bind(CreateFrame('Frame', nil, cooldown:GetParent()))
	timer:SetFrameLevel(cooldown:GetFrameLevel() + 5)
	timer:Hide()

	timer.text = timer:CreateFontString(nil, 'OVERLAY')
	timer.cooldown = cooldown

	timer:SetPoint('CENTER', cooldown)
	timer:UpdateFontSize(cooldown:GetSize())

	timers[cooldown] = timer
	return timer
end

function Timer:Get(cooldown)
	return timers[cooldown]
end


--[[ Controls ]]--

function Timer:Start(start, duration)
	self.start = start
	self.visible = self.cooldown:IsVisible()
	self.duration = duration
	self.textStyle = nil
	self.enabled = true

	self:UpdateShown()
end

function Timer:Stop()
	self.start, self.duration, self.enabled, self.visible, self.textStyle = nil
	self:CancelUpdate()
	self:Hide()
end


--[[ Update Schedules ]]--

function Timer:ScheduleUpdate(delay)
	local engine = OmniCC:GetUpdateEngine()
	local updater = engine:Get(self)

	updater:ScheduleUpdate(delay)
end

function Timer:OnScheduledUpdate()
	self:UpdateText()
end

function Timer:CancelUpdate()
	local engine = OmniCC:GetUpdateEngine()
	local updater = engine:GetActive(self)

	if updater then
		updater:CancelUpdate()
	end
end


--[[ Redraw ]]--

function Timer:UpdateFontSize(width, height)
	self.abRatio = round(width) / ICON_SIZE

	self:SetSize(width, height)
	self:UpdateTextPosition()

	if self.enabled and self.visible then
		self:UpdateText(true)
	end
end

function Timer:UpdateText(forceStyleUpdate)
	if self.start > GetTime() then
		return self:ScheduleUpdate(self.start - GetTime())
	end

	local remain = self:GetRemain()
	if remain > 0 then
		local overallScale = self.abRatio * (self:GetEffectiveScale()/UIParent:GetScale()) --used to determine text visibility

		if overallScale < self:GetSettings().minSize then
			self.text:Hide()
			self:ScheduleUpdate(1)
		else
			local style = self:GetTextStyleId(remain)
			if (style ~= self.textStyle) or forceStyleUpdate then
				self.textStyle = style
				self:UpdateTextStyle()
			end

			if self.text:GetFont() then
				self.text:SetFormattedText(self:GetTimeText(remain))
				self.text:Show()
			end

			self:ScheduleUpdate(self:GetNextUpdate(remain))
		end
	else
		if self.duration >= self:GetSettings().minEffectDuration then
			OmniCC:TriggerEffect(self:GetSettings().effect, self.cooldown)
		end
		
		self:Stop()
	end
end

function Timer:UpdateTextStyle()
	local sets = self:GetSettings()
	local font, size, outline = sets.fontFace, sets.fontSize, sets.fontOutline
	local style = sets.styles[self.textStyle]
	
	if sets.scaleText then
		size = size * style.scale * (self.abRatio or 1)
	else
		size = size * style.scale
	end

	if size > 0 then
		if not self.text:SetFont(font, size, outline) then
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


--[[ Accessors ]]--

function Timer:GetRemain()
	return self.duration - (GetTime() - self.start)
end

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

function Timer:GetNextUpdate(remain)
	local sets = self:GetSettings()

	if remain < (sets.tenthsDuration + 0.5) then
		return 0.1
		
	elseif remain < Minuteish then
		return remain - round(remain) + 0.51
		
	elseif remain < sets.mmSSDuration then
		return remain - round(remain) + 0.51
		
	elseif remain < Hourish then
		local minutes = round(remain/Minute)
		if minutes > 1 then
			return remain - (minutes*Minute - HalfMinuteish)
		end
		return remain - Minuteish + 0.01
		
	elseif remain < Dayish then
		local hours = round(remain/Hour)
		if hours > 1 then
			return remain - (hours*Hour - HalfHourish)
		end
		return remain - Hourish + 0.01
		
	else
		local days = round(remain/Day)
		if days > 1 then
			return remain - (days*Day - HalfDayish)
		end
		return remain - Dayish + 0.01
	end
end

function Timer:GetTimeText(remain)
	local sets = self:GetSettings()

	if remain < sets.tenthsDuration then
		return '%.1f', remain
		
	elseif remain < Minuteish then
		local seconds = round(remain)
		return seconds ~= 0 and seconds or ''
		
	elseif remain < sets.mmSSDuration then
		local seconds = round(remain)
		return '%d:%02d', seconds/Minute, seconds%Minute
		
	elseif remain < Hourish then
		return '%dm', round(remain/Minute)
		
	elseif remain < Dayish then
		return '%dh', round(remain/Hour)

	else
		return '%dd', round(remain/Day)
	end
end

function Timer:ShouldShow()
	if not (self.enabled and self.visible) or self.cooldown.noCooldownCount then
		return false
	end

	local sets = self:GetSettings()
	if self.duration < sets.minDuration then
		return false
	end

	return sets.enabled
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


--[[ Settings Methods ]]--

function Timer:GetSettings()
	return OmniCC:GetGroupSettings(OmniCC:CDToGroup(self.cooldown))
end


--[[ Cooldown Display ]]--

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

local function cooldown_OnHide(self)
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer.visible = nil
		timer:Hide()
	end
end

-- adjust the size of the timer when the cooldown's width changes, because OnSizeChanged occurs frequently
local function cooldown_OnSizeChanged(self, ...)
	local width = ...
	if self.omniccw ~= width then
		self.omniccw = width
		
		local timer = Timer:Get(self)
		if timer then
			timer:UpdateFontSize(...)
		end
	end
end

local function cooldown_StopTimer(self)
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer:Stop()
	end
end

local function cooldown_Init(self)
	self:HookScript('OnShow', cooldown_OnShow)
	self:HookScript('OnHide', cooldown_OnHide)
	self:HookScript('OnSizeChanged', cooldown_OnSizeChanged)
	self.omnicc = true
end

local function cooldown_ParentAction(self)
	local parent = self:GetParent()
	return parent and parent:GetAttribute("action")
end

local function cooldown_HasCharges(self)
	local action = self.omniccAction or cooldown_ParentAction(self)
	return action and GetActionCharges(action) ~= 0
end

local function cooldown_CanShow(self, start, duration)
	if self.noCooldownCount or not (start and duration) or cooldown_HasCharges(self) then
		return
	end
	
	local sets = OmniCC:GetGroupSettings(OmniCC:CDToGroup(self)) 
	self:SetAlpha(sets.showCooldownModels and 1 or 0)
	
	if start > 0 and duration >= sets.minDuration and sets.enabled then
		return true
	end
end

local function cooldown_Show(self, start, duration)
	if cooldown_CanShow(self, start, duration) then
		if not self.omnicc then
			cooldown_Init(self)
		end

		local timer = Timer:Get(self) or Timer:New(self)
		timer:Start(start, duration)
	else
		cooldown_StopTimer(self)
	end
end


--[[ ActionUI Button ]]--

local actions = {}
local function action_OnShow(self)
	actions[self] = true
end

local function action_OnHide(self)
	actions[self] = nil
end

local function action_Add(button, action, cooldown)
	if not cooldown.omniccAction then
		cooldown:HookScript('OnShow', action_OnShow)
		cooldown:HookScript('OnHide', action_OnHide)
	end
	cooldown.omniccAction = action
end

local function actions_Update()
	for cooldown in pairs(actions) do
        local start, duration = GetActionCooldown(cooldown.omniccAction)
        cooldown_Show(cooldown, start, duration)
    end
end


--[[ Events ]]--

local f = CreateFrame('Frame'); f:Hide()
f:SetScript('OnEvent', function(self, event, ...)
	if event == 'ACTIONBAR_UPDATE_COOLDOWN' then
		actions_Update()
	
	elseif event == 'PLAYER_ENTERING_WORLD' then
		Timer:ForAllShown('UpdateText')
		
	elseif ... == Addon then
		hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', cooldown_Show)
		hooksecurefunc('SetActionUIButton', action_Add)
			
		for i, button in pairs(ActionBarButtonEventsFrame.frames) do
			action_Add(button, button.action, button.cooldown)
		end
			
		self:UnregisterEvent('ADDON_LOADED')
	end
end)

f:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('ADDON_LOADED')