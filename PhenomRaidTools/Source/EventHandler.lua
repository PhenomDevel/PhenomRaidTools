local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local EventHandler = {
  worldEvents = {
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "ENCOUNTER_START",
    "ENCOUNTER_END",
    "PLAYER_ENTERING_WORLD",
  },

  trackedInCombatEvents = {
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_HEALTH",
    "UNIT_POWER_UPDATE",
    "UNIT_COMBAT"
  },

  difficultyIDToNameMapping = {
    [1] = "Normal", -- Normal Dungeon
    [2] = "Heroic", -- Heroic Dungeon
    [8] = "Mythic", -- Mythic Keystone Dungeon
    [23] = "Mythic", -- Mythic Dungeon

    [14] = "Normal", -- Normal Raid
    [15] = "Heroic", -- Heroic Raid
    [16] = "Mythic" -- Mythic Raid
  }
}

-- Create local copies of API functions which we use
local GetTime, CombatLogGetCurrentEventInfo, UnitGUID, GetInstanceInfo =
  GetTime, CombatLogGetCurrentEventInfo, UnitGUID, GetInstanceInfo


-------------------------------------------------------------------------------
-- Local Helper

function EventHandler.StartReceiveMessages()
  if PRT.db.profile.enabled then
    if PRT.db.profile.receiverMode then
      PRT.ReceiverOverlay.ShowAll()
      AceTimer:ScheduleRepeatingTimer(PRT.ReceiverOverlay.UpdateFrameText, 0.01)
    else
      PRT.Debug(PRT.HighlightString("Receiver mode"), "is disabled. We won't track messages.")
    end
  else
    PRT.Debug(PRT.HighlightString("PhenomRaidTools"), "is disabled. We won't track messages.")
  end
end

local function NewEncounter()
  return {
    trackedUnits = {},
    inFight = true,
    encounter = {},
    interestingUnits = {},
    interestingEvents = {},
    statistics = {}
  }
end

local function CompileInterestingUnitsByTriggerCondition(interestingUnits, condition)
  if condition.target and not interestingUnits[condition.target] then
    interestingUnits[condition.target] = condition.target
  end

  if condition.source and not interestingUnits[condition.source] then
    interestingUnits[condition.source] = condition.source
  end
end

local function CompileInterestingUnitsByTriggers(interestingUnits, triggers)
  for _, trigger in pairs(triggers) do
    if trigger.enabled and trigger.stopCondition then
      CompileInterestingUnitsByTriggerCondition(interestingUnits, trigger.stopCondition )
    end
    if trigger.enabled and trigger.startCondition then
      CompileInterestingUnitsByTriggerCondition(interestingUnits, trigger.startCondition)
    end
    if trigger.enabled and trigger.triggerCondition then
      CompileInterestingUnitsByTriggerCondition(interestingUnits, trigger.triggerCondition)
    end
  end
end

local function CompileInterestingUnits(currentEncounter)
  local interestingUnits = {}

  for _, percentage in pairs(currentEncounter.encounter.HealthPercentages) do
    if percentage.enabled and not interestingUnits[percentage.unitID] then
      interestingUnits[percentage.unitID] = percentage.unitID
    end
  end

  for _, percentage in pairs(currentEncounter.encounter.PowerPercentages) do
    if percentage.enabled and not interestingUnits[percentage.unitID] then
      interestingUnits[percentage.unitID] = percentage.unitID
    end
  end

  CompileInterestingUnitsByTriggers(interestingUnits, currentEncounter.encounter.Timers)
  CompileInterestingUnitsByTriggers(interestingUnits, currentEncounter.encounter.Rotations)
  CompileInterestingUnitsByTriggers(interestingUnits, currentEncounter.encounter.HealthPercentages)
  CompileInterestingUnitsByTriggers(interestingUnits, currentEncounter.encounter.PowerPercentages)

  currentEncounter.interestingUnits = interestingUnits
end

local function CompileInterestingEventsByTriggers(interestingEvents, triggers)
  for _, trigger in pairs(triggers) do
    if trigger.enabled and trigger.stopCondition then
      if trigger.stopCondition.event and not interestingEvents[trigger.stopCondition.event] then
        interestingEvents[trigger.stopCondition.event] = trigger.stopCondition.event
      end
    end
    if trigger.enabled and trigger.startCondition then
      if trigger.startCondition.event and not interestingEvents[trigger.startCondition.event] then
        interestingEvents[trigger.startCondition.event] = trigger.startCondition.event
      end
    end
    if trigger.enabled and trigger.triggerCondition then
      if trigger.triggerCondition.event and not interestingEvents[trigger.triggerCondition.event] then
        interestingEvents[trigger.triggerCondition.event] = trigger.triggerCondition.event
      end
    end
  end
end

local function CompileInterestingEvents(currentEncounter)
  local interestingEvents = {}

  CompileInterestingEventsByTriggers(interestingEvents, currentEncounter.encounter.Timers)
  CompileInterestingEventsByTriggers(interestingEvents, currentEncounter.encounter.Rotations)
  CompileInterestingEventsByTriggers(interestingEvents, currentEncounter.encounter.HealthPercentages)
  CompileInterestingEventsByTriggers(interestingEvents, currentEncounter.encounter.PowerPercentages)

  currentEncounter.interestingEvents = interestingEvents
end

local function LogInterestingUnitsAndEvents(currentEncounter)
  PRT.Debug("Tracked Units:")
  for _, unit in pairs(currentEncounter.interestingUnits) do
    PRT.Debug("-", PRT.HighlightString(unit))
  end

  PRT.Debug("Tracked Events:")
  for _, event in pairs(currentEncounter.interestingEvents) do
    PRT.Debug("-", PRT.HighlightString(event))
  end
end

local function LogEncounterStatistics(currentEncounter)
  if currentEncounter.statistics then
    PRT.Debug("Handled event statistics:")
    for k, value in pairs(currentEncounter.statistics) do
      PRT.Debug("Handled", PRT.HighlightString(value), "events for", PRT.HighlightString(k))
    end
  end
end

function EventHandler.StartEncounter(event, encounterID, encounterName)
  if PRT.db.profile.enabled then
    wipe(PRT.db.profile.debugLog)
    if PRT.db.profile.senderMode then
      PRT.currentEncounter = NewEncounter()
      PRT.Debug("Starting new encounter", PRT.HighlightString(encounterName),"(", PRT.HighlightString(encounterID), ")" , "|r")

      local _, encounter = PRT.FilterEncounterTable(PRT.db.profile.encounters, encounterID)

      PRT.EnsureEncounterTrigger(encounter)

      if encounter then
        if encounter.enabled then
          PRT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
          PRT:RegisterEvent("UNIT_POWER_UPDATE")
          PRT:RegisterEvent("UNIT_HEALTH")

          PRT.currentEncounter.encounter = PRT.TableUtils.CopyTable(encounter)
          PRT.currentEncounter.encounter.startedAt = GetTime()

          CompileInterestingUnits(PRT.currentEncounter)
          CompileInterestingEvents(PRT.currentEncounter)
          LogInterestingUnitsAndEvents(PRT.currentEncounter)

          if PRT.db.profile.overlay.sender.enabled then
            PRT.SenderOverlay.Show()
            PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, false)
            AceTimer:ScheduleRepeatingTimer(PRT.SenderOverlay.UpdateFrame, 1, PRT.currentEncounter.encounter, PRT.db.profile.overlay.sender)
            AceTimer:ScheduleRepeatingTimer(PRT.ProcessMessageQueue, 0.5)
            AceTimer:ScheduleRepeatingTimer(PRT.CheckTimerTimings, 0.5, PRT.currentEncounter.encounter.Timers)
          end
        else
          PRT.Warn("Found encounter but it is disabled. Skipping encounter.")
        end
      end
    end

    PRT:COMBAT_LOG_EVENT_UNFILTERED(event)

    -- Simulate encounter start events when in test mode
    if PRT.db.profile.testMode then
      PRT:COMBAT_LOG_EVENT_UNFILTERED("PLAYER_REGEN_DISABLED")
      PRT:COMBAT_LOG_EVENT_UNFILTERED("ENCOUNTER_START")
    end
  else
    PRT.Debug(PRT.HighlightString("PhenomRaidTools"), "is disabled. We won't start encounter.")
  end
end

function EventHandler.StopEncounter(event)
  PRT.Debug("Combat stopped.")
  if PRT.db.profile.senderMode then
    LogEncounterStatistics(PRT.currentEncounter)

    -- Send the last event before unregistering the event
    PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
    PRT:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    PRT:UnregisterEvent("UNIT_POWER_UPDATE")
    PRT:UnregisterEvent("UNIT_HEALTH")

    if PRT.currentEncounter then
      PRT.currentEncounter = {}
    end

    -- Hide overlay if necessary
    if PRT.db.profile.overlay.sender.hideAfterCombat then
      PRT.SenderOverlay.Hide()
    end
  end

  if PRT.db.profile.overlay.sender.enabled then
    PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, true)
  end

  -- Clear ReceiverFrame
  if PRT.db.profile.receiverMode then
    PRT.ReceiverOverlay.ClearMessageStack()
    PRT.ReceiverOverlay.UpdateFrameText()
    PRT.ReceiverOverlay.HideAll()
  end

  AceTimer:CancelAllTimers()
end


-------------------------------------------------------------------------------
-- Public API

function PRT.RegisterEvents(events)
  for _, event in ipairs(events) do
    PRT:RegisterEvent(event)
  end
end

function PRT.UnregisterEvents(events)
  for _, event in ipairs(events) do
    PRT:UnregisterEvent(event)
  end
end

function PRT.RegisterWorldEvents()
  PRT.RegisterEvents(EventHandler.worldEvents)
end

function PRT.UnrgisterWorldEvents()
  PRT.UnregisterEvents(EventHandler.worldEvents)
end

function PRT:ENCOUNTER_START(event, encounterID, encounterName)
  -- We only start a real encounter if PRT is enabled (correct dungeon/raid difficulty) and we're not in test mode
  if PRT.enabled and not self.db.profile.testMode then
    PRT.RegisterEvents(EventHandler.trackedInCombatEvents)
    EventHandler.StartEncounter(event, encounterID, encounterName)
  end
end

function PRT:PLAYER_REGEN_DISABLED(event)
  -- Initialize overlays
  PRT.SenderOverlay.Initialize(PRT.db.profile.overlay.sender)
  PRT.ReceiverOverlay.Initialize(PRT.db.profile.overlay.receiver)

  if self.db.profile.testMode then
    PRT.Debug("You are currently in test mode.")

    local _, encounter = PRT.FilterEncounterTable(self.db.profile.encounters, self.db.profile.testEncounterID)

    if encounter then
      if encounter.enabled then
        PRT.RegisterEvents(EventHandler.trackedInCombatEvents)
        EventHandler.StartEncounter(event, encounter.id, encounter.name)
      else
        PRT.Warn("The selected encounter is disabled. Please enable it before testing.")
      end
    else
      PRT.Warn("You are in test mode and have no encounter selected.")
    end
  end

  -- Always try to start receiver
  EventHandler.StartReceiveMessages()
end

function PRT:ENCOUNTER_END(event)
  EventHandler.StopEncounter(event)
  PRT.UnregisterEvents(EventHandler.trackedInCombatEvents)
end

function PRT:PLAYER_REGEN_ENABLED(event)
  if not PRT.PlayerInParty() or self.db.profile.testMode then
    EventHandler.StopEncounter(event)
    PRT.UnregisterEvents(EventHandler.trackedInCombatEvents)
  end
end

function PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
  if PRT.currentEncounter and PRT.db.profile.senderMode then
    local _, combatEvent, _, sourceGUID, sourceName, _, _, targetGUID, targetName, _, _, eventSpellID, _, _ = CombatLogGetCurrentEventInfo()

    if PRT.currentEncounter.inFight then
      if PRT.currentEncounter.encounter then
        if PRT.currentEncounter.interestingEvents[combatEvent] or PRT.currentEncounter.interestingEvents[event] then
          PRT.currentEncounter.statistics.CLEU = (PRT.currentEncounter.statistics.CLEU or 0) + 1
          local timers = PRT.currentEncounter.encounter.Timers
          local rotations = PRT.currentEncounter.encounter.Rotations
          local healthPercentages = PRT.currentEncounter.encounter.HealthPercentages
          local powerPercentages = PRT.currentEncounter.encounter.PowerPercentages

          -- Checking Timer activation
          if timers then
            PRT.CheckTimerStopConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
            PRT.CheckTimerStartConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
          end

          -- Checking Rotation activation
          if rotations then
            PRT.CheckTriggersStopConditions(rotations, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
            PRT.CheckTriggersStartConditions(rotations, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
            PRT.CheckRotationTriggerCondition(rotations, event, combatEvent, eventSpellID, targetGUID, targetName, sourceGUID, sourceName)
          end

          -- Checking Health Percentage activation
          if healthPercentages then
            PRT.CheckTriggersStartConditions(healthPercentages, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
            PRT.CheckTriggersStopConditions(healthPercentages, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
          end

          -- Checking Resource Percentage activation
          if powerPercentages then
            PRT.CheckTriggersStartConditions(powerPercentages, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
            PRT.CheckTriggersStopConditions(powerPercentages, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
          end
        end
      end
    end
  end
end

local function IsInterestingUnit(currentEncounter, unitID)
  local unitName = GetUnitName(unitID)
  local guid = UnitGUID(unitID)
  local mobID = PRT.GUIDToMobID(guid)

  return currentEncounter.interestingUnits and (currentEncounter.interestingUnits[unitID] or currentEncounter.interestingUnits[unitName] or currentEncounter.interestingUnits[mobID])
end

local function IsTrackedUnit(currentEncounter, guid)
  return currentEncounter.trackedUnits and currentEncounter.trackedUnits[guid]
end

function PRT:UNIT_POWER_UPDATE(_, unitID)
  if PRT.currentEncounter and PRT.db.profile.senderMode then
    if PRT.currentEncounter.inFight then
      if PRT.currentEncounter.encounter then
        local unitGUID = UnitGUID(unitID)
        if IsInterestingUnit(PRT.currentEncounter, unitID) and IsTrackedUnit(PRT.currentEncounter, unitGUID) then
          PRT.currentEncounter.statistics.UNIT_POWER_UPDATE = (PRT.currentEncounter.statistics.UNIT_POWER_UPDATE or 0) + 1
          local powerPercentages = PRT.currentEncounter.encounter.PowerPercentages

          if powerPercentages then
            PRT.CheckUnitPowerPercentages(powerPercentages)
          end
        end
      end
    end
  end
end

function PRT:UNIT_HEALTH(_, unitID)
  if PRT.currentEncounter and PRT.db.profile.senderMode then
    if PRT.currentEncounter.inFight then
      if PRT.currentEncounter.encounter then
        local unitGUID = UnitGUID(unitID)
        if IsInterestingUnit(PRT.currentEncounter, unitID) and IsTrackedUnit(PRT.currentEncounter, unitGUID) then
          PRT.currentEncounter.statistics.UNIT_HEALTH = (PRT.currentEncounter.statistics.UNIT_HEALTH or 0) + 1
          local healthPercentages = PRT.currentEncounter.encounter.HealthPercentages

          if healthPercentages then
            PRT.CheckUnitHealthPercentages(healthPercentages)
          end
        end
      end
    end
  end
end

local function EnsureTrackedUnit(guid)
  if PRT.currentEncounter then
    if PRT.currentEncounter.trackedUnits then
      if not PRT.currentEncounter.trackedUnits[guid] then
        PRT.currentEncounter.trackedUnits[guid] = {}
      end
    end
  end
end

local function UpdateTrackedUnit(unitID, name, guid)
  if PRT.currentEncounter.trackedUnits then
    EnsureTrackedUnit(guid)

    if unitID ~= PRT.currentEncounter.trackedUnits[guid].unitID then
      PRT.currentEncounter.trackedUnits[guid].unitID = unitID
      PRT.currentEncounter.trackedUnits[guid].guid = guid
      PRT.currentEncounter.trackedUnits[guid].name = name
    end
  end
end

local untrackedUnitIDs = {
  "target",
}

function PRT.AddUnitToTrackedUnits(unitID)
  if PRT.currentEncounter then
    if not tContains(untrackedUnitIDs, unitID) then
      local unitName = GetUnitName(unitID)
      local guid = UnitGUID(unitID)

      if IsInterestingUnit(PRT.currentEncounter, unitID) then
        if IsTrackedUnit(PRT.currentEncounter, guid) then
          if PRT.currentEncounter.trackedUnits[guid].unitID ~= unitID then
            -- PRT.Debug("Updating tracked unit ", PRT.HighlightString(unitName.." ("..unitID..")"))
            UpdateTrackedUnit(unitID, unitName, guid)
          end
        else
          PRT.Debug("Adding ", PRT.HighlightString(unitName.." ("..unitID..")"), "to tracked units.")
          UpdateTrackedUnit(unitID, unitName, guid)
        end
      end
    end
  end
end

function PRT:UNIT_COMBAT(_, unitID)
  PRT.AddUnitToTrackedUnits(unitID)
end

function PRT:PLAYER_ENTERING_WORLD(_)
  PRT.Debug("Currently active profile", PRT.HighlightString(PRT.db:GetCurrentProfile()))
  PRT.Debug("Zone entered.")
  PRT.Debug("Will check zone/difficulty in 5 seconds to determine if addon should be loaded.")

  AceTimer:ScheduleTimer(
    function()
      local name, type, difficultyID, _ = GetInstanceInfo()
      local difficultyNameEN = EventHandler.difficultyIDToNameMapping[difficultyID]
      PRT.currentDifficulty = difficultyNameEN

      if type == "party" then
        PRT.Debug("Player entered dungeon - checking difficulty")
        PRT.Debug("Current difficulty is", PRT.HighlightString(difficultyID or ""), "-", PRT.HighlightString(difficultyNameEN or ""))

        if self.db.profile.enabledDifficulties["dungeon"][difficultyNameEN] then
          PRT.Debug("Enabling PhenomRaidTools for", PRT.HighlightString(name), "on difficulty", PRT.HighlightString(difficultyNameEN))
          PRT.enabled = true
        else
          PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
          PRT.enabled = false
        end
      elseif type == "raid" then
        PRT.Debug("Player entered raid - checking difficulty")
        PRT.Debug("Current difficulty is", PRT.HighlightString(difficultyID), "-", PRT.HighlightString(difficultyNameEN))

        if self.db.profile.enabledDifficulties["raid"][difficultyNameEN] then
          PRT.Debug("Enabling PhenomRaidTools for", PRT.HighlightString(name), "on", PRT.HighlightString(difficultyNameEN), "difficulty")
          PRT.enabled = true
        else
          PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
          PRT.enabled = false
        end
      elseif type == "none" then
        PRT.Debug("Player is not in a raid nor in a dungeon. PhenomRaidTools disabled.")
      end
    end,
    5
  )
end
