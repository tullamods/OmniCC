--[[
	settings.lua
		handles OmniCC saved variables
--]]

local Settings = 'OmniCC4Config'
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


--[[ Startup ]]--

function OmniCC:StartupSettings()
	self.sets = _G[Settings] or self:GetDefaults()
	self:UpgradeSettings()
	
	_G[Settings] = self.sets
end

function OmniCC:UpgradeSettings()
	local version = self:GetVersionID()
	if version < 40000 then
		self.sets = self:GetDefaults()
	elseif version < 50006 then
		self.sets.engine = 'AniUpdater'
		self.sets.updaterEngine = nil
		
		for _, group in pairs(self.sets.groupSettings) do
			CopyTable(group, self:GetGroupDefaults())
		end
	end

	self.sets.version = self:GetVersion()
end
	

--[[ Constants ]]--

function OmniCC:GetDefaults()
	return {
		engine = 'AniUpdater',
		groups = {},
		groupSettings = {
			base = self:GetGroupDefaults()
		}
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
				r = 0.7, g = 0.7, b = 0.7, a = 1,
				scale = 0.75
			}
		}
	}
end

--[[ Version ]]--

function OmniCC:GetVersionID()
	local version = self.sets.version or self:GetVersion()
	local expansion, patch, release = version:match('(%d+)\.(%d+)\.(%w+)')
	
	return tonumber(expansion) * 10000 + tonumber(patch) * 100 + tonumber(release)
end

function OmniCC:GetVersion()
	return GetAddOnMetadata('OmniCC', 'Version')
end