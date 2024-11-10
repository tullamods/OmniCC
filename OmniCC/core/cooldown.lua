-- hooks for watching cooldown events
local _, Addon = ...

-- how far in the future a cooldown can be before we show text for it
-- this is used to filter out buggy cooldowns (usually ones that started)
-- before a user rebooted
local MAX_START_DELAY_MS = 86400
local GCD_SPELL_ID = 61304

-- how much of a buffer we give finish effets (in seconds)
local FINISH_EFFECT_BUFFER = -0.15

local cooldowns = {}

local Cooldown = {}

-- queries
local IsGlobalCooldown, GetGCDTimeRemaining

if type(C_Spell) == "table" and type(C_Spell.GetSpellCooldown) == "function" then
    IsGlobalCooldown = function (start, duration, modRate)
        if not (start > 0 and duration > 0 and modRate > 0) then
            return false
        end

        local gcd = C_Spell.GetSpellCooldown(GCD_SPELL_ID)

        return gcd 
            and start == gcd.startTime
            and duration == gcd.duration
            and modRate == gcd.modRate
    end

    GetGCDTimeRemaining = function()
        local gcd = C_Spell.GetSpellCooldown(GCD_SPELL_ID)
        if not (gcd and gcd.isEnabled) then
            return 0
        end

        local start, duration, modRate = gcd.startTime, gcd.duration, gcd.modRate
        if not (start > 0 and duration > 0 and modRate > 0) then
            return 0
        end

        local remain = (start + duration) - GetTime()
        if remain > 0 then
            return remain / modRate
        end

        return 0
    end
else
    IsGlobalCooldown = function (start, duration, modRate)
        if not (start > 0 and duration > 0 and modRate > 0) then
            return false
        end

        local gcdStart, gcdDuration, gcdEnabled, gcdModRate = GetSpellCooldown(GCD_SPELL_ID)

        return gcdEnabled
            and start == gcdStart 
            and duration == gcdDuration 
            and modRate == gcdModRate
    end

    GetGCDTimeRemaining = function()
        local start, duration, enabled, modRate = GetSpellCooldown(GCD_SPELL_ID)
        if (not enabled and start > 0 and duration > 0 and modRate > 0) then
            return 0
        end

        local remain = (start + duration) - GetTime()
        if remain > 0 then
            return remain / modRate
        end

        return 0
    end
end

function Cooldown:CanShowText()
    if self.noCooldownCount then
        return false
    end

    -- filter gcd
    if self._occ_gcd then
        return false
    end

    local start = self._occ_start or 0
    local duration = self._occ_duration or 0
    local modRate = self._occ_modRate or 1

    -- no active cooldown
    if not (start > 0 and duration > 0 and modRate > 0) then
        return false
    end

    -- config checks
    local settings = self._occ_settings
    if not settings then
        return false
    end

    -- at least min duration
    if duration < (settings.minDuration or math.huge) then
        return false
    end

    -- at most max duration
    local maxDuration = settings.maxDuration or 0
    if maxDuration > 0 and duration > maxDuration then
        return false
    end

    -- hide text if we don't want to display it for this kind of cooldown
    if not settings.enableText then
        return false
    end

    -- time checks
    local t = GetTime()

    -- expired cooldowns
    if (start + duration) <= t then
        return false
    end

    -- future cooldowns that don't start for at least a day
    -- these are probably buggy ones
    if (start - t) > MAX_START_DELAY_MS then
        return false
    end

    -- filter GCD
    return true
end

function Cooldown:CanShowFinishEffect()
    -- filter gcd
    if self._occ_gcd then
        return false
    end

    local start = self._occ_start or 0
    local duration = self._occ_duration or 0
    local modRate = self._occ_modRate or 1

    -- invalid cooldown
    if not (start > 0 and duration > 0 and modRate > 0) then
        return false
    end

    local remain = ((start + duration) - GetTime()) / modRate

    -- cooldown expired too long ago
    if remain < FINISH_EFFECT_BUFFER then
        return false
    end

    -- cooldown outside of GCD bounds
    -- or has time remaining if we're outside of GCD
    if remain > GetGCDTimeRemaining() then
        return false
    end

    -- settings checks
    -- no config, do nothing
    local settings = self._occ_settings
    if not settings then
        return false
    end

    -- not long enough, do nothing
    if duration < (settings.minEffectDuration or math.huge) then
        return false
    end

    -- no effect, do nothing
    local effect = settings.effect or 'none'
    if effect == 'none' then
        return false
    end

    return true, effect
end

function Cooldown:GetKind()
    local cdType = self.currentCooldownType

    if cdType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
        return 'loc'
    end

    if cdType == COOLDOWN_TYPE_NORMAL then
        return 'default'
    end

    local parent = self:GetParent()
    if parent and parent.chargeCooldown == self then
        return 'charge'
    end

    return 'default'
end

function Cooldown:GetPriority()
    if self._occ_kind == 'charge' then
        return 2
    end

    return 1
end

-- actions
function Cooldown:Initialize()
    if cooldowns[self] then
        return
    end

    cooldowns[self] = true

    self._occ_start = 0
    self._occ_duration = 0
    self._occ_modRate = 1
    self._occ_settings = Cooldown.GetTheme(self)

    self:HookScript('OnShow', Cooldown.OnVisibilityUpdated)
    self:HookScript('OnHide', Cooldown.OnVisibilityUpdated)
    self:HookScript('OnCooldownDone', Cooldown.OnCooldownDone)

    -- this is a hack to make sure that text for charge cooldowns can appear
    -- above the charge cooldown itself, as charge cooldowns have a TOOLTIP
    -- frame level
    local parent = self:GetParent()
    if parent and parent.chargeCooldown == self then
        local cooldown = parent.cooldown
        if cooldown then
            self:SetFrameStrata(cooldown:GetFrameStrata())
            self:SetFrameLevel(cooldown:GetFrameLevel() + 7)
        end
    end
end

function Cooldown:ShowText()
    local oldDisplay = self._occ_display
    local newDisplay = Addon.Display:GetOrCreate(self:GetParent() or self)

    if oldDisplay ~= newDisplay then
        self._occ_display = newDisplay

        if oldDisplay then
            oldDisplay:RemoveCooldown(self)
        end
    end

    if newDisplay then
        newDisplay:AddCooldown(self)
    end
end

function Cooldown:HideText()
    local display = self._occ_display

    if display then
        display:RemoveCooldown(self)
        self._occ_display = nil
    end
end

function Cooldown:UpdateText()
    if self._occ_show and (not self:IsForbidden()) and self:IsVisible() then
        Cooldown.ShowText(self)
    else
        Cooldown.HideText(self)
    end
end

function Cooldown:UpdateStyle()
    local settings = self._occ_settings
    if not settings then
        return
    end

    local opacity = tonumber(settings.cooldownOpacity) or 1
    if opacity < 1 then
        if self:GetAlpha() ~= opacity then
            self:SetAlpha(opacity)
        end
    end
end

do
    local pending = {}

    local updater = Addon:CreateHiddenFrame('Frame')

    updater:SetScript('OnUpdate', function(self)
        for cooldown in pairs(pending) do
            Cooldown.UpdateText(cooldown)
            Cooldown.UpdateStyle(cooldown)
            pending[cooldown] = nil
        end

        self:Hide()
    end)

    function Cooldown:RequestUpdate()
        if not pending[self] then
            pending[self] = true
            updater:Show()
        end
    end
end

function Cooldown:Refresh(force)
    if force then
        self._occ_start = nil
        self._occ_duration = nil
        self._occ_modRate = nil
    end

    local start, duration = self:GetCooldownTimes()
    local rawDuration = self:GetCooldownDisplayDuration()

    start = (start or 0) / 1000
    duration = (duration or 0) / 1000

    local modRate
    if rawDuration > 0 then
        modRate = duration / rawDuration
    else
        modRate = 1
    end

    Cooldown.Initialize(self)
    Cooldown.SetTimer(self, start, duration, modRate)
end

function Cooldown:SetTimer(start, duration, modRate)
    -- both the wow api and addons (espcially auras) have a habit of resetting
    -- cooldowns every time there's an update to an aura
    -- we chack and do nothing if there's an exact start/duration match
    if self._occ_start == start and self._occ_duration == duration and self._occ_modRate == modRate then
        return
    end

    -- attempt to show a finish effect here, because there are cases where a
    -- cooldown can be ovewritten before it has actually completed
    Cooldown.TryShowFinishEffect(self)

    self._occ_start = start
    self._occ_duration = duration
    self._occ_modRate = modRate

    self._occ_gcd = IsGlobalCooldown(start, duration, modRate)
    self._occ_kind = Cooldown.GetKind(self)
    self._occ_priority = Cooldown.GetPriority(self)
    self._occ_show = Cooldown.CanShowText(self)

    Cooldown.RequestUpdate(self)
end

function Cooldown:SetNoCooldownCount(disable, owner)
    owner = owner or true

    if disable then
        if not self.noCooldownCount then
            self.noCooldownCount = owner
            Cooldown.Refresh(self, true)
        end
    elseif self.noCooldownCount == owner then
        self.noCooldownCount = nil
        Cooldown.Refresh(self, true)
    end
end

-- attempts to trigger a finish effect
function Cooldown:TryShowFinishEffect()
    local show, effect = Cooldown.CanShowFinishEffect(self)

    if show then
        Addon.FX:Run(self, effect)

        -- reset start/duration so that we don't trigger again
        self._occ_start = 0
        self._occ_duration = 0
    end
end

-- events
function Cooldown:OnCooldownDone()
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.TryShowFinishEffect(self)
end

function Cooldown:OnSetCooldown(start, duration, modRate)
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    start = tonumber(start) or 0
    duration = tonumber(duration) or 0
    modRate = tonumber(modRate) or 1

    Cooldown.Initialize(self)
    Cooldown.SetTimer(self, start, duration, modRate)
end

function Cooldown:OnSetCooldownDuration(duration, modRate)
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    local start = GetTime()
    duration = tonumber(duration) or 0
    modRate = tonumber(modRate) or 1

    Cooldown.Initialize(self)
    Cooldown.SetTimer(self, start, duration, modRate)
end

function Cooldown:SetDisplayAsPercentage()
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.SetNoCooldownCount(self, true)
end

function Cooldown:OnVisibilityUpdated()
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.RequestUpdate(self)
end

-- misc
function Cooldown:SetupHooks()
    local Cooldown_MT = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(Cooldown_MT, 'SetCooldown', Cooldown.OnSetCooldown)
    hooksecurefunc(Cooldown_MT, 'SetCooldownDuration', Cooldown.OnSetCooldownDuration)
    hooksecurefunc('CooldownFrame_SetDisplayAsPercentage',
                   Cooldown.SetDisplayAsPercentage)
end

function Cooldown:UpdateSettings(force)
    local newSettings = Cooldown.GetTheme(self)

    if force or self._occ_settings ~= newSettings then
        self._occ_settings = newSettings
        Cooldown.Refresh(self, true)
        return true
    end

    return false
end

local function getFirstAncestorWithName(cooldown)
    local frame = cooldown
    repeat
        local name = frame:GetName()
        if name then
            return name
        end
        frame = frame:GetParent()
    until not frame
end

function Cooldown:GetTheme()
    if self._occ_settings_force then
        return self._occ_settings_force
    end

    local name = getFirstAncestorWithName(self)

    if name then
        local rule = Addon:GetMatchingRule(name)
        if rule then
            return Addon:GetTheme(rule.theme)
        end
    end

    return Addon:GetDefaultTheme()
end

function Cooldown:ForAll(method, ...)
    local func = self[method]
    if type(func) ~= 'function' then
        error(('Cooldown method %q not found'):format(method), 2)
    end

    for cooldown in pairs(cooldowns) do
        func(cooldown, ...)
    end
end

-- exports
Addon.Cooldown = Cooldown
