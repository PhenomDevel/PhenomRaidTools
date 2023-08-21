local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local addon = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local AceTimer = LibStub("AceTimer-3.0")

local EventHandler = {
  worldEvents = {
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "ENCOUNTER_START",
    "ENCOUNTER_END",
    "PLAYER_ENTERING_WORLD"
  },
  retailWorldEvents = {
    "PLAYER_SPECIALIZATION_CHANGED"
  },
  trackedInCombatEvents = {
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_HEALTH",
    "UNIT_POWER_FREQUENT",
    "UNIT_COMBAT",
    "INSTANCE_ENCOUNTER_ENGAGE_UNIT"
  },
  difficultyIDToNameMapping = {
    [1] = "Normal", -- Normal Dungeon
    [14] = "Normal", -- Normal Raid
    [175] = "Normal", -- Normal Raid Wotlk 10man
    [176] = "Normal", -- Normal Raid Wotlk 25man
    [2] = "Heroic", -- Heroic Dungeon
    [5] = "Heroic", -- 10 Man Heroic
    [6] = "Heroic", -- 25 Man Heroic
    [15] = "Heroic", -- Heroic Raid
    [193] = "Heroic", -- Heroic Raid Wotlk 10man
    [194] = "Heroic", -- Heroic Raid Wotlk 25man
    [8] = "Mythic", -- Mythic Keystone Dungeon
    [23] = "Mythic", -- Mythic Dungeon
    [16] = "Mythic" -- Mythic Raid
  }
}

-- Create local copies of API functions which we use
local GetTime, CombatLogGetCurrentEventInfo, UnitGUID, GetInstanceInfo, GetZoneText = GetTime, CombatLogGetCurrentEventInfo, UnitGUID, GetInstanceInfo, GetZoneText

local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo

-------------------------------------------------------------------------------
-- Local Helper

function EventHandler.StartReceiveMessages()
  if PRT.GetProfileDB().enabled then
    if PRT.IsReceiver() then
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
      CompileInterestingUnitsByTriggerCondition(interestingUnits, trigger.stopCondition)
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
  if PRT.GetProfileDB().combatEventRecorder.options.resetOnEncounterStart then
    PRT.GetProfileDB().combatEventRecorder.data = {}
  end

  if PRT.IsEnabled() then
    wipe(PRT.GetProfileDB().debugLog)

    PRT.currentEncounter = NewEncounter()

    if PRT.IsSender() then
      PRT.Debug("Starting new encounter", PRT.HighlightString(encounterName), "(", PRT.HighlightString(encounterID), ")", "|r")
      local _, encounter = PRT.GetEncounterById(PRT.GetProfileDB().encounters, encounterID)
      local _, encounterVersion = PRT.GetSelectedVersionEncounterByID(PRT.GetProfileDB().encounters, encounterID)

      if encounter then
        if encounter.enabled then
          PRT.Debug(L["Running PhenomRaidTools version %s"]:format(PRT.HighlightString(PRT.GetProfileDB().version)))
          PRT.EnsureEncounterTrigger(encounterVersion)
          PRT.RegisterEvents(EventHandler.trackedInCombatEvents)
          PRT.currentEncounter.encounter = PRT.TableUtils.Clone(encounterVersion)
          PRT.currentEncounter.encounter.startedAt = GetTime()

          CompileInterestingUnits(PRT.currentEncounter)
          CompileInterestingEvents(PRT.currentEncounter)
          LogInterestingUnitsAndEvents(PRT.currentEncounter)

          PRT.SetupEncounterSpecificCustomPlaceholders()

          AceTimer:ScheduleRepeatingTimer(PRT.ProcessMessageQueue, 0.5)

          -- Make sure timings are once queried at the start so timing with < 0.5s will trigger
          AceTimer:ScheduleTimer(PRT.CheckTimerTimings, 0.1, PRT.currentEncounter.encounter.Timers)
          AceTimer:ScheduleRepeatingTimer(PRT.CheckTimerTimings, 0.5, PRT.currentEncounter.encounter.Timers)

          if PRT.IsReceiver() then
            PRT.ReceiverOverlay.ReInitialize(PRT.GetProfileDB().overlay.receivers)
          end

          if PRT.GetProfileDB().overlay.sender.enabled then
            AceTimer:ScheduleRepeatingTimer(PRT.SenderOverlay.UpdateFrame, 1, PRT.currentEncounter.encounter, PRT.GetProfileDB().overlay.sender)
            PRT.SenderOverlay.Show()
            PRT.SenderOverlay.Lock()
          end
        else
          PRT.Warn("Found encounter but it is disabled. Skipping encounter.")
        end
      end
    end

    addon:COMBAT_LOG_EVENT_UNFILTERED(event)

    -- Simulate encounter start events when in test mode
    if PRT.IsTestMode() then
      addon:COMBAT_LOG_EVENT_UNFILTERED("PLAYER_REGEN_DISABLED")
      addon:COMBAT_LOG_EVENT_UNFILTERED("ENCOUNTER_START")
    end
  else
    PRT.Debug(PRT.HighlightString("PhenomRaidTools"), "is disabled. We won't start encounter.")
  end
end

function EventHandler.StopEncounter(event)
  if PRT.IsSender() and PRT.currentEncounter then
    PRT.Debug("Combat stopped.")

    -- Send the last event before unregistering the event
    addon:COMBAT_LOG_EVENT_UNFILTERED(event)
    PRT.UnregisterEvents(EventHandler.trackedInCombatEvents)

    LogEncounterStatistics(PRT.currentEncounter)
    PRT.currentEncounter = {}
  end

  -- Hide overlay if necessary
  if PRT.GetProfileDB().overlay.sender.hideAfterCombat then
    PRT.SenderOverlay.Hide()
  end

  if PRT.GetProfileDB().overlay.sender.enabled then
    PRT.SenderOverlay.Unlock()
  end

  -- Clear ReceiverFrame
  if PRT.IsReceiver() then
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
    PRT.Debug("Registering event", PRT.HighlightString(event))
    addon:RegisterEvent(event)
  end
end

function PRT.UnregisterEvents(events)
  for _, event in ipairs(events) do
    PRT.Debug("Unregistering event", PRT.HighlightString(event))
    addon:UnregisterEvent(event)
  end
end

function PRT.RegisterWorldEvents()
  PRT.RegisterEvents(EventHandler.worldEvents)

  if PRT.IsRetail() then
    PRT.RegisterEvents(EventHandler.retailWorldEvents)
  end
end

function PRT.UnrgisterWorldEvents()
  PRT.UnregisterEvents(EventHandler.worldEvents)

  if PRT.IsRetail() then
    PRT.UnregisterEvents(EventHandler.retailWorldEvents)
  end
end

function addon:ENCOUNTER_START(event, encounterID, encounterName)
  -- We only start a real encounter if PRT is enabled (correct dungeon/raid difficulty) and we're not in test mode
  if PRT.enabled and not PRT.IsTestMode() then
    EventHandler.StartEncounter(event, encounterID, encounterName)
  end
end

function addon:PLAYER_REGEN_DISABLED(event)
  -- Initialize overlays
  PRT.SenderOverlay.Initialize(PRT.GetProfileDB().overlay.sender)
  PRT.ReceiverOverlay.Initialize(PRT.GetProfileDB().overlay.receiver)

  if PRT.IsTestMode() then
    PRT.Debug("You are currently in test mode.")

    local _, encounter = PRT.TableUtils.GetBy(PRT.GetProfileDB().encounters, "id", PRT.GetProfileDB().testEncounterID)

    if encounter then
      if encounter.enabled then
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

function addon:ENCOUNTER_END(event)
  EventHandler.StopEncounter(event)
end

function addon:PLAYER_REGEN_ENABLED(event)
  if not PRT.PlayerInParty() or PRT.IsTestMode() then
    EventHandler.StopEncounter(event)
  end
end

local function recordCombatEvent(...)
  local ts, combatEvent, _, _, sourceName, _, _, _, targetName, _, _, eventSpellID, _, _ = ...

  if tContains(PRT.GetProfileDB().combatEventRecorder.options.unitsToRecord, "RAID") then
    if not PRT.UnitInParty(sourceName) then
      return
    end
  elseif
    (not tContains(PRT.GetProfileDB().combatEventRecorder.options.unitsToRecord, sourceName)) and
      (not tContains(PRT.GetProfileDB().combatEventRecorder.options.unitsToRecord, "ALL"))
   then
    return
  end

  if
    (not tContains(PRT.GetProfileDB().combatEventRecorder.options.eventsToRecord, combatEvent)) and
      (not tContains(PRT.GetProfileDB().combatEventRecorder.options.eventsToRecord, "ALL"))
   then
    return
  end

  if PRT.GetProfileDB().combatEventRecorder.data and combatEvent and sourceName and eventSpellID then
    local entry = {
      ts = ts,
      event = combatEvent,
      spellID = eventSpellID,
      dateTime = PRT.Now(),
      sourceName = sourceName,
      targetName = targetName,
      zoneName = GetZoneText()
    }
    tinsert(PRT.GetProfileDB().combatEventRecorder.data, entry)
  end
end

function addon:COMBAT_LOG_EVENT_UNFILTERED(event)
  if PRT.GetProfileDB().combatEventRecorder.options.enabled then
    recordCombatEvent(CombatLogGetCurrentEventInfo())
  end

  if PRT.currentEncounter and PRT.IsSender() then
    local _, combatEvent, _, sourceGUID, sourceName, _, _, targetGUID, targetName, _, _, eventSpellID, _, _ = CombatLogGetCurrentEventInfo()

    if PRT.currentEncounter.inFight then
      if PRT.currentEncounter.encounter then
        if PRT.currentEncounter.interestingEvents[combatEvent] or PRT.currentEncounter.interestingEvents[event] then
          PRT.currentEncounter.statistics[combatEvent or event] = (PRT.currentEncounter.statistics[combatEvent or event] or 0) + 1

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
  local npcID = PRT.GUIDToNPCID(guid)

  return currentEncounter.interestingUnits and
    (currentEncounter.interestingUnits[unitID] or currentEncounter.interestingUnits[unitName] or currentEncounter.interestingUnits[npcID])
end

local function IsTrackedUnit(currentEncounter, guid)
  return currentEncounter.trackedUnits and currentEncounter.trackedUnits[guid]
end

function addon:UNIT_POWER_FREQUENT(event, unitID)
  if PRT.currentEncounter and PRT.IsSender() then
    if PRT.currentEncounter.inFight then
      if PRT.currentEncounter.encounter then
        local unitGUID = UnitGUID(unitID)
        if IsInterestingUnit(PRT.currentEncounter, unitID) and IsTrackedUnit(PRT.currentEncounter, unitGUID) then
          PRT.currentEncounter.statistics[event] = (PRT.currentEncounter.statistics[event] or 0) + 1
          local powerPercentages = PRT.currentEncounter.encounter.PowerPercentages

          if powerPercentages then
            PRT.CheckUnitPowerPercentages(powerPercentages)
          end
        end
      end
    end
  end
end

function addon:UNIT_HEALTH(event, unitID)
  if PRT.currentEncounter and PRT.IsSender() then
    if PRT.currentEncounter.inFight then
      if PRT.currentEncounter.encounter then
        local unitGUID = UnitGUID(unitID)
        if IsInterestingUnit(PRT.currentEncounter, unitID) and IsTrackedUnit(PRT.currentEncounter, unitGUID) then
          PRT.currentEncounter.statistics[event] = (PRT.currentEncounter.statistics[event] or 0) + 1
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
  "target"
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
          PRT.Debug("Adding ", PRT.HighlightString(unitName .. " (" .. unitID .. ")"), "to tracked units.")
          UpdateTrackedUnit(unitID, unitName, guid)
        end
      end
    end
  end
end

function addon:UNIT_COMBAT(_, unitID)
  PRT.AddUnitToTrackedUnits(unitID)
end

function addon:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
  for i = 1, 5 do
    local unitID = "boss" .. i

    if IsInterestingUnit(PRT.currentEncounter, unitID) then
      if UnitExists(unitID) then
        PRT.AddUnitToTrackedUnits(unitID)
      end
    end
  end
end

local function SetProfileBySpec()
  if PRT.GetCharDB().profileSettings.specSpecificProfiles.enabled then
    local specIndex = GetSpecialization()
    local profile = PRT.GetCharDB().profileSettings.specSpecificProfiles.profileBySpec[specIndex]
    local specName = select(2, GetSpecializationInfo(specIndex))

    if profile then
      PRT.SetProfile(profile)
      PRT.Info(string.format("Specialization (%s) specific profile %s was loaded.", PRT.HighlightString(specName), PRT.HighlightString(profile)))
    else
      PRT.Info(string.format("Spec specific profiles are enabled, but you haven't selected any profile for spec %s yet.", PRT.HighlightString(specName)))
    end
  end
end

function addon:PLAYER_ENTERING_WORLD(_)
  SetProfileBySpec()
  PRT.Debug("Currently loaded profile", PRT.HighlightString(PRT.GetCurrentProfile()))
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

        if PRT.GetProfileDB().enabledDifficulties["dungeon"][difficultyNameEN] then
          PRT.Debug("Enabling PhenomRaidTools for", PRT.HighlightString(name), "on difficulty", PRT.HighlightString(difficultyNameEN))
          PRT.enabled = true
        else
          PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
          PRT.enabled = false
        end
      elseif type == "raid" then
        PRT.Debug("Player entered raid - checking difficulty")
        PRT.Debug("Current difficulty is", PRT.HighlightString(difficultyID), "-", PRT.HighlightString(difficultyNameEN))

        if PRT.GetProfileDB().enabledDifficulties["raid"][difficultyNameEN] then
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

if PRT.IsRetail() then
  function addon:PLAYER_SPECIALIZATION_CHANGED()
    SetProfileBySpec()
  end
end
