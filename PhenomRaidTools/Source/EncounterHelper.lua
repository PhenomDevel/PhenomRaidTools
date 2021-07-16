local _, PRT = ...

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

function PRT.ExampleEncounter()
  return {
    enabled = true,
    id = 9999,
    name = "Example",
    selectedVersion = 1,
    versions = {
      {
        enabled = true,
        name = "Example Version 1",
        Timers = {
          {
            enabled = true,
            startCondition = {
              event = "PLAYER_REGEN_DISABLED",
              spellID = nil,
              source = nil,
              target = nil
            },
            stopCondition = {
              event = nil,
              spellID = nil,
              source = nil,
              target = nil
            },
            name = "Phase 1 Timer",
            timings = {
              {
                seconds = {1, 7},
                messages = {
                  {
                    message = "Message 1 and 7 seconds into Encounter",
                    duration = 5,
                    targets = {
                      "ALL"
                    },
                    delay = 0
                  }
                }
              },
              {
                seconds = {5},
                messages = {
                  {
                    message = "Message with raid marker {rt1}",
                    duration = 5,
                    targets = {
                      "ALL"
                    },
                    delay = 0
                  }
                }
              }
            }
          }
        },
        Rotations = {
          {
            enabled = true,
            triggerCondition = {
              event = "SPELL_CAST_START",
              spellID = 188196,
              spellIcon = 136048,
              spellName = "Lightning Bolt",
              source = nil,
              target = nil
            },
            name = "Lightning Bolt Cast started",
            entries = {
              {
                messages = {
                  {
                    message = "You cast {spell:188196}",
                    duration = 5,
                    targets = {
                      "ALL"
                    },
                    delay = 0
                  }
                }
              }
            },
            shouldRestart = true,
            ignoreAfterActivation = false,
            ignoreDuration = 0
          },
          {
            enabled = false,
            triggerCondition = {
              event = "SPELL_CAST_SUCCESS",
              source = nil,
              target = nil
            },
            name = "Disabled Rotation",
            entries = {
              {
                messages = {}
              }
            },
            shouldRestart = true,
            ignoreAfterActivation = false,
            ignoreDuration = 0
          }
        },
        HealthPercentages = {
          {
            enabled = true,
            name = "Above 60 %",
            unitID = "player",
            values = {
              {
                value = 60,
                operator = "greater",
                messages = {
                  {
                    message = "You are above 60%% HP",
                    duration = 5,
                    targets = {
                      "ALL"
                    },
                    delay = 0
                  }
                }
              }
            },
            ignoreAfterActivation = false,
            ignoreDuration = nil
          }
        },
        PowerPercentages = {
          {
            enabled = true,
            name = "Above 90% Power",
            unitID = "player",
            values = {
              {
                value = 90,
                operator = "greater",
                messages = {
                  {
                    message = "You are above 90%% Power",
                    duration = 5,
                    targets = {
                      "ALL"
                    },
                    delay = 0
                  }
                }
              }
            },
            ignoreAfterActivation = false,
            ignoreDuration = nil
          }
        },
        CustomPlaceholders = {}
      }
    }
  }
end
