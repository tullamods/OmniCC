--[[
	An animation sytem based timer thingy
--]]

local Classy = LibStub('Classy-1.0')
local OmniCC = OmniCC
local AniUpdater = Classy:New('Frame'); OmniCC.AniUpdater = AniUpdater

local active = {}
local inactive = {}

local aniGroup_OnFinished = function(self)
	--print('aniGroup_OnFinished')
	self:GetParent():OnFinished()
end

function AniUpdater:Get(frame)
	local updater = self:GetActive(frame) or self:Restore() or self:New()
	active[updater] = frame

	--print('AniUpdater:Get')
	return updater
end

function AniUpdater:New()
	local updater = self:Bind(CreateFrame('Frame', nil)); updater:Hide()

	local aniGroup = updater:CreateAnimationGroup()
	aniGroup:SetLooping('NONE')
	aniGroup:SetScript('OnFinished', aniGroup_OnFinished)
	updater.aniGroup = aniGroup

	local ani = aniGroup:CreateAnimation('Animation')
	ani:SetOrder(1)
	updater.ani = ani

	--print('AniUpdater:New')
	return updater
end

function AniUpdater:Restore()
	local updater = next(inactive)
	if updater then
		inactive[updater] = nil
	end
	
	--print('AniUpdater:Restore')
	return updater
end

function AniUpdater:GetActive(frameToFind)
	for updater, frame in pairs(active) do
		if frame == frameToFind then
			--print('AniUpdater:GetActive')
			return updater
		end
	end
end

function AniUpdater:Free()
	--print('AniUpdater:Free')
	
	self:Hide()
	active[self] = nil
	inactive[self] = true
end

function AniUpdater:ScheduleUpdate(delay)
	--print('AniUpdater:ScheduleUpdate', delay)
	
	if self.aniGroup:IsPlaying() then
		self.aniGroup:Stop()
	end

	if delay > 0 then
		self:Show()
		self.ani:SetDuration(delay)
		self.aniGroup:Play()
	else
		self:OnFinished()
	end
end

function AniUpdater:CancelUpdate()
	--print('AniUpdater:CancelUpdate')
	
	if self.aniGroup:IsPlaying() then
		self.aniGroup:Stop()
	end
	self:Free()
end

function AniUpdater:OnFinished()
	--print('AniUpdater:OnFinished')
	
	local frame = active[self]
	self:Free()
	frame:OnScheduledUpdate()
end