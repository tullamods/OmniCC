--[[
	config.lua
		OmniCC configuration settings
--]]

local round = function(x) return math.floor(x + 0.5) end

local OmniCC = CreateFrame('Frame', 'OmniCC'); OmniCC:Hide()


--[[---------------------------------------------------------------------------
	Events
--]]---------------------------------------------------------------------------

OmniCC:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, event, ...)
	end
end)

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

	self:UpdateFont()
end

function OmniCC:PLAYER_LOGOUT()
	self:RemoveDefaults()
end

OmniCC:RegisterEvent('PLAYER_LOGOUT')
OmniCC:RegisterEvent('PLAYER_LOGIN')


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
	return tbl
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
	return self.db or self:InitDB()
end

function OmniCC:InitDB()
	self.db = _G['OmniCCGlobalSettings']
	if self.db then
		if self.db.version ~= self:GetAddOnVersion() then
			self:UpgradeDB()
		end
	else
		self.db = self:CreateNewDB()
	end
	return copyDefaults(self.db, self:GetDefaults())
end

function OmniCC:GetDefaults()
	return {
		showCooldownModels = true,
		useBlacklist = false,
		blacklist = {},
		fontFace = STANDARD_TEXT_FONT,
		fontSize = 18,
		fontOutline = 'OUTLINE',
		scaleText = true,
		minDuration = 3,
		minFontSize = 9,
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
end

function OmniCC:RemoveDefaults()
	local db = self.db
	if db then
		removeDefaults(db, self:GetDefaults())
	end
end

function OmniCC:CreateNewDB()
	local db = {version = self:GetAddOnVersion()}
	_G['OmniCCGlobalSettings'] = db
	return db
end

function OmniCC:UpgradeDB()
	self:GetDB().version = self:GetAddOnVersion()
end

function OmniCC:GetAddOnVersion()
	return GetAddOnMetadata('OmniCC', 'Version')
end


--[[---------------------------------------------------------------------------
	Configuration
--]]---------------------------------------------------------------------------

--[[ Blacklist ]]--

--enable/disable blacklist
function OmniCC:SetUseBlacklist(enable)
	self:GetDB().useBlacklist = enable and true or false
	self.Timer:ForAll('UpdateShown')
end

function OmniCC:UsingBlacklist()
	return self:GetDB().useBlacklist
end

--backlist item editing
function OmniCC:GetBlacklist()
	return self:GetDB().blacklist
end

--adding/removing items to the blacklist
local function isValidBlacklistPattern(pattern)
	return pattern and not pattern:match('^%s*$')
end

function OmniCC:AddToBlacklist(patternToAdd)
	if not isValidBlacklistPattern(patternToAdd) then
		return false
	end

	if not self:GetBlacklistIndex(patternToAdd) then
		self:ClearBlacklistCache()

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
		self:ClearBlacklistCache()

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

do
	--blacklist cache
	--returns true if the name of the given frame matches a pattern on the blacklist
	--and false otherwise
	--frames with no name are considered NOT on the blacklist
	local blacklistCache = setmetatable({}, {__index = function(t, frame)
		if frame.noCooldownCount then
			return true
		end

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

	--returns true if the given frame is blacklisted, and false otherwise
	function OmniCC:IsBlacklisted(frame)
		return (self:UsingBlacklist() and blacklistCache[frame]) or frame.noCooldownCount
	end

	--purges the blacklist cache
	function OmniCC:ClearBlacklistCache()
		for k, v in pairs(blacklistCache) do
			blacklistCache[k] = nil
		end
	end
end

--[[ Font ]]--

--font id
function OmniCC:SetFontFace(fontFace)
	self:GetDB().fontFace = fontFace
	self:UpdateFont()
end

function OmniCC:GetFontFace()
	return self:GetDB().fontFace
end

--font size
function OmniCC:SetFontSize(fontSize)
	self:GetDB().fontSize = fontSize
	self:UpdateFont()
end

function OmniCC:GetFontSize()
	return self:GetDB().fontSize
end

--font outline
function OmniCC:SetFontOutline(fontOutline)
	self:GetDB().fontOutline = fontOutline
	self:UpdateFont()
end

function OmniCC:GetFontOutline()
	return self:GetDB().fontOutline
end

--font scaling
function OmniCC:SetScaleText(enable)
	self:GetDB().scaleText = enable and true or false
	self:UpdateFont()
end

function OmniCC:ScalingText()
	return self:GetDB().scaleText
end

--create an object to track font size changes
do
	local fontFace, fontSize, fontOutline, fontScale = STANDARD_TEXT_FONT, 18, 'OUTINE', 1

	--create a basic frame for testing font size changes
	local tester = CreateFrame('Frame', nil, UIParent)
	tester:Hide()
	tester:SetSize(36, 36)

	local text = tester:CreateFontString()
	text:SetFont(fontFace, fontSize, fontOutline)
	text:SetText('10s') --text that maps to whatever the longest possible string for cooldown text is
	text:SetPoint('CENTER', f)
	tester.text = text

	--recalculate font info
	function OmniCC:UpdateFont()
		--confirm that the font is valid
		fontFace, fontSize, fontOutline = self:GetFontFace(), self:GetFontSize(), self:GetFontOutline()
		if not tester.text:SetFont(fontFace, fontSize, fontOutline) then
			fontFace = STANDARD_TEXT_FONT
			tester.text:SetFont(fontFace, fontSize, fontOutline)
		end

		--calculate font scale
		if self:ScalingText() then
			fontScale = round(tester:GetWidth()) / round(tester.text:GetStringWidth())
		else
			fontScale = 1
		end

		self.Timer:ForAll('UpdateFont')
		return self
	end

	function OmniCC:GetFontInfo()
		return fontFace, fontSize * fontScale, fontOutline
	end
end

--[[ Display Restrictions ]]--

--minimum font size to display text
function OmniCC:SetMinFontSize(size)
	self:GetDB().minFontSize = size or 0
	self.Timer:ForAll('UpdateShown')
end

function OmniCC:GetMinFontSize()
	return self:GetDB().minFontSize
end

--how many seconds, in length, must a cooldown be to show text
function OmniCC:SetMinDuration(duration)
	self:GetDB().minDuration = duration or 0
end

function OmniCC:GetMinDuration()
	return self:GetDB().minDuration
end

--minumum duration to show tenths of seconds
function OmniCC:SetTenthsDuration(value)
	self:GetDB().tenthsDuration = value or 0
	self.Timer:ForAllShown('UpdateText')
end

function OmniCC:GetTenthsDuration()
	return self:GetDB().tenthsDuration
end

--[[ Timer Style ]]--

--color
function OmniCC:SetPeriodColor(timePeriod, ...)
	local style = self:GetDB().styles[timePeriod]
	style.r, style.g, style.b, style.a = ...
	self.Timer:ForAllShown('UpdateText', true)
end

function OmniCC:GetPeriodColor(timePeriod)
	local style = self:GetDB().styles[timePeriod]
	return style.r, style.g, style.b, style.a
end

--scale
function OmniCC:SetPeriodScale(timePeriod, scale)
	local style = self:GetDB().styles[timePeriod]
	style.scale = scale or 1
	self.Timer:ForAllShown('UpdateText', true)
end

function OmniCC:GetPeriodScale(timePeriod)
	return self:GetDB().styles[timePeriod].scale
end

--minimum duration to display text as MM:SS
function OmniCC:SetMMSSDuration(value)
	self:GetDB().mmSSDuration = value or 0
	self.Timer:ForAllShown('UpdateText')
end

function OmniCC:GetMMSSDuration()
	return self:GetDB().mmSSDuration
end

function OmniCC:UsingMMSS()
	return self:GetDB().mmSSDuration > 60
end

--cooldown model showing/hiding
local function cooldown_Hide(self, enable)
	self:SetAlpha(enable and 1 or 0)
end

function OmniCC:SetShowCooldownModels(enable)
	self:GetDB().showCooldownModels = enable and true or false
	self.Timer:ForAllShownCooldowns(cooldown_Hide)
end

function OmniCC:ShowingCooldownModels()
	return self:GetDB().showCooldownModels
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

--[[ Compatibility Hacks ]]--

--turn off OmniCC_Pulse + OmniCC_Shine
--and also provide something valid to return from CreateClass to prevent user errors
function OmniCC:CreateClass(...)
	DisableAddOn('OmniCC_Pulse')
	DisableAddOn('OmniCC_Shine')
	return LibStub('Classy-1.0'):New(...)
end