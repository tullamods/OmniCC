--[[
	OmniCC
		Displays text for cooldowns
--]]

--libraries!
local Classy = LibStub('Classy-1.0')

--constants!
local PADDING = 4
local ICON_SIZE = 36 --the normal size for an icon
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEHALFISH = 3600 * 23.5, 60 * 59.5, 89.5, --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

--local bindings!
local format = string.format
local floor = math.floor
local round = function(x) return floor(x + 0.5) end
local min = math.min
local abs = math.abs
local GetDate = GetDate


--[[---------------------------------------------------------------------------
	Timer Code
--]]---------------------------------------------------------------------------

local Timer = Classy:New('Frame'); Timer:Hide()

--constructor
do
	local timers = {}

	function Timer:New(cooldown)
		local t = self:Bind(CreateFrame('Frame', nil, cooldown:GetParent())); t:Hide()
		t.cooldown = cooldown
		t:SetAllPoints(cooldown)
		t:SetToplevel(true)
		t:SetScript('OnShow', t.OnShow)
		t:SetScript('OnSizeChanged', t.OnSizeChanged)
		t:SetScript('OnUpdate', t.OnUpdate)

		local text = t:CreateFontString(nil, 'OVERLAY')
		text:SetPoint('CENTER', 0, 0)
		t.text = text

		timers[cooldown] = t
		return t
	end

	function Timer:Get(cooldown)
		return timers[cooldown]
	end

	function Timer:ForAllShown(f, ...)
		for cooldown, timer in pairs(timers) do
			if timer:IsShown() then
				f(timer, ...)
			end
		end
	end

	function Timer:ForAllShownCooldowns(f, ...)
		for cooldown in pairs(timers) do
			if cooldown:IsShown() then
				f(cooldown, ...)
			end
		end
	end
end

--frame events
function Timer:OnShow()
	if self:GetRemainingTime() <= 0 then
		self:Stop()
	else
		self:UpdateFont()
	end
end

function Timer:OnUpdate(elapsed)
	local nextUpdate = self.toNextUpdate
	if nextUpdate > 0 then
		self.toNextUpdate = nextUpdate - elapsed
	else
		self:Update()
	end
end

function Timer:OnSizeChanged()
	if self:IsVisible() and OmniCC:ScalingText() then
		self:UpdateFont()
	end
end

--actions
function Timer:Start(cooldown, start, duration)
	local timer = self:Get(cooldown) or self:New(cooldown)
	if not self:GetShower(cooldown) then
		self:CreateShower(cooldown)
	end

	timer.start = start
	timer.duration = duration
	timer.toNextUpdate = 0
	timer:UpdateFont()
	timer:Show()
end

function Timer:Stop()
	self.start = 0
	self.duration = 0
	self.style = nil
	self:Hide()
end

function Timer:Update()
	local remain = self:GetRemainingTime()
	if remain > 0 then
		self:UpdateDisplay(remain)
	else
		if self.duration >= OmniCC:GetMinEffectDuration() then
			OmniCC:TriggerEffect(self.cooldown)
		end
		self:Stop()
	end
end

function Timer:UpdateDisplay(remain)
	local text = self.text
	local displayText, toNextUpdate = self:GetDisplayText(remain)

	self.toNextUpdate = toNextUpdate

	if text:IsShown() and text:GetFont() then
		text:SetText(displayText)

		local style = self:GetPeriodStyle(remain)
		if style ~= self.style then
			local r, g, b, alpha, scale = OmniCC:GetPeriodStyle(style)
			text:SetVertexColor(r, g, b)
			self:SetAlpha(alpha)
			self:SetScale(scale)
			self.style = style
		end
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
		text:SetFont(font, size, outline)
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
		return (round(self:GetWidth() - PADDING)  * self:GetScale()) / ICON_SIZE
	end
	return 1
end

--retrieves what text to display, as well as the time until the next time text should change
function Timer:GetDisplayText(s)
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

--shower: a frame used to properly show and hide timer text without forcing the timer to be parented to the cooldown frame (needed for hiding the cooldown frame)
do
	local showers = {}

	local function Shower_OnShow(self)
		local parent = self:GetParent()
		local timer = Timer:Get(parent)
		if timer.wasShown and not parent.noCooldownCount then
			timer:Show()
		end
	end

	local function Shower_OnHide(self)
		local timer = Timer:Get(self:GetParent())
		if timer:IsShown() then
			timer.wasShown = true
			timer:Hide()
		end
	end

	function Timer:CreateShower(cooldown)
		local shower = CreateFrame('Frame', nil, cooldown)
		shower:SetScript('OnShow', Shower_OnShow)
		shower:SetScript('OnHide', Shower_OnHide)

		showers[cooldown] = shower
		return shower
	end

	function Timer:GetShower(cooldown)
		return showers[cooldown]
	end
end


--[[---------------------------------------------------------------------------
	Global Updater/Event Handler
--]]---------------------------------------------------------------------------

local OmniCC = CreateFrame('Frame', 'OmniCC'); OmniCC:Hide()

--[[ Frame Events ]]--

OmniCC:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, event, ...)
	end
end)

--[[ Events ]]--

--force update on entering world to handle things like arena resets
function OmniCC:PLAYER_ENTERING_WORLD()
	self:UpdateTimers()
end

function OmniCC:PLAYER_LOGIN()
	--create options loader
	local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	f:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)
		LoadAddOn('OmniCC_Config')
	end)

	--add slash commands
	SLASH_OmniCC1 = '/omnicc'
	SLASH_OmniCC2 = '/occ'
	SlashCmdList['OmniCC'] = function(msg)
		if LoadAddOn('OmniCC_Config') then
			InterfaceOptionsFrame_OpenToCategory(self.GeneralOptions)
		end
	end
end

function OmniCC:PLAYER_LOGOUT()
	self:RemoveDefaults()
end

OmniCC:RegisterEvent('PLAYER_ENTERING_WORLD')
OmniCC:RegisterEvent('PLAYER_LOGOUT')
OmniCC:RegisterEvent('PLAYER_LOGIN')

--[[ Actions ]]--


function OmniCC:UpdateTimers()
	Timer:ForAllShown(Timer.Update)
end

function OmniCC:UpdateTimerFonts()
	Timer:ForAllShown(Timer.UpdateFont)
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

--[[---------------------------------------------------------------------------
	Cooldown Model Hook
--]]---------------------------------------------------------------------------

local function shouldShowTimer(cooldown)
	if OmniCC:UsingBlacklist() and OmniCC:IsBlacklisted(cooldown) then
		return false
	end
	return not cooldown.noCooldownCount
end

--ActionButton1Cooldown here, is something we think will always exist
hooksecurefunc(getmetatable(_G['ActionButton1Cooldown']).__index, 'SetCooldown', function(self, start, duration)
	if shouldShowTimer(self) then
		self:SetAlpha(OmniCC:ShowingCooldownModels() and 1 or 0)
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
		showCooldownModels = true,
		useBlacklist = false,
		blacklist = {},
		font = 'Friz Quadrata TT',
		fontSize = 18,
		fontOutline = 'OUTLINE',
		scaleText = true,
		minDuration = 3,
		minFontSize = 8,
		effect = 'pulse',
		minEffectDuration = 30,
		tenthsDuration = 0,
		mmSSDuration = 0,
		styles = {
			soon = {
				r = 1,
				g = 0,
				b= 0,
				a = 1,
				scale = 1.5,
			},
			seconds = {
				r = 1,
				g = 1,
				b= 0,
				a = 1,
				scale = 1,
			},
			minutes = {
				r = 1,
				g = 1,
				b = 1,
				a = 1,
				scale = 1,
			},
			hours = {
				r = 0.7,
				g = 0.7,
				b = 0.7,
				a = 1,
				scale = 0.75,
			}
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

--adding/removing items to the blacklist
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
function OmniCC:SetPeriodColor(timePeriod, ...)
	local style = self:GetDB().styles[timePeriod]
	style.r, style.g, style.b, style.a = ...
end

function OmniCC:GetPeriodColor(timePeriod)
	local style = self:GetDB().styles[timePeriod]
	return style.r, style.g, style.b, style.a
end

function OmniCC:SetPeriodScale(timePeriod, scale)
	local style = self:GetDB().styles[timePeriod]
	style.scale = scale or 1
end

function OmniCC:GetPeriodScale(timePeriod)
	return self:GetDB().styles[timePeriod].scale
end

function OmniCC:GetPeriodStyle(timePeriod)
	local style = self:GetDB().styles[timePeriod]
	return style.r, style.g, style.b, style.a, style.scale
end

--cooldown model showing/hiding
function OmniCC:SetShowCooldownModels(enable)
	self:GetDB().showCooldownModels = enable and true or false
	Timer:ForAllShownCooldowns(function(cooldown) cooldown:SetAlpha(enable and 1 or 0) end)
end

function OmniCC:ShowingCooldownModels()
	return self:GetDB().showCooldownModels
end

--[[---------------------------------------------------------------------------
	Blacklisting
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
		local LSM = LibStub('LibSharedMedia-3.0')
		local mediaType = LSM.MediaType.FONT

		if fontId and LSM:IsValid(mediaType, fontId) then
			return LSM:Fetch(mediaType, fontId)
		end
		return LSM:GetDefault(mediaType)
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