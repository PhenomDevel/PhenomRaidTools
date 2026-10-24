-- luacheck: read globals EJ_GetCurrentTier EJ_SelectTier EJ_GetInstanceByIndex EJ_SelectInstance EJ_GetEncounterInfoByIndex
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI
local Widgets = PRT.Widgets
local colors = Widgets.colors
local Messages = UI.Messages

--[[
  Encounters and their plans. Levels (UI.Navigate("encounters", ...)):

    {}                                    all encounters
    { id }                                one encounter: settings, version,
                                          timeline, timers, rotations, ...
    { id, "timer:3" }                     timer 3 of the selected version
    { id, "timer:3", timing }             one timing: times and messages
    { id, "timer:3", timing, message }    the assignment editor
    { id, "rotation:2", entry, message }  same for rotations
    { id, "placeholder:Name" }            an encounter placeholder

  Triggers that can't fire since Midnight (combat log, boss health/power)
  are not edited here: they are listed once per encounter and can be
  removed.
]]

local START_EVENTS = {
  {value = "ENCOUNTER_START", label = L["Pull"]},
  {value = "PLAYER_REGEN_DISABLED", label = L["Combat start"]}
}

local TRIGGER_EVENTS = {
  {value = "ENCOUNTER_START", label = L["Pull"]},
  {value = "PLAYER_REGEN_DISABLED", label = L["Combat start"]},
  {value = "ENCOUNTER_END", label = L["Encounter end"]},
  {value = "PLAYER_REGEN_ENABLED", label = L["Combat end"]}
}

local DIFFICULTIES = {
  {value = "Normal", label = L["Normal"]},
  {value = "Heroic", label = L["Heroic"]},
  {value = "Mythic", label = L["Mythic"]}
}

local TRIGGER_TYPE_LABELS = {
  timer = L["Timer"],
  rotation = L["Rotation"],
  healthPercentage = L["Health percentage"],
  powerPercentage = L["Power percentage"]
}

local TRIGGER_TABLES = {
  timer = "Timers",
  rotation = "Rotations",
  healthPercentage = "HealthPercentages",
  powerPercentage = "PowerPercentages"
}

local REASONS = {
  combatLog = L["needs the combat log"],
  unitValues = L["needs boss health or power"]
}

-------------------------------------------------------------------------------
-- Data

local function Encounters()
  return PRT.GetProfileDB().encounters
end

local function FindEncounter(id)
  for index, encounter in ipairs(Encounters()) do
    if encounter.id == id then
      return encounter, index
    end
  end
end

-- The selected version; repairs encounters without one.
local function Version(encounter)
  encounter.versions = encounter.versions or {}
  if #encounter.versions == 0 then
    encounter.versions[1] = PRT.EmptyEncounterVersion(encounter.id, encounter.name)
  end
  if not encounter.versions[encounter.selectedVersion or 0] then
    encounter.selectedVersion = 1
  end
  local version = encounter.versions[encounter.selectedVersion]
  PRT.EnsureEncounterTrigger(version)
  return version
end

local function NewID()
  local id = 1
  while FindEncounter(id) do
    id = id + 1
  end
  return id
end

local function CountMessages(version)
  local count = 0
  for _, timer in ipairs(version.Timers or {}) do
    for _, timing in ipairs(timer.timings or {}) do
      count = count + #(timing.messages or {}) * #(timing.seconds or {})
    end
  end
  return count
end

-- Index lists of the timers/rotations that still work.
local function Supported(version, triggerType)
  local indices = {}
  for index, trigger in ipairs(version[TRIGGER_TABLES[triggerType]] or {}) do
    if not PRT.GetUnsupportedReason(triggerType, trigger) then
      indices[#indices + 1] = index
    end
  end
  return indices
end

local function ParseKey(key)
  if type(key) ~= "string" then
    return
  end
  return key:match("^(%a+):(.+)$")
end

local function EventLabel(event)
  for _, entry in ipairs(TRIGGER_EVENTS) do
    if entry.value == event then
      return entry.label
    end
  end
  return event or "?"
end

local function TimesText(timing)
  local times = {}
  for index, second in ipairs(timing.seconds or {}) do
    times[index] = second + (timing.offset or 0)
  end
  table.sort(times)
  return #times > 0 and Widgets.FormatTimeList(times) or L["no time"]
end

local function MoveEntry(list, index, delta)
  local target = index + delta
  if list[target] then
    list[index], list[target] = list[target], list[index]
  end
end

-------------------------------------------------------------------------------
-- Encounter journal

local journal

-- Encounters of the current tier, raids first; nil without journal (WoW: Forever).
local function JournalEncounters()
  if journal ~= nil then
    return journal or nil
  end
  journal = false
  if not (EJ_GetCurrentTier and EJ_SelectTier and EJ_GetInstanceByIndex and EJ_SelectInstance and EJ_GetEncounterInfoByIndex) then
    return nil
  end
  local values = {}
  local ok =
    pcall(
    function()
      EJ_SelectTier(EJ_GetCurrentTier())
      for _, isRaid in ipairs({true, false}) do
        local instanceIndex = 1
        local instanceID, instanceName = EJ_GetInstanceByIndex(instanceIndex, isRaid)
        while instanceID do
          EJ_SelectInstance(instanceID)
          local bossIndex = 1
          local name, _, _, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
          while name do
            if encounterID then
              values[#values + 1] = {value = encounterID, label = ("%s · %s"):format(instanceName or "?", name), name = name}
            end
            bossIndex = bossIndex + 1
            name, _, _, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
          end
          instanceIndex = instanceIndex + 1
          instanceID, instanceName = EJ_GetInstanceByIndex(instanceIndex, isRaid)
        end
      end
    end
  )
  if ok and #values > 0 then
    journal = values
  end
  return journal or nil
end

-------------------------------------------------------------------------------
-- Import

local pendingImport = {text = "", data = nil, error = nil}

local function CheckImport(text, expectVersion)
  pendingImport.text, pendingImport.data, pendingImport.error = text or "", nil, nil
  if pendingImport.text == "" then
    return
  end
  local ok, data = PRT.Deserialize(pendingImport.text)
  if not ok or type(data) ~= "table" then
    pendingImport.error = L["This is no PRT import string."]
  elseif not (data.Timers or data.Rotations or data.HealthPercentages or data.PowerPercentages) then
    pendingImport.error = expectVersion and L["This string contains no encounter version."] or L["This string contains no encounter."]
  else
    pendingImport.data = data
  end
end

-- An exported version knows its encounter id: it becomes a new version of
-- that encounter, or a new encounter if there is none.
local function ImportVersion(data, encounter)
  data.CustomPlaceholders = data.CustomPlaceholders or {}
  data.name = (data.name or L["Imported"]) .. " - " .. L["Import"] .. " " .. PRT.Now()
  data.createdAt = PRT.Now()
  PRT.ForEachMessage({encounters = {{versions = {data}}}}, PRT.NormalizeTargets)
  encounter = encounter or (data.id and FindEncounter(data.id))
  if not encounter then
    encounter = {enabled = true, id = data.id or NewID(), name = data.name, selectedVersion = 1, versions = {}}
    tinsert(Encounters(), encounter)
  end
  tinsert(encounter.versions, data)
  encounter.selectedVersion = #encounter.versions
  return encounter
end

local function ImportRows(encounter)
  local rows = {
    {
      type = "textarea",
      label = L["Import"],
      placeholder = L["Paste an export string"],
      layout = true,
      get = function()
        return pendingImport.text
      end,
      set = function(text)
        CheckImport(text, encounter ~= nil)
      end
    }
  }
  if pendingImport.error then
    rows[#rows + 1] = {type = "notice", tone = "danger", label = pendingImport.error}
  elseif pendingImport.data then
    local data = pendingImport.data
    local target = encounter or (data.id and FindEncounter(data.id))
    local summary =
      target and L["%s: becomes a new version of %s."]:format(data.name or "?", target.name) or L["%s: becomes a new encounter."]:format(data.name or "?")
    rows[#rows + 1] = {type = "notice", tone = "ok", label = summary}
    rows[#rows + 1] = {
      type = "button",
      label = L["Add"],
      buttonText = L["Import"],
      layout = true,
      onClick = function()
        local imported = ImportVersion(pendingImport.data, encounter)
        CheckImport("")
        PRT.Info(L["Imported into %s."]:format(PRT.HighlightString(imported.name)))
        if not encounter then
          UI.Navigate("encounters", imported.id)
        end
      end
    }
  end
  return rows
end

-------------------------------------------------------------------------------
-- List of encounters

local function EncounterItems()
  local items = {}
  for _, encounter in ipairs(Encounters()) do
    local version = Version(encounter)
    local timers = #Supported(version, "timer")
    local note = L["%d timer(s) · %d message(s)"]:format(timers, CountMessages(version))
    if not encounter.enabled then
      note = note .. " · " .. L["off"]
    end
    items[#items + 1] = {
      label = encounter.name or tostring(encounter.id),
      note = note,
      color = encounter.enabled and colors.ok or colors.control,
      dim = not encounter.enabled
    }
  end
  return items
end

local function ListPage()
  return L["Encounters"], L["Plans per boss: what happens when, for whom"], {
    {
      title = L["Encounters"],
      note = L["Enabled encounters are sent to the group and run on the pull."],
      rows = {
        {
          type = "list",
          items = EncounterItems,
          empty = L["No encounter yet."],
          onClick = function(index)
            UI.Push(Encounters()[index].id)
          end,
          onRemove = function(index)
            tremove(Encounters(), index)
          end,
          confirmRemove = function(index)
            return L["Delete %s with all versions?"]:format(Encounters()[index].name or "?")
          end,
          onAdd = function()
            local encounter = PRT.EmptyEncounter()
            encounter.id = NewID()
            encounter.name = L["New encounter"]
            encounter.versions[1].name = L["Version %d"]:format(1)
            tinsert(Encounters(), encounter)
            UI.Push(encounter.id)
          end,
          addLabel = L["New encounter"]
        }
      }
    },
    {title = L["Import"], note = L["An encounter version exported from PRT."], rows = ImportRows(nil)}
  }
end

-------------------------------------------------------------------------------
-- Encounter

local function SettingsCard(encounter)
  local rows = {
    {
      type = "checkbox",
      label = L["Enabled"],
      note = L["Sent to the group and run on the pull."],
      get = function()
        return encounter.enabled
      end,
      set = function(value)
        encounter.enabled = value
      end
    },
    {
      type = "text",
      label = L["Name"],
      layout = true,
      get = function()
        return encounter.name or ""
      end,
      set = function(value)
        if value ~= "" then
          encounter.name = value
        end
      end
    },
    {
      type = "text",
      label = L["Encounter ID"],
      note = L["The ID of ENCOUNTER_START. Must be unique."],
      get = function()
        return tostring(encounter.id)
      end,
      set = function(value)
        local id = tonumber(value)
        local existing = id and FindEncounter(id)
        if not id then
          PRT.Error(L["The encounter ID must be a number."])
        elseif existing and existing ~= encounter then
          PRT.Error(L["The encounter ID %s is taken by %s."]:format(PRT.HighlightString(id), PRT.HighlightString(existing.name)))
        else
          encounter.id = id
          UI.Navigate("encounters", id)
        end
      end
    }
  }
  local journalValues = JournalEncounters()
  if journalValues then
    rows[#rows + 1] = {
      type = "dropdown",
      label = L["From the dungeon journal"],
      note = L["Sets ID and name."],
      values = journalValues,
      placeholder = L["Choose"],
      get = function()
        return encounter.id
      end,
      set = function(id)
        local existing = FindEncounter(id)
        if existing and existing ~= encounter then
          PRT.Error(L["The encounter ID %s is taken by %s."]:format(PRT.HighlightString(id), PRT.HighlightString(existing.name)))
          return
        end
        for _, entry in ipairs(journalValues) do
          if entry.value == id then
            encounter.name = entry.name
          end
        end
        encounter.id = id
        UI.Navigate("encounters", id)
      end
    }
  end
  return {title = L["Encounter"], rows = rows}
end

local function VersionValues(encounter)
  local values = {}
  for index, version in ipairs(encounter.versions) do
    values[index] = {value = index, label = ("%d: %s"):format(index, version.name or "")}
  end
  return values
end

local function VersionCard(encounter)
  local version = Version(encounter)
  local rows = {
    {
      type = "dropdown",
      label = L["Active version"],
      note = version.createdAt and L["Created %s"]:format(version.createdAt) or nil,
      values = VersionValues(encounter),
      layout = true,
      get = function()
        return encounter.selectedVersion
      end,
      set = function(index)
        encounter.selectedVersion = index
      end
    },
    {
      type = "text",
      label = L["Version name"],
      layout = true,
      get = function()
        return version.name or ""
      end,
      set = function(value)
        version.name = value
      end
    },
    {
      type = "button",
      label = L["New version"],
      note = L["Starts empty."],
      buttonText = L["New"],
      layout = true,
      onClick = function()
        local newVersion = PRT.NewEncounterVersion(encounter)
        newVersion.createdAt = PRT.Now()
        tinsert(encounter.versions, newVersion)
        encounter.selectedVersion = #encounter.versions
      end
    },
    {
      type = "button",
      label = L["Copy version"],
      note = L["To try changes without losing the current plan."],
      buttonText = L["Copy"],
      layout = true,
      onClick = function()
        local copy = PRT.TableUtils.Clone(version)
        copy.name = L["Copy of %s"]:format(version.name or "")
        copy.createdAt = PRT.Now()
        tinsert(encounter.versions, copy)
        encounter.selectedVersion = #encounter.versions
      end
    }
  }
  if #encounter.versions > 1 then
    rows[#rows + 1] = {
      type = "button",
      label = L["Delete version"],
      buttonText = L["Delete"],
      danger = true,
      onClick = function()
        UI.Confirm(
          L["Delete %s?"]:format(version.name or ""),
          L["Delete"],
          function()
            tremove(encounter.versions, encounter.selectedVersion)
            encounter.selectedVersion = math.max(1, encounter.selectedVersion - 1)
            UI.Refresh()
          end
        )
      end
    }
  end
  rows[#rows + 1] = {type = "header", label = L["Share"]}
  rows[#rows + 1] = {
    type = "textarea",
    label = L["Export"],
    note = L["Click to select, then copy with Ctrl+C."],
    readOnly = true,
    get = function()
      return PRT.Serialize(version)
    end
  }
  for _, row in ipairs(ImportRows(encounter)) do
    rows[#rows + 1] = row
  end
  return {title = L["Version"], rows = rows}
end

-- Lanes by target, a marker per message after the pull.
local TYPE_COLORS = {
  cooldown = Widgets.brand,
  raidwarning = colors.notice,
  raidtarget = colors.danger
}

local MAX_LANES = 12

local function TimelineCard(encounter)
  local version = Version(encounter)
  local lanes, laneByKey, length = {}, {}, 60
  local function Lane(key)
    local lane = laneByKey[key]
    if not lane then
      if #lanes >= MAX_LANES then
        key = L["Others"]
        lane = laneByKey[key]
      end
      if not lane then
        lane = {label = key, markers = {}}
        laneByKey[key] = lane
        lanes[#lanes + 1] = lane
      end
    end
    return lane
  end
  for _, timerIndex in ipairs(Supported(version, "timer")) do
    local timer = version.Timers[timerIndex]
    if timer.enabled ~= false then
      for timingIndex, timing in ipairs(timer.timings or {}) do
        for _, second in ipairs(timing.seconds or {}) do
          for messageIndex, message in ipairs(timing.messages or {}) do
            PRT.NormalizeTargets(message)
            local at = second + (timing.offset or 0) + (message.delay or 0)
            length = math.max(length, at + 10)
            local key
            if message.type == "raidwarning" then
              key = L["Raid warning"]
            elseif message.type == "raidtarget" then
              key = L["Raid marker"]
            else
              key = table.concat(message.targets, ", ")
              key = key ~= "" and key or L["nobody"]
            end
            local markers = Lane(key).markers
            markers[#markers + 1] = {
              time = math.max(0, at),
              color = TYPE_COLORS[message.type] or colors.accent,
              tooltipTitle = ("%s · %s"):format(Widgets.FormatTime(math.max(0, at)), timer.name or ""),
              tooltip = Messages.DisplayText(message),
              onClick = function()
                UI.Navigate("encounters", encounter.id, "timer:" .. timerIndex, timingIndex, messageIndex)
              end
            }
          end
        end
      end
    end
  end
  return {
    title = L["Timeline"],
    note = L["Every message of the enabled timers after the pull. Click a marker to edit it."],
    fullWidth = true,
    rows = {{type = "timeline", lanes = lanes, length = length, empty = L["No messages yet. Add a timer below."]}}
  }
end

local function TimerItems(version)
  local items = {}
  for _, index in ipairs(Supported(version, "timer")) do
    local timer = version.Timers[index]
    local count = 0
    for _, timing in ipairs(timer.timings or {}) do
      count = count + #(timing.messages or {})
    end
    items[#items + 1] = {
      label = timer.name or "?",
      note = L["%s · %d timing(s) · %d message(s)"]:format(EventLabel(timer.startCondition and timer.startCondition.event), #(timer.timings or {}), count),
      color = timer.enabled ~= false and colors.ok or colors.control,
      dim = timer.enabled == false
    }
  end
  return items
end

local function TimersCard(encounter)
  local version = Version(encounter)
  return {
    title = L["Timers"],
    note = L["Start on the pull; their timings say when which message shows."],
    rows = {
      {
        type = "list",
        items = function()
          return TimerItems(version)
        end,
        empty = L["No timer yet."],
        onClick = function(index)
          UI.Push("timer:" .. Supported(version, "timer")[index])
        end,
        onRemove = function(index)
          tremove(version.Timers, Supported(version, "timer")[index])
        end,
        confirmRemove = function(index)
          return L["Delete %s?"]:format(version.Timers[Supported(version, "timer")[index]].name or "")
        end,
        onAdd = function()
          local timer = PRT.EmptyTimer()
          timer.name = L["Timer %d"]:format(#version.Timers + 1)
          timer.startCondition = {event = "ENCOUNTER_START"}
          timer.timings = {}
          tinsert(version.Timers, timer)
          UI.Push("timer:" .. #version.Timers)
        end,
        addLabel = L["New timer"]
      }
    }
  }
end

local function RotationsCard(encounter)
  local version = Version(encounter)
  return {
    title = L["Rotations"],
    note = L["Show the next entry each time their event happens. Since Midnight only pull, combat and encounter start or end are left."],
    rows = {
      {
        type = "list",
        items = function()
          local items = {}
          for _, index in ipairs(Supported(version, "rotation")) do
            local rotation = version.Rotations[index]
            items[#items + 1] = {
              label = rotation.name or "?",
              note = L["%s · %d entries"]:format(EventLabel(rotation.triggerCondition and rotation.triggerCondition.event), #(rotation.entries or {})),
              color = rotation.enabled ~= false and colors.ok or colors.control,
              dim = rotation.enabled == false
            }
          end
          return items
        end,
        empty = L["No rotation."],
        onClick = function(index)
          UI.Push("rotation:" .. Supported(version, "rotation")[index])
        end,
        onRemove = function(index)
          tremove(version.Rotations, Supported(version, "rotation")[index])
        end,
        confirmRemove = function(index)
          return L["Delete %s?"]:format(version.Rotations[Supported(version, "rotation")[index]].name or "")
        end,
        onAdd = function()
          local rotation = PRT.EmptyRotation()
          rotation.name = L["Rotation %d"]:format(#version.Rotations + 1)
          rotation.triggerCondition = {event = "ENCOUNTER_START"}
          tinsert(version.Rotations, rotation)
          UI.Push("rotation:" .. #version.Rotations)
        end,
        addLabel = L["New rotation"]
      }
    }
  }
end

local function UnsupportedCard(encounter)
  local version = Version(encounter)
  local unsupported = PRT.GetUnsupportedTriggers(version)
  if #unsupported == 0 then
    return
  end
  return {
    title = L["Can't fire anymore"],
    note = L["Since Midnight addons get no combat log and no boss health or power. These triggers are kept for reference; rebuild them as timers from the pull."],
    rows = {
      {
        type = "list",
        items = function()
          local items = {}
          for _, entry in ipairs(PRT.GetUnsupportedTriggers(version)) do
            items[#items + 1] = {
              label = entry.trigger.name or "?",
              note = ("%s · %s"):format(TRIGGER_TYPE_LABELS[entry.type], REASONS[entry.reason] or entry.reason),
              color = colors.danger,
              dim = true
            }
          end
          return items
        end,
        onRemove = function(index)
          local entry = PRT.GetUnsupportedTriggers(version)[index]
          local list = version[TRIGGER_TABLES[entry.type]]
          for listIndex, trigger in ipairs(list) do
            if trigger == entry.trigger then
              tremove(list, listIndex)
              break
            end
          end
        end,
        confirmRemove = function(index)
          return L["Delete %s?"]:format(PRT.GetUnsupportedTriggers(version)[index].trigger.name or "")
        end
      }
    }
  }
end

local function SortedPlaceholderNames(version)
  local names = {}
  for name in pairs(version.CustomPlaceholders or {}) do
    names[#names + 1] = name
  end
  table.sort(names)
  return names
end

local function PlaceholdersCard(encounter)
  local version = Version(encounter)
  version.CustomPlaceholders = version.CustomPlaceholders or {}
  return {
    title = L["Encounter placeholders"],
    note = L["Like the placeholders under {Players & groups}, but only for this encounter and sent with its plan."],
    rows = {
      {
        type = "list",
        items = function()
          local items = {}
          for _, name in ipairs(SortedPlaceholderNames(version)) do
            local placeholder = version.CustomPlaceholders[name]
            items[#items + 1] = {
              label = "$" .. name,
              note = table.concat(placeholder.characterNames or {}, ", ")
            }
          end
          return items
        end,
        empty = L["No placeholders yet."],
        onClick = function(index)
          UI.Push("placeholder:" .. SortedPlaceholderNames(version)[index])
        end,
        onRemove = function(index)
          version.CustomPlaceholders[SortedPlaceholderNames(version)[index]] = nil
        end,
        onAdd = function()
          local index = 1
          while version.CustomPlaceholders["Encounter" .. index] do
            index = index + 1
          end
          local name = "Encounter" .. index
          version.CustomPlaceholders[name] = {name = name, type = "player", characterNames = {}}
          UI.Push("placeholder:" .. name)
        end,
        addLabel = L["New placeholder"]
      }
    }
  }
end

local function MRTOption(key, label, note)
  return {
    type = "checkbox",
    label = label,
    note = note,
    layout = true,
    get = function()
      return PRT.GetProfileDB().mrtExportDefaults[key]
    end,
    set = function(value)
      PRT.GetProfileDB().mrtExportDefaults[key] = value
    end
  }
end

local function MRTCard(encounter)
  local options = PRT.GetProfileDB().mrtExportDefaults
  local rows = {
    MRTOption("withEncounterName", L["Encounter name"]),
    MRTOption("withTriggerNames", L["Trigger names"]),
    MRTOption("withLinePrefix", L["Time in front of each line"]),
    MRTOption("withEmptyLines", L["Empty lines"]),
    MRTOption("withPersonalization", L["Personalized"], L["Each player sees only their own lines."]),
    {
      type = "textarea",
      label = L["Note"],
      note = L["Cooldown messages of all enabled timers and rotations."],
      readOnly = true,
      height = 90,
      get = function()
        return PRT.MethodRaidToolsNote(encounter, options)
      end
    }
  }
  if PRT.HasMethodRaidTools() then
    rows[#rows + 1] = MRTOption("updatePRTTag", L["Only between the PRT tags"], L["Replaces only the part between `{prtstart}` and `{prtend}` in your note."])
    rows[#rows + 1] = {
      type = "button",
      label = L["Write into your MRT note"],
      buttonText = L["Write"],
      onClick = function()
        local function Write()
          if PRT.WriteMethodRaidToolsNote(PRT.MethodRaidToolsNote(encounter, options), options.updatePRTTag) then
            PRT.Info(L["MethodRaidTools note updated. Send it with MRT as usual."])
          end
        end
        if options.updatePRTTag then
          Write()
        else
          UI.Confirm(L["Replace your whole MethodRaidTools note?"], L["Replace"], Write)
        end
      end
    }
  end
  return {title = L["MethodRaidTools note"], rows = rows}
end

local function EncounterPage(encounter)
  local cards = {
    TimelineCard(encounter),
    SettingsCard(encounter),
    TimersCard(encounter),
    VersionCard(encounter),
    RotationsCard(encounter),
    PlaceholdersCard(encounter)
  }
  local unsupported = UnsupportedCard(encounter)
  if unsupported then
    cards[#cards + 1] = unsupported
  end
  cards[#cards + 1] = MRTCard(encounter)
  local version = Version(encounter)
  return encounter.name or "?", ("%s · %s"):format(version.name or "", encounter.enabled and L["enabled"] or L["off"]), cards
end

-------------------------------------------------------------------------------
-- Timer

local function DifficultiesRow(trigger)
  return {
    type = "multiselect",
    label = L["Difficulties"],
    values = DIFFICULTIES,
    get = function(value)
      return trigger.enabledDifficulties == nil or trigger.enabledDifficulties[value]
    end,
    set = function(value, selected)
      trigger.enabledDifficulties = trigger.enabledDifficulties or {Normal = true, Heroic = true, Mythic = true}
      trigger.enabledDifficulties[value] = selected
    end
  }
end

local function TriggerSettingsRows(trigger)
  return {
    {
      type = "checkbox",
      label = L["Enabled"],
      get = function()
        return trigger.enabled ~= false
      end,
      set = function(value)
        trigger.enabled = value
      end
    },
    {
      type = "text",
      label = L["Name"],
      layout = true,
      get = function()
        return trigger.name or ""
      end,
      set = function(value)
        if value ~= "" then
          trigger.name = value
        end
      end
    },
    DifficultiesRow(trigger),
    {
      type = "textarea",
      label = L["Description"],
      placeholder = L["Notes for yourself"],
      height = 44,
      get = function()
        return trigger.description or ""
      end,
      set = function(value)
        trigger.description = value
      end
    }
  }
end

local function TimingItems(timer)
  local items = {}
  for _, timing in ipairs(timer.timings or {}) do
    local summaries = {}
    for _, message in ipairs(timing.messages or {}) do
      summaries[#summaries + 1] = Messages.DisplayText(message)
    end
    items[#items + 1] = {
      label = TimesText(timing) .. (timing.name and timing.name ~= "" and ("  " .. timing.name) or ""),
      note = #summaries == 1 and summaries[1] or L["%d messages"]:format(#summaries),
      tooltip = table.concat(summaries, "\n")
    }
  end
  return items
end

local function TimerPage(encounter, timerIndex)
  local version = Version(encounter)
  local timer = version.Timers[timerIndex]
  timer.timings = timer.timings or {}
  timer.startCondition = timer.startCondition or {event = "ENCOUNTER_START"}
  local settings = TriggerSettingsRows(timer)
  table.insert(
    settings,
    3,
    {
      type = "dropdown",
      label = L["Starts on"],
      note = L["Pull and combat start are the same moment."],
      values = START_EVENTS,
      get = function()
        return timer.startCondition.event
      end,
      set = function(event)
        timer.startCondition = {event = event}
      end
    }
  )
  if timer.hasStopCondition then
    settings[#settings + 1] = {
      type = "button",
      label = L["Stop condition"],
      note = L["Stops on %s. Since Midnight that only happens at the end of the encounter."]:format(EventLabel(timer.stopCondition and timer.stopCondition.event)),
      buttonText = L["Remove"],
      layout = true,
      onClick = function()
        timer.hasStopCondition = false
        timer.stopCondition = {}
      end
    }
  end
  return timer.name or "?", L["Timer of %s"]:format(encounter.name or "?"), {
    {title = L["Timer"], rows = settings},
    {
      title = L["Timings"],
      note = L["Times after the start. Each timing shows its messages."],
      rows = {
        {
          type = "list",
          items = function()
            return TimingItems(timer)
          end,
          empty = L["No timing yet."],
          onClick = function(index)
            UI.Push(index)
          end,
          onMove = function(index, delta)
            MoveEntry(timer.timings, index, delta)
          end,
          onRemove = function(index)
            tremove(timer.timings, index)
          end,
          onAdd = function()
            local timing = PRT.EmptyTiming()
            local last = timer.timings[#timer.timings]
            local lastTime = last and last.seconds and last.seconds[#last.seconds]
            timing.seconds = {lastTime and lastTime + 30 or 10}
            tinsert(timer.timings, timing)
            UI.Push(#timer.timings)
          end,
          addLabel = L["New timing"]
        }
      }
    }
  }, {encounter.name}
end

local function MessagesListRow(messages, onAdd)
  return {
    type = "list",
    items = function()
      local items = {}
      for _, message in ipairs(messages) do
        items[#items + 1] = {label = Messages.Summary(message)}
      end
      return items
    end,
    empty = L["No message yet."],
    onClick = function(index)
      UI.Push(index)
    end,
    onMove = function(index, delta)
      MoveEntry(messages, index, delta)
    end,
    onRemove = function(index)
      tremove(messages, index)
    end,
    onAdd = onAdd,
    addLabel = L["New message"]
  }
end

local function NewMessage(messages)
  local message = PRT.EmptyMessage()
  if message.type == "cooldown" then
    message.type = "advanced"
    message.targets = PRT.TableUtils.Clone(PRT.GetProfileDB().triggerDefaults.messageDefaults.defaultTargets or {"ALL"})
  end
  tinsert(messages, message)
  UI.Push(#messages)
end

local function TimingPage(encounter, timerIndex, timingIndex)
  local timer = Version(encounter).Timers[timerIndex]
  local timing = timer.timings[timingIndex]
  timing.messages = timing.messages or {}
  return TimesText(timing), L["Timing of %s"]:format(timer.name or "?"), {
    {
      title = L["When"],
      rows = {
        {
          type = "timelist",
          key = tostring(timing),
          label = L["Times after the start"],
          note = L["e.g. `0:30, 1:15, 90`: each time shows the messages."],
          get = function()
            return timing.seconds
          end,
          set = function(times)
            timing.seconds = times
          end
        },
        {
          type = "slider",
          label = L["Offset"],
          note = L["Moves all times, e.g. to warn earlier."],
          min = -30,
          max = 30,
          step = 0.5,
          layout = true,
          get = function()
            return timing.offset or 0
          end,
          set = function(value)
            timing.offset = value
          end
        },
        {
          type = "text",
          label = L["Name"],
          placeholder = L["e.g. Phase 2"],
          layout = true,
          get = function()
            return timing.name or ""
          end,
          set = function(value)
            timing.name = value ~= "" and value or nil
          end
        }
      }
    },
    {
      title = L["Messages"],
      rows = {
        MessagesListRow(
          timing.messages,
          function()
            NewMessage(timing.messages)
          end
        )
      }
    }
  }, {encounter.name, timer.name}
end

local function TimingMessagePage(encounter, timerIndex, timingIndex, messageIndex)
  local version = Version(encounter)
  local timer = version.Timers[timerIndex]
  local timing = timer.timings[timingIndex]
  local message = timing.messages[messageIndex]
  local first = timing.seconds and timing.seconds[1]
  local context = {version = version, at = first and first + (timing.offset or 0)}
  return L["Message %d"]:format(messageIndex), L["%s at %s"]:format(timer.name or "?", TimesText(timing)), Messages.Cards(message, context), {
    encounter.name,
    timer.name,
    TimesText(timing)
  }
end

-------------------------------------------------------------------------------
-- Rotation

local function RotationPage(encounter, rotationIndex)
  local rotation = Version(encounter).Rotations[rotationIndex]
  rotation.entries = rotation.entries or {}
  rotation.triggerCondition = rotation.triggerCondition or {event = "ENCOUNTER_START"}
  local settings = TriggerSettingsRows(rotation)
  table.insert(
    settings,
    3,
    {
      type = "dropdown",
      label = L["Next entry on"],
      values = TRIGGER_EVENTS,
      get = function()
        return rotation.triggerCondition.event
      end,
      set = function(event)
        rotation.triggerCondition = {event = event}
      end
    }
  )
  table.insert(
    settings,
    4,
    {
      type = "checkbox",
      label = L["Start over"],
      note = L["After the last entry the first one follows."],
      get = function()
        return rotation.shouldRestart
      end,
      set = function(value)
        rotation.shouldRestart = value
      end
    }
  )
  return rotation.name or "?", L["Rotation of %s"]:format(encounter.name or "?"), {
    {title = L["Rotation"], rows = settings},
    {
      title = L["Entries"],
      rows = {
        {
          type = "list",
          items = function()
            local items = {}
            for index, entry in ipairs(rotation.entries) do
              items[index] = {label = L["Entry %d"]:format(index), note = L["%d messages"]:format(#(entry.messages or {}))}
            end
            return items
          end,
          onClick = function(index)
            UI.Push(index)
          end,
          onMove = function(index, delta)
            MoveEntry(rotation.entries, index, delta)
          end,
          onRemove = function(index)
            tremove(rotation.entries, index)
          end,
          onAdd = function()
            tinsert(rotation.entries, {messages = {}})
            UI.Push(#rotation.entries)
          end,
          addLabel = L["New entry"]
        }
      }
    }
  }, {encounter.name}
end

local function RotationEntryPage(encounter, rotationIndex, entryIndex)
  local rotation = Version(encounter).Rotations[rotationIndex]
  local entry = rotation.entries[entryIndex]
  entry.messages = entry.messages or {}
  return L["Entry %d"]:format(entryIndex), rotation.name, {
    {
      title = L["Messages"],
      rows = {
        MessagesListRow(
          entry.messages,
          function()
            NewMessage(entry.messages)
          end
        )
      }
    }
  }, {encounter.name, rotation.name}
end

local function RotationMessagePage(encounter, rotationIndex, entryIndex, messageIndex)
  local version = Version(encounter)
  local rotation = version.Rotations[rotationIndex]
  local message = rotation.entries[entryIndex].messages[messageIndex]
  return L["Message %d"]:format(messageIndex), rotation.name, Messages.Cards(message, {version = version}), {
    encounter.name,
    rotation.name,
    L["Entry %d"]:format(entryIndex)
  }
end

-------------------------------------------------------------------------------
-- Encounter placeholder

local PLACEHOLDER_TYPES = {
  {value = "player", label = L["Player"]},
  {value = "group", label = L["Group"]}
}

local function PlaceholderPage(encounter, name)
  local version = Version(encounter)
  local placeholder = version.CustomPlaceholders[name]
  return "$" .. name, L["Placeholder of %s"]:format(encounter.name or "?"), {
    {
      title = L["Placeholder"],
      rows = {
        {
          type = "text",
          label = L["Name"],
          note = L["Without `$` and spaces. Messages use `$Name`."],
          get = function()
            return name
          end,
          set = function(value)
            value = (value or ""):gsub("[%s$]", "")
            if value == "" or value == name or version.CustomPlaceholders[value] then
              return
            end
            version.CustomPlaceholders[value], version.CustomPlaceholders[name] = placeholder, nil
            placeholder.name = value
            UI.Navigate("encounters", encounter.id, "placeholder:" .. value)
          end
        },
        {
          type = "dropdown",
          label = L["Type"],
          note = L["{Player}: the first name that is in the group and alive. {Group}: everyone."],
          values = PLACEHOLDER_TYPES,
          get = function()
            return placeholder.type or "player"
          end,
          set = function(value)
            placeholder.type = value
          end
        },
        {
          type = "textarea",
          label = L["Names"],
          note = L["Separated by commas, in order of priority."],
          placeholder = "Name1, Name2-Realm",
          get = function()
            return table.concat(placeholder.characterNames or {}, ", ")
          end,
          set = function(value)
            local names = {}
            for entry in (value or ""):gmatch("[^,]+") do
              entry = strtrim(entry)
              if entry ~= "" then
                names[#names + 1] = entry
              end
            end
            placeholder.characterNames = names
          end
        }
      }
    }
  }, {encounter.name}
end

-------------------------------------------------------------------------------

-- Resolves the path to the deepest level that still exists.
local function Build(path)
  local encounter = path[1] and FindEncounter(path[1])
  if not encounter then
    return ListPage()
  end
  local version = Version(encounter)
  local kind, key = ParseKey(path[2])
  if kind == "timer" then
    local index = tonumber(key)
    local timer = index and version.Timers[index]
    if timer and not PRT.GetUnsupportedReason("timer", timer) then
      local timing = path[3] and timer.timings and timer.timings[path[3]]
      if timing then
        if path[4] and timing.messages and timing.messages[path[4]] then
          return TimingMessagePage(encounter, index, path[3], path[4])
        end
        return TimingPage(encounter, index, path[3])
      end
      return TimerPage(encounter, index)
    end
  elseif kind == "rotation" then
    local index = tonumber(key)
    local rotation = index and version.Rotations[index]
    if rotation and not PRT.GetUnsupportedReason("rotation", rotation) then
      local entry = path[3] and rotation.entries and rotation.entries[path[3]]
      if entry then
        if path[4] and entry.messages and entry.messages[path[4]] then
          return RotationMessagePage(encounter, index, path[3], path[4])
        end
        return RotationEntryPage(encounter, index, path[3])
      end
      return RotationPage(encounter, index)
    end
  elseif kind == "placeholder" and version.CustomPlaceholders and version.CustomPlaceholders[key] then
    return PlaceholderPage(encounter, key)
  end
  return EncounterPage(encounter)
end

UI.RegisterPage(
  {
    id = "encounters",
    label = L["Encounters"],
    order = 20,
    badge = function()
      local count = 0
      for _, encounter in ipairs(Encounters()) do
        if encounter.enabled then
          count = count + 1
        end
      end
      return count > 0 and tostring(count) or nil
    end,
    build = Build
  }
)
