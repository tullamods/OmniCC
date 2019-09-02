-- OmniCC's configuration API

local AddonName, Addon = ...

local DB_NAME = AddonName .. "DB"
local DB_VERSION = 5

local LEGACY_DB_NAME = "OmniCC4Config"

function Addon:InitializeDB()
	self.db = LibStub("AceDB-3.0"):New(DB_NAME, self:GetDBDefaults(), DEFAULT)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	self:UpgradeDB()
end

function Addon:OnProfileChanged(...)
	self.Cooldown:UpdateSettings()
end

function Addon:GetDBDefaults()
	return {
		global = {},
		profile = {
			groupOrder = {
				"default"
			},
			groupSettings = {
				["**"] = {
					-- should we show text for the group
					enableText = true,
					scaleText = true,
					spiralOpacity = 1,
					fontFace = STANDARD_TEXT_FONT,
					fontSize = 18,
					fontOutline = "OUTLINE",
					minDuration = 2,
					minSize = 0.5,
					effect = "pulse",
					minEffectDuration = 30,
					tenthsDuration = 0,
					mmSSDuration = 0,
					xOff = 0,
					yOff = 0,
					anchor = "CENTER",
					styles = {
						["**"] = {
							r = 1,
							g = 1,
							b = 1,
							a = 1,
							scale = 1
						},
						soon = {
							r = 1,
							g = .1,
							b = .1,
							scale = 1.5
						},
						seconds = {
							r = 1,
							g = 1,
							b = .1
						},
						minutes = {
							r = 1,
							g = 1,
							b = 1
						},
						hours = {
							r = .7,
							g = .7,
							b = .7,
							scale = .75
						},
						charging = {
							r = 0.8,
							g = 1,
							b = .3,
							a = .8,
							scale = .75
						},
						controlled = {
							r = 1,
							g = .1,
							b = .1,
							scale = 1.5
						}
					},
					rules = {}
				}
			}
		}
	}
end

function Addon:UpgradeDB()
	local dbVersion = self.db.global.dbVersion
	if dbVersion ~= DB_VERSION then
		if dbVersion == nil then
			self:MigrateLegacySettings(_G[LEGACY_DB_NAME])
		end

		self.db.global.dbVersion = DB_VERSION
	end

	local addonVersion = self.db.global.addonVersion
	if addonVersion ~= GetAddOnMetadata(AddonName, "Version") then
		self.db.global.addonVersion = GetAddOnMetadata(AddonName, "Version")
	end
end

function Addon:MigrateLegacySettings(legacyDb)
	if not type(legacyDb) == "table" then
		return
	end

	local function getNewGroupId(id)
		if id == "base" then
			return "default"
		end

		return id
	end

	local function copyTable(src, dest)
		if not type(dest) == "table" then
			dest = {}
		end

		for k, v in pairs(src) do
			if type(v) == "table" then
				dest[k] = copyTable(v, dest[k])
			else
				dest[k] = v
			end
		end

		return dest
	end

	local oldGroupSettings = legacyDb.groupSettings
	if type(oldGroupSettings) == "table" then
		for id, group in pairs(oldGroupSettings) do
			-- apply the old settings
			local newGroupSettings = copyTable(group, self.db.profile.groupSettings[getNewGroupId(id)])

			-- apply field changes
			newGroupSettings.enableText = newGroupSettings.enabled
			newGroupSettings.enabled = nil
		end
	end

	local oldGroupOrder = legacyDb.groups
	if type(oldGroupOrder) == "table" then
		for i = #oldGroupOrder, 1, -1 do
			local group = oldGroupOrder[i]
			local newGroupId = getNewGroupId(group.id)

			copyTable(group.rules, self.db.profile.groupSettings[newGroupId].rules)

			if group.enabled then
				tinsert(self.db.profile.groupOrder, 1, newGroupId)
			end
		end
	end

	return true
end
