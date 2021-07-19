local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local TriggerHandler = {}

-- Create local copies of API functions which we use
local UnitName, UnitGUID, GetTime, UnitExists, UnitIsDead, UnitHealth, UnitHealthMax, UnitPower, UnitPowerMax =
  UnitName,
  UnitGUID,
  GetTime,
  UnitExists,
  UnitIsDead,
  UnitHealth,
  UnitHealthMax,
  UnitPower,
  UnitPowerMax

-------------------------------------------------------------------------------
-- Local Helper

function TriggerHandler.CheckCurrentDifficulty(trigger)
  if trigger.enabledDifficulties and PRT.currentDifficulty then
    return trigger.enabledDifficulties[PRT.currentDifficulty]
  end
end

function TriggerHandler.UnitExistsInTrackedUnits(conditionUnitID, eventUnitGUID)
  if PRT.currentEncounter.trackedUnits then
    for _, trackedUnit in pairs(PRT.currentEncounter.trackedUnits) do
      if tonumber(conditionUnitID) then
        -- Find by NPC-ID
        local npcID = PRT.GUIDToNPCID(trackedUnit.guid)
        if npcID == conditionUnitID and trackedUnit.guid == eventUnitGUID then
          return true
        end
      elseif UnitExists(conditionUnitID) and trackedUnit.guid == eventUnitGUID then
        return true
      elseif type(conditionUnitID) == "string" then
        -- Find by name
        if trackedUnit.name == conditionUnitID and trackedUnit.guid == eventUnitGUID then
          return true
        end
      end
    end
  end
end

function TriggerHandler.ValidTestModeEvent(event, combatEvent, conditionEvent)
  if PRT.IsTestMode() then
    if conditionEvent == "ENCOUNTER_START" then
      local simulatedConditionEvent = "PLAYER_REGEN_DISABLED"

      return (simulatedConditionEvent ~= nil and (simulatedConditionEvent == event or simulatedConditionEvent == combatEvent))
    else
      return false
    end
  else
    return false
  end
end

function TriggerHandler.CheckOccurence(trigger)
  if ((trigger.occurence or 0) >= (trigger.triggerAtOccurence or 1)) or trigger.startCondition == nil then
    return true
  end

  return false
end

function TriggerHandler.CheckCondition(condition, event, combatEvent, spellID, targetGUID, sourceGUID)
  if
    condition ~= nil and
      ((condition.event ~= nil and (condition.event == event or condition.event == combatEvent)) or TriggerHandler.ValidTestModeEvent(event, combatEvent, condition.event)) and
      (condition.spellID == nil or condition.spellID == spellID) and
      (condition.source == nil or UnitGUID(condition.source or "") == sourceGUID or TriggerHandler.UnitExistsInTrackedUnits(condition.source or "", sourceGUID)) and
      (condition.target == nil or UnitGUID(condition.target or "") == targetGUID or TriggerHandler.UnitExistsInTrackedUnits(condition.target or "", targetGUID))
   then
    return true
  end

  return false
end

function TriggerHandler.FilterTimingsTable(timings, timeOffset)
  local timingTables = {}

  if timings then
    for _, v in ipairs(timings) do
      local secondsWithOffset

      if v.offset then
        secondsWithOffset = {}
        for _, second in ipairs(v.seconds) do
          tinsert(secondsWithOffset, second + (v.offset or 0))
        end
      else
        secondsWithOffset = v.seconds
      end

      if tContains(secondsWithOffset, timeOffset) then
        tinsert(timingTables, v)
      end
    end
  end

  return timingTables
end

function TriggerHandler.FilterPercentagesTable(percentages, percent)
  local value

  if percentages and percent then
    for _, v in ipairs(percentages) do
      if v.operator == "greater" then
        if percent > v.value then
          if not value then
            value = v
          end
        end
      elseif v.operator == "less" then
        if percent < v.value then
          if not value then
            value = v
          end
        end
      elseif v.operator == "lessorequals" then
        if percent <= v.value then
          if not value then
            value = v
          end
        end
      elseif v.operator == "greaterorequals" then
        if percent >= v.value then
          if not value then
            value = v
          end
        end
      elseif v.operator == "equals" then
        if v.value == percent then
          if not value then
            value = v
          end
        end
      end
    end
  end

  return value
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

function TriggerHandler.CheckStopIgnorePercentageCondition(percentage)
  for _, percentageValue in ipairs(percentage.values) do
    if percentage.checkAgain and percentageValue.ignored == true then
      if ((percentageValue.lastActivation or 0) + (percentage.checkAgainAfter or 5)) < GetTime() then
        percentageValue.ignored = false
        PRT.Debug("Stopped ignoring trigger", PRT.HighlightString(percentageValue.name))
      end
    end
  end
end

function TriggerHandler.SendMessagesAfterDelay(messages)
  for _, message in ipairs(messages) do
    AceTimer:ScheduleTimer(
      function()
        PRT.ExecuteMessage(message)
      end,
      message.delay or 0
    )
  end
end

function TriggerHandler.SendMessagesAfterDelayWithEventInfo(messages, targetName, sourceName)
  if messages then
    for _, message in ipairs(messages) do
      AceTimer:ScheduleTimer(
        function()
          -- Make sure we are not changing the configured message itself
          local messageForReceiver = PRT.TableUtils.Clone(message)

          if targetName then
            messageForReceiver.message = messageForReceiver.message:gsub("$target", targetName)
          else
            messageForReceiver.message = messageForReceiver.message:gsub("$target", "N/A")
          end
          if sourceName then
            messageForReceiver.message = messageForReceiver.message:gsub("$source", sourceName)
          else
            messageForReceiver.message = messageForReceiver.message:gsub("$source", "N/A")
          end
          if tContains(messageForReceiver.targets, "$target") then
            messageForReceiver.eventTarget = targetName
          end
          PRT.ExecuteMessage(messageForReceiver)
        end,
        message.delay or 0
      )
    end
  end
end

-------------------------------------------------------------------------------
-- Public API

function PRT.IsTriggerActive(trigger)
  local isEnabled = trigger.enabled == true or trigger.enabled == nil
  local isEnabledForDifficulty = TriggerHandler.CheckCurrentDifficulty(trigger) or PRT.IsTestMode()
  local isActive = trigger.active

  return (isEnabled and isEnabledForDifficulty and (isActive or (trigger.active == nil and (not trigger.hasStartCondition))))
end

-- Timer
function PRT.CheckTimerStartConditions(timers, event, combatEvent, spellID, targetGUID, sourceGUID)
  if timers ~= nil then
    for _, timer in ipairs(timers) do
      if timer.enabled == true or timer.enabled == nil then
        if timer.startCondition ~= nil and timer.started ~= true then
          if TriggerHandler.CheckCondition(timer.startCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
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

function PRT.CheckTimerStopConditions(timers, event, combatEvent, spellID, targetGUID, sourceGUID)
  if timers ~= nil then
    for _, timer in ipairs(timers) do
      if timer.enabled == true or timer.enabled == nil then
        if timer.stopCondition ~= nil and timer.started == true then
          if TriggerHandler.CheckCondition(timer.stopCondition, event, combatEvent, spellID, sourceGUID, targetGUID) then
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

function PRT.CheckTriggersStartConditions(triggers, event, combatEvent, spellID, targetGUID, sourceGUID)
  if triggers ~= nil then
    for _, trigger in ipairs(triggers) do
      if trigger.enabled == true or trigger.enabled == nil then
        if trigger.startCondition ~= nil and trigger.active ~= true then
          if TriggerHandler.CheckCondition(trigger.startCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
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

function PRT.CheckTriggersStopConditions(triggers, event, combatEvent, spellID, targetGUID, sourceGUID)
  if triggers ~= nil then
    for _, trigger in ipairs(triggers) do
      if trigger.enabled == true or trigger.enabled == nil then
        if trigger.stopCondition ~= nil and PRT.IsTriggerActive(trigger) then
          if TriggerHandler.CheckCondition(trigger.stopCondition, event, combatEvent, spellID, sourceGUID, targetGUID) then
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

function PRT.CheckTimerTimings(timers)
  local currentTime = GetTime()
  if timers ~= nil then
    for _, timer in ipairs(timers) do
      if PRT.IsTriggerActive(timer) and TriggerHandler.CheckOccurence(timer) then
        if timer.started == true and timer.timings ~= nil then
          local elapsedTime = PRT.Round(currentTime - timer.startedAt)
          local timings = timer.timings
          local timingsByTime = TriggerHandler.FilterTimingsTable(timings, elapsedTime)

          for _, timingByTime in ipairs(timingsByTime) do
            if timingByTime then
              local messagesByTime = timingByTime.messages

              if messagesByTime ~= nil then
                messagesByTime.executionTimes = messagesByTime.executionTimes or {}
                if messagesByTime.executionTimes[elapsedTime] ~= true then
                  TriggerHandler.SendMessagesAfterDelay(messagesByTime)
                  messagesByTime.executionTimes[elapsedTime] = true
                end
              end
            end
          end
        end
      end
    end
  end
end

-- Rotations
function PRT.CheckRotationTriggerCondition(rotations, event, combatEvent, eventSpellID, targetGUID, targetName, sourceGUID, sourceName)
  if rotations ~= nil then
    for _, rotation in ipairs(rotations) do
      if PRT.IsTriggerActive(rotation) and TriggerHandler.CheckOccurence(rotation) then
        if rotation.triggerCondition ~= nil then
          TriggerHandler.CheckStopIgnoreRotationCondition(rotation)

          if rotation.triggerCondition.event and not rotation.triggerCondition.spellID then
            if string.find(rotation.triggerCondition.event, "SPELL_") then
              PRT.Error(
                "Rotation",
                PRT.HighlightString(rotation.name),
                "has a SPELL_* event configured without a spellID.",
                "This may lead to a lot of messages and is therefore skipped and disabled."
              )
              rotation.enabled = false
              return
            end
          end

          if rotation.ignored ~= true then
            if TriggerHandler.CheckCondition(rotation.triggerCondition, event, combatEvent, eventSpellID, targetGUID, sourceGUID) then
              TriggerHandler.UpdateRotationCounter(rotation)

              local messages = TriggerHandler.GetRotationMessages(rotation)
              TriggerHandler.SendMessagesAfterDelayWithEventInfo(messages, targetName, sourceName)

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

local function ValidUnit(unitID)
  return UnitExists(unitID) and (not UnitIsDead(unitID))
end
-- Health Percentages
function PRT.GetEffectiveUnits(unit)
  local matchedUnits = {}

  if PRT.currentEncounter.trackedUnits then
    for trackedUnitGUID, trackedUnit in pairs(PRT.currentEncounter.trackedUnits) do
      if tonumber(unit) then
        -- Find by NPC-ID
        local npcID = PRT.GUIDToNPCID(trackedUnitGUID)
        if npcID == unit then
          if ValidUnit(trackedUnit.unitID) then
            tinsert(matchedUnits, trackedUnit)
          end
        end
      elseif UnitExists(unit) then
        tinsert(
          matchedUnits,
          {
            unitID = unit,
            guid = UnitGUID(unit),
            name = UnitName(unit)
          }
        )
      elseif type(unit) == "string" then
        -- Find by name
        if trackedUnit.name == unit then
          if ValidUnit(trackedUnit.unitID) then
            tinsert(matchedUnits, trackedUnit)
          end
        end
      end
    end
  end

  return matchedUnits
end

function TriggerHandler.ExecutePercentageValue(percentage, percentageValue)
  TriggerHandler.SendMessagesAfterDelay(percentageValue.messages)
  percentageValue.lastActivation = GetTime()
  if percentage.checkAgain == true then
    percentageValue.ignored = true
    PRT.Debug("Started ignoring percentage", PRT.HighlightString(percentageValue.name), "for", PRT.HighlightString(percentage.checkAgainAfter))
  else
    percentageValue.executed = true
  end
end

function PRT.CheckUnitHealthPercentages(percentages)
  if percentages ~= nil then
    for _, percentage in ipairs(percentages) do
      if PRT.IsTriggerActive(percentage) then
        TriggerHandler.CheckStopIgnorePercentageCondition(percentage)
        for _, percentageValue in ipairs(percentage.values) do
          if percentageValue.ignored ~= true and percentageValue.executed ~= true then
            local effectiveUnits = PRT.GetEffectiveUnits(percentage.unitID)

            for _, effectiveUnit in pairs(effectiveUnits) do
              if effectiveUnit and effectiveUnit.name == UnitName(effectiveUnit.unitID) then
                if ValidUnit(effectiveUnit.unitID) then
                  local unitCurrentHP = UnitHealth(effectiveUnit.unitID)
                  local unitMaxHP = UnitHealthMax(effectiveUnit.unitID)
                  local unitHPPercent = PRT.Round(unitCurrentHP / unitMaxHP * 100, 0)
                  local percentageValueMatched = TriggerHandler.FilterPercentagesTable({percentageValue}, unitHPPercent)

                  if percentageValueMatched and percentageValue.messages then
                    PRT.Debug(
                      L["%s (%s) health match (%s%% %s %s%%)"]:format(
                        effectiveUnit.unitID,
                        effectiveUnit.name,
                        unitHPPercent,
                        percentageValueMatched.operator,
                        percentageValueMatched.value
                      )
                    )
                    TriggerHandler.ExecutePercentageValue(percentage, percentageValue)

                    -- NOTE: Stop after first match
                    break
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

function PRT.CheckUnitPowerPercentages(percentages)
  if percentages ~= nil then
    for _, percentage in ipairs(percentages) do
      if PRT.IsTriggerActive(percentage) then
        TriggerHandler.CheckStopIgnorePercentageCondition(percentage)
        for _, percentageValue in ipairs(percentage.values) do
          if percentageValue.ignored ~= true and percentageValue.executed ~= true then
            local effectiveUnits = PRT.GetEffectiveUnits(percentage.unitID)

            for _, effectiveUnit in pairs(effectiveUnits) do
              if effectiveUnit and effectiveUnit.name == UnitName(effectiveUnit.unitID) then
                if ValidUnit(effectiveUnit.unitID) then
                  local unitCurrentPower = UnitPower(effectiveUnit.unitID)
                  local unitMaxPower = UnitPowerMax(effectiveUnit.unitID)
                  local unitPowerPercent = PRT.Round(unitCurrentPower / unitMaxPower * 100, 0)
                  local percentageValueMatched = TriggerHandler.FilterPercentagesTable(percentage.values, unitPowerPercent)

                  if percentageValueMatched and percentageValue.messages then
                    if percentageValueMatched and percentageValue.messages then
                      PRT.Debug(
                        "Unit power percentage matched with unit",
                        PRT.HighlightString(effectiveUnit.unitID),
                        unitPowerPercent,
                        percentageValueMatched.operator,
                        percentageValueMatched.value
                      )
                      TriggerHandler.ExecutePercentageValue(percentage, percentageValue)

                      -- NOTE: Stop after first match
                      break
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Message Queue Processing

function PRT.ProcessMessage(message)
  PRT.ExecuteMessage(message)
end

function PRT.ProcessMessageQueue()
  if PRT.MessageQueue ~= nil then
    if not PRT.TableUtils.IsEmpty(PRT.MessageQueue) then
      local currentTime = GetTime()
      for i, message in ipairs(PRT.MessageQueue) do
        if message.executionTime < currentTime then
          PRT.ProcessMessage(message)
          tremove(PRT.MessageQueue, i)
        end
      end
    end
  end
end
