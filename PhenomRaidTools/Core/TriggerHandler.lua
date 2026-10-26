local _, PRT = ...

--[[
  Since 12.0 (also on WoW: Forever) addons get no combat log and no boss
  health/power during encounters, so the only trigger left is a timer from
  the pull: every timer of the running plan starts on the pull and its
  timings show their messages.
]]

local GetTime = GetTime

-- Pull and combat start are the same moment (EventHandler).
local START_EVENTS = {
  ENCOUNTER_START = true,
  PLAYER_REGEN_DISABLED = true
}

-- Timers from before 3.0 may start on a combat log event (or a spell, source
-- or target); those never fire anymore.
function PRT.IsTimerSupported(timer)
  local condition = timer.startCondition
  return condition == nil or
    (START_EVENTS[condition.event] == true and condition.spellID == nil and condition.source == nil and condition.target == nil)
end

-- Timers without difficulties (old imports, the example) run on all.
local function IsEnabledForDifficulty(timer)
  if PRT.IsTestMode() then
    return true
  end
  return PRT.currentDifficulty ~= nil and (timer.enabledDifficulties == nil or timer.enabledDifficulties[PRT.currentDifficulty])
end

-- Assignments: without difficulties on all, with an empty set on none.
function PRT.IsTimingForDifficulty(timing)
  local difficulties = timing.difficulties
  if difficulties == nil then
    return true
  end
  if PRT.IsTestMode() then
    return next(difficulties) ~= nil
  end
  return PRT.currentDifficulty ~= nil and difficulties[PRT.currentDifficulty] == true
end

-- The longest lead time of a timing's messages: the timing fires that much earlier.
local function LeadTime(messages)
  local lead = 0
  for _, message in ipairs(messages) do
    lead = math.max(lead, PRT.MessageLeadTime(message) - (message.delay or 0))
  end
  return lead
end

-- at: when the timing is due. A message with a lead time shows that much
-- before its time and counts down to it.
local function SendMessages(messages, at)
  local now = GetTime()
  for _, message in ipairs(messages) do
    local lead = PRT.MessageLeadTime(message)
    local dueAt = at + (message.delay or 0)
    local pressAt = lead > 0 and dueAt or nil
    local wait = dueAt - lead - now
    if wait > 0 then
      PRT.EncounterTimer:ScheduleTimer(
        function()
          PRT.ExecuteMessage(message, pressAt)
        end,
        wait
      )
    else
      PRT.ExecuteMessage(message, pressAt)
    end
  end
end

-------------------------------------------------------------------------------
-- Public API

-- On the pull: starts every enabled timer of the plan.
function PRT.StartTimers(timers)
  local now = GetTime()
  for _, timer in ipairs(timers or {}) do
    if timer.enabled ~= false and PRT.IsTimerSupported(timer) and IsEnabledForDifficulty(timer) then
      PRT.Debug("Started timer", PRT.HighlightString(timer.name))
      timer.started = true
      timer.startedAt = now
    end
  end
end

-- Fires every timing whose time (minus its lead time) has passed and that
-- didn't fire yet, so a late tick sends late instead of never and fractional
-- times work.
function PRT.CheckTimerTimings(timers)
  if not timers then
    return
  end
  local now = GetTime()
  for _, timer in ipairs(timers) do
    if timer.started and timer.timings then
      local elapsed = now - timer.startedAt
      for _, timing in ipairs(timer.timings) do
        local messages = timing.messages
        if messages and PRT.IsTimingForDifficulty(timing) then
          local offset = timing.offset or 0
          local lead = LeadTime(messages)
          for _, second in ipairs(timing.seconds or {}) do
            local at = second + offset
            if elapsed >= at - lead then
              messages.executionTimes = messages.executionTimes or {}
              if not messages.executionTimes[at] then
                messages.executionTimes[at] = true
                SendMessages(messages, timer.startedAt + at)
              end
            end
          end
        end
      end
    end
  end
end
