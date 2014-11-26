--[[
	settings.lua
		handles OmniCC saved variables
--]]

local function ToNumber(number)
	return tonumber(number) or 0
end


--[[ Startup ]]--

function OmniCC:StartupSettings()
	local version = self:GetSettingsVersion()
	if version < 50201 then
		OmniCC4Config = {
			engine = 'AniUpdater',
			groupSettings = {base = self:DefaultGroup()},
			groups = {}
		}
	end

	self.sets = OmniCC4Config
	self.sets.version = self:GetVersion()

	if version < 60007 then
		if self:AddGroup('Ignore') then
			self.sets.groupSettings['Ignore'].enabled = false
			self.sets.groups[#self.sets.groups].rules = {'LossOfControl', 'TotemFrame'}
		end
	end
end

function OmniCC:DefaultGroup()
	return {
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
				r = 0.8, g = 1, b = .3, a = .8,
				scale = .75
			},
			controlled = {
				r = 1, g = .1, b = .1, a = 1,
				scale = 1.5
			},
		}
	}
end


--[[ Version ]]--

function OmniCC:GetVersion()
	return GetAddOnMetadata('OmniCC', 'Version')
end

function OmniCC:GetSettingsVersion()
	local version = OmniCC4Config and OmniCC4Config.version
	if version then
		local expansion, patch, release = version:match('(%d+)\.(%d+)\.(%d+)')
		return ToNumber(expansion) * 10000 + ToNumber(patch) * 100 + ToNumber(release)
	end

	return 0
end