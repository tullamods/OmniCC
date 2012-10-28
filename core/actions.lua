--[[
	actions.lua
		Handles action buttons specific behaviour
--]]

local Action = OmnCC:New('Actions', {visible = {}})
local Cooldown = OmniCC.Cooldown


--[[ API ]]--

function Actions:AddDefaults()
	for i, button in pairs(ActionBarButtonEventsFrame.frames) do
		self:Add(button.action, button.cooldown)
	end
end

function Actions:Add(action, cooldown)
	if not cooldown.omniccAction then
		cooldown:HookScript('OnShow', Action.OnShow)
		cooldown:HookScript('OnHide', Action.OnHide)
	end

	cooldown.omniccAction = action
end

function Actions:Update()
	for cooldown in pairs(self.visible) do
        local start, duration = Cooldown.GetAction(cooldown.omniccAction)
        Cooldown.Show(cooldown, start, duration)
    end
end


--[[ Events ]]--

function Actions:OnShow()
	Action.visible[self] = true
end

function Actions:OnHide()
	Action.visible[self] = nil
end