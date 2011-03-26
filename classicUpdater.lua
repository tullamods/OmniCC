--[[
	An OnUpdate sytem based timer thingy
--]]

local Classy = LibStub('Classy-1.0')
local OmniCC = OmniCC
local ClassicUpdater = Classy:New('Frame'); OmniCC.ClassicUpdater = ClassicUpdater

local active = {}
local inactive = {}


--[[ Updater Retrieval ]]--

function ClassicUpdater:Get(frame)
	local updater = self:GetActive(frame) or self:Restore() or self:New()
	active[updater] = frame

	return updater
end

function ClassicUpdater:New()
	local updater = self:Bind(CreateFrame('Frame', nil)); updater:Hide()
	updater:SetScript('OnUpdate', updater.OnUpdate)

	--print('ClassicUpdater:New')
	return updater
end

function ClassicUpdater:Restore()
	local updater = next(inactive)
	if updater then
		inactive[updater] = nil
	end
	
	--print('ClassicUpdater:Restore')
	return updater
end

function ClassicUpdater:GetActive(frameToFind)
	for updater, frame in pairs(active) do
		if frame == frameToFind then
			--print('ClassicUpdater:GetActive')
			return updater
		end
	end
end

function ClassicUpdater:Free()
	--print('ClassicUpdater:Free')
	
	self:Hide()
	self.delay = nil
	active[self] = nil
	inactive[self] = true
end


--[[ Updater Updating ]]--

function ClassicUpdater:ScheduleUpdate(delay)
	--print('ClassicUpdater:ScheduleUpdate', delay)
	
	if delay > 0 then
		self.delay = delay
		self:Show()
	else
		self:OnFinished()
	end
end

function ClassicUpdater:CancelUpdate()
	--print('ClassicUpdater:CancelUpdate')

	self:Free()
end

function ClassicUpdater:OnUpdate(elapsed)
	--print('ClassicUpdater:OnUpdate', elapsed)
	
	self.delay = self.delay - elapsed
	if self.delay <= 0 then
		self:OnFinished()
	end
end

function ClassicUpdater:OnFinished()
	--print('ClassicUpdater:OnFinished')

	local frame = active[self]
	self:Free()

	frame:OnScheduledUpdate()
end