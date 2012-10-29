--[[
	alert.lua
		a finish effect that displays the cooldown at the center of the screen
--]]

local L = OMNICC_LOCALS
local Frame = CreateFrame('Frame', nil, UIParent)
Frame:SetPoint('CENTER')
Frame:SetSize(50, 50)
Frame:SetAlpha(0)

local Icon = Frame:CreateTexture()
Icon:SetAllPoints()

local Anims = Frame:CreateAnimationGroup()
Anims:SetLooping('NONE')
Anims:SetScript('OnFinished', function()
  Frame:Hide()
end)

local function newAnim(type, change, order)
  local anim = Anims:CreateAnimation(type)
  anim:SetDuration(0.3)
  anim:SetOrder(order)

  if type == 'Scale' then
    anim:SetOrigin('CENTER', 0, 0)
    anim:SetScale(change, change)
  else
    anim:SetChange(change)
  end
end

newAnim('Scale', 2.5, 1)
newAnim('Alpha', .7, 1)

newAnim('Scale', -2.5, 2)
newAnim('Alpha', -.7, 2)

OmniCC:RegisterEffect({
	id = 'alert',
	name = L.Alert,
	desc = L.AlertTip,
	Setup = function() end,
	
	Run = function(self, cooldown)
		local button = cooldown:GetParent()
		local icon = OmniCC:GetButtonIcon(button)

		if icon then
		  Icon:SetVertexColor(icon:GetVertexColor())
		  Icon:SetTexture(icon:GetTexture())
		  Frame:Show()

		  if Anims:IsPlaying() then
		    Anims:Finish()
		  end

		  Anims:Play()
		end
	end
})