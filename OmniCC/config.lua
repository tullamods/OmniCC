--[[
	config.lua
		OmniCC configuration settings
--]]

local OmniCC = CreateFrame('Frame', 'OmniCC'); OmniCC:Hide()

--[[ Frame Events ]]--

OmniCC:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, event, ...)
	end
end)


--[[ Events ]]--

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

OmniCC:RegisterEvent('PLAYER_LOGOUT')
OmniCC:RegisterEvent('PLAYER_LOGIN')


--[[ Actions ]]--

function OmniCC:UpdateTimers()
	self.Timer:ForAllShown('UpdateText', true)
end

function OmniCC:UpdateTimerFonts()
	self.Timer:ForAllShown('UpdateFont', true)
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
	self:UpdateTimers()
end

function OmniCC:GetPeriodColor(timePeriod)
	local style = self:GetDB().styles[timePeriod]
	return style.r, style.g, style.b, style.a
end

function OmniCC:SetPeriodScale(timePeriod, scale)
	local style = self:GetDB().styles[timePeriod]
	style.scale = scale or 1
	self:UpdateTimers()
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