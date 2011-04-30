--[[
	config.lua
		OmniCC configuration settings
--]]

local OmniCC = CreateFrame('Frame', 'OmniCC'); OmniCC:Hide()
local CONFIG_NAME = 'OmniCC4Config'
local L = OMNICC_LOCALS


--[[---------------------------------------
	Local Functions
--]]---------------------------------------

local function removeTable(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(tbl[k]) == 'table' and type(v) == 'table' then
			removeTable(tbl[k], v)
			if next(tbl[k]) == nil then
				tbl[k] = nil
			end
		elseif tbl[k] == v then
			tbl[k] = nil
		end
	end
	return tbl
end

local function copyTable(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table' then
			tbl[k] = copyTable(tbl[k] or {}, v)
		elseif tbl[k] == nil then
			tbl[k] = v
		end
	end
	return tbl
end


--[[---------------------------------------
	Events
--]]---------------------------------------

OmniCC:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, event, ...)
	end
end)

function OmniCC:PLAYER_LOGIN()
	--add slash commands
	SLASH_OmniCC1 = '/omnicc'
	SLASH_OmniCC2 = '/occ'
	SlashCmdList['OmniCC'] = function(msg)
		self:OnSlashCmd(strsplit(' ', (msg or ''):lower()))
	end

	--create options loader
	local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	f:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)
		LoadAddOn('OmniCC_Config')
	end)
end

function OmniCC:PLAYER_LOGOUT()
	self:RemoveDefaults(self.db)
end

OmniCC:RegisterEvent('PLAYER_LOGOUT')
OmniCC:RegisterEvent('PLAYER_LOGIN')

--[[---------------------------------------
	Saved Settings
--]]---------------------------------------

function OmniCC:GetDB()
	return self.db or self:InitDB()
end

function OmniCC:InitDB()
	local db = _G[CONFIG_NAME]
	if db then
		if db.version ~= self:GetAddOnVersion() then
			db = self:UpgradeDB(db)
		end
	else
		db = self:CreateNewDB()
		_G[CONFIG_NAME] = db
	end

	copyTable(db, self:GetGlobalDefaults())

	--copy defaults
	local groupDefaults = self:GetGroupDefaults()
	for groupId, styleInfo in pairs(db.groupSettings) do
		copyTable(styleInfo, groupDefaults)
	end

	self.db = db
	return db
end

function OmniCC:RemoveDefaults(db)
	if not db then return end

	removeTable(db, self:GetGlobalDefaults())

	--remove base from any custom groups
	local groupDefaults = self:GetGroupDefaults()
	for groupId, styleInfo in pairs(db.groupSettings) do
		removeTable(styleInfo, groupDefaults)
	end
end

function OmniCC:CreateNewDB()
	local db = {
		groups = {},
		groupSettings = {
			base = {},
		},
		version = self:GetAddOnVersion()
	}

	--upgrade jamber from OmniCC3 to 4
	if _G['OmniCCGlobalSettings'] then
		db.groupSettings.base = _G['OmniCCGlobalSettings']
		db.groupSettings.base.blacklist = nil
		db.groupSettings.base.useBlacklist = nil
		db.groupSettings.base.minFontSize = nil
	end
	return db
end

function OmniCC:GetGlobalDefaults()
	return {
		updaterEngine = 'AniUpdater',
	}
end

function OmniCC:GetGroupDefaults()
	return {
		enabled = true,
		scaleText = true,
		showCooldownModels = true,
		fontFace = STANDARD_TEXT_FONT,
		fontSize = 18,
		fontOutline = 'OUTLINE',
		minDuration = 3,
		minSize = 0.5,
		effect = 'none',
		minEffectDuration = 30,
		tenthsDuration = 0,
		mmSSDuration = 0,
		--text coloring
		styles = {
			soon = {
				r = 1, g = 0, b= 0, a = 1,
				scale = 1.5,
			},
			seconds = {
				r = 1, g = 1, b= 0, a = 1,
				scale = 1,
			},
			minutes = {
				r = 1, g = 1, b = 1, a = 1,
				scale = 1,
			},
			hours = {
				r = 0.7, g = 0.7, b = 0.7, a = 1,
				scale = 0.75,
			},
		},
		--text positioning
		xOff = 0,
		yOff = 0,
		anchor = 'CENTER'
	}
end

function OmniCC:UpgradeDB(db)
	local pMajor, pMinor, pBugfix = db.version:match('(%d+)\.(%d+)\.(%w+)')

	if tonumber(pMajor) < 4 then
		db = OmniCC:CreateNewDB()
		_G[CONFIG_NAME] = db
		return db
	end

	db.version = self:GetAddOnVersion()
	return db
end

function OmniCC:GetAddOnVersion()
	return GetAddOnMetadata('OmniCC', 'Version')
end


--[[---------------------------------------
	Timer Scheduling
--]]---------------------------------------

function OmniCC:ScheduleUpdate(frame, delay)
	local engine = self:GetUpdateEngine()
	local updater = engine:Get(frame)

	updater:ScheduleUpdate(delay)
end

function OmniCC:CancelUpdate(frame)
	local engine = self:GetUpdateEngine()
	local updater = engine:GetActive(frame)

	if updater then
		updater:CancelUpdate()
	end
end

function OmniCC:GetUpdateEngine()
	return self[self:GetDB().updaterEngine]
end

function OmniCC:GetUpdateEngineName()
	return self:GetDB().updaterEngine
end

function OmniCC:SetUpdateEngine(engine)
	self:GetDB().updaterEngine = engine or 'AniUpdater'
end


--[[---------------------------------------
	Group Mapping
--]]---------------------------------------

local cdToGroupCache = {}

local function cooldown_GetGroupId(cooldown)
	local name = cooldown:GetName()
	if name then
		local groups = OmniCC:GetDB().groups
		for i = #groups, 1, -1 do
			local group = groups[i]
			if group.enabled then
				for _, pattern in pairs(group.rules) do
					if name:match(pattern) then
						return group.id
					end
				end
			end
		end
	end
	return 'base'
end

--maps the given cooldown to a groupId
function OmniCC:CDToGroup(cooldown)
	local groupId = cdToGroupCache[cooldown]

	--save groupIds so that we don't have to look them up again
	if not groupId then
		groupId = cooldown_GetGroupId(cooldown)
		cdToGroupCache[cooldown] = groupId
	end

	return groupId
end

function OmniCC:RecalculateCachedGroups()
	for cooldown, groupId in pairs(cdToGroupCache) do
		local newGroupId = cooldown_GetGroupId(cooldown)
		if groupId ~= newGroupId then
			cdToGroupCache[cooldown] = newGroupId

			--settings group changed, update timer
			local timer = self.Timer:Get(cooldown)
			if timer and timer.visible then
				timer:UpdateText(true)
				timer:UpdateCooldownShown()
			end
		end
	end
end

function OmniCC:GetGroupSettings(groupId)
	return self:GetDB().groupSettings[groupId]
end


--[[---------------------------------------
	Group Adding/Removing
--]]---------------------------------------

function OmniCC:AddGroup(groupId)
	if not self:GetGroupIndex(groupId) then
		local db = self:GetDB()
		db.groupSettings[groupId] = copyTable({}, db.groupSettings['base'])
		table.insert(db.groups, {id = groupId, rules = {}, enabled = true})

		self:RecalculateCachedGroups()
		return true
	end
end

function OmniCC:RemoveGroup(groupId)
	local index = self:GetGroupIndex(groupId)
	if index then
		local db = self:GetDB()
		db.groupSettings[groupId] = nil
		table.remove(db.groups, index)

		self:RecalculateCachedGroups()
		return true
	end
end

function OmniCC:GetGroupIndex(groupId)
	local db = self:GetDB()
	for i, group in pairs(db.groups) do
		if group.id == groupId then
			return i
		end
	end
	return false
end


--[[---------------------------------------
	Finish Effects
--]]---------------------------------------

function OmniCC:TriggerEffect(effectId, cooldown, ...)
	local effect = self:GetEffect(effectId)
	if effect then
		effect:Run(cooldown, ...)
	end
end

function OmniCC:RegisterEffect(effect)
	if not self:GetEffect(effect.id) then
		self.effects = self.effects or {}
		table.insert(self.effects, effect)
	end
end

function OmniCC:GetEffect(effectId)
	if self.effects then
		for _, effect in pairs(self.effects) do
			if effect.id == effectId then
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

--[[---------------------------------------
	Slash Commands
--]]---------------------------------------

function OmniCC:OnSlashCmd(...)
	local cmd = ...
	if cmd == '' or cmd == 'config' or cmd == 'menu' then
		if LoadAddOn('OmniCC_Config') then
			InterfaceOptionsFrame_OpenToCategory('OmniCC')
		end
	elseif cmd == 'setengine' then
		local engine = select(2, ...)
		if engine == 'classic' then
			self:SetUpdateEngine('ClassicUpdater')
			self:Print(L.SetEngine_Classic)
		elseif engine == 'animation' or engine == 'ani' then
			self:SetUpdateEngine('AniUpdater')
			self:Print(L.SetEngine_Animation)
		elseif engine and engine ~= '' then
			self:Print(L.UnknownEngineName:format(engine))
		else
			self:Print(L.SetEngineUsage)
		end
	elseif cmd == 'engine' then
		local engineName = (self:GetUpdateEngineName() == 'AniUpdater' and 'Animation' or 'Classic')
		self:Print(engineName)
	elseif cmd == 'version' then
		self:Print(self:GetAddOnVersion())
	elseif cmd == 'help' then
		self:Print(L.Commands)
		print(L.Command_ShowOptionsMenu)
		print(L.Command_SetTimerEngine)
		print(L.Command_ShowAddonVersion)
	else
		self:Print(L.UnknownCommandName:format(cmd))
	end
end

function OmniCC:Print(...)
	return print('|cffFCF75EOmniCC|r:', ...)
end