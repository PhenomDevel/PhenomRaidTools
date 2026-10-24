local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local addon = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local EventHandler = {
  worldEvents = {
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "ENCOUNTER_START",
    "ENCOUNTER_END",
    "PLAYER_ENTERING_WORLD",
    "READY_CHECK"
  },
  retailWorldEvents = {
    "PLAYER_SPECIALIZATION_CHANGED"
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
    [16] = "Mythic", -- Mythic Raid
    [3] = "Normal", -- 10 Player (legacy)
    [4] = "Normal", -- 25 Player (legacy)
    [9] = "Normal", -- 40 Player (legacy)
    [148] = "Normal", -- 20 Player (legacy)
    [173] = "Normal", -- Normal Dungeon (legacy)
    [174] = "Heroic" -- Heroic Dungeon (legacy)
  }
}

-- Create local copies of API functions which we use
local GetTime, GetInstanceInfo = GetTime, GetInstanceInfo

-------------------------------------------------------------------------------
-- Local Helper

local function NewEncounter()
  return {
    inFight = true,
    encounter = {}
  }
end

-- The plan to run: the own one in sender and test mode, otherwise the one
-- received from the raid lead (PlanSync). Returns plan, received.
function EventHandler.GetPlan(encounterID)
  if PRT.IsSender() or PRT.IsTestMode() then
    local _, encounter = PRT.GetEncounterById(PRT.GetProfileDB().encounters, encounterID)
    if encounter and not encounter.enabled then
      PRT.Warn("Found encounter but it is disabled. Skipping encounter.")
      return
    end
    local _, encounterVersion = PRT.GetSelectedVersionEncounterByID(PRT.GetProfileDB().encounters, encounterID)
    if encounterVersion then
      return encounterVersion, false
    end
  end

  if PRT.IsReceiver() then
    local received = PRT.PlanSync.GetReceivedPlan(encounterID)
    if received then
      PRT.Debug("Running plan received from", PRT.ClassColoredName(received.sender))
      return received.plan, true
    end
  end
end

-- Timings are checked ten times a second: often enough for fractional times,
-- cheap because a check only compares numbers.
local TIMING_INTERVAL = 0.1

function EventHandler.StartEncounter(event, encounterID, encounterName)
  if PRT.IsEnabled() then
    wipe(PRT.GetProfileDB().debugLog)
    -- A start without an end before (e.g. test mode, a reload in combat).
    PRT.EncounterTimer:CancelAllTimers()

    PRT.currentEncounter = NewEncounter()

    PRT.Debug("Starting new encounter", PRT.HighlightString(encounterName), "(", PRT.HighlightString(encounterID), ")", "|r")
    local plan, received = EventHandler.GetPlan(encounterID)

    if plan then
      PRT.Debug(L["Running PhenomRaidTools version %s"]:format(PRT.HighlightString(PRT.GetProfileDB().version)))
      PRT.currentEncounter.running = true
      PRT.currentEncounter.received = received
      PRT.currentEncounter.encounter = PRT.TableUtils.Clone(plan)
      PRT.EnsureEncounterTrigger(PRT.currentEncounter.encounter)
      PRT.currentEncounter.encounter.startedAt = GetTime()

      PRT.SetupEncounterSpecificCustomPlaceholders()

      PRT.EncounterTimer:ScheduleRepeatingTimer(PRT.CheckTimerTimings, TIMING_INTERVAL, PRT.currentEncounter.encounter.Timers)

      if not received and PRT.GetProfileDB().overlay.sender.enabled then
        PRT.SenderOverlay.Start(PRT.currentEncounter.encounter)
      end
    end

    -- Pull and combat start are the same moment here: combat starts before
    -- ENCOUNTER_START, and test mode starts on combat without an encounter.
    EventHandler.DispatchEvent(event)
    EventHandler.DispatchEvent(event == "ENCOUNTER_START" and "PLAYER_REGEN_DISABLED" or "ENCOUNTER_START")

    PRT.CheckTimerTimings(PRT.currentEncounter.encounter.Timers)
    if PRT.currentEncounter.running and PRT.IsReceiver() then
      PRT.Upcoming.Start(PRT.currentEncounter.encounter)
    end
  else
    PRT.Debug(PRT.HighlightString("PhenomRaidTools"), "is disabled. We won't start encounter.")
  end
end

function EventHandler.StopEncounter(event)
  if PRT.currentEncounter and PRT.currentEncounter.running then
    PRT.Debug("Combat stopped.")

    EventHandler.DispatchEvent(event)
    PRT.currentEncounter = {}
  end

  PRT.EncounterTimer:CancelAllTimers()
  PRT.SenderOverlay.Stop()
  PRT.Upcoming.Stop()
  PRT.ReceiverOverlay.Clear()
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

function PRT.UnregisterWorldEvents()
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
end

function addon:READY_CHECK()
  PRT.PlanSync.OnReadyCheck()
end

function addon:ENCOUNTER_END(event)
  EventHandler.StopEncounter(event)
end

function addon:PLAYER_REGEN_ENABLED(event)
  if not PRT.PlayerInParty() or PRT.IsTestMode() then
    EventHandler.StopEncounter(event)
  end
end

-- Feeds encounter events (ENCOUNTER_START/END, combat start/stop) into the
-- trigger conditions. Nothing else reaches addons during encounters since 12.0.
function EventHandler.DispatchEvent(event)
  local currentEncounter = PRT.currentEncounter
  if not (currentEncounter and currentEncounter.running and currentEncounter.inFight and currentEncounter.encounter) then
    return
  end

  local encounter = currentEncounter.encounter
  if encounter.Timers then
    PRT.CheckTimerStopConditions(encounter.Timers, event)
    PRT.CheckTimerStartConditions(encounter.Timers, event)
  end
  if encounter.Rotations then
    PRT.CheckTriggersStopConditions(encounter.Rotations, event)
    PRT.CheckTriggersStartConditions(encounter.Rotations, event)
    PRT.CheckRotationTriggerCondition(encounter.Rotations, event)
  end
end

local function SetProfileBySpec()
  if PRT.GetCharDB().profileSettings.specSpecificProfiles.enabled and PRT.HasSpecializations() then
    local specIndex = PRT.GetSpecialization()
    if not specIndex then
      return
    end

    local profile = PRT.GetCharDB().profileSettings.specSpecificProfiles.profileBySpec[specIndex]
    local specName = select(2, PRT.GetSpecializationInfo(specIndex))

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

  PRT.Timer:ScheduleTimer(
    function()
      local name, type, difficultyID, _ = GetInstanceInfo()
      local difficultyNameEN = EventHandler.difficultyIDToNameMapping[difficultyID]

      if not difficultyNameEN and (type == "party" or type == "raid") then
        PRT.Debug("Unknown difficulty", PRT.HighlightString(difficultyID), "- treating it as Normal")
        difficultyNameEN = "Normal"
      end
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
