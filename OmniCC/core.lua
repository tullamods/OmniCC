--[[
	OmniCC
		Displays text for cooldowns
--]]

--libraries!
local LSM = LibStub('LibSharedMedia-3.0')

--constants!
local PADDING = 4
local ICON_SIZE = 36 --the normal size for an icon
local DAY, HOUR, MINUTE = 86400, 3600, 60 --value in seconds for days, hours, and minutes
local UPDATE_DELAY = 0.01 --minimum time between timer updates
local DEFAULT_FONT = 'Friz Quadrata TT' --the default font id to use
local NO_OUTLINE = 'none'

--local bindings!
local format = string.format
local floor = math.floor
local min = math.min
local GRAY_FONT_COLOR_CODE = GRAY_FONT_COLOR_CODE
local NORMAL_FONT_COLOR_CODE = NORMAL_FONT_COLOR_CODE
local YELLOW_FONT_COLOR_CODE = YELLOW_FONT_COLOR_CODE
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local LSM_FONT = LSM.MediaType.FONT

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
	text:SetFont(self:GetFont())
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
	local font, size, outline = self:GetFont(self:GetFontScale())
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

--[[ Font Retrieval ]]--

function Timer:GetFontScale()
	if OmniCC:ScalingText() then
		return floor(self:GetWidth() - PADDING + 0.5) / ICON_SIZE
	end
	return 1
end

--wrapper for LSM functionality
local function fetchFont(fontId)
	if fontId and LSM:IsValid(LSM_FONT, fontId) then
		return LSM:Fetch(LSM_FONT, fontId)
	end
	return LSM:Fetch(LSM_FONT, DEFAULT_FONT)
end

local function fetchOutline(outlineId)
	if outlineId == NO_OUTLINE then
		return nil
	end
	return outlineId
end

function Timer:GetFont(scale)
	local scale = scale or 1
	return fetchFont(OmniCC:GetFontID()), OmniCC:GetFontSize() * scale, fetchOutline(OmniCC:GetFontOutline())
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
--			self:Print('OmniCC Initialized')
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
--	self:Print(('Updated to v%s'):format(self:GetDBVersion()))
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

function OmniCC:SetUseBlacklist(enable)
	self:GetDB().useBlacklist = enable and true or false
end

function OmniCC:UsingBlacklist()
	return self:GetDB().useBlacklist
end

function OmniCC:GetBlacklist()
	return self:GetDB().blacklist
end

function OmniCC:AddToBlacklist(patternToAdd)
	local blacklist = self:GetBlacklist()

	for i, pattern in pairs(blacklist) do
		if pattern == patternToAdd then
			return i
		end
	end
	
	table.insert(blacklist, pattern)
	table.sort(blacklist)

	for i, pattern in pairs(blacklist) do
		if pattern == patternToAdd then
			return i
		end
	end

	return false
end

function OmniCC:RemoveFromBlacklist(patternToRemove)
	local blacklist = self:GetBlacklist()
	for i, pattern in pairs(blacklist) do
		if pattern == patternToRemove then
			table.remove(blacklist, i)
			return i
		end
	end
	return false
end

--how many seconds, in length, must a cooldown be to show text
function OmniCC:SetMinDuration(duration)
	self:GetDB().minDuration = duration or 0
	self:UpdateTimers()
end

function OmniCC:GetMinDuration()
	return self:GetDB().minDuration or 0
end

--retrieves the id of the font we've chosen to use
function OmniCC:SetFontID(font)
	self:GetDB().font = font
	self:UpdateTimers()
end

function OmniCC:GetFontID()
	return self:GetDB().font or DEFAULT_FONT
end

function OmniCC:SetFontSize(size)
	self:GetDB().fontSize = size
	self:UpdateTimers()
end

function OmniCC:GetFontSize()
	return self:GetDB().fontSize or 18
end

function OmniCC:SetFontOutline(outline)
	self:GetDB().fontOutline = outline
	self:UpdateTimers()
end

function OmniCC:GetFontOutline()
	return self:GetDB().fontOutline or NONE
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
	Blacklisting/Whitelisting
--]]---------------------------------------------------------------------------

--blacklisting
--returns true if the name of the given frame matches a pattern on the blacklist
--and false otherwise
--frames with no name are considered NOT on the blacklist
do
	local blacklistedFrames = setmetatable({}, {__index = function(table, frame)
		local frameName = k:GetName()
		local blacklisted = false

		if frameName then
			for _, pattern in pairs(OmniCC:GetBlacklist()) do
				if frameName:match(pattern) then
					blacklisted = true
					break
				end
			end
		end	

		table[frame] = blacklisted
		return blacklisted
	end})

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

	local whitelistedFrames = setmetatable({}, {__index = function(table, frame)
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

		table[frame] = whitelisted		
		return whitelisted
	end})

	function Omnicc:IsWhitelisted(frame)
		return whitelistedFrames[frame]
	end
end


--[[---------------------------------------------------------------------------
	Utility
--]]---------------------------------------------------------------------------

function OmniCC:Print(...)
	return print('OmniCC:', ...)
end

--convienence functions for testing CooldownTextFrames
function OmniCC:AddFrame(f)
	CooldownTextFrames = CooldownTextFrames or {}
	CooldownTextFrames[f] = true
end

function OmniCC:RemoveFrame(f)
	if CooldownTextFrames then
		CooldownTextFrames[f] = nil
	end
end