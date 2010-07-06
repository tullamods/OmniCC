--[[
	pulse.lua
		a pulsing effect for when a cooldown completes
--]]

local Classy = LibStub('Classy-1.0')
local PULSE_SCALE = 3
local PULSE_DURATION = 0.5

--[[
	The pulse object
--]]

local Pulse = Classy:New('Frame')

function Pulse:New(parent)
	local f = self:Bind(CreateFrame('Frame', nil, parent)) 
	f:SetAllPoints(parent)
	f:SetToplevel(true)
	f:Hide()
	
	f.animation = f:CreatePulseAnimation()
	f:SetScript('OnHide', f.OnHide)

	local icon = f:CreateTexture(nil, 'OVERLAY')
	icon:SetPoint('CENTER')
	icon:SetBlendMode('ADD')
	icon:SetAllPoints(f)
	f.icon = icon

	return f
end

do
	local function animation_OnFinished(self)
		local parent = self:GetParent()
		if parent:IsShown() then
			parent:Hide()
		end
	end
	
	local function grow_OnFinished(self)
		if self.reversed then
			self.reversed = nil
			self:GetParent():Finish()
		else
			self.reversed = true
		end
	end

	function Pulse:CreatePulseAnimation()
		local g = self:CreateAnimationGroup()
		g:SetLooping('BOUNCE')
		g:SetScript('OnFinished', animation_OnFinished)

		--animation = AnimationGroup:CreateAnimation("animationType" [, "name" [, "inheritsFrom"]])
		local grow = g:CreateAnimation('Scale')
		grow:SetScale(PULSE_SCALE, PULSE_SCALE)
		grow:SetOrigin('CENTER', 0, 0)
		grow:SetDuration(PULSE_DURATION/2)
		grow:SetOrder(1)
		grow:SetSmoothing('IN')
		grow:SetScript('OnFinished', grow_OnFinished)

		return g
	end
end

function Pulse:OnHide()
	self.animation:Finish()
	self:Hide()
end

function Pulse:Start(texture)
	if not self.animation:IsPlaying() then
		local icon = self.icon
		local r, g, b = icon:GetVertexColor()
		icon:SetVertexColor(r, g, b, 0.7)
		icon:SetTexture(texture:GetTexture())

		self:Show()
		self.animation:Play()
	end
end


--[[ register effect with OmniCC ]]--

do
	local pulses = setmetatable({}, {__index = function(t, k)
		local f = Pulse:New(k)
		t[k] = f
		return f
	end})
	
	local function getTexture(frame)
		if not frame then
			return
		end
		
		local icon = frame.icon
		if icon then
			return icon
		end
		
		local name = frame:GetName()
		if name then
		 	return _G[name .. 'Icon'] or _G[name .. 'IconTexture']
		end
	end
	
	OmniCC:RegisterEffect{
		id = 'pulse',
		GetName = function(self) 
			return OMNICC_LOCALS['Pulse'] 
		end,
		Enable = function(self)
			OmniCC:Listen(self, 'COOLDOWN_FINISHED')
		end,
		Disable = function(self)
			OmniCC:Ignore(self, 'COOLDOWN_FINISHED')
		end,
		COOLDOWN_FINISHED = function(self, msg, cooldown)
			local parent = cooldown:GetParent()
			local texture = getTexture(parent)
			if texture then
				pulses[parent]:Start(texture)
			end
		end
	}
end