local _, PRT = ...

local TriggerHandler = {}

local GetTime = GetTime

-------------------------------------------------------------------------------
-- Local Helper

-- Triggers without difficulties (old imports, the example) run on all.
function TriggerHandler.CheckCurrentDifficulty(trigger)
  if PRT.currentDifficulty then
    return trigger.enabledDifficulties == nil or trigger.enabledDifficulties[PRT.currentDifficulty]
  end
end

function TriggerHandler.CheckOccurence(trigger)
  if ((trigger.occurence or 0) >= (trigger.triggerAtOccurence or 1)) or trigger.startCondition == nil then
    return true
  end

  return false
end

-- Conditions with a spell, source or target came from the combat log and
-- never match anymore (see PRT.GetUnsupportedReason).
function TriggerHandler.CheckCondition(condition, event)
  return condition ~= nil and condition.event ~= nil and condition.spellID == nil and condition.source == nil and condition.target == nil and
    condition.event == event
end

function TriggerHandler.GetTriggerOccurence(trigger)
  if trigger ~= nil then
    if trigger.occurence ~= nil then
      return trigger.occurence
    else
      return 0
    end
  end
end

function TriggerHandler.GetTriggerCounter(trigger)
  if trigger ~= nil then
    if trigger.counter ~= nil then
      return trigger.counter
    else
      return 0
    end
  end
end

function TriggerHandler.GetRotationMessages(rotation)
  local rotationCounter = TriggerHandler.GetTriggerCounter(rotation)
  if rotation ~= nil then
    if rotation.entries ~= nil then
      if rotationCounter <= table.getn(rotation.entries) then
        local messagesByCounter = rotation.entries[rotationCounter]

        if messagesByCounter.messages ~= nil then
          return messagesByCounter.messages
        end
      end
    end
  end
end

function TriggerHandler.IncrementTriggerOccurence(trigger)
  local triggerOccurence = TriggerHandler.GetTriggerOccurence(trigger)
  local newValue = triggerOccurence + 1

  PRT.Debug(
    string.format("Incrementing trigger occurence (" .. (trigger.name or "NO NAME") .. ") from %s to %s", PRT.HighlightString(triggerOccurence), PRT.HighlightString(newValue))
  )
  trigger.occurence = newValue
end

function TriggerHandler.IncrementTriggerCounter(trigger)
  local triggerCounter = TriggerHandler.GetTriggerCounter(trigger)
  local newValue = triggerCounter + 1

  PRT.Debug(string.format("Incrementing trigger counter (" .. (trigger.name or "NO NAME") .. ") from %s to %s", PRT.HighlightString(triggerCounter), PRT.HighlightString(newValue)))
  trigger.counter = newValue
end

function TriggerHandler.UpdateRotationCounter(rotation)
  if rotation ~= nil then
    if rotation.entries ~= nil then
      local rotationCurrentCount = TriggerHandler.GetTriggerCounter(rotation)
      local rotationMaxCount = table.getn(rotation.entries)

      if rotationCurrentCount >= rotationMaxCount then
        if rotation.shouldRestart == true then
          PRT.Debug("Resetting rotation counter to 1 for", PRT.HighlightString(rotation.name))
          rotation.counter = 1
        else
          TriggerHandler.IncrementTriggerCounter(rotation)
        end
      else
        TriggerHandler.IncrementTriggerCounter(rotation)
      end
    end
  end
end

function TriggerHandler.CheckStopIgnoreRotationCondition(trigger)
  if trigger.ignoreAfterActivation and trigger.ignored == true then
    if ((trigger.lastActivation or 0) + (trigger.ignoreDuration or 5)) < GetTime() then
      trigger.ignored = false
      PRT.Debug("Stopped ignoring trigger", PRT.HighlightString(trigger.name))
    end
  end
end

function TriggerHandler.SendMessagesAfterDelay(messages)
  for _, message in ipairs(messages) do
    if (message.delay or 0) > 0 then
      PRT.EncounterTimer:ScheduleTimer(PRT.ExecuteMessage, message.delay, message)
    else
      PRT.ExecuteMessage(message)
    end
  end
end

-------------------------------------------------------------------------------
-- Public API

-- Since 12.0 (also on WoW: Forever) only these events reach the trigger
-- conditions: no combat log, no boss health/power during encounters.
local SUPPORTED_CONDITION_EVENTS = {
  ENCOUNTER_START = true,
  ENCOUNTER_END = true,
  PLAYER_REGEN_DISABLED = true,
  PLAYER_REGEN_ENABLED = true
}

local function UsesUnsupportedEvent(condition)
  return condition ~= nil and condition.event ~= nil and
    (not SUPPORTED_CONDITION_EVENTS[condition.event] or condition.spellID ~= nil or condition.source ~= nil or condition.target ~= nil)
end

-- Why a trigger can't fire anymore ("unitValues" or "combatLog"), nil if it can.
-- triggerType: "timer", "rotation", "healthPercentage" or "powerPercentage".
function PRT.GetUnsupportedReason(triggerType, trigger)
  if triggerType == "healthPercentage" or triggerType == "powerPercentage" then
    return "unitValues"
  end
  if triggerType == "rotation" and UsesUnsupportedEvent(trigger.triggerCondition) then
    return "combatLog"
  end
  -- Timers always have a start condition, rotations only with hasStartCondition.
  if (triggerType == "timer" or trigger.hasStartCondition) and UsesUnsupportedEvent(trigger.startCondition) then
    return "combatLog"
  end
  -- A stop condition that never fires would let a timer run on (e.g. into the next phase).
  if trigger.hasStopCondition and UsesUnsupportedEvent(trigger.stopCondition) then
    return "combatLog"
  end
end

-- encounterVersion -> { { type, trigger, reason } } for all triggers that can't fire.
function PRT.GetUnsupportedTriggers(encounterVersion)
  local unsupported = {}
  local function Collect(triggerType, triggers)
    for _, trigger in ipairs(triggers or {}) do
      local reason = PRT.GetUnsupportedReason(triggerType, trigger)
      if reason then
        unsupported[#unsupported + 1] = {type = triggerType, trigger = trigger, reason = reason}
      end
    end
  end
  Collect("timer", encounterVersion.Timers)
  Collect("rotation", encounterVersion.Rotations)
  Collect("healthPercentage", encounterVersion.HealthPercentages)
  Collect("powerPercentage", encounterVersion.PowerPercentages)
  return unsupported
end

function PRT.IsTriggerActive(trigger)
  local isEnabled = trigger.enabled == true or trigger.enabled == nil
  local isEnabledForDifficulty = TriggerHandler.CheckCurrentDifficulty(trigger) or PRT.IsTestMode()
  local isActive = trigger.active

  return (isEnabled and isEnabledForDifficulty and (isActive or (trigger.active == nil and (not trigger.hasStartCondition))))
end

-- Timer
function PRT.CheckTimerStartConditions(timers, event)
  if timers ~= nil then
    for _, timer in ipairs(timers) do
      if timer.enabled == true or timer.enabled == nil then
        if timer.startCondition ~= nil and timer.started ~= true then
          if TriggerHandler.CheckCondition(timer.startCondition, event) then
            TriggerHandler.IncrementTriggerOccurence(timer)

            if TriggerHandler.CheckOccurence(timer) then
              PRT.Debug("Started timer", PRT.HighlightString(timer.name))
              timer.started = true
              timer.startedAt = GetTime()
            end
          end
        end
      end
    end
  end
end

function PRT.CheckTimerStopConditions(timers, event)
  if timers ~= nil then
    for _, timer in ipairs(timers) do
      if timer.enabled == true or timer.enabled == nil then
        if timer.stopCondition ~= nil and timer.started == true then
          if TriggerHandler.CheckCondition(timer.stopCondition, event) then
            PRT.Debug("Stopped timer", PRT.HighlightString(timer.name))
            timer.started = false
            timer.startedAt = nil

            if timer.resetOccurenceOnStop or timer.resetCounterOnStop then
              timer.occurence = 0
            end

            for _, timing in pairs(timer.timings) do
              timing.executed = false

              if timing.messages then
                timing.messages.executionTimes = {}
              end
            end
          end
        end
      end
    end
  end
end

function PRT.CheckTriggersStartConditions(triggers, event)
  if triggers ~= nil then
    for _, trigger in ipairs(triggers) do
      if trigger.enabled == true or trigger.enabled == nil then
        if trigger.startCondition ~= nil and trigger.active ~= true then
          if TriggerHandler.CheckCondition(trigger.startCondition, event) then
            TriggerHandler.IncrementTriggerOccurence(trigger)

            if TriggerHandler.CheckOccurence(trigger) then
              PRT.Debug("Started trigger", PRT.HighlightString(trigger.name))
              trigger.active = true
            end
          end
        end
      end
    end
  end
end

function PRT.CheckTriggersStopConditions(triggers, event)
  if triggers ~= nil then
    for _, trigger in ipairs(triggers) do
      if trigger.enabled == true or trigger.enabled == nil then
        if trigger.stopCondition ~= nil and PRT.IsTriggerActive(trigger) then
          if TriggerHandler.CheckCondition(trigger.stopCondition, event) then
            if trigger.resetOccurenceOnStop or trigger.resetCounterOnStop then
              trigger.occurence = 0
            end

            PRT.Debug("Stopped trigger", PRT.HighlightString(trigger.name))
            trigger.active = false
          end
        end
      end
    end
  end
end

-- Fires every timing whose time has passed and that didn't fire yet, so a
-- late tick sends late instead of never and fractional times work.
function PRT.CheckTimerTimings(timers)
  if not timers then
    return
  end
  local now = GetTime()
  for _, timer in ipairs(timers) do
    if timer.started == true and timer.timings and PRT.IsTriggerActive(timer) and TriggerHandler.CheckOccurence(timer) then
      local elapsed = now - timer.startedAt
      for _, timing in ipairs(timer.timings) do
        local messages = timing.messages
        if messages then
          local offset = timing.offset or 0
          for _, second in ipairs(timing.seconds or {}) do
            local at = second + offset
            if elapsed >= at then
              messages.executionTimes = messages.executionTimes or {}
              if not messages.executionTimes[at] then
                messages.executionTimes[at] = true
                TriggerHandler.SendMessagesAfterDelay(messages)
              end
            end
          end
        end
      end
    end
  end
end

-- Rotations
function PRT.CheckRotationTriggerCondition(rotations, event)
  if rotations ~= nil then
    for _, rotation in ipairs(rotations) do
      if PRT.IsTriggerActive(rotation) and TriggerHandler.CheckOccurence(rotation) then
        if rotation.triggerCondition ~= nil then
          TriggerHandler.CheckStopIgnoreRotationCondition(rotation)

          if rotation.ignored ~= true then
            if TriggerHandler.CheckCondition(rotation.triggerCondition, event) then
              TriggerHandler.UpdateRotationCounter(rotation)

              local messages = TriggerHandler.GetRotationMessages(rotation)
              TriggerHandler.SendMessagesAfterDelay(messages or {})

              rotation.lastActivation = GetTime()

              if rotation.ignoreAfterActivation == true then
                rotation.ignored = true
                PRT.Debug("Started ignoring rotation", PRT.HighlightString(rotation.name), "for", PRT.HighlightString(rotation.ignoreDuration))
              end
            end
          end
        end
      end
    end
  end
end
