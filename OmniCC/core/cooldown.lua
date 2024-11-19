-- hooks for watching cooldown events
local _, Addon = ...

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

-- how far in the future a cooldown can be before we show text for it
-- this is used to filter out buggy cooldowns (usually ones that started)
-- before a user rebooted
local MIN_START_OFFSET = -86400

-- the global cooldown spell id
local GCD_SPELL_ID = 61304

-- how much of a buffer we give finish effets (in seconds)
local FINISH_EFFECT_BUFFER = -0.15

-------------------------------------------------------------------------------
-- Utility Methods
-------------------------------------------------------------------------------

local IsGCD, GetGCDTimeRemaining

-- gcd tests
if type(C_Spell) == "table" and type(C_Spell.GetSpellCooldown) == "function" then
    ---@param start number
    ---@param duration number
    ---@param modRate number
    ---@return boolean
    IsGCD = function (start, duration, modRate)
        if not (start > 0 and duration > 0 and modRate > 0) then
            return false
        end

        local gcd = C_Spell.GetSpellCooldown(GCD_SPELL_ID)

        return gcd
            and gcd.isEnabled
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
    ---@param start number
    ---@param duration number
    ---@param modRate number
    ---@return boolean    
    IsGCD = function (start, duration, modRate)
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
            return remain
        end

        return 0
    end
end

---Retrieves the name of the given region. If no name is found, checks ancestors
---@param frame Region
---@return string?
local function getFirstName(frame)
    while frame do
        local name = frame:GetName()

        if name then
            return name
        end

        frame = frame:GetParent()
    end
end

-------------------------------------------------------------------------------
-- Cooldown Tracking
-------------------------------------------------------------------------------

local Cooldown = {}

---@type { [OmniCCCooldown]: true }
local cooldowns = {}

---@param self OmniCCCooldown
---@return boolean
function Cooldown:CanShowText()
    if self.noCooldownCount or self._occ_gcd then
        return false
    end

    local duration = self._occ_duration or 0
    if duration <= 0 then
        return false
    end

    local modRate = self._occ_modRate or 1
    if modRate <= 0 then
        return false
    end

    local start = self._occ_start or 0
    if start <= 0 then
        return false
    end

    local elapsed = GetTime() - start
    if elapsed >= duration or elapsed <= MIN_START_OFFSET then
        return false
    end

    -- config checks
    local settings = self._occ_settings

    -- text enabled
    if not (settings and settings.enableText) then
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

    return true
end

---@param self OmniCCCooldown
function Cooldown:CanShowFinishEffect()
    if self.noCooldownCount or self._occ_gcd then
        return false
    end

    local duration = self._occ_duration or 0
    if duration <= 0 then
        return false
    end

    local modRate = self._occ_modRate or 1
    if modRate <= 0 then
        return false
    end

    local start = self._occ_start or 0
    if start <= 0 then
        return false
    end

    local remain = (start + duration) - GetTime()

    -- cooldown expired too long ago
    -- cooldown outside of GCD bounds
    -- or has time remaining if we're outside of GCD    
    if remain < FINISH_EFFECT_BUFFER or remain > GetGCDTimeRemaining() then
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

---@param self OmniCCCooldown
---@return OmniCCCooldownKind
function Cooldown:GetKind()
    local cdType = self.currentCooldownType

    if cdType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
        return 'loc'
    end

    if cdType == COOLDOWN_TYPE_NORMAL then
        return 'default'
    end

    ---@type Frame|{ chargeCooldown: Cooldown? }?
    local parent = self:GetParent()
    if parent and parent.chargeCooldown == self then
        return 'charge'
    end

    return 'default'
end

---@param self OmniCCCooldown
---@return OmniCCCooldownPriority
function Cooldown:GetPriority()
    if self._occ_kind == 'charge' then
        return 2
    end

    return 1
end

---@param self OmniCCCooldown
function Cooldown:Initialize()
    if not cooldowns[self] then
        self._occ_settings = Cooldown.GetTheme(self)

        self:HookScript('OnShow', Cooldown.OnVisibilityUpdated)
        self:HookScript('OnHide', Cooldown.OnVisibilityUpdated)
        self:HookScript('OnCooldownDone', Cooldown.OnCooldownDone)
    
        -- this is a hack to make sure that text for charge cooldowns can appear
        -- above the charge cooldown itself, as charge cooldowns have a TOOLTIP
        -- frame level
        ---@type Frame|{ chargeCooldown: Cooldown?, cooldown: Cooldown? }?
        local parent = self:GetParent()
        
        if parent and parent.chargeCooldown == self then
            local cooldown = parent.cooldown
            if cooldown then
                self:SetFrameStrata(cooldown:GetFrameStrata())
                self:SetFrameLevel(cooldown:GetFrameLevel() + 7)
            end
        end

        cooldowns[self] = true
    end
end

---@param self OmniCCCooldown
function Cooldown:ShowText()
    local oldDisplay = self._occ_display
    ---@type OmniCCDisplay?
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

---@param self OmniCCCooldown
function Cooldown:HideText()
    local display = self._occ_display

    if display then
        display:RemoveCooldown(self)
        self._occ_display = nil
    end
end

---@param self OmniCCCooldown
function Cooldown:UpdateText()
    if self._occ_show and (not self:IsForbidden()) and self:IsVisible() then
        Cooldown.ShowText(self)
    else
        Cooldown.HideText(self)
    end
end

---@param self OmniCCCooldown
function Cooldown:UpdateStyle()
    local settings = self._occ_settings
    if not settings then
        return
    end

    local opacity = settings.cooldownOpacity or 1
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

---@param self OmniCCCooldown
function Cooldown:Refresh(force)
    if force then
        self._occ_start = nil
        self._occ_duration = nil
        self._occ_modRate = nil
    end

    Cooldown.Initialize(self)

    local start, duration = self:GetCooldownTimes()
    if start == 0 or duration == 0 then
        Cooldown.SetTimer(self, 0, 0, 1)
    else
        Cooldown.SetTimer(self, start / 1000, duration / 1000, duration / self:GetCooldownDisplayDuration())
    end
end

---@param self OmniCCCooldown
---@param start number
---@param duration number
---@param modRate number?
function Cooldown:SetTimer(start, duration, modRate)
    if modRate == nil then
        modRate = 1
    end

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

    self._occ_gcd = IsGCD(start, duration, modRate)
    self._occ_kind = Cooldown.GetKind(self)
    self._occ_priority = Cooldown.GetPriority(self)
    self._occ_show = Cooldown.CanShowText(self)

    Cooldown.RequestUpdate(self)
end

---@param self OmniCCCooldown
---@param disable boolean?
---@param owner Frame|boolean|nil
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

---@param self OmniCCCooldown
function Cooldown:TryShowFinishEffect()
    local show, effect = Cooldown.CanShowFinishEffect(self)

    if show then
        Addon.FX:Run(self, effect)

        -- reset start/duration so that we don't trigger again
        self._occ_start = 0
        self._occ_duration = 0
    end
end

---@param self OmniCCCooldown
function Cooldown:OnCooldownDone()
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.TryShowFinishEffect(self)
end

---@param self OmniCCCooldown
---@param start number
---@param duration number
---@param modRate number?
function Cooldown:OnSetCooldown(start, duration, modRate)
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.Initialize(self)
    Cooldown.SetTimer(self, start, duration, modRate)
end

---@param self OmniCCCooldown
---@param duration number
---@param modRate number?
function Cooldown:OnSetCooldownDuration(duration, modRate)
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.Initialize(self)
    Cooldown.SetTimer(self, self:GetCooldownTimes() / 1000, duration, modRate)
end

---@param self OmniCCCooldown
function Cooldown:SetDisplayAsPercentage()
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.SetNoCooldownCount(self, true)
end

---@param self OmniCCCooldown
function Cooldown:OnVisibilityUpdated()
    if self.noCooldownCount or self:IsForbidden() then
        return
    end

    Cooldown.RequestUpdate(self)
end

---@param self OmniCCCooldown
function Cooldown:OnClear()
    if self._occ_start ~= nil then
        self._occ_start = nil
        self._occ_duration = nil
        self._occ_modRate = nil

        Cooldown.HideText(self)
    end
end

---@param self OmniCCCooldown
function Cooldown:UpdateSettings(force)
    local newSettings = Cooldown.GetTheme(self)

    if force or self._occ_settings ~= newSettings then
        self._occ_settings = newSettings
        Cooldown.Refresh(self, true)
        return true
    end

    return false
end

---@param self OmniCCCooldown
---@return OmniCCCooldownSettings
function Cooldown:GetTheme()
    if self._occ_settings_force then
        return self._occ_settings_force
    end

    local name = getFirstName(self)

    if name then
        local rule = Addon:GetMatchingRule(name)
        if rule then
            return Addon:GetTheme(rule.theme)
        end
    end

    return Addon:GetDefaultTheme()
end

-- misc
function Cooldown.SetupHooks()
    local cooldown_mt = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(cooldown_mt, 'SetCooldown', Cooldown.OnSetCooldown)
    hooksecurefunc(cooldown_mt, 'SetCooldownDuration', Cooldown.OnSetCooldownDuration)
    hooksecurefunc(cooldown_mt, 'Clear', Cooldown.OnClear)
    hooksecurefunc('CooldownFrame_SetDisplayAsPercentage', Cooldown.SetDisplayAsPercentage)
end

---@param method string
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
