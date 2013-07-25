--[[
	settings.lua
		handles OmniCC saved variables
--]]

local SAVED_VAR = 'OmniCC4Config'
local GROUP_DEFAULTS = {
	enabled = true,
	scaleText = true,
	spiralOpacity = 1,
	fontFace = STANDARD_TEXT_FONT,
	fontSize = 18,
	fontOutline = 'OUTLINE',
	minDuration = 2,
	minSize = 0.5,
	effect = 'pulse',
	minEffectDuration = 30,
	tenthsDuration = 0,
	mmSSDuration = 0,
	xOff = 0,
	yOff = 0,
	anchor = 'CENTER',
	styles = {
		soon = {
			r = 1, g = .1, b = .1, a = 1,
			scale = 1.5
		},
		seconds = {
			r = 1, g = 1, b = .1, a = 1,
			scale = 1
		},
		minutes = {
			r = 1, g = 1, b = 1, a = 1,
			scale = 1
		},
		hours = {
			r = .7, g = .7, b = .7, a = 1,
			scale = .75
		},
		charging = {
			r = 1, g = .98, b = .4, a = .8,
			scale = .65
		}
	}
}

local DEFAULTS = {
	engine = 'AniUpdater',
	groups = {},
	groupSettings = {base = GROUP_DEFAULTS}
}


--[[ Utilities ]]--

local function CopyTable(target, source)
	for k, v in pairs(source) do
		if type(v) == 'table' then
			target[k] = CopyTable(target[k] or {}, v)
			
		elseif target[k] == nil then
			target[k] = v
		end
	end
	
	return target
end

local function ToNumber(number)
	return tonumber(number) or 0
end


--[[ Startup ]]--

function OmniCC:StartupSettings()
	self.sets = _G[SAVED_VAR] or DEFAULTS
	self:UpgradeSettings()
	
	_G[SAVED_VAR] = self.sets
end

function OmniCC:UpgradeSettings()
	local version = self:GetVersionID()
	local groups = self.sets.groupSettings

	if version < 40000 then
		self.sets = DEFAULTS
	elseif version < 50006 then
		self.sets.engine = 'AniUpdater'
		self.sets.updaterEngine = nil
		
		for _, group in pairs(groups) do
			CopyTable(group, GROUP_DEFAULTS)
		end
	else
		if version < 50201 then
			for _, group in pairs(groups) do
				group.showCooldownModels = nil
				group.spiralOpacity = 1
			end
		end

		if version < 50302 then
			for _, group in pairs(groups) do
				group.styles.charging = GROUP_DEFAULTS.styles.charging
			end
		end
	end

	self.sets.version = self:GetVersion()
end


--[[ Version ]]--

function OmniCC:GetVersionID()
	local version = self.sets.version or self:GetVersion()
	local expansion, patch, release = version:match('(%d+)\.(%d+)\.(%d+)')
	
	return ToNumber(expansion) * 10000 + ToNumber(patch) * 100 + ToNumber(release)
end

function OmniCC:GetVersion()
	return GetAddOnMetadata('OmniCC', 'Version')
end