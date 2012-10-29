--[[
	shine.lua
		a shine finish effect
--]]

local L = OMNICC_LOCALS
local Shine = LibStub('Classy-1.0'):New('Frame')
Shine.id = 'shine'
Shine.name = L.Shine
Shine.instances = {}

Shine.texture = [[Interface\Cooldown\star4]]
Shine.duration = .75
Shine.scale = 5


--[[ Run ]]--

function Shine:Run(cooldown)
	local shine = self.instances[cooldown]
	if shine then
		shine:Start()
	end
end

function Shine:Start()
	if self.animation:IsPlaying() then
		self.animation:Finish()
	end
	
	self:Show()
	self.animation:Play()
end

function Shine:OnAnimationFinished()
	local parent = self:GetParent()
	if parent:IsShown() then
		parent:Hide()
	end
end

function Shine:OnHide()
	if self.animation:IsPlaying() then
		self.animation:Finish()
	end
	
	self:Hide()
end


--[[ Setup ]]--

function Shine:Setup(cooldown)
	local parent = cooldown:GetParent()
	if parent then
		local shine = self:Bind(CreateFrame('Frame', nil, parent))
		shine:Hide()
		shine:SetScript('OnHide', shine.OnHide)
		shine:SetAllPoints(parent)
		shine:SetToplevel(true)
		shine.animation = shine:CreateShineAnimation()

		local icon = shine:CreateTexture(nil, 'OVERLAY')
		icon:SetPoint('CENTER')
		icon:SetBlendMode('ADD')
		icon:SetAllPoints(shine)
		icon:SetTexture(self.texture)

		self.instances[cooldown] = shine
		return shine
	end
end

function Shine:CreateShineAnimation()
	local group = self:CreateAnimationGroup()
	group:SetScript('OnFinished', self.OnAnimationFinished)
	group:SetLooping('NONE')

	local startTrans = group:CreateAnimation('Alpha')
	startTrans:SetChange(-1)
	startTrans:SetDuration(0)
	startTrans:SetOrder(0)

	local grow = group:CreateAnimation('Scale')
	grow:SetOrigin('CENTER', 0, 0)
	grow:SetScale(self.scale, self.scale)
	grow:SetDuration(self.duration / 2)
	grow:SetOrder(1)

	local brighten = group:CreateAnimation('Alpha')
	brighten:SetChange(1)
	brighten:SetDuration(self.duration / 2)
	brighten:SetOrder(1)

	local shrink = group:CreateAnimation('Scale')
	shrink:SetOrigin('CENTER', 0, 0)
	shrink:SetScale(-self.scale, -self.scale)
	shrink:SetDuration(self.duration / 2)
	shrink:SetOrder(2)

	local fade = group:CreateAnimation('Alpha')
	fade:SetChange(-1)
	fade:SetDuration(self.duration / 2)
	fade:SetOrder(2)

	return group
end

OmniCC:RegisterEffect(Shine)