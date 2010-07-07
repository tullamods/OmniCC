--[[ 
	The cooldown model hook
--]]

local OmniCC = OmniCC

local function shouldShowTimer(cooldown)
	if OmniCC:UsingBlacklist() and OmniCC:IsBlacklisted(cooldown) then
		return false
	end
	if OmniCC:UsingWhitelist() and not OmniCC:IsWhitelisted(cooldown) then
		return false
	end
	return true
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