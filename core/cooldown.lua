--[[
	cooldown.lua
		Manages the cooldowns need for timers
--]]

local Cooldown = OmniCC:New('Cooldown')
local Timer = OmniCC.Timer


--[[ Control ]]--

function Cooldown:Start(...)
	local timer = Timer:Get(self) or Timer:New(self)
	timer:UpdateOpacity()

	if Cooldown.CanShow(self, ...) then
		Cooldown.Setup(self)
		timer:Start(...)
	else
		Cooldown.Stop(self)
	end
end

function Cooldown:Setup()
	if not self.omnicc then
		self:HookScript('OnShow', Cooldown.OnShow)
		self:HookScript('OnHide', Cooldown.OnHide)
		self:HookScript('OnSizeChanged', Cooldown.OnSizeChanged)
		self.omnicc = true
	end
	
	OmniCC:SetupEffect(self)
end

function Cooldown:Stop()
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer:Stop()
	end
end

function Cooldown:CanShow(start, duration, charges)
	if not self.noCooldownCount and start and duration then
		local sets = OmniCC:GetGroupSettingsFor(self) 
		return start > 0 and duration >= sets.minDuration and sets.enabled
	end
end


--[[ Frame Events ]]--

function Cooldown:OnShow()
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		if timer:GetRemain() > 0 then
			timer.visible = true
			timer:UpdateShown()
		else
			timer:Stop()
		end
	end
end

function Cooldown:OnHide()
	local timer = Timer:Get(self)
	if timer and timer.enabled then
		timer.visible = nil
		timer:Hide()
	end
end

function Cooldown:OnSizeChanged(width, ...)
	if self.omniWidth ~= width then
		self.omniWidth = width
		
		local timer = Timer:Get(self)
		if timer then
			timer:UpdateFontSize(width, ...)
		end
	end
end