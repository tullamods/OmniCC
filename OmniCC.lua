--[[
	config.lua
		OmniCC configuration settings
--]]

local OmniCC = CreateFrame('Frame', 'OmniCC'); OmniCC:Hide()
local CONFIG_NAME = 'OmniCC4Config'


--[[---------------------------------------------------------------------------
	Local Functions
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
	--add slash commands
	SLASH_OmniCC1 = '/omnicc'
	SLASH_OmniCC2 = '/occ'
	SlashCmdList['OmniCC'] = function(msg)
		if LoadAddOn('OmniCC_Config') then
			InterfaceOptionsFrame_OpenToCategory('OmniCC')
		end
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
	--done so that I can call remove defaults from Config without blowing up the base defaults
	removeDefaults(db.groupSettings.base, self:GetBaseDefaults())
end

OmniCC:RegisterEvent('PLAYER_LOGOUT')
OmniCC:RegisterEvent('PLAYER_LOGIN')


--[[---------------------------------------------------------------------------
	Saved Settings
--]]---------------------------------------------------------------------------

function OmniCC:GetDB()
	return self.db or self:InitDB()
end

function OmniCC:InitDB()
	local db = _G[CONFIG_NAME]
	if db then
		if db.version ~= self:GetAddOnVersion() then
			self:UpgradeDB(db)
		end
	else
		db = self:CreateNewDB()
		_G[CONFIG_NAME] = db
	end
	copyDefaults(db.groupSettings.base, self:GetBaseDefaults())
	
	self.db = db
	return db
end

function OmniCC:RemoveDefaults(db)
	if db then
		--remove base style defaults from other Settings
		local baseStyle = db.groupSettings['base']
		for groupId, styleInfo in pairs(db.groupSettings) do
			if groupId ~= 'base' then
				removeDefaults(styleInfo, baseStyle)
			end
		end
	end
end

function OmniCC:CreateNewDB()
	return {
		version = self:GetAddOnVersion(),
		groups = {
			{
				id = 'action',
				rules = {'Action'},
				enabled = true,
			},
			{
				id = 'aura', 
				rules = {'Aura', 'Buff', 'Debuff', 'PitBull'},
				enabled = true,
			},
			{
				id = 'pet',
				rules = {'PetActionButton'},
				enabled = true,
			}
		},
		groupSettings = {
			base = {},
			action = {},
			pet = {fontSize = 16},
			aura = {fontSize = 10, showCooldownModels = false},
		}
	}
end

function OmniCC:GetBaseDefaults()
	return {
		enabled = true,
		scaleText = false,
		showCooldownModels = true,
		fontFace = STANDARD_TEXT_FONT,
		fontSize = 18,
		fontOutline = 'OUTLINE',
		minDuration = 3,
		minFontSize = 9,
		effect = 'pulse',
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
	
	--upgrade db if the major verson changes
	if tonumber(pMajor) < 4 then
		db = OmniCC:CreateNewDB()
		_G[CONFIG_NAME] = db
		return
	end
	
	db.version = self:GetAddOnVersion()
	return db
end

function OmniCC:GetAddOnVersion()
	return GetAddOnMetadata('OmniCC', 'Version')
end


--[[---------------------------------------------------------------------------
	Group Mapping
--]]---------------------------------------------------------------------------

local cdToGroupCache = setmetatable({}, {__index = function(t, cooldown)
	local name = cooldown:GetName()
	if name then
		local groups = OmniCC:GetDB().groups
		for i = #groups, 1, -1 do
			local group = groups[i]
			if group.enabled then
				for _, pattern in pairs(group.rules) do
					if name:match(pattern) then
						t[cooldown] = group.id
						return group.id
					end
				end
			end
		end
	end
	t[cooldown] = 'base'
	return 'base'
end})

--maps the given cooldown to a groupId
function OmniCC:CDToGroup(cooldown)
	return cdToGroupCache[cooldown]
end

--retrieves settings for the given groupId
--if a setting cannot be found in the group, then retrieves the setting from the base group
local groupSettingsCache = setmetatable({}, {__index = function(t, groupId)
	local groupSettings = OmniCC:GetDB().groupSettings
	
	local sets = setmetatable({}, {__index = function(_, k)
		local v = groupSettings[groupId][k]
		if v ~= nil then
			return v
		end
		return groupSettings['base'][k]
	end})
	
	t[groupId] = sets
	return sets
end})

function OmniCC:GetGroupSettings(groupId)
	return groupSettingsCache[groupId]
end


--[[---------------------------------------------------------------------------
	Group Adding/Removing
--]]---------------------------------------------------------------------------

function OmniCC:AddGroup(groupId)
	if not self:GetGroupIndex(groupId) then
		local db = self:GetDB()
		table.insert(db.groups, {id = groupId, rules = {}, enabled = true})
		db.groupSettings[groupId] = {}
				
		return true
	end
end

function OmniCC:RemoveGroup(groupId)
	local index = self:GetGroupIndex(groupId)
	if index then
		local db = self:GetDB()
		table.remove(db.groups, index)
		db.groupSettings[groupId] = nil	
			
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


--[[---------------------------------------------------------------------------
	Finish Effects
--]]---------------------------------------------------------------------------

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