-- luacheck: read globals EJ_GetCurrentTier EJ_SelectTier EJ_GetInstanceByIndex EJ_SelectInstance EJ_GetEncounterInfoByIndex
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI
local Widgets = PRT.Widgets
local colors = Widgets.colors
local Messages = UI.Messages

--[[
  Encounters and their plans. Levels (UI.Navigate("encounters", ...)):

    {}                  all encounters
    { "new" }           a new encounter: the raid bosses of the current tier
    { id }              one encounter: timeline, assignments, groups, ...
    { id, "a:3:2" }     an assignment: timing 2 of timer 3
    { id, "timer:3" }   a group (timer 3) of the selected version

  Since Midnight a plan is timers from the pull. Each timing holds exactly
  one message (PRT.CleanEncounterVersion), so the editor shows them as
  assignments; timers are groups of assignments that can be switched off or
  limited to difficulties together.
]]

local DIFFICULTIES = {
  {value = "Normal", label = L["Normal"]},
  {value = "Heroic", label = L["Heroic"]},
  {value = "Mythic", label = L["Mythic"]}
}

-- The timeline shows at least this much, so there is room to click.
local MIN_TIMELINE_LENGTH = 180

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

local function ParseKey(key)
  if type(key) ~= "string" then
    return
  end
  return key:match("^(%a+):(.+)$")
end

local function FirstTime(timing)
  local first
  for _, second in ipairs(timing.seconds or {}) do
    first = first and math.min(first, second) or second
  end
  return first
end

-- Every assignment of a version (or one timer), soonest first:
-- { timerIndex, timingIndex, timer, timing, message, first }.
local function Assignments(version, onlyTimer)
  local list = {}
  for timerIndex, timer in ipairs(version.Timers) do
    if not onlyTimer or onlyTimer == timerIndex then
      for timingIndex, timing in ipairs(timer.timings or {}) do
        local message = timing.messages and timing.messages[1]
        if message then
          list[#list + 1] = {
            timerIndex = timerIndex,
            timingIndex = timingIndex,
            timer = timer,
            timing = timing,
            message = message,
            first = FirstTime(timing) or 0
          }
        end
      end
    end
  end
  table.sort(
    list,
    function(a, b)
      if a.first ~= b.first then
        return a.first < b.first
      elseif a.timerIndex ~= b.timerIndex then
        return a.timerIndex < b.timerIndex
      end
      return a.timingIndex < b.timingIndex
    end
  )
  return list
end

local function AssignmentKey(timerIndex, timingIndex)
  return ("a:%d:%d"):format(timerIndex, timingIndex)
end

local function NewMessage()
  local message = PRT.EmptyMessage()
  if message.type == "cooldown" then
    message.type = "advanced"
    message.targets = PRT.TableUtils.Clone(PRT.GetProfileDB().triggerDefaults.messageDefaults.defaultTargets or {"ALL"})
  end
  return message
end

local function NewGroup(version, name)
  local timer = PRT.EmptyTimer()
  timer.name = name
  tinsert(version.Timers, timer)
  return #version.Timers
end

-- A new assignment at `at` seconds after the pull, opened in the editor.
local function AddAssignment(encounter, at, timerIndex)
  local version = Version(encounter)
  timerIndex = timerIndex or 1
  if not version.Timers[timerIndex] then
    timerIndex = NewGroup(version, L["Pull"])
  end
  local timer = version.Timers[timerIndex]
  timer.timings = timer.timings or {}
  tinsert(timer.timings, {seconds = {math.max(0, at)}, messages = {NewMessage()}})
  UI.Navigate("encounters", encounter.id, AssignmentKey(timerIndex, #timer.timings))
end

local function NextFreeTime(version, onlyTimer)
  local last
  for _, assignment in ipairs(Assignments(version, onlyTimer)) do
    last = assignment.first
  end
  return last and last + 10 or 10
end

local function CountAssignments(version)
  return #Assignments(version)
end

-------------------------------------------------------------------------------
-- Encounter journal

local journal

-- Raid bosses of the current tier: { { name = instance, bosses = { { id, name } } } };
-- nil without journal (WoW: Forever).
local function JournalRaids()
  if journal ~= nil then
    return journal or nil
  end
  journal = false
  if not (EJ_GetCurrentTier and EJ_SelectTier and EJ_GetInstanceByIndex and EJ_SelectInstance and EJ_GetEncounterInfoByIndex) then
    return nil
  end
  local raids = {}
  local ok =
    pcall(
    function()
      EJ_SelectTier(EJ_GetCurrentTier())
      local instanceIndex = 1
      local instanceID, instanceName = EJ_GetInstanceByIndex(instanceIndex, true)
      while instanceID do
        EJ_SelectInstance(instanceID)
        local raid = {name = instanceName or "?", bosses = {}}
        local bossIndex = 1
        local name, _, _, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
        while name do
          if encounterID then
            raid.bosses[#raid.bosses + 1] = {id = encounterID, name = name}
          end
          bossIndex = bossIndex + 1
          name, _, _, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
        end
        if #raid.bosses > 0 then
          raids[#raids + 1] = raid
        end
        instanceIndex = instanceIndex + 1
        instanceID, instanceName = EJ_GetInstanceByIndex(instanceIndex, true)
      end
    end
  )
  if ok and #raids > 0 then
    journal = raids
  end
  return journal or nil
end

local function CreateEncounter(id, name)
  local encounter = PRT.EmptyEncounter()
  encounter.id = id
  encounter.name = name
  encounter.versions[1].id = id
  encounter.versions[1].name = L["Version %d"]:format(1)
  tinsert(Encounters(), encounter)
  UI.Navigate("encounters", encounter.id)
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
  elseif not data.Timers then
    pendingImport.error = expectVersion and L["This string contains no encounter version."] or L["This string contains no encounter."]
  else
    pendingImport.data = data
  end
end

-- An exported version knows its encounter id: it becomes a new version of
-- that encounter, or a new encounter if there is none.
local function ImportVersion(data, encounter)
  PRT.ForEachMessage({encounters = {{versions = {data}}}}, PRT.NormalizeTargets)
  PRT.CleanEncounterVersion(data)
  data.name = (data.name or L["Imported"]) .. " - " .. L["Import"] .. " " .. PRT.Now()
  data.createdAt = PRT.Now()
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
    local note = L["%d assignment(s)"]:format(CountAssignments(Version(encounter)))
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
            UI.Push("new")
          end,
          addLabel = L["New encounter"]
        }
      }
    },
    {title = L["Import"], note = L["An encounter version exported from PRT."], rows = ImportRows(nil)}
  }
end

-------------------------------------------------------------------------------
-- New encounter

local function NewEncounterPage()
  local cards = {}
  for _, raid in ipairs(JournalRaids() or {}) do
    local rows = {}
    for _, boss in ipairs(raid.bosses) do
      local existing = FindEncounter(boss.id)
      rows[#rows + 1] = {
        type = "nav",
        label = boss.name,
        value = existing and L["added"] or nil,
        onClick = function()
          if existing then
            UI.Navigate("encounters", boss.id)
          else
            CreateEncounter(boss.id, boss.name)
          end
        end
      }
    end
    cards[#cards + 1] = {title = raid.name, rows = rows}
  end
  cards[#cards + 1] = {
    title = L["Other encounter"],
    note = L["Any boss by its encounter ID, e.g. from a dungeon or an older raid."],
    rows = {
      {
        type = "button",
        label = L["Empty encounter"],
        buttonText = L["Create"],
        onClick = function()
          CreateEncounter(NewID(), L["New encounter"])
        end
      }
    }
  }
  local subtitle = JournalRaids() and L["Choose a boss of the current raids."] or L["The dungeon journal is not available: create the encounter by its ID."]
  return L["New encounter"], subtitle, cards
end

-------------------------------------------------------------------------------
-- Encounter

local function SettingsCard(encounter)
  return {
    title = L["Encounter"],
    rows = {
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
  }
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

local function LaneKey(message)
  PRT.NormalizeTargets(message)
  local key = table.concat(message.targets, ", ")
  return key ~= "" and key or L["nobody"]
end

local MAX_LANES = 10

-- Lanes by target, a marker per time of each assignment.
local function TimelineCard(encounter)
  local version = Version(encounter)
  local lanes, laneByKey, length = {}, {}, MIN_TIMELINE_LENGTH
  local function Lane(key)
    if not laneByKey[key] and #lanes >= MAX_LANES then
      key = L["Others"]
    end
    local lane = laneByKey[key]
    if not lane then
      lane = {label = key, markers = {}}
      laneByKey[key] = lane
      lanes[#lanes + 1] = lane
    end
    return lane
  end
  for _, assignment in ipairs(Assignments(version)) do
    local message, timer = assignment.message, assignment.timer
    local off = timer.enabled == false
    for _, second in ipairs(assignment.timing.seconds or {}) do
      local at = math.max(0, second + (assignment.timing.offset or 0) + (message.delay or 0))
      length = math.max(length, at + 30)
      local markers = Lane(LaneKey(message)).markers
      markers[#markers + 1] = {
        time = at,
        color = off and colors.control or message.type == "cooldown" and Widgets.brand or colors.accent,
        tooltipTitle = ("%s · %s"):format(Widgets.FormatTime(at), timer.name or ""),
        tooltip = Messages.DisplayText(message),
        onClick = function()
          UI.Navigate("encounters", encounter.id, AssignmentKey(assignment.timerIndex, assignment.timingIndex))
        end
      }
    end
  end
  return {
    title = L["Timeline"],
    note = L["Click into the timeline to add an assignment at that time, click a marker to edit it."],
    fullWidth = true,
    rows = {
      {
        type = "timeline",
        lanes = lanes,
        length = length,
        empty = L["Nothing planned yet: click where the first assignment belongs."],
        onClickTime = function(seconds)
          AddAssignment(encounter, seconds)
        end
      }
    }
  }
end

local function AssignmentItems(version, onlyTimer)
  local items = {}
  local showGroup = #version.Timers > 1 and not onlyTimer
  for _, assignment in ipairs(Assignments(version, onlyTimer)) do
    local message = assignment.message
    local note = Messages.WhenText(assignment.timing)
    if showGroup then
      note = note .. " · " .. (assignment.timer.name or "")
    end
    items[#items + 1] = {
      label = Messages.Summary(message),
      note = note,
      icon = message.type == "cooldown" and PRT.SpellIcon(message.spellID) or nil,
      color = assignment.timer.enabled == false and colors.control or colors.accent,
      dim = assignment.timer.enabled == false,
      tooltip = Messages.DisplayText(message)
    }
  end
  return items
end

local function AssignmentsRow(encounter, onlyTimer)
  local version = Version(encounter)
  return {
    type = "list",
    items = function()
      return AssignmentItems(version, onlyTimer)
    end,
    empty = L["No assignment yet."],
    onClick = function(index)
      local assignment = Assignments(version, onlyTimer)[index]
      UI.Navigate("encounters", encounter.id, AssignmentKey(assignment.timerIndex, assignment.timingIndex))
    end,
    onRemove = function(index)
      local assignment = Assignments(version, onlyTimer)[index]
      tremove(assignment.timer.timings, assignment.timingIndex)
    end,
    onAdd = function()
      AddAssignment(encounter, NextFreeTime(version, onlyTimer), onlyTimer)
    end,
    addLabel = L["New assignment"]
  }
end

local function AssignmentsCard(encounter)
  return {
    title = L["Assignments"],
    note = L["What each player sees and when. Once or repeating, counted from the pull."],
    fullWidth = true,
    rows = {AssignmentsRow(encounter)}
  }
end

local function GroupItems(version)
  local items = {}
  for _, timer in ipairs(version.Timers) do
    local note = L["%d assignment(s)"]:format(#(timer.timings or {}))
    if timer.enabled == false then
      note = note .. " · " .. L["off"]
    end
    items[#items + 1] = {
      label = timer.name or "?",
      note = note,
      color = timer.enabled ~= false and colors.ok or colors.control,
      dim = timer.enabled == false
    }
  end
  return items
end

local function GroupsCard(encounter)
  local version = Version(encounter)
  return {
    title = L["Groups"],
    note = L["Optional: assignments of a group are switched off or limited to difficulties together."],
    rows = {
      {
        type = "list",
        items = function()
          return GroupItems(version)
        end,
        empty = L["No group yet."],
        onClick = function(index)
          UI.Push("timer:" .. index)
        end,
        onRemove = function(index)
          tremove(version.Timers, index)
        end,
        confirmRemove = function(index)
          return L["Delete %s with its assignments?"]:format(version.Timers[index].name or "")
        end,
        onAdd = function()
          UI.Push("timer:" .. NewGroup(version, L["Group %d"]:format(#version.Timers + 1)))
        end,
        addLabel = L["New group"]
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
    MRTOption("withTriggerNames", L["Group names"]),
    MRTOption("withLinePrefix", L["Time in front of each line"]),
    MRTOption("withEmptyLines", L["Empty lines"]),
    MRTOption("withPersonalization", L["Personalized"], L["Each player sees only their own lines."]),
    {
      type = "textarea",
      label = L["Note"],
      note = L["The cooldown assignments of all enabled groups."],
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
  local version = Version(encounter)
  local cards = {
    TimelineCard(encounter),
    AssignmentsCard(encounter),
    SettingsCard(encounter),
    GroupsCard(encounter),
    VersionCard(encounter),
    MRTCard(encounter)
  }
  return encounter.name or "?", ("%s · %s"):format(version.name or "", encounter.enabled and L["enabled"] or L["off"]), cards
end

-------------------------------------------------------------------------------
-- Group (timer)

local function GroupPage(encounter, timerIndex)
  local timer = Version(encounter).Timers[timerIndex]
  timer.timings = timer.timings or {}
  return timer.name or "?", L["Group of %s"]:format(encounter.name or "?"), {
    {
      title = L["Group"],
      rows = {
        {
          type = "checkbox",
          label = L["Enabled"],
          get = function()
            return timer.enabled ~= false
          end,
          set = function(value)
            timer.enabled = value
          end
        },
        {
          type = "text",
          label = L["Name"],
          layout = true,
          get = function()
            return timer.name or ""
          end,
          set = function(value)
            if value ~= "" then
              timer.name = value
            end
          end
        },
        {
          type = "multiselect",
          label = L["Difficulties"],
          values = DIFFICULTIES,
          get = function(value)
            return timer.enabledDifficulties == nil or timer.enabledDifficulties[value]
          end,
          set = function(value, selected)
            timer.enabledDifficulties = timer.enabledDifficulties or {Normal = true, Heroic = true, Mythic = true}
            timer.enabledDifficulties[value] = selected
          end
        },
        {
          type = "textarea",
          label = L["Description"],
          placeholder = L["Notes for yourself"],
          height = 44,
          get = function()
            return timer.description or ""
          end,
          set = function(value)
            timer.description = value
          end
        }
      }
    },
    {title = L["Assignments"], rows = {AssignmentsRow(encounter, timerIndex)}}
  }, {encounter.name}
end

-------------------------------------------------------------------------------
-- Assignment

local function GroupValues(version)
  local values = {}
  for index, timer in ipairs(version.Timers) do
    values[index] = {value = index, label = timer.name or tostring(index)}
  end
  return values
end

local function AssignmentPage(encounter, timerIndex, timingIndex)
  local version = Version(encounter)
  local timer = version.Timers[timerIndex]
  local timing = timer.timings[timingIndex]
  local message = timing.messages[1]
  local context = {
    version = version,
    timing = timing,
    groups = #version.Timers > 1 and GroupValues(version) or nil,
    group = timerIndex,
    setGroup = function(index)
      if index ~= timerIndex and version.Timers[index] then
        tremove(timer.timings, timingIndex)
        local target = version.Timers[index]
        target.timings = target.timings or {}
        tinsert(target.timings, timing)
        UI.Navigate("encounters", encounter.id, AssignmentKey(index, #target.timings))
      end
    end,
    onRemove = function()
      tremove(timer.timings, timingIndex)
      UI.Navigate("encounters", encounter.id)
    end
  }
  return Messages.WhenText(timing), Messages.DisplayText(message), Messages.Cards(message, context), {encounter.name}
end

-------------------------------------------------------------------------------

-- Resolves the path to the deepest level that still exists.
local function Build(path)
  if path[1] == "new" then
    return NewEncounterPage()
  end
  local encounter = path[1] and FindEncounter(path[1])
  if not encounter then
    return ListPage()
  end
  local version = Version(encounter)
  local kind, key = ParseKey(path[2])
  if kind == "a" then
    local timerIndex, timingIndex = key:match("^(%d+):(%d+)$")
    local timer = version.Timers[tonumber(timerIndex) or 0]
    local timing = timer and timer.timings and timer.timings[tonumber(timingIndex)]
    if timing and timing.messages and timing.messages[1] then
      return AssignmentPage(encounter, tonumber(timerIndex), tonumber(timingIndex))
    end
  elseif kind == "timer" then
    local index = tonumber(key)
    if index and version.Timers[index] then
      return GroupPage(encounter, index)
    end
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
