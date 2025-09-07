-- a shine finish effect
local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local SHINE_TEXTURE = [[Interface\Cooldown\star4]]
local SHINE_DURATION = 0.75
local SHINE_SCALE = 5

local ShineEffect = Addon.FX:Create("shine", L.Shine)

local unused = {}

local function onShineAnimationFinished(self)
	local parent = self:GetParent()
	if parent:IsShown() then
		parent:Hide()
	end
end

local function createShineAnimation(parent)
	local group = parent:CreateAnimationGroup()
	group:SetScript('OnFinished', onShineAnimationFinished)
	group:SetLooping('NONE')

	local init = group:CreateAnimation('Alpha')
	init:SetFromAlpha(1)
	init:SetDuration(0)
	init:SetToAlpha(0)
	init:SetOrder(0)

	local grow = group:CreateAnimation('Scale')
	grow:SetOrigin('CENTER', 0, 0)
	grow:SetScale(SHINE_SCALE, SHINE_SCALE)
	grow:SetDuration(SHINE_DURATION / 2)
	grow:SetOrder(1)

	local brighten = group:CreateAnimation('Alpha')
	brighten:SetDuration(SHINE_DURATION / 2)
	brighten:SetFromAlpha(0)
	brighten:SetToAlpha(1)
	brighten:SetOrder(1)

	local shrink = group:CreateAnimation('Scale')
	shrink:SetOrigin('CENTER', 0, 0)
	shrink:SetScale(1 / SHINE_SCALE, 1 / SHINE_SCALE)
	shrink:SetDuration(SHINE_DURATION / 2)
	shrink:SetOrder(2)

	local fade = group:CreateAnimation('Alpha')
	fade:SetDuration(SHINE_DURATION / 2)
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetOrder(2)

	return group
end

local function onShineFrameHidden(self)
	if not unused[self] then
		unused[self] = true
		self:StopAnimating()
		self:Hide()
	end
end

local function createShineFrame()
	local frame = CreateFrame('Frame')
	frame:Hide()
	frame:SetScript('OnHide', onShineFrameHidden)
	frame:SetToplevel(true)

	local icon = frame:CreateTexture(nil, 'OVERLAY')
	icon:SetPoint('CENTER')
	icon:SetBlendMode('ADD')
	icon:SetAllPoints(icon:GetParent())
	icon:SetTexture(SHINE_TEXTURE)

	frame.animation = createShineAnimation(frame)

	return frame
end

function ShineEffect:Run(cooldown)
	local owner = cooldown:GetParent() or cooldown

	if owner and owner:IsVisible() then
		local shine = next(unused) or createShineFrame()
		unused[shine] = nil

		shine:SetParent(owner)
		shine:ClearAllPoints()
		shine:SetAllPoints(cooldown)
		shine:Show()
		shine.animation:Play()
	end
end
