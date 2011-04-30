--[[
	pulse.lua
		a pulsing effect for when a cooldown completes
--]]

local Classy = LibStub('Classy-1.0')
local L = OMNICC_LOCALS
local PULSE_SCALE = 2
local PULSE_DURATION = 1.5

--[[
	The pulse object
--]]

local Pulse = Classy:New('Frame')

function Pulse:New(parent)
	local f = self:Bind(CreateFrame('Frame', nil, parent)); f:Hide()
	f:SetAllPoints(parent)
	f:SetToplevel(true)
	f:SetScript('OnHide', f.OnHide)

	f.animation = f:CreatePulseAnimation()

	local icon = f:CreateTexture(nil, 'OVERLAY')
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
	
	local function scale_OnFinished(self)
		if self.reverse then
			self.reverse = nil
			self:GetParent():Finish()
		else
			self.reverse = true
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
		grow:SetOrder(0)
		grow:SetScript('OnFinished', scale_OnFinished)

		return g
	end
end

function Pulse:OnHide()
	if self.animation:IsPlaying() then
		self.animation:Stop()
	end
	self:Hide()
end

function Pulse:Start(texture)
	if self.animation:IsPlaying() then
		self.animation:Stop()
	end

	local icon = self.icon
	local r, g, b = icon:GetVertexColor()
	icon:SetVertexColor(r, g, b, 0.7)
	icon:SetTexture(texture:GetTexture())

	self:Show()
	self.animation:Play()
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

	OmniCC:RegisterEffect{
		id = 'pulse',
		name = L.Pulse,
		Run = function(self, cooldown)
			local p = cooldown:GetParent()
			local texture = getTexture(p)
			if texture then
				pulses[p]:Start(texture)
			end
		end
	}
end