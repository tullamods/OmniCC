--[[
	shine.lua
		a shine effect for when a cooldown completes
--]]

local Classy = LibStub('Classy-1.0')
local L = OMNICC_LOCALS
local SCALE = 5
local DURATION = 0.8
local TEXTURE = [[Interface\Cooldown\star4]]


--[[
	The shine object
--]]

local Shine = Classy:New('Frame')

function Shine:New(parent)
	local f = self:Bind(CreateFrame('Frame', nil, parent)); f:Hide()
	f:SetScript('OnHide', f.OnHide)
	f:SetAllPoints(parent)
	f:SetToplevel(true)

	f.animation = f:CreateShineAnimation()

	local icon = f:CreateTexture(nil, 'OVERLAY')
	icon:SetPoint('CENTER')
	icon:SetBlendMode('ADD')
	icon:SetAllPoints(f)
	icon:SetTexture(TEXTURE)

	return f
end

do
	local function animation_OnFinished(self)
		local parent = self:GetParent()
		if parent:IsShown() then
			parent:Hide()
		end
	end

	function Shine:CreateShineAnimation()
		local g = self:CreateAnimationGroup()
		g:SetLooping('NONE')
		g:SetScript('OnFinished', animation_OnFinished)

		--start the animation as completely transparent
		local startTrans = g:CreateAnimation('Alpha')
		startTrans:SetChange(-1)
		startTrans:SetDuration(0)
		startTrans:SetOrder(0)

		local grow = g:CreateAnimation('Scale')
		grow:SetOrigin('CENTER', 0, 0)
		grow:SetScale(SCALE, SCALE)
		grow:SetDuration(DURATION/2)
		grow:SetOrder(1)

		local brighten = g:CreateAnimation('Alpha')
		brighten:SetChange(1)
		brighten:SetDuration(DURATION/2)
		brighten:SetOrder(1)

		local shrink = g:CreateAnimation('Scale')
		shrink:SetOrigin('CENTER', 0, 0)
		shrink:SetScale(-SCALE, -SCALE)
		shrink:SetDuration(DURATION/2)
		shrink:SetOrder(2)

		local fade = g:CreateAnimation('Alpha')
		fade:SetChange(-1)
		fade:SetDuration(DURATION/2)
		fade:SetOrder(2)

		return g
	end
end

function Shine:OnHide()
	self.animation:Finish()
	self:Hide()
end

function Shine:Start()
	if not self.animation:IsPlaying() then
		self:Show()
		self.animation:Play()
	end
end


--[[ register effect with OmniCC ]]--

do
	local shines = setmetatable({}, {__index = function(t, k)
		local f = Shine:New(k)
		t[k] = f
		return f
	end})

	OmniCC:RegisterEffect{
		id = 'shine',
		name = L.Shine,
		Run = function(self, cooldown)
			local p = cooldown:GetParent()
			if p then
				shines[p]:Start()
			end
		end
	}
end