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
local UPDATE_DELAY = 0.02 --minimum time between timer updates
local DEFAULT_FONT = 'Friz Quadrata TT' --the default font id to use
local NO_OUTLINE = 'none'

--local bindings!
local format = string.format
local floor = math.floor
local min = math.min
local LSM_FONT = LSM.MediaType.FONT


--[[---------------------------------------------------------------------------
	Timer Code
--]]---------------------------------------------------------------------------

local Timer = Classy:New('Frame'); Timer:Hide()
Timer.timers = {}

function Timer:New(parent)
	local t = self:Bind(CreateFrame('Frame', nil, parent)); t:Hide()
	t:SetAllPoints(parent)
	t:SetScript('OnShow', t.OnShow)
	t:SetScript('OnHide', t.OnHide)
	t:SetScript('OnSizeChanged', t.OnSizeChanged)

	local text = t:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', 0, 1)
	t.text = text

	t:UpdateFont()
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

function Timer:OnSizeChanged()
	if self:IsVisible() and OmniCC:ScalingText() then
		self:UpdateFont()
	end
end

function Timer:Start(cooldown, start, duration)
	local timer = self.timers[cooldown]
	if not timer then
		timer = Timer:New(cooldown)
		self.timers[cooldown] = timer
	end
	timer.start = start
	timer.duration = duration

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
	end
end

function Timer:GetRemainingTime()
	return self.duration - (GetTime() - self.start)
end

--[[ Font Retrieval ]]--

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

function Timer:GetFont()
	local font, size, outline = OmniCC:GetFontInfo()
	return font, size * self:GetFontScale(), outline
end

function Timer:GetFontScale()
	if OmniCC:ScalingText() then
		return floor(self:GetWidth() - PADDING + 0.5) / ICON_SIZE
	end
	return 1
end

function Timer:GetFormattedTime(s)
	if s >= DAY then
		return format('|cff808080%ds|r', floor(s/DAY + 0.5))
	elseif s >= HOUR then
		return format('|cffffd200%dh|r', floor(s/HOUR + 0.5))
	elseif s >= 90 then --three minutes
		return format('|cffffff00%dm|r', floor(s/MINUTE + 0.5))
	elseif s >= 10 then --10 seconds
		return format('|cffffff00%d|r', floor(s + 0.5))
	elseif s >= 3 then
		return format('|cffff2020%d|r', floor(s + 0.5))
	end
	return format('|cff20ff20%.1f|r', s)
end

function Timer:Get(cooldown)
	return self.timers[cooldown]
end

--[[---------------------------------------------------------------------------
	Global Updater/Event Handler
--]]---------------------------------------------------------------------------

local OmniCC = CreateFrame('Frame', 'OmniCC', UIParent); OmniCC:Hide()
OmniCC.elapsed = UPDATE_DELAY
OmniCC.timers = {}

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
		--self:SetAlpha(OmniCC:ShowingModels() and 1 or 0)
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
	self:Print(L.Updated:format(self:GetDBVersion()))
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
	self:GetDB().minFontSize = size
	self:UpdateTimerFonts()
end

function OmniCC:GetMinFontSize()
	return self:GetDB().minFontSize
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


--[[---------------------------------------------------------------------------
	Utility
--]]---------------------------------------------------------------------------

function OmniCC:Print(...)
	return print('|cff33aa33OmniCC|r:', ...)
end