--[[ 
	The cooldown model hook
--]]

local OmniCC = OmniCC

local function isParent(parent, frame)
	if parent and frame then
		local fParent = frame:GetParent()
		return parent == fParent or isParent(parent, fParent)
	end
end

local enabledFrames = setmetatable({}, {__index = function(t, k)
	local frames = _G['CooldownTextFrames']
	if frames then
		for f, enabled in pairs(frames) do
			if isParent(f, k) then
				t[k] = enabled
				return enabled
			end
		end
	end
end})

local function shouldShowTimer(cooldown)
	return enabledFrames[cooldown] and not cooldown.noCooldownCount
end

local function hideTimer(cooldown)
	if cooldown.timer then
		cooldown.timer:Stop()
	end
end

--ActionButton1Cooldown here, is something we think will always exist
local methods = getmetatable(_G['ActionButton1Cooldown']).__index
hooksecurefunc(methods, 'SetCooldown', function(self, start, duration)
	if shouldShowTimer(self) then
		--self:SetAlpha(OmniCC:ShowingModels() and 1 or 0)
		if start > 0 and duration > OmniCC:GetMinDuration() then
			OmniCC:StartTimer(self, start, duration)
			return
		end
	end
	hideTimer(self)
end)