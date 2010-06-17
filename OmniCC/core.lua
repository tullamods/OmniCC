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

local GRAY_FONT_COLOR_CODE = GRAY_FONT_COLOR_CODE
local NORMAL_FONT_COLOR_CODE = NORMAL_FONT_COLOR_CODE
local YELLOW_FONT_COLOR_CODE = YELLOW_FONT_COLOR_CODE
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE

--[[---------------------------------------------------------------------------
	Timer Code
--]]---------------------------------------------------------------------------

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
	local scale = self:GetFontScale()
	local font, size, outline = OmniCC:GetFont(scale)
	local text = self.text

	if size < OmniCC:GetMinFontSize() then
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

function Timer:GetFontScale()
	if OmniCC:ScalingText() then
		 --icon sizes seem to vary a little bit, so this takes care of making them round to whole numbers
		return floor(self:GetWidth() - PADDING + 0.5) / ICON_SIZE 
	end
	return 1
end


--[[---------------------------------------------------------------------------
	Global Updater/Event Handler
--]]---------------------------------------------------------------------------

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


--[[ Events ]]--

--force update on entering world to handle things like arena resets
function OmniCC:PLAYER_ENTERING_WORLD()
	self:UpdateTimers()
end

function OmniCC:PLAYER_LOGIN()
	self:CreateOptionsLoader()
end

function OmniCC:PLAYER_LOGOUT()
	self:ClearDefaults()
end

OmniCC:RegisterEvent('PLAYER_ENTERING_WORLD')
OmniCC:RegisterEvent('PLAYER_LOGOUT')
OmniCC:RegisterEvent('PLAYER_LOGIN')


--[[ Actions ]]--

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

function OmniCC:StartTimer(cooldown, start, duration)
	Timer:Start(cooldown, start, duration)
end

--create a loader for the options menu
function OmniCC:CreateOptionsLoader()
	local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	f:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)
		LoadAddOn('OmniCC_Config')
	end)
end



--[[---------------------------------------------------------------------------
	Saved Settings
--]]---------------------------------------------------------------------------

local function removeDefaults(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(tbl[k]) == 'table' and type(v) == 'table' then
			removeDefaults(tbl[k], v)

			if next(tbl[k]) == nil then
				tbl[k] = nil
			end
		elseif tbl[k] == v then
			tbl[k] = nil
		end
	end
end

local function copyDefaults(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table' then
			tbl[k] = copyDefaults(tbl[k] or {}, v)
		elseif tbl[k] == nil then
			tbl[k] = v
		end
	end
	return tbl
end

function OmniCC:GetDB()
	if not self.db then
		self.db = _G['OmniCCGlobalSettings']
		if self.db then
			if self:IsDBOutOfDate() then
				self:UpgradeDB()
			end
		else
			self.db = self:CreateNewDB()
			self:Print('OmniCC Initialized')
		end
		copyDefaults(self.db, self:GetDefaults())
	end
	return self.db
end

function OmniCC:GetDefaults()
	self.defaults = self.defaults or {
		useWhiteList = false,
		fontFace = STANDARD_TEXT_FONT,
		fontSize = 18,
		fontOutline = 'OUTLINE',
		scaleText = true,
		minDuration = 3,
		minFontSize = 8,
	}
	return self.defaults
end

function OmniCC:CreateNewDB()
	local db = {
		version = self:GetAddOnVersion()
	}

	_G['OmniCCGlobalSettings'] = db
	return db
end

function OmniCC:UpgradeDB()
	local major, minor = self:GetDBVersion():match('(%w+)%.(%w+)')
	
	self:GetDB().version = self:GetAddOnVersion()
	self:Print(('Updated to v%s'):format(self:GetDBVersion()))
end

function OmniCC:IsDBOutOfDate()
	return self:GetDBVersion() ~= self:GetAddOnVersion()
end

function OmniCC:GetDBVersion()
	return self:GetDB().version
end

function OmniCC:GetAddOnVersion()
	return GetAddOnMetadata('OmniCC', 'Version')
end


--[[---------------------------------------------------------------------------
	Configuration
--]]---------------------------------------------------------------------------

--whitelist settings
function OmniCC:SetUseWhitelist(enable)
	self:GetDB().useWhiteList = enable and true or false
--	self:UpdateWhitelist()
end

function OmniCC:UsingWhitelist()
	return self:GetDB().useWhiteList
end

--how many seconds, in length, must a cooldown be to show text
function OmniCC:SetMinDuration(duration)
	self:GetDB().minDuration = duration or 0
	self:UpdateTimers()
end

function OmniCC:GetMinDuration()
	return self:GetDB().minDuration or 0
end

--retrieves font information at the given scale
--defaults scale to 1 if omitted
function OmniCC:SetFontFace(font)
	self:GetDB().fontFace = font
	self:UpdateTimers()
end

function OmniCC:SetFontSize(size)
	self:GetDB().fontSize = size
	self:UpdateTimers()
end

function OmniCC:SetFontOutline(outline)
	self:GetDB().fontOutline = outline
	self:UpdateTimers()
end

function OmniCC:GetFont(scale)
	local db = self:GetDB()
	return db.fontFace or STANDARD_TEXT_FONT, (db.fontSize or 18) * (scale or 1), db.fontOutline
end

--returns true if font scaling is enabled or not
function OmniCC:SetScaleText(enable)
	self:GetDB().scaleText = enable and true or false

	self:UpdateTimers()
end

function OmniCC:ScalingText()
	return self:GetDB().scaleText
end

--returns the minimum size to display text at
function OmniCC:SetMinFontSize(size)
	self:GetDB().minFontSize = size
	self:UpdateTimers()
end

function OmniCC:GetMinFontSize()
	return self:GetDB().minFontSize or 8
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


--[[---------------------------------------------------------------------------
	Utility
--]]---------------------------------------------------------------------------

function OmniCC:Print(...)
	return print('OmniCC:', ...)
end

function OmniCC:AddFrame(f, enable)
	CooldownTextFrames = CooldownTextFrames or {}
	CooldownTextFrames[f] = enable
end