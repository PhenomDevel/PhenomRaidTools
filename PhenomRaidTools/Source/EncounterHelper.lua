local _, PRT = ...

-------------------------------------------------------------------------------
-- Messages

-- Targets as a list; cooldown messages of older versions stored them as
-- { [name] = name }.
function PRT.NormalizeTargets(message)
  local targets = message.targets
  if type(targets) ~= "table" then
    message.targets = {}
    return
  end
  if #targets == PRT.TableUtils.Count(targets) then
    return
  end
  local list = {}
  for _, target in pairs(targets) do
    if type(target) == "string" and target ~= "" and not tContains(list, target) then
      list[#list + 1] = target
    end
  end
  table.sort(list)
  message.targets = list
end

local function EachMessage(messages, fn)
  for _, message in ipairs(messages or {}) do
    fn(message)
  end
end

-- Calls fn(message) for every message of a profile: all encounter versions and
-- the message templates.
function PRT.ForEachMessage(profile, fn)
  for _, encounter in ipairs(profile.encounters or {}) do
    for _, version in ipairs(encounter.versions or {}) do
      for _, timer in ipairs(version.Timers or {}) do
        for _, timing in ipairs(timer.timings or {}) do
          EachMessage(timing.messages, fn)
        end
      end
      for _, rotation in ipairs(version.Rotations or {}) do
        for _, entry in ipairs(rotation.entries or {}) do
          EachMessage(entry.messages, fn)
        end
      end
      for _, percentages in ipairs({version.HealthPercentages or {}, version.PowerPercentages or {}}) do
        for _, percentage in ipairs(percentages) do
          for _, value in ipairs(percentage.values or {}) do
            EachMessage(value.messages, fn)
          end
        end
      end
    end
  end
  for _, template in pairs(profile.templateStore and profile.templateStore.messages or {}) do
    fn(template)
  end
end

-------------------------------------------------------------------------------
-- Condition

function PRT.EmptyCondition()
  return {
    event = PRT.GetProfileDB().triggerDefaults.conditionDefaults.defaultEvent,
    spellID = nil,
    source = nil,
    target = nil
  }
end

-------------------------------------------------------------------------------
-- Message

function PRT.EmptyMessage()
  local message = {
    message = PRT.GetProfileDB().triggerDefaults.messageDefaults.defaultMessage or "TODO",
    useCustomSound = false,
    duration = PRT.GetProfileDB().triggerDefaults.messageDefaults.defaultDuration or 5,
    targets = PRT.TableUtils.Clone(PRT.GetProfileDB().triggerDefaults.messageDefaults.defaultTargets) or {"ALL"},
    targetOverlay = PRT.GetProfileDB().triggerDefaults.messageDefaults.defaultTargetOverlay or 1,
    delay = 0,
    type = PRT.GetProfileDB().triggerDefaults.messageDefaults.defaultMessageType or "cooldown",
    withCountdown = true
  }

  if message.type == "cooldown" then
    message.targets = {}
  end

  return message
end

-------------------------------------------------------------------------------
-- Timer

function PRT.EmptyTiming()
  return {
    seconds = {1},
    offset = 0,
    name = nil,
    messages = {
      PRT.EmptyMessage()
    }
  }
end

function PRT.EmptyTimer()
  return {
    enabled = true,
    startCondition = PRT.EmptyCondition(),
    stopCondition = {},
    hasStopCondition = false,
    occurence = 0,
    triggerAtOccurence = 1,
    resetOccurenceOnStop = false,
    name = "Timer Name" .. PRT.RandomNumber(),
    enabledDifficulties = {
      Normal = true,
      Heroic = true,
      Mythic = true
    },
    description = "",
    timings = {
      PRT.EmptyTiming()
    }
  }
end

-------------------------------------------------------------------------------
-- Rotation

function PRT.EmptyRotationEntry()
  return {
    messages = {
      PRT.EmptyMessage()
    }
  }
end

function PRT.EmptyRotation()
  return {
    enabled = true,
    triggerCondition = PRT.EmptyCondition(),
    name = "Rotation Name" .. PRT.RandomNumber(),
    counter = 0,
    occurence = 0,
    triggerAtOccurence = 1,
    entries = {
      PRT.EmptyRotationEntry()
    },
    enabledDifficulties = {
      Normal = true,
      Heroic = true,
      Mythic = true
    },
    description = "",
    shouldRestart = PRT.GetProfileDB().triggerDefaults.rotationDefaults.defaultShouldRestart,
    ignoreAfterActivation = PRT.GetProfileDB().triggerDefaults.rotationDefaults.defaultIgnoreAfterActivation,
    ignoreDuration = PRT.GetProfileDB().triggerDefaults.rotationDefaults.defaultIgnoreDuration
  }
end

-------------------------------------------------------------------------------
-- Percentage

function PRT.EmptyPercentageEntry()
  return {
    value = 50,
    operator = "equals",
    messages = {
      PRT.EmptyMessage()
    }
  }
end

function PRT.EmptyPercentage()
  return {
    enabled = true,
    name = "Percentage Name" .. PRT.RandomNumber(),
    unitID = PRT.GetProfileDB().triggerDefaults.percentageDefaults.defaultUnitID,
    values = {
      PRT.EmptyPercentageEntry()
    },
    enabledDifficulties = {
      Normal = true,
      Heroic = true,
      Mythic = true
    },
    description = "",
    checkAgain = PRT.GetProfileDB().triggerDefaults.percentageDefaults.defaultCheckAgain,
    checkAgainAfter = PRT.GetProfileDB().triggerDefaults.percentageDefaults.defaultCheckAgainAfter
  }
end

-------------------------------------------------------------------------------
-- Encounter

function PRT.EmptyEncounterVersion(encounterId, encounterName)
  return {
    id = encounterId,
    enabled = true,
    name = encounterName .. " Version 1",
    createdAt = PRT.Now(),
    Timers = {},
    Rotations = {},
    HealthPercentages = {},
    PowerPercentages = {},
    CustomPlaceholders = {}
  }
end

function PRT.NewEncounterVersion(encounter)
  local encounterVersion = PRT.EmptyEncounterVersion(encounter.id, "")
  encounterVersion.name = encounter.name .. " Version " .. (PRT.TableUtils.Count(encounter.versions) + 1)
  encounterVersion.enabled = true

  return encounterVersion
end

function PRT.EmptyEncounter()
  local name = "Encounter Name" .. PRT.RandomNumber()
  local id = PRT.RandomNumber()

  return {
    enabled = true,
    id = id,
    name = name,
    selectedVersion = 1,
    versions = {
      [1] = PRT.EmptyEncounterVersion(id, name)
    }
  }
end

-- Only what still works since Midnight: a timer from the pull.
function PRT.ExampleEncounter()
  local function Message(text, seconds, targets)
    return {
      seconds = seconds,
      messages = {
        {
          type = "advanced",
          message = text,
          duration = 5,
          targets = targets,
          targetOverlay = 1,
          delay = 0
        }
      }
    }
  end

  return {
    enabled = true,
    id = 9999,
    name = "Example",
    selectedVersion = 1,
    versions = {
      {
        enabled = true,
        name = "Example Version 1",
        createdAt = PRT.Now(),
        Timers = {
          {
            enabled = true,
            name = "Pull",
            startCondition = {event = "ENCOUNTER_START"},
            stopCondition = {},
            hasStopCondition = false,
            triggerAtOccurence = 1,
            enabledDifficulties = {Normal = true, Heroic = true, Mythic = true},
            timings = {
              Message("Message 1 and 7 seconds after the pull", {1, 7}, {"ALL"}),
              Message("Message with raid marker {rt1}, ends in %.0f", {3}, {"$me"}),
              Message("{spell:31821} for the healers", {12}, {"HEALER"})
            }
          }
        },
        Rotations = {},
        HealthPercentages = {},
        PowerPercentages = {},
        CustomPlaceholders = {}
      }
    }
  }
end
