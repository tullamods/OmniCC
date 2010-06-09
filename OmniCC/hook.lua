--[[ 
	The cooldown model hook
--]]

local OmniCC = OmniCC

local function textDisabled(cooldown)
	return cooldown.noCooldownCount
end

local function hideTimer(cooldown)
	if cooldown.timer then
		cooldown.timer:Stop()
	end
end

--ActionButton1Cooldown here, is something we think will always exist
local methods = getmetatable(_G['ActionButton1Cooldown']).__index
hooksecurefunc(methods, 'SetCooldown', function(self, start, duration)
	if textDisabled(self) then
		hideTimer(self)
	else
		self:SetAlpha(OmniCC:ShowingModels() and 1 or 0)
		if start > 0 and duration > OmniCC:GetMinDuration() then
			OmniCC:StartTimer(self, start, duration)
		else
			hideTimer(self)
		end
	end
end)