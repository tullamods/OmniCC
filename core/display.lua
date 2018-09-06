--[[ A cooldown text display ]] --

local Addon = _G[...]

local ICON_SIZE = math.ceil(_G.ActionButton1:GetWidth()) -- the expected size of an icon
local CreateFrame = _G.CreateFrame

local Display = CreateFrame("Frame")
Display:Hide()

local Display_mt = {__index = Display}
local round = _G.Round
local displays = {}

function Display:Get(cooldown)
    return displays[cooldown]
end

function Display:Create(cooldown)
    local display = setmetatable(CreateFrame("Frame", nil, cooldown:GetParent()), Display_mt)

    display.cooldown = cooldown
    display:SetAllPoints(cooldown)
    display:SetScript("OnShow", self.OnShow)
    display:SetScript("OnSizeChanged", self.OnSizeChanged)
    display:Hide()

    local text = display:CreateFontString(nil, "OVERLAY")
    display.text = text

    displays[cooldown] = display
    return display
end

-- update text when the timer notifies us of a change
function Display:OnTimerTextUpdated(timer, text)
    if self.timer == timer and self.text:IsShown() then
        self.text:SetText(timer.text or "")
    end
end

function Display:OnTimerStateUpdated(timer, state)
    if self.timer == timer then
        self.state = timer.state or "seconds"

        self:UpdateTextAppearance()
    end
end

function Display:OnTimerFinished(timer)
    if self.timer == timer then
        local settings = self:GetSettings()

        if timer.duration >= (settings.minEffectDuration or 0) then
            Addon.FX:Run(self.cooldown, settings.effect or "none")
        end
    end
end

-- hide the display when its parent timer is destroyed
function Display:OnTimerDestroyed(timer)
    if self.timer == timer then
        self.timer = nil
        self.state = nil
        self.text:SetText("")

        self:Hide()
    end
end

function Display:OnShow()
    if not self.scale then
        self:OnSizeChanged(self:GetSize())
    end
end

-- adjust font size whenever the timer's size changes
-- and hide if it gets too tiny
function Display:OnSizeChanged(width, height)
    local scale = round(width) / ICON_SIZE

    if scale ~= self.scale then
        self.scale = scale

        self:UpdateTextAppearance()
        self:UpdateTextShown()
    end
end

function Display:Activate(timer)
    local oldTimer = self.timer

    if oldTimer ~= timer then
        self.timer = timer

        if oldTimer then
            oldTimer:Unsubscribe(self)
        end

        self:UpdateTextAppearance()
        self:UpdateTextPosition()
        timer:Subscribe(self)
    end

    self:Show()
end

function Display:Deactivate()
    local timer = self.timer

    if timer then
        timer:Unsubscribe(self)
        self.timer = nil
    end

    self.text:SetText("")
    self:Hide()
end

function Display:UpdateTextShown()
    local scale = self.scale or 0
    local settings = self:GetSettings()

    if scale >= (settings and settings.minSize or 0) then
        self.text:Show()
    else
        self.text:Hide()
    end
end

function Display:UpdateTextAppearance()
    local sets = self:GetSettings()
    local face = sets.fontFace
    local outline = sets.fontOutline
    local style = sets.styles[self.state or "seconds"]
    local size = sets.fontSize * (sets.scaleText and self.scale or 1)
    local text = self.text

    if size > 0 then
        if not text:SetFont(face, size, outline) then
            text:SetFont(STANDARD_TEXT_FONT, size, outline)
        end

        text:SetTextColor(style.r, style.g, style.b, style.a)
        text:SetText(self.timer and self.timer.text or "")
    end
end

function Display:UpdateTextPosition()
    local sets = self:GetSettings()
    local scale = self.scale or 1
    local text = self.text

    text:ClearAllPoints()
    text:SetPoint(sets.anchor, sets.xOff * scale, sets.yOff * scale)
end

function Display:UpdateShown()
    local scale = self.scale or 0
    local settings = self:GetSettings()

    if scale >= (settings and settings.minSize or 0) then
        self.text:Show()
    else
        self.text:Hide()
    end
end

function Display:GetSettings()
    return Addon:GetGroupSettingsFor(self.cooldown)
end

function Display:ForAll(method, ...)
    for _, display in pairs(displays) do
        local func = display[method]
        if type(func) == "function" then
            func(display, ...)
        end
    end
end

function Display:ForActive(method, ...)
    for _, display in pairs(displays) do
        if display.timer ~= nil then
            local func = display[method]
            if type(func) == "function" then
                func(display, ...)
            end
        end
    end
end

do
    -- hook the SetCooldown method of all cooldown frames
    -- ActionButton1Cooldown is used here since its likely to always exist
    -- and I'd rather not create my own cooldown frame to preserve a tiny bit of memory
    local Cooldown_MT = getmetatable(_G.ActionButton1Cooldown).__index
    local blacklist = {}

    local function deactivateDisplay(cooldown)
        local display = Display:Get(cooldown)
        if display then
            display:Deactivate()
        end
    end

    local function setBlacklisted(cooldown, isBlacklisted)
        if isBlacklisted then
            if not blacklist[cooldown] then
                blacklist[cooldown] = true
                deactivateDisplay(cooldown)
            end
        else
            blacklist[cooldown] = nil
        end
    end

    hooksecurefunc(Cooldown_MT, "SetCooldown", function(cooldown, start, duration, modRate)
        if cooldown.noCooldownCount or blacklist[cooldown] or cooldown:IsForbidden()  then
            return
        end

        local settings = Addon:GetGroupSettingsFor(cooldown)
        local enabled, minDuration
        if settings then
            enabled = settings.enabled
            minDuration = settings.minDuration or 0
        else
            enabled = false
            minDuration = 0
        end

        if enabled and (duration or 0) > minDuration and (modRate or 1) > 0 then
            local display = Display:Get(cooldown) or Display:Create(cooldown)
            display:Activate(Addon.Timer:GetOrCreate(settings, start, duration))
        else
            deactivateDisplay(cooldown)
        end
    end)

    hooksecurefunc(Cooldown_MT, "Clear", deactivateDisplay)

    hooksecurefunc(Cooldown_MT, "SetHideCountdownNumbers", function(cooldown, hide)
        setBlacklisted(cooldown, hide and Addon.sets and Addon.sets.obeyHideCountdownNumbers)
    end)

    hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(cooldown)
        setBlacklisted(cooldown, true)
    end)
end

Addon.Display = Display
