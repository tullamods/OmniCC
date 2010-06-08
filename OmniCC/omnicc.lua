--[[
	OmniCC
		A featureless, 'pure' version of OmniCC.
		This version should work on absolutely everything, but I've removed pretty much all of the options
--]]

--[[ constants & local bindings ]]--

local PADDING = 2
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local TEXT_FONT = STANDARD_TEXT_FONT --what font to use
local FONT_SIZE = 18 --the base font size to use at a scale of 1
local MIN_SCALE = 0.8 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 3 --the minimum duration to show cooldown text for
local DAY, HOUR, MINUTE = 86400, 3600, 60
local UPDATE_DELAY = 0.01 --minimum time between timer updates

--omg speed
local format = string.format
local floor = math.floor
local min = math.min

--[[
	Timer Code
--]]

local function formatTime(s)
	if s >= DAY then
		return GRAY_FONT_COLOR_CODE .. format('%dd', floor(s/DAY + 0.5)) .. FONT_COLOR_CODE_CLOSE
	elseif s >= HOUR then
		return NORMAL_FONT_COLOR_CODE .. format('%dh', floor(s/HOUR + 0.5)) .. FONT_COLOR_CODE_CLOSE
	elseif s >= MINUTE then
		return YELLOW_FONT_COLOR_CODE .. format('%dm', floor(s/MINUTE + 0.5)) .. FONT_COLOR_CODE_CLOSE
	elseif floor(s + 0.5) > 10 then
		return YELLOW_FONT_COLOR_CODE .. floor(s + 0.5) .. FONT_COLOR_CODE_CLOSE
	elseif s >= 3 then
		return RED_FONT_COLOR_CODE .. floor(s + 0.5) .. FONT_COLOR_CODE_CLOSE
	end
	return GREEN_FONT_COLOR_CODE .. format('%.1f', s) .. FONT_COLOR_CODE_CLOSE
end

local Timer = CreateFrame('Frame'); Timer:Hide()
local timer_MT = {__index = Timer}

function Timer:New(parent)
	local t = setmetatable(CreateFrame('Frame', nil, parent), timer_MT)
	t:Hide()
	t:SetAllPoints(parent)
	t:SetScript('OnShow', t.OnShow)
	t:SetScript('OnHide', t.OnHide)

	local text = t:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', 0, 1)
	text:SetFont(TEXT_FONT, FONT_SIZE, 'OUTLINE')
	t.text = text

	return t
end

function Timer:OnShow()
	if self:GetRemainingTime() > 0 then
		OmniCC:Add(self)
	else
		self:Stop()
	end
end

function Timer:OnHide()
	OmniCC:Remove(self)
end

function Timer:Start(cooldown, start, duration)
	local timer = cooldown.timer
	if not timer then
		timer = Timer:New(cooldown)
		cooldown.timer = timer
	end

	timer.start = start
	timer.duration = duration
	timer:Show()
end

function Timer:Stop()
	self.start = 0
	self.duration = 0
	self:Hide()
end

function Timer:Update()
	if self:GetRemainingTime() > 0 then
		self:UpdateDisplay()
	else
		self:Stop()
	end
end

function Timer:UpdateDisplay()
	local rScale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local iconScale = floor(self:GetWidth() - PADDING + 0.5) / ICON_SIZE --icon sizes seem to vary a little bit, so this takes care of making them round to whole numbers
	local text = self.text

	if (iconScale*rScale) < MIN_SCALE or iconScale <= 0 then
		text:Hide()
	else
		local fontSize = FONT_SIZE * iconScale
		if not(text.fontSize and text.fontSize == fontSize) then
			text:SetFont(TEXT_FONT, fontSize, 'OUTLINE')
			text.fontSize = fontSize
		end

		text:SetText(formatTime(self:GetRemainingTime()))
		text:Show()
	end
end

function Timer:GetRemainingTime()
	return self.duration - (GetTime() - self.start)
end

--[[
	global updater
--]]

local OmniCC = CreateFrame('Frame', 'OmniCC', UIParent); OmniCC:Hide()
OmniCC:RegisterEvent('PLAYER_ENTERING_WORLD')
OmniCC.timers = {}
OmniCC.nextUpdate = 0

OmniCC:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, event, ...)
	end
end)

OmniCC:SetScript('OnHide', function(self, elapsed)
	self.nextUpdate = 0
end)

OmniCC:SetScript('OnUpdate', function(self, elapsed)
	if not next(self.timers) then
		self:Hide()
		return
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		self.nextUpdate = UPDATE_DELAY
		self:UpdateTimers()
	end
end)


--[[
	Events
--]]

--force update on entering world to handle things like arena resets
function OmniCC:PLAYER_ENTERING_WORLD()
	self:UpdateTimers()
end


--[[
	Actions
--]]

function OmniCC:Add(timer)
	self.timers[timer] = true
	self:UpdateShown()
end

function OmniCC:Remove(timer)
	if next(self.timers) then
		self.timers[timer] = nil
		self:UpdateShown()
	end
end

function OmniCC:UpdateShown()
	if next(self.timers) then
		self:Show()
	else
		self:Hide()
	end
end

function OmniCC:UpdateTimers()
	for timer in pairs(self.timers) do
		timer:Update()
	end
end

--[[
	the hook
--]]

--ActionButton1Cooldown here, is something we think will always exist
local methods = getmetatable(_G['ActionButton1Cooldown']).__index
hooksecurefunc(methods, 'SetCooldown', function(self, start, duration)
	if start > 0 and duration > MIN_DURATION then
		Timer:Start(self, start, duration)
	elseif self.timer then
		self.timer:Stop()
	end
end)