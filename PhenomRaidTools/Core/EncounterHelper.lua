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
    end
  end
  for _, template in pairs(profile.templateStore and profile.templateStore.messages or {}) do
    fn(template)
  end
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
    startCondition = {event = "ENCOUNTER_START"},
    name = "Pull",
    timings = {}
  }
end

-------------------------------------------------------------------------------
-- Encounter

-- Messages that act for the group (raid warnings, raid markers) can't run
-- during encounters since Midnight.
local REMOVED_MESSAGE_TYPES = {raidwarning = true, raidtarget = true}

function PRT.IsMessageSupported(message)
  return not REMOVED_MESSAGE_TYPES[message.type]
end

function PRT.SpellName(spellID)
  local info = spellID and C_Spell.GetSpellInfo(tonumber(spellID) or spellID)
  return info and info.name
end

-- Text of a cooldown message: its icon and its custom text, or else the spell's name.
function PRT.CooldownMessageText(message)
  local label = message.cooldownText
  if not label or strtrim(label) == "" then
    label = PRT.SpellName(message.spellID) or ""
  end
  local text = ("{spell:%s} %s"):format(message.spellID or "", label)
  if message.withCountdown then
    text = text .. " %.0f"
  end
  return strtrim(text)
end

-- One message per timing (none: dropped), with its delay and the timing's offset folded into
-- the times: a timing is one assignment in the editor.
local function SplitTimings(timer)
  local timings = {}
  for _, timing in ipairs(timer.timings or {}) do
    local messages = timing.messages or {}
    if #messages == 1 and (timing.offset or 0) == 0 and (messages[1].delay or 0) == 0 then
      timings[#timings + 1] = timing
    else
      for _, message in ipairs(messages) do
        local seconds = {}
        for index, second in ipairs(timing.seconds or {}) do
          seconds[index] = math.max(0, second + (timing.offset or 0) + (message.delay or 0))
        end
        message.delay = 0
        timings[#timings + 1] = {seconds = seconds, name = timing.name, messages = {message}}
      end
    end
  end
  timer.timings = timings
end

local ALL_DIFFICULTIES = {"Normal", "Heroic", "Mythic"}

-- The difficulties of a timer as an assignment's: nil for all, {} when off.
local function TimerDifficulties(timer)
  if timer.enabled == false then
    return {}
  end
  local enabled = timer.enabledDifficulties
  if not enabled then
    return nil
  end
  local difficulties, all = {}, true
  for _, difficulty in ipairs(ALL_DIFFICULTIES) do
    difficulties[difficulty] = enabled[difficulty] or nil
    all = all and enabled[difficulty] == true
  end
  return not all and difficulties or nil
end

-- Groups are gone: one timer holds every assignment, each with the
-- difficulties its group had.
local function MergeTimers(timers)
  local merged = {enabled = true, name = "Pull", startCondition = {event = "ENCOUNTER_START"}, timings = {}}
  for _, timer in ipairs(timers) do
    local difficulties = TimerDifficulties(timer)
    for _, timing in ipairs(timer.timings or {}) do
      if difficulties and timing.difficulties == nil then
        timing.difficulties = PRT.TableUtils.Clone(difficulties)
      end
      merged.timings[#merged.timings + 1] = timing
    end
  end
  return {merged}
end

-- Strips what can't run since Midnight from an encounter version (also
-- imports from older versions): rotations, health/power percentages, timers
-- on combat log events, stop conditions, encounter placeholders, raid
-- warnings and markers. Returns the number of removed triggers.
function PRT.CleanEncounterVersion(version)
  local removed = #(version.Rotations or {}) + #(version.HealthPercentages or {}) + #(version.PowerPercentages or {})
  version.Rotations, version.HealthPercentages, version.PowerPercentages = nil, nil, nil
  version.CustomPlaceholders, version.RaidRoster = nil, nil
  local timers = {}
  for _, timer in ipairs(version.Timers or {}) do
    if PRT.IsTimerSupported(timer) then
      timer.startCondition = {event = "ENCOUNTER_START"}
      timer.stopCondition, timer.hasStopCondition = nil, nil
      timer.occurence, timer.triggerAtOccurence, timer.resetOccurenceOnStop, timer.resetCounterOnStop = nil, nil, nil, nil
      for _, timing in ipairs(timer.timings or {}) do
        local messages = {}
        for _, message in ipairs(timing.messages or {}) do
          if PRT.IsMessageSupported(message) then
            messages[#messages + 1] = message
          end
        end
        timing.messages = messages
      end
      SplitTimings(timer)
      timers[#timers + 1] = timer
    else
      removed = removed + 1
    end
  end
  version.Timers = MergeTimers(timers)
  return removed
end

function PRT.EmptyEncounterVersion(encounterId, encounterName)
  return {
    id = encounterId,
    enabled = true,
    name = encounterName .. " Version 1",
    createdAt = PRT.Now(),
    Timers = {}
  }
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
            enabledDifficulties = {Normal = true, Heroic = true, Mythic = true},
            timings = {
              Message("Message 1 and 7 seconds after the pull", {1, 7}, {"ALL"}),
              Message("Message with raid marker {rt1}, ends in %.0f", {3}, {"$me"}),
              Message("{spell:31821} for the healers", {12}, {"HEALER"})
            }
          }
        },
      }
    }
  }
end
