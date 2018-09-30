-- A pool of objects for determining what text to display for a given cooldown
-- and notify subscribers when the text change

-- local bindings!
local Addon = _G[...]
local L = _G.OMNICC_LOCALS

local After = _G.C_Timer.After
local GetTime = _G.GetTime

local max = math.max
local min = math.min
local modf = math.modf
local next = next
local round = _G.Round
local strjoin = _G.strjoin

-- sexy constants!
-- the minimum timer increment in ms
local TICK = 10

-- time units in ms
local DAY = 86400000
local HOUR = 3600000
local MINUTE = 60000
local SECOND = 1000
local TENTHS = 100

local HALF_DAY = 43200000
local HALF_HOUR = 5400000
local HALF_MINUTE = 30000
local HALF_SECOND = 500
local HALF_TENTHS = 50

-- transition points
local HOURS_THRESHOLD = 84600000 --23.5 hours in ms
local MINUTES_THRESHOLD = 3570000 --59.5 minutes in ms
local SECONDS_THRESHOLD = 59500 --59.5 seconds in ms
local SOON_THRESHOLD = 5500

-- internal state!
-- all active timers
local active = {}
-- inactive timers
-- here we use a weak table so that inactive timers are cleaned up on garbage
-- collection
local inactive = setmetatable({}, {__mode = "k" })

local function cooldown_GetKind(cooldown)
    if cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
        return "loc"
    end

    local parent = cooldown:GetParent()
    if parent and parent.chargeCooldown == cooldown then
        return "charge"
    end

    return "default"
end


local Timer = {}
local Timer_MT = { __index = Timer }

function Timer:GetOrCreate(cooldown)
    local start, duration = cooldown:GetCooldownTimes()
    if not (start and duration and start > 0 and duration > 0) then
        return
    end

    local kind = cooldown_GetKind(cooldown)
    local settings = Addon:GetCooldownSettings(cooldown)
    local key = strjoin("-", start, duration, kind, settings and settings.id or "base")

    local timer = active[key]
    if not timer then
        timer = self:Restore() or self:Create()

        timer.duration = duration
        timer.endTime = start + duration
        timer.key = key
        timer.kind = kind
        timer.settings = settings
        timer.subscribers = {}

        active[key] = timer
        timer:Update()
    end

    return timer
end

function Timer:Restore()
    local timer = next(inactive)

    if timer then
        inactive[timer] = nil
    end

    return timer
end

function Timer:Create()
    local timer = setmetatable({}, Timer_MT)

    timer.callback = function() timer:Update() end

    return timer
end

function Timer:Destroy()
    if not self.key then return end

    active[self.key] = nil

    -- clear subscribers
    for subscriber in pairs(self.subscribers) do
        subscriber:OnTimerDestroyed(self)
    end

    -- reset fields
    self.duration = nil
    self.finished = nil
    self.key = nil
    self.kind = nil
    self.settings = nil
    self.endTime = nil
    self.state = nil
    self.subscribers = nil
    self.text = nil

    inactive[self] = true
end

function Timer:Update()
    if not self.key then return end

    local remain = round(self.endTime - (GetTime() * SECOND))

    -- handle cooldowns that will start in the future or are broken after a
    -- computer restart. The precision here is over 10 so that we can account
    -- for some floating point math fun
    if (remain - self.duration) > 10 then
        local text = ""
        if self.text ~= text then
            self.text = text
            for subscriber in pairs(self.subscribers) do
                subscriber:OnTimerTextUpdated(self, text)
            end
        end

        local state = "hours"
        if self.state ~= state then
            self.state = state
            for subscriber in pairs(self.subscribers) do
                subscriber:OnTimerStateUpdated(self, state)
            end
        end

        local sleep = remain - self.duration
        if sleep < math.huge then
            After(max(sleep, TICK) / SECOND, self.callback)
        end
    elseif remain > 0 then
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
        if sleep < math.huge then
            After(max(sleep, TICK) / SECOND, self.callback)
        end
    elseif not self.finished then
        self.finished = true

        for subscriber in pairs(self.subscribers) do
            subscriber:OnTimerFinished(self)
        end

        self:Destroy()
    end
end

function Timer:Subscribe(subscriber)
    if not self.key then return end

    if not self.subscribers[subscriber] then
        self.subscribers[subscriber] = true
    end
end

function Timer:Unsubscribe(subscriber)
    if not self.key then return end

    if self.subscribers[subscriber] then
        self.subscribers[subscriber] = nil

        if not next(self.subscribers) then
            self:Destroy()
        end
    end
end

function Timer:GetTimerText(remain)
    local tenthsThreshold, mmSSThreshold

    local sets = self.settings
    if sets then
        tenthsThreshold = round((sets.tenthsDuration or 0) * SECOND)
        mmSSThreshold = round((sets.mmSSDuration or 0) * SECOND)
    else
        tenthsThreshold = 0
        mmSSThreshold = 0
    end

    if remain < tenthsThreshold then
        -- tenths of seconds
        local tenths = (remain + HALF_TENTHS) - ((remain + HALF_TENTHS) % TENTHS)
        local sleep = 1 + (remain - (tenths - HALF_TENTHS))

        if tenths > 0 then
            return L.TenthsFormat:format(tenths / SECOND), sleep
        end

        return "", sleep
    elseif remain < SECONDS_THRESHOLD then
        -- seconds
        local seconds = round(remain / SECOND)

        local sleep = 1 + (remain - max(
            (seconds * SECOND) - HALF_SECOND,
            tenthsThreshold
        ))

        if seconds > 0 then
            return seconds, sleep
        end

        return "", sleep
    elseif remain < mmSSThreshold then
        -- MM:SS
        local minutes, seconds = modf(remain / MINUTE)
        local minutesInSeconds = round(remain / SECOND)

        local sleep = 1 + (remain - max(
            (minutesInSeconds * SECOND) - HALF_SECOND,
            SECONDS_THRESHOLD
        ))

        return L.MMSSFormat:format(minutes, round(seconds * 60)), sleep
    elseif remain < MINUTES_THRESHOLD then
        -- minutes
        local minutes = round(remain / MINUTE)

        local sleep = 1 + (remain - max(
            -- transition point of showing one minute versus another (29.5s, 89.5s, 149.5s, ...)
            (minutes * MINUTE) - HALF_MINUTE,
            -- transition point of displaying minutes to displaying seconds (59.5s)
            SECONDS_THRESHOLD,
            -- transition point of displaying MM:SS (user set)
            mmSSThreshold
        ))

        return L.MinuteFormat:format(minutes), sleep
    elseif remain < HOURS_THRESHOLD then
        -- hours
        local hours = round(remain / HOUR)

        local sleep = 1 + (remain - max(
            (hours * HOUR) - HALF_HOUR,
            MINUTES_THRESHOLD
        ))

        return L.HourFormat:format(hours), sleep
    else
        -- days
        local days = round(remain / DAY)

        local sleep = 1 + (remain - max(
            days - HALF_DAY,
            HOURS_THRESHOLD
        ))

        return L.DayFormat:format(days), sleep
    end
end

function Timer:GetTimerState(remain)
    if remain <= 0 then
        return "finished", math.huge
    elseif self.kind == "loc" then
        return "controlled", math.huge
    elseif self.kind == "charge" then
        return "charging", math.huge
    elseif remain < SOON_THRESHOLD then
        return "soon", math.huge
    elseif remain < SECONDS_THRESHOLD then
        return "seconds", 1 + (remain - SOON_THRESHOLD)
    elseif remain < MINUTES_THRESHOLD then
        return "minutes", 1 + (remain - SECONDS_THRESHOLD)
    else
        return "hours", 1 + (remain - MINUTES_THRESHOLD)
    end
end

function Timer:ForActive(method, ...)
    for _, timer in pairs(active) do
        local func = timer[method]
        if type(func) == "function" then
            func(timer, ...)
        end
    end
end

Addon.Timer = Timer
