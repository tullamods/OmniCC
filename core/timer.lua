-- A pool of objects for determining what text to display for a given cooldown, and notify subscribers when the text change

local Addon = _G[...]
local L = _G.OMNICC_LOCALS

local Timer = {}
local Timer_mt = {__index = Timer}
local active = {}
local inactive = {}

--local bindings!
local GetTime = _G.GetTime
local After = _G.C_Timer.After
local floor = math.floor
local max = math.max
local round = _G.Round
local next = next
local tinsert = table.insert
local tremove = table.remove
local strjoin = _G.strjoin

--sexy constants!
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH, SOONISH = 3600 * 23.5, 60 * 59.5, 59.5, 5.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5 --used for calculating next update times
local MIN_DELAY = 0.01

function Timer:GetOrCreate(settings, start, duration)
    -- start and duration can have milisecond precision, so convert them into ints
    -- when creating a key to avoid floating point weirdness
    local key = strjoin("-", settings.id or "base", floor(start * 1000), floor(duration * 1000))

    -- first, look for an already active timer
    -- if we don't have one, then either reuse an old one or create a new one
    local timer = active[key]

    if not timer then
        if next(inactive) then
            timer = tremove(inactive)
            timer.key = key
            timer.start = start
            timer.duration = duration
            timer.text = nil
            timer.state = nil
            timer.settings = settings
        else
            timer = {
                key = key,
                start = start,
                duration = duration,
                settings = settings,
                subscribers = {}
            }

            setmetatable(timer, Timer_mt)

            timer.callback = function()
                timer:Update()
            end
        end

        active[key] = timer
        timer:Update()
    end

    return timer
end

function Timer:Update()
    if not active[self.key] then
        return
    end

    local remain = (self.duration - (GetTime() - self.start)) or 0

    if round(remain) > 0 then
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

        After(max(min(textSleep, stateSleep), MIN_DELAY), self.callback)
    elseif not self.finished then
        self.finished = true

        for subscriber in pairs(self.subscribers) do
            subscriber:OnTimerFinished(self)
        end

        self:Destroy()
    end
end

function Timer:Subscribe(subscriber)
    if self.subscribers[subscriber] then
        return
    end

    self.subscribers[subscriber] = true
    subscriber:OnTimerTextUpdated(self, self.text or "")
    subscriber:OnTimerStateUpdated(self, self.state or "seconds")
end

function Timer:Unsubscribe(subscriber)
    self.subscribers[subscriber] = nil

    if not next(self.subscribers) then
        self:Destroy()
    end
end

function Timer:Destroy()
    if active[self.key] then
        active[self.key] = nil

        self.settings = nil
        self.text = nil
        self.state = nil
        self.finished = nil

        for subscriber in pairs(self.subscribers) do
            subscriber:OnTimerDestroyed(self)
            self.subscribers[subscriber] = nil
        end

        tinsert(inactive, self)
    end
end

function Timer:GetTimerText(remain)
    local sets = self.settings or {}

    if remain < (sets.tenthsDuration or 0) then
        -- tenths of seconds
        return L.TenthsFormat:format(remain), MIN_DELAY
    elseif remain < MINUTEISH then
        -- minutes
        local seconds = round(remain)
        local sleep = remain - (seconds - 0.51)

        if seconds > 0 then
            return seconds, sleep
        end

        return "", sleep
    elseif remain < (sets.mmSSDuration or 0) then
        -- MM:SS
        local seconds = round(remain)
        local sleep = remain - (seconds - 0.51)

        return L.MMSSFormat:format(seconds / MINUTE, seconds % MINUTE), sleep
    elseif remain < HOUR then
        -- minutes
        local minutes = round(remain / MINUTE)
        local sleep

        if minutes > 1 then
            sleep = (remain - (minutes * MINUTE - HALFMINUTEISH))
        else
            sleep = (remain - MINUTEISH)
        end

        return L.MinuteFormat:format(minutes), sleep
    elseif remain < DAYISH then
        -- hours
        local hours = round(remain / HOUR)
        local sleep = hours > 1 and (remain - (hours * HOUR - HALFHOURISH)) or (remain - HOURISH)

        return L.HourFormat:format(hours), sleep
    else
        -- days
        local days = round(remain / DAY)
        local sleep = days > 1 and (remain - (days * DAY - HALFDAYISH)) or (remain - DAYISH)

        return L.DayFormat:format(days), sleep
    end
end

function Timer:GetTimerState(remain)
    if remain <= 0 then
        return "finished", 1 / 0
    elseif self.controlled then
        return "controlled", remain
    elseif self.charging then
        return "charging", remain
    elseif remain < SOONISH then
        return "soon", remain
    elseif remain < MINUTEISH then
        return "seconds", remain - SOONISH
    elseif remain < HOURISH then
        return "minutes", remain - MINUTEISH
    else
        return "hours", remain - HOURISH
    end
end

function Timer:ForActive(method, ...)
    for timer in pairs(active) do
        local func = timer[method]
        if type(func) == "function" then
            func(timer, ...)
        end
    end
end

Addon.Timer = Timer
