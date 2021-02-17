local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local EventHandler = {
  essentialEvents = {
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "ENCOUNTER_START",
    "ENCOUNTER_END",
    "PLAYER_ENTERING_WORLD",

  },

  combatEvents = {
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
local GetTime, CombatLogGetCurrentEventInfo, UnitGUID, UnitIsPlayer, GetInstanceInfo =
  GetTime, CombatLogGetCurrentEventInfo, UnitGUID, UnitIsPlayer, GetInstanceInfo


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
    encounter = {}
  }
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

          PRT.currentEncounter.encounter = PRT.TableUtils.CopyTable(encounter)
          PRT.currentEncounter.encounter.startedAt = GetTime()

          if PRT.db.profile.overlay.sender.enabled then
            PRT.SenderOverlay.Show()
            PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, false)
            AceTimer:ScheduleRepeatingTimer(PRT.SenderOverlay.UpdateFrame, 1, PRT.currentEncounter.encounter, PRT.db.profile.overlay.sender)
          end
        else
          PRT.Warn("Found encounter but it is disabled. Skipping encounter.")
        end
      end
    end

    PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
  else
    PRT.Debug(PRT.HighlightString("PhenomRaidTools"), "is disabled. We won't start encounter.")
  end
end

function EventHandler.StopEncounter(event)
  PRT.Debug("Combat stopped.")
  if PRT.db.profile.senderMode then
    -- Send the last event before unregistering the event
    PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
    PRT:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

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

function PRT.RegisterEssentialEvents()
  PRT.RegisterEvents(EventHandler.essentialEvents)
end

function PRT.UnregisterEssentialEvents()
  PRT.UnregisterEvents(EventHandler.essentialEvents)
end

function PRT:ENCOUNTER_START(event, encounterID, encounterName)
  -- We only start a real encounter if PRT is enabled (correct dungeon/raid difficulty) and we're not in test mode
  if PRT.enabled and not self.db.profile.testMode then
    PRT.RegisterEvents(EventHandler.combatEvents)
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
        PRT.RegisterEvents(EventHandler.combatEvents)
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
  PRT.UnregisterEvents(EventHandler.combatEvents)
end

function PRT:PLAYER_REGEN_ENABLED(event)
  if not PRT.PlayerInParty() or self.db.profile.testMode then
    EventHandler.StopEncounter(event)
    PRT.UnregisterEvents(EventHandler.combatEvents)
  end
end

function PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
  if PRT.currentEncounter and PRT.db.profile.senderMode then
    local _, combatEvent, _, sourceGUID, sourceName, _, _, targetGUID, targetName, _, _, eventSpellID, _, _ = CombatLogGetCurrentEventInfo()

    if PRT.currentEncounter.inFight then
      if PRT.currentEncounter.encounter then
        local timers = PRT.currentEncounter.encounter.Timers
        local rotations = PRT.currentEncounter.encounter.Rotations
        local healthPercentages = PRT.currentEncounter.encounter.HealthPercentages
        local powerPercentages = PRT.currentEncounter.encounter.PowerPercentages

        -- Checking Timer activation
        if timers then
          PRT.CheckTimerStopConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
          PRT.CheckTimerStartConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
          PRT.CheckTimerTimings(timers)
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
          PRT.CheckUnitHealthPercentages(healthPercentages)
        end

        -- Checking Resource Percentage activation
        if powerPercentages then
          PRT.CheckTriggersStartConditions(powerPercentages, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
          PRT.CheckTriggersStopConditions(powerPercentages, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
          PRT.CheckUnitPowerPercentages(powerPercentages)
        end

        -- Process Message Queue after activations
        if timers or rotations or healthPercentages or powerPercentages then
          PRT.ProcessMessageQueue()
        end
      end
    end
  end
end

local function EnsureTrackedUnit(guid)
  if PRT.currentEncounter then
    if not PRT.currentEncounter.trackedUnits then
      PRT.currentEncounter.trackedUnits = {}
    end
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

    PRT.currentEncounter.trackedUnits[guid].unitID = unitID
    PRT.currentEncounter.trackedUnits[guid].guid = guid
    PRT.currentEncounter.trackedUnits[guid].name = name
    PRT.currentEncounter.trackedUnits[guid].lastChecked = GetTime()
  end
end

function PRT.AddUnitToTrackedUnits(unitID)
  local unitName = GetUnitName(unitID)
  local guid = UnitGUID(unitID)

  if PRT.currentEncounter then
    if not PRT.UnitInParty(unitID) and not UnitIsPlayer(unitID) then
      if PRT.currentEncounter.trackedUnits then
        if PRT.currentEncounter.trackedUnits[guid] then
          if PRT.currentEncounter.trackedUnits[guid].unitID ~= unitID then
            -- PRT.Debug("Updating tracked unit "..PRT.HighlightString(unitName.." ("..unitID..")"))
            UpdateTrackedUnit(unitID, unitName, guid)
          end
        else
          PRT.Debug("Adding "..PRT.HighlightString(unitName.." ("..unitID..")"), "to tracked units.")
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
