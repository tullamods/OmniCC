--[[
	An OnUpdate sytem based timer thingy
--]]

local OmniCC = OmniCC
local Classy = LibStub('Classy-1.0')
local ClassicUpdater = Classy:New('Frame'); OmniCC.ClassicUpdater = ClassicUpdater

local updaters = setmetatable({}, {__index = function(self, frame)
	local updater = ClassicUpdater:New(frame)
	self[frame] = updater

	return updater
end})


--[[ Updater Retrieval ]]--

function ClassicUpdater:Get(frame)
	-- print('ClassicUpdater:Get', frame)

	return updaters[frame]
end

function ClassicUpdater:GetActive(frame)
	-- print('ClassicUpdater:GetActive', frame)

	return rawget(updaters, frame)
end

function ClassicUpdater:New(frame)
	-- print('ClassicUpdater:New', count, frame)

	local updater = self:Bind(CreateFrame('Frame', nil)); updater:Hide()
	updater:SetScript('OnUpdate', updater.OnUpdate)
	updater.frame = frame

	return updater
end


--[[ Updater Events ]]--

function ClassicUpdater:OnUpdate(elapsed)
	-- print('ClassicUpdater:OnUpdate', elapsed)

	local delay = self.delay - elapsed
	if delay > 0 then
		self.delay = delay
	else
		self:OnFinished()
	end
end

function ClassicUpdater:OnFinished()
	-- print('ClassicUpdater:OnFinished')

	self:Cleanup()
	self.frame:OnScheduledUpdate()
end


--[[ Updater Updating ]]--

function ClassicUpdater:ScheduleUpdate(delay)
	-- print('ClassicUpdater:ScheduleUpdate', delay)

	if delay > 0 then
		self.delay = delay
		self:Show()
	else
		self:OnFinished()
	end
end

function ClassicUpdater:CancelUpdate()
	-- print('ClassicUpdater:CancelUpdate')

	self:Cleanup()
end

function ClassicUpdater:Cleanup()
	-- print('ClassicUpdater:Cleanup')

	self:Hide()
	self.delay = nil
end