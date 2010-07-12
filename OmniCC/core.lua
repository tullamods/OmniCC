--[[
	OmniCC
		Displays text for cooldowns
--]]

--libraries!
local Classy = LibStub('Classy-1.0')
local LSM = LibStub('LibSharedMedia-3.0')

--constants!
local PADDING = 4
local ICON_SIZE = 36 --the normal size for an icon
local DAY, HOUR, MINUTE = 86400, 3600, 60 --value in seconds for days, hours, and minutes

local DAYISH = 3600 * 23.5 --used for transition points when rounding (http://www.gammon.com.au/forum/?id=7805)
local HOURISH = 60 * 59.5
local MINUTEISH = 59.5
local SOONISH = 10.5

local UPDATE_DELAY = 0.02 --minimum time between timer updates
local DEFAULT_FONT = 'Friz Quadrata TT' --the default font id to use
local NO_OUTLINE = 'none'

--local bindings!
local format = string.format
local floor = math.floor
local min = math.min
local LSM_FONT = LSM.MediaType.FONT

--local functions!
local function round(x)
	return floor(x + 0.5)
end


--[[---------------------------------------------------------------------------
	Timer Code
--]]---------------------------------------------------------------------------

local Timer = Classy:New('Frame'); Timer:Hide()
Timer.timers = {}

--constructor
function Timer:New(cooldown)
	local t = self:Bind(CreateFrame('Frame', nil, cooldown)); t:Hide()
	t:SetAllPoints(cooldown)
	t:SetScript('OnShow', t.OnShow)
	t:SetScript('OnHide', t.OnHide)
	t:SetScript('OnSizeChanged', t.OnSizeChanged)

	local text = t:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', 0, 1)
	t.text = text

	return t
end

function Timer:Get(cooldown)
	return self.timers[cooldown]
end

--frame events
function Timer:OnShow()
	if self:GetRemainingTime() > 0 then
		self:UpdateFont()
		OmniCC:Add(self)
	else
		self:Stop()
	end
end

function Timer:OnHide()
	OmniCC:Remove(self)
end

function Timer:OnSizeChanged()
	if self:IsVisible() and OmniCC:ScalingText() then
		self:UpdateFont()
	end
end

--actions
function Timer:Start(cooldown, start, duration)
	local timer = self.timers[cooldown]
	if not timer then
		timer = Timer:New(cooldown)
		self.timers[cooldown] = timer
	end
	timer.start = start
	timer.duration = duration
	timer:UpdateFont()

	--this handles the case of timers that are being updated for one reason or another
	--like cooldowns expiring, etc
	if timer:IsShown() then
		timer:Update()
	else
		timer:Show()
	end
end

function Timer:Stop()
	self.start = 0
	self.duration = 0
	self:Hide()
end

function Timer:Update()
	local remain = self:GetRemainingTime()
	if remain > 0 then
		self:UpdateDisplay(remain)
	else
		if self.duration >= OmniCC:GetMinEffectDuration() then
			OmniCC:TriggerEffect(self:GetParent())
		end
		self:Stop()
	end
end

function Timer:UpdateDisplay(remain)
	local text = self.text
	if text:IsShown() then
		text:SetText(self:GetFormattedTime(remain))

		local r, g, b = self:GetFormattedColor(remain)
		text:SetVertexColor(r, g, b)
	end
end

function Timer:GetRemainingTime()
	return self.duration - (GetTime() - self.start)
end

function Timer:UpdateFont()
	local font, size, outline = self:GetFont()
	local text = self.text

	if size < OmniCC:GetMinFontSize() then
		text:Hide()
	else
		text:SetFont(self:GetFont())
		text:Show()
	end
end

--settings
function Timer:GetFont()
	local font, size, outline = OmniCC:GetFontInfo()
	return font, size * self:GetFontScale(), outline
end

function Timer:GetFontScale()
	if OmniCC:ScalingText() then
		return round(self:GetWidth() - PADDING) / ICON_SIZE
	end
	return 1
end

function Timer:GetFormattedTime(s)
	if s < OmniCC:GetTenthsDuration() then
		return format('%.1f', s)
	elseif s < 90.5 then --format text as seconds when at 90 seconds or below
		return round(s)
	elseif s < OmniCC:GetMMSSDuration() then --format text as MM:SS when below the MM:SS threshold
		return format('%d:%02d', s/MINUTE, s%MINUTE)
	elseif s < HOURISH then --format text as minutes when below an hour
		return round(s/MINUTE) .. 'm'
	elseif s < DAYISH then --format text as hours when below a day
		return round(s/HOUR) .. 'h'
	else --format text as days
		return round(s/DAY) .. 'd'
	end
end

function Timer:GetFormattedColor(s)
	if s < SOONISH then
		return OmniCC:GetColor('soon')
	elseif s < MINUTEISH then
		return OmniCC:GetColor('seconds')
	elseif s <  HOURISH then
		return OmniCC:GetColor('minutes')
	else
		return OmniCC:GetColor('hours')
	end
end

--[[---------------------------------------------------------------------------
	Global Updater/Event Handler
--]]---------------------------------------------------------------------------

local OmniCC = CreateFrame('Frame', 'OmniCC', UIParent); OmniCC:Hide()
OmniCC.elapsed = UPDATE_DELAY
OmniCC.timers = {}

--[[ Frame Events ]]--

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
	self:AddSlashCommands()
	self:SetUseDynamicColor(false)
end

function OmniCC:PLAYER_LOGOUT()
	self:RemoveDefaults()
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

function OmniCC:UpdateTimerFonts()
	for timer in pairs(self.timers) do
		timer:UpdateFont()
	end
end

function OmniCC:StartTimer(cooldown, start, duration)
	Timer:Start(cooldown, start, duration)
end

function OmniCC:StopTimer(cooldown)
	local timer = Timer:Get(cooldown)
	if timer then
		timer:Hide()
	end
end

--create a loader for the options menu
function OmniCC:CreateOptionsLoader()
	local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	f:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)
		LoadAddOn('OmniCC_Config')
	end)
end

function OmniCC:ShowOptions()
	if LoadAddOn('OmniCC_Config') then
		InterfaceOptionsFrame_OpenToCategory(self.GeneralOptions)
		return true
	end
	return false
end

function OmniCC:AddSlashCommands()
	SLASH_OmniCC1 = '/omnicc'
	SLASH_OmniCC2 = '/occ'
	SlashCmdList['OmniCC'] = function(msg)
		self:ShowOptions()
	end
end


--[[---------------------------------------------------------------------------
	Cooldown Model Hook
--]]---------------------------------------------------------------------------

local function shouldShowTimer(cooldown)
	if OmniCC:UsingBlacklist() and OmniCC:IsBlacklisted(cooldown) then
		return false
	end
	if OmniCC:UsingWhitelist() and not OmniCC:IsWhitelisted(cooldown) then
		return false
	end
	return true
end

--ActionButton1Cooldown here, is something we think will always exist
hooksecurefunc(getmetatable(_G['ActionButton1Cooldown']).__index, 'SetCooldown', function(self, start, duration)
	if shouldShowTimer(self) then
		if start > 0 and duration > OmniCC:GetMinDuration() then
			OmniCC:StartTimer(self, start, duration)
			return
		end
	end
	OmniCC:StopTimer(self)
end)


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
		end
		copyDefaults(self.db, self:GetDefaults())
	end
	return self.db
end

function OmniCC:GetDefaults()
	self.defaults = self.defaults or {
		useWhiteList = false,
		useBlacklist = false,
		blacklist = {},
		font = DEFAULT_FONT,
		fontSize = 18,
		fontOutline = 'OUTLINE',
		scaleText = true,
		minDuration = 3,
		minFontSize = 8,
		effect = 'pulse',
		minEffectDuration = 15,
		tenthsDuration = 0,
		mmSSDuration = 300,
		colors = {
			soon = {1, 0, 0},
			seconds = {1, 1, 0},
			minutes = {1, 1, 1},
			hours = {0.5, 0.5, 0.5}
		}
	}
	return self.defaults
end

function OmniCC:RemoveDefaults()
	local db = self.db
	if db then
		removeDefaults(db, self:GetDefaults())
	end
end

function OmniCC:CreateNewDB()
	local db = {
		version = self:GetAddOnVersion()
	}

	_G['OmniCCGlobalSettings'] = db
	return db
end

function OmniCC:UpgradeDB()
	local oldMajor, oldMinor = self:GetDBVersion():match('(%w+)%.(%w+)')
	self:GetDB().version = self:GetAddOnVersion()
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
end

function OmniCC:UsingWhitelist()
	return self:GetDB().useWhiteList
end

--blacklist settings
function OmniCC:SetUseBlacklist(enable)
	self:GetDB().useBlacklist = enable and true or false
end

function OmniCC:UsingBlacklist()
	return self:GetDB().useBlacklist
end

function OmniCC:GetBlacklist()
	return self:GetDB().blacklist
end

do
	local function isValidBlacklistPattern(pattern)
		return pattern and not pattern:match('^%s*$')
	end

	function OmniCC:AddToBlacklist(patternToAdd)
		if not isValidBlacklistPattern(patternToAdd) then
			return false
		end

		if not self:GetBlacklistIndex(patternToAdd) then
			local blacklist = self:GetBlacklist()
			table.insert(blacklist, patternToAdd)
			table.sort(blacklist)

			for i, pattern in pairs(blacklist) do
				if pattern == patternToAdd then
					return true
				end
			end
		end
	end

	function OmniCC:RemoveFromBlacklist(patternToRemove)
		if not isValidBlacklistPattern(patternToRemove) then
			return false
		end

		local index = self:GetBlacklistIndex(patternToRemove)
		if index then
			table.remove(self:GetBlacklist(), index)
			return true
		end
	end

	function OmniCC:GetBlacklistIndex(patternToFind)
		if not isValidBlacklistPattern(patternToFind) then
			return false
		end

		for i, pattern in pairs(self:GetBlacklist()) do
			if pattern == patternToFind then
				return i
			end
		end
	end
end

--how many seconds, in length, must a cooldown be to show text
function OmniCC:SetMinDuration(duration)
	self:GetDB().minDuration = duration or 0
	self:UpdateTimers()
end

function OmniCC:GetMinDuration()
	return self:GetDB().minDuration
end

--font id
function OmniCC:SetFontID(font)
	self:GetDB().font = font
	self:GetFontInfo(true)
	self:UpdateTimerFonts()
end

function OmniCC:GetFontID()
	return self:GetDB().font
end

--font size
function OmniCC:SetFontSize(size)
	self:GetDB().fontSize = size
	self:UpdateTimerFonts()
end

function OmniCC:GetFontSize()
	return self:GetDB().fontSize
end

--font outline
function OmniCC:SetFontOutline(outline)
	self:GetDB().fontOutline = outline
	self:UpdateTimerFonts()
end

function OmniCC:GetFontOutline()
	return self:GetDB().fontOutline
end

--font scaling
function OmniCC:SetScaleText(enable)
	self:GetDB().scaleText = enable and true or false
	self:UpdateTimerFonts()
end

function OmniCC:ScalingText()
	return self:GetDB().scaleText
end

--minimum font size to display text
function OmniCC:SetMinFontSize(size)
	self:GetDB().minFontSize = size or 0
	self:UpdateTimerFonts()
end

function OmniCC:GetMinFontSize()
	return self:GetDB().minFontSize
end

--minumum duration to show tenths of seconds
function OmniCC:SetTenthsDuration(value)
	self:GetDB().tenthsDuration = value or 0
end

function OmniCC:GetTenthsDuration()
	return self:GetDB().tenthsDuration
end

--minimum duration to display text as MM:SS
function OmniCC:SetMMSSDuration(value)
	self:GetDB().mmSSDuration = value or 0
end

function OmniCC:GetMMSSDuration()
	return self:GetDB().mmSSDuration
end

--text colors
function OmniCC:SetColor(timePeriod, ...)
	local color = self:GetDB().colors[timePeriod]
	for i = 1, select('#', ...) do
		color[i] = select(i, ...)
	end
end

function OmniCC:GetColor(timePeriod)
	return unpack(self:GetDB().colors[timePeriod])
end

--[[---------------------------------------------------------------------------
	Blacklisting/Whitelisting
--]]---------------------------------------------------------------------------

--blacklisting
--returns true if the name of the given frame matches a pattern on the blacklist
--and false otherwise
--frames with no name are considered NOT on the blacklist
do
	local blacklistedFrames = setmetatable({}, {__index = function(t, frame)
		local frameName = frame:GetName()
		local blacklisted = false

		if frameName then
			for _, pattern in pairs(OmniCC:GetBlacklist()) do
				if frameName:match(pattern) then
					blacklisted = true
					break
				end
			end
		end

		t[frame] = blacklisted
		return blacklisted
	end})

	function OmniCC:ClearBlacklistCache()
		for k, v in pairs(blacklistedFrames) do
			blacklistedFrames[k] = nil
		end
	end

	function OmniCC:IsBlacklisted(frame)
		return blacklistedFrames[frame]
	end
end

--whitelisting
--returns true if the given frame is registered with CooldownTextFrames
--and false otherwise
--returns FALSE if CooldownTextFrames does not exist
do
	--returns true if the given frame is a descendant of the other frame
	local function isDescendant(frame, otherFrame)
		if not (frame and otherFrame) then
			return false
		end
		if frame == otherFrame then
			return true
		end
		return isDescendant(frame:GetParent(), otherFrame)
	end

	local whitelistedFrames = setmetatable({}, {__index = function(t, frame)
		local cooldownTextFrames = _G['CooldownTextFrames']
		local whitelisted = false

		if cooldownTextFrames then
			for f, enabled in pairs(cooldownTextFrames) do
				if isDescendant(frame, f) then
					whitelisted = enabled
					break
				end
			end
		end

		t[frame] = whitelisted
		return whitelisted
	end})

	function OmniCC:ClearWhitelistCache()
		for k, v in pairs(whitelistedFrames) do
			whitelistedFrames[k] = nil
		end
	end

	function OmniCC:IsWhitelisted(frame)
		return whitelistedFrames[frame]
	end
end


--[[---------------------------------------------------------------------------
	Finish Effects
--]]---------------------------------------------------------------------------

function OmniCC:TriggerEffect(cooldown)
	local effect = self:GetSelectedEffect()
	if effect then
		effect:Run(cooldown)
	end
end

function OmniCC:RegisterEffect(effect)
	if not self:GetEffect(effect.id) then
		self.effects = self.effects or {}
		table.insert(self.effects, effect)
	end
end

function OmniCC:GetEffect(id)
	if self.effects then
		for _, effect in pairs(self.effects) do
			if effect.id == id then
				return effect
			end
		end
	end
end

function OmniCC:ForEachEffect(f, ...)
	local results
	if self.effects then
		for _, effect in pairs(self.effects) do
			local result = f(effect, ...)
			if result then
				results = results or {}
				table.insert(results, result)
			end
		end
	end
	return results
end


--effect configuration
function OmniCC:SetEffect(effectID)
	self:GetDB().effect = effectID
end

function OmniCC:GetSelectedEffectID()
	return self:GetDB().effect or 'none'
end

function OmniCC:GetSelectedEffect()
	return self:GetEffect(self:GetSelectedEffectID())
end

function OmniCC:SetMinEffectDuration(duration)
	self:GetDB().minEffectDuration = duration
end

function OmniCC:GetMinEffectDuration()
	return self:GetDB().minEffectDuration
end


--[[---------------------------------------------------------------------------
	Font Retrieval - Really here to just minimize calls to SharedMedia/saved settings access
--]]---------------------------------------------------------------------------

do
	--these functions are here to minimize calls to SharedMedia
	local function fetchFont(fontId)
		if fontId and LSM:IsValid(LSM_FONT, fontId) then
			return LSM:Fetch(LSM_FONT, fontId)
		end
		return LSM:Fetch(LSM_FONT, DEFAULT_FONT)
	end

	function OmniCC:GetFontInfo(force)
		local font = self.font
		if (not font) or force then
			font = fetchFont(self:GetFontID())
			self.font = font
		end

		local db = self:GetDB()
		return font, db.fontSize, db.fontOutline
	end
end


--[[
	formatted color function retrieval
		when viewing the options menu, set the Timer.GetFormattedColor function to one that pulls values directly from the database
			this is so that the user can see color changes in real time
		when not viewing the options menu, use a static version of the getformattedcololor function
			this is done so that we remove all table lookups.  By doing so, we can reduce cpu usage by a good bit
--]]
do
	local function genGetFormattedColor()
		local nR, nG, nB = OmniCC:GetColor('soon')
		local sR, sG, sB = OmniCC:GetColor('seconds')
		local mR, mG, mB = OmniCC:GetColor('minutes')
		local hR, hG, hB = OmniCC:GetColor('hours')

		return loadstring(format([[
			return function(self, s)
				if s < %.1f then
					return %.2f, %.2f, %.2f
				elseif s < %.1f then
					return %.2f, %.2f, %.2f
				elseif s <  %.1f then
					return %.2f, %.2f, %.2f
				else
					return %.2f, %.2f, %.2f
				end
			end
		]], SOONISH, nR, nG, nB, MINUTEISH, sR, sG, sB, HOURISH, mR, mG, mB, hR, hG, hB))()
	end

	local getFormattedColor = Timer.GetFormattedColor

	function OmniCC:SetUseDynamicColor(enable)
		if enable then
			Timer.GetFormattedColor = getFormattedColor
		else
			Timer.GetFormattedColor = genGetFormattedColor()
		end
	end
end