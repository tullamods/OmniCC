-- A pool of objects for determining what text to display for a given cooldown
-- and notify subscribers when the text change

-- local bindings!
local AddonName, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale(AddonName)

-- time units in ms
local TENTH = 100
local SECOND = TENTH * 10
local MINUTE = SECOND * 60
local HOUR = MINUTE * 60
local DAY = HOUR * 24

-- rounding values in ms
local HALF_TENTH = TENTH / 2
local HALF_SECOND = SECOND / 2
local HALF_MINUTE = MINUTE / 2
local HALF_HOUR = HOUR / 2
local HALF_DAY = DAY / 2

-- transition points in ms
local SOON_THRESHOLD = SECOND * 5.5 -- 5.5 seconds
local SECONDS_THRESHOLD = MINUTE - HALF_SECOND -- 59.5 seconds
local MINUTES_THRESHOLD = HOUR - HALF_MINUTE -- 59.5 minutes
local HOURS_THRESHOLD = DAY - HALF_HOUR -- 23.5 hours

---@type { [string]: OmniCCTimer }
local active = {}

---@type { [OmniCCTimer]: true }
local inactive = setmetatable({}, {__mode = 'k'})

---@class OmniCCTimer
local Timer = {}

Timer.__index = Timer

---@param cooldown OmniCCCooldown
function Timer:GetOrCreate(cooldown)
    local endTime = (cooldown._occ_start + cooldown._occ_duration) * SECOND
    local kind = cooldown._occ_kind
    local settings = cooldown._occ_settings
    local key = strjoin('/', kind, tostring(endTime), tostring(settings or 'NONE'))

    local timer = active[key]
    if not timer then
        timer = next(inactive)

        if timer then
            inactive[timer] = nil
        else
            timer = setmetatable({}, Timer)
        end

        timer.endTime = endTime
        timer.key = key
        timer.kind = kind
        timer.settings = settings
        timer.subscribers = {}
        timer.callback = function() timer:Update(key) end
        timer:Update(key)

        active[key] = timer
    end

    return timer
end

function Timer:Destroy()
    if not self.key then
        return
    end

    active[self.key] = nil

    -- clear subscribers
    for subscriber in pairs(self.subscribers) do
        subscriber:OnTimerDestroyed(self)
    end

    -- reset fields
    self.endTime = nil
    self.key = nil
    self.kind = nil
    self.settings = nil
    self.state = nil
    self.subscribers = nil
    self.text = nil

    inactive[self] = true
end

---@param key string?
function Timer:Update(key)
    if self.key ~= key then return end

    local remain = self.endTime - (GetTime() * SECOND)
    if remain <= 0 then
        self:Destroy()
        return
    end

    local text, textSleep = self:GetTimerText(remain)
    if self.text ~= text then
        self.text = text
        for subscriber in pairs(self.subscribers) do
            subscriber:OnTimerTextUpdated(self, text)
        end
    end

    local state, stateSleep = self:GetTimerState(remain)
    if self.state ~= state then
        self.state = state
        for subscriber in pairs(self.subscribers) do
            subscriber:OnTimerStateUpdated(self, state)
        end
    end

    local sleep = min(textSleep, stateSleep)
    if sleep < DAY then
        C_Timer.After(max(sleep / SECOND, GetTickTime()), self.callback)
    end
end

function Timer:Subscribe(subscriber)
    if not self.key then
        return
    end

    if not self.subscribers[subscriber] then
        self.subscribers[subscriber] = true
    end
end

function Timer:Unsubscribe(subscriber)
    if not self.key then
        return
    end

    if self.subscribers[subscriber] then
        self.subscribers[subscriber] = nil

        if not next(self.subscribers) then
            self:Destroy()
        end
    end
end

-- Calculates timer text
---@param remain number -- The remaining time on the timer, in miliseconds
---@return string? -- The formatted text for the time remaining
---@return number -- How long, in miliseconds, until the the next text update
function Timer:GetTimerText(remain)
    if remain <= 0 then
        return '', DAY
    end

    local tenthsThreshold, mmSSThreshold

    local sets = self.settings
    if sets then
        tenthsThreshold = (sets.tenthsDuration or 0) * SECOND
        mmSSThreshold = (sets.mmSSDuration or 0) * SECOND
    else
        tenthsThreshold = 0
        mmSSThreshold = 0
    end

    if remain < tenthsThreshold then
        -- tenths of seconds
        local tenths = (remain + HALF_TENTH) - (remain + HALF_TENTH) % TENTH

        local sleep = remain - (tenths - HALF_TENTH)

        if tenths > 0 then
            return L.TenthsFormat:format(tenths / SECOND), sleep
        end

        return '', sleep
    elseif remain < SECONDS_THRESHOLD then
        -- seconds
        local seconds = (remain + HALF_SECOND) - (remain + HALF_SECOND) % SECOND

        local sleep = remain - max(seconds - HALF_SECOND, tenthsThreshold)

        if seconds > 0 then
            return L.SecondsFormat:format(seconds / SECOND), sleep
        end

        return '', sleep
    elseif remain < mmSSThreshold then
        -- MM:SS
        local seconds = (remain + HALF_SECOND) - (remain + HALF_SECOND) % SECOND

        local sleep = remain - max(seconds - HALF_SECOND, SECONDS_THRESHOLD)

        return L.MMSSFormat:format(seconds / MINUTE, (seconds % MINUTE) / SECOND), sleep
    elseif remain < MINUTES_THRESHOLD then
        -- minutes
        local minutes = (remain + HALF_MINUTE) - (remain + HALF_MINUTE) % MINUTE

        local wait = max(
            -- transition point of showing one minute versus another (29.5s, 89.5s, 149.5s, ...)
            minutes - HALF_MINUTE,
            -- transition point of displaying minutes to displaying seconds (59.5s)
            SECONDS_THRESHOLD,
            -- transition point of displaying MM:SS (user set)
            mmSSThreshold
        )

        local sleep = remain - wait

        return L.MinutesFormat:format(minutes / MINUTE), sleep
    elseif remain < HOURS_THRESHOLD then
        -- hours
        local hours = (remain + HALF_HOUR) - (remain + HALF_HOUR) % HOUR

        local sleep = remain - max(hours - HALF_HOUR, MINUTES_THRESHOLD)

        return L.HoursFormat:format(hours / HOUR), sleep
    elseif remain <= (DAY * 7) then
        -- days
        local days = (remain + HALF_DAY) - (remain + HALF_DAY) % DAY

        local sleep = remain - max(days - HALF_DAY, HOURS_THRESHOLD)

        return L.DaysFormat:format(days / DAY), sleep
    else
        return '', DAY
    end
end

-- Calculates timer state
---@param remain number -- The remaining time on the timer, in miliseconds
---@return OmniCCTimerState -- The curent state of the timer
---@return number -- How long, in miliseconds, until the next timer state
function Timer:GetTimerState(remain)
    if self.kind == 'loc' then
        return 'controlled', math.huge
    elseif self.kind == 'charge' then
        return 'charging', math.huge
    elseif remain < SOON_THRESHOLD then
        return 'soon', math.huge
    elseif remain < SECONDS_THRESHOLD then
        return 'seconds', remain - SOON_THRESHOLD
    elseif remain < MINUTES_THRESHOLD then
        return 'minutes', remain - SECONDS_THRESHOLD
    else
        return 'hours', remain - MINUTES_THRESHOLD
    end
end

function Timer:ForActive(method, ...)
    local func = self[method]

    if type(func) ~= 'function' then
        return
    end

    for _, timer in pairs(active) do
        func(timer, ...)
    end
end

-- exports
Addon.Timer = Timer
