--[[
	modules.lua
		manages the plugable features
--]]


--[[ Finish Effects ]]--

function OmniCC:TriggerEffect(cooldown)
	if self.effect then
		self.effect:Run(cooldown)
	end
end

function OmniCC:ForAllEffect(func, ...)
	local results
	
	for _, effect in pairs(self.effects) do
		local result = func(effect, ...)
		if result then
			results = results or {}
			tinsert(results, result)
		end
	end

	return results
end

function OmniCC:RegisterEffect(effect)
	self.effects[id] = effect
end

function OmniCC:GetEffect(id)
	return self.effects[id]
end


--[[ Utilities ]]--

function OmniCC:GetButtonIcon(frame)
	if frame then
		local icon = frame.icon
		if icon and icon.GetTexture then
			return icon
		end

		local name = frame:GetName()
		if name then
			local icon = _G[name .. 'Icon'] or _G[name .. 'IconTexture']
			if icon and icon.GetTexture then
				return icon
			end
		end
	end
end

function OmniCC:GetUpdateEngine()
	return self[self.sets.engine]
end