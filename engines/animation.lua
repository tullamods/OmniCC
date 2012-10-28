--[[
	An animation sytem based timer thingy
--]]

local Classy = LibStub('Classy-1.0')
local OmniCC = OmniCC
local AniUpdater = Classy:New('Frame'); OmniCC.AniUpdater = AniUpdater

local updaters = setmetatable({}, {__index = function(self, frame)
	local updater = AniUpdater:New(frame)
	self[frame] = updater

	return updater
end})

function AniUpdater:Get(frame)
	return updaters[frame]
end

function AniUpdater:GetActive(frame)
	return rawget(updaters, frame)
end

local animation_OnFinished = function(self) self:GetParent():OnFinished() end
function AniUpdater:New(frame)
	local updater = self:Bind(CreateFrame('Frame', nil)); updater:Hide()
	updater.frame = frame

	local aniGroup = updater:CreateAnimationGroup()
	aniGroup:SetLooping('NONE')
	aniGroup:SetScript('OnFinished', animation_OnFinished)
	updater.aniGroup = aniGroup

	local ani = aniGroup:CreateAnimation('Animation')
	ani:SetOrder(1)
	updater.ani = ani

	return updater
end

function AniUpdater:StopAnimation()
	if self.aniGroup:IsPlaying() then
		self.aniGroup:Stop()
	end
end

function AniUpdater:ScheduleUpdate(delay)
	self:StopAnimation()
	
	if delay > 0 then
		self:Show()
		self.ani:SetDuration(delay + 0.0002)
		self.aniGroup:Play()
	else
		self:OnFinished()
	end
end

function AniUpdater:CancelUpdate()
	self:StopAnimation()
	self:Hide()
end

function AniUpdater:OnFinished()
	self:Hide()
	self.frame:OnScheduledUpdate()
end