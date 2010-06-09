--[[
	OmniCC
		Displays text for cooldowns
--]]

--constants!
local PADDING = 2
local ICON_SIZE = 36 --the normal size for an icon
local DAY, HOUR, MINUTE = 86400, 3600, 60 --value in seconds for days, hours, and minutes
local UPDATE_DELAY = 0.01 --minimum time between timer updates

--omg speed
local format = string.format
local floor = math.floor
local min = math.min


--[[
	Timer Code
--]]

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
	text:SetFont(OmniCC:GetFont())
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
		OmniCC:SendMessage('COOLDOWN_FINISHED', self:GetParent())
	end
end

function Timer:UpdateDisplay()
	local scale = floor(self:GetWidth() - PADDING + 0.5) / ICON_SIZE --icon sizes seem to vary a little bit, so this takes care of making them round to whole numbers
	local font, size, outline = OmniCC:GetFont(scale)
	local text = self.text

	if fontSize < OmniCC:GetMinFontSize() then
		text:Hide()
	else
		if not(text.font == font and text.fontSize == size and text.fontOutline == outline) then
			text:SetFont(font, size, outline)
			text.font = font
			text.fontSize = size
			text.fontOutline = outline
		end
		text:SetText(OmniCC:GetFormattedTime(self:GetRemainingTime()))
		text:Show()
	end
end

function Timer:GetRemainingTime()
	return self.duration - (GetTime() - self.start)
end


--[[
	Global Updater/Event Handler
--]]

local OmniCC = CreateFrame('Frame', 'OmniCC', UIParent); OmniCC:Hide()
OmniCC.timers = {}
OmniCC.elapsed = UPDATE_DELAY

OmniCC:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, event, ...)
	end
end)

OmniCC:SetScript('OnUpdate', function(self, elapsed)
	if not next(self.timers) then
		self:Hide()
		return
	end

	if self.elapsed < UPDATE_DELAY then
		self.elapsed = self.elapsed + elapsed
	else
		self.elapsed = 0
		self:UpdateTimers()
	end
end)


OmniCC:SetScript('OnHide', function(self, elapsed)
	self.elapsed = UPDATE_DELAY
end)


--[[
	Events
--]]

--force update on entering world to handle things like arena resets
function OmniCC:PLAYER_ENTERING_WORLD()
	self:UpdateTimers()
end

OmniCC:RegisterEvent('PLAYER_ENTERING_WORLD')


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
	Config Settings
--]]

--how many seconds, in length, must a cooldown be to show text
function OmniCC:GetMinDuration()
	return 3
end

--enables|disables showing cooldown models
function OmniCC:ShowingModels()
	return true
end

--retrieves font information at the given scale
--defaults scale to 1 if omitted
function OmniCC:GetFont(scale)
	return STANDARD_TEXT_FONT, 18 * (scale or 1), 'OUTLINE'
end

--returns the minimum size to display text at
function OmniCC:GetMinFontSize()
	return 8
end

function OmniCC:GetFormattedTime(s)
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