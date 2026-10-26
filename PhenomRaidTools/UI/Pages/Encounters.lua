-- luacheck: read globals EJ_GetCurrentTier EJ_SelectTier EJ_GetInstanceByIndex EJ_SelectInstance EJ_GetEncounterInfoByIndex EJ_GetNumTiers EJ_GetCreatureInfo
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
  if #version.Timers == 0 then
    version.Timers[1] = PRT.EmptyTimer()
  end
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

-- A new assignment at `at` seconds after the pull, opened in the editor.
local function AddAssignment(encounter, at)
  local version = Version(encounter)
  local timer = version.Timers[1]
  timer.timings = timer.timings or {}
  tinsert(timer.timings, {seconds = {math.max(0, at)}, messages = {NewMessage()}})
  UI.Navigate("encounters", encounter.id, AssignmentKey(1, #timer.timings))
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

local journal, journalByEncounter

-- Bosses of a journal instance: { { id = encounter ID, name, icon } }; the
-- icon is the boss portrait.
local function JournalBosses(instanceID)
  local bosses = {}
  local index = 1
  local name, _, journalEncounterID, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(index, instanceID)
  while name do
    if encounterID then
      local icon = EJ_GetCreatureInfo and select(5, EJ_GetCreatureInfo(1, journalEncounterID))
      bosses[#bosses + 1] = {id = encounterID, name = name, icon = icon}
    end
    index = index + 1
    name, _, journalEncounterID, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(index, instanceID)
  end
  return bosses
end

-- Calls fn(instance) for each raid (or dungeon) of the selected tier, with
-- instance = { name, icon, bosses }.
local function EachJournalInstance(isRaid, fn)
  local index = 1
  local instanceID, name, _, _, _, _, icon = EJ_GetInstanceByIndex(index, isRaid)
  while instanceID do
    EJ_SelectInstance(instanceID)
    fn({name = name or "?", icon = icon, bosses = JournalBosses(instanceID)})
    index = index + 1
    instanceID, name, _, _, _, _, icon = EJ_GetInstanceByIndex(index, isRaid)
  end
end

local function HasJournal()
  return EJ_GetCurrentTier and EJ_GetNumTiers and EJ_SelectTier and EJ_GetInstanceByIndex and EJ_SelectInstance and EJ_GetEncounterInfoByIndex
end

-- Raid bosses of the current tier: { { name, icon, bosses = { { id, name, icon } } } };
-- nil without journal (WoW: Forever).
local function JournalRaids()
  if journal ~= nil then
    return journal or nil
  end
  journal = false
  if not HasJournal() then
    return nil
  end
  local raids = {}
  local ok =
    pcall(
    function()
      EJ_SelectTier(EJ_GetCurrentTier())
      EachJournalInstance(
        true,
        function(raid)
          if #raid.bosses > 0 then
            raids[#raids + 1] = raid
          end
        end
      )
    end
  )
  if ok and #raids > 0 then
    journal = raids
  end
  return journal or nil
end

-- Every boss of every tier, raids and dungeons, by encounter ID:
-- { instance, instanceIcon, icon }. Scanned once per session.
local function JournalEncounters()
  if journalByEncounter then
    return journalByEncounter
  end
  journalByEncounter = {}
  if not HasJournal() then
    return journalByEncounter
  end
  pcall(
    function()
      for tier = 1, EJ_GetNumTiers() do
        EJ_SelectTier(tier)
        for _, isRaid in ipairs({true, false}) do
          EachJournalInstance(
            isRaid,
            function(instance)
              for _, boss in ipairs(instance.bosses) do
                journalByEncounter[boss.id] = {instance = instance.name, instanceIcon = instance.icon, icon = boss.icon}
              end
            end
          )
        end
      end
      EJ_SelectTier(EJ_GetCurrentTier())
    end
  )
  return journalByEncounter
end

-- The instance of an encounter, remembered once the journal knew it.
local function Instance(encounter)
  if not encounter.instance then
    local entry = JournalEncounters()[encounter.id]
    encounter.instance = entry and entry.instance
  end
  return encounter.instance
end

local function BossIcon(encounter)
  local entry = JournalEncounters()[encounter.id]
  return entry and entry.icon
end

local function InstanceIcon(encounter)
  local entry = JournalEncounters()[encounter.id]
  return entry and entry.instanceIcon
end

-- "|T…|t name" for titles and labels; just the name without icon.
local function WithIcon(icon, text)
  return icon and ("|T%s:16:16|t %s"):format(icon, text) or text
end

local function CreateEncounter(id, name, instance)
  local encounter = PRT.EmptyEncounter()
  encounter.id = id
  encounter.name = name
  encounter.instance = instance
  encounter.versions[1].id = id
  encounter.versions[1].name = name
  tinsert(Encounters(), encounter)
  UI.Navigate("encounters", encounter.id)
end

-------------------------------------------------------------------------------
-- Import

local pendingImport = {text = "", data = nil, error = nil}

local function IsValidImport(data)
  return data.Timers
end

local function CheckImport(text)
  pendingImport.text = text or ""
  pendingImport.data, pendingImport.error = PRT.ParseImport(pendingImport.text, IsValidImport, L["This string contains no encounter."])
end

-- An export knows its encounter id: it replaces that encounter's plan, or
-- becomes a new encounter if there is none.
local function ImportPlan(data)
  PRT.ForEachMessage({encounters = {{versions = {data}}}}, PRT.NormalizeTargets)
  PRT.CleanEncounterVersion(data)
  local encounter = data.id and FindEncounter(data.id)
  if not encounter then
    encounter = {enabled = true, id = data.id or NewID(), name = data.name}
    tinsert(Encounters(), encounter)
  end
  data.id = encounter.id
  encounter.versions, encounter.selectedVersion = {data}, 1
  return encounter
end

local function ImportRows()
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
        CheckImport(text)
      end
    }
  }
  if pendingImport.error then
    rows[#rows + 1] = {type = "notice", tone = "danger", label = pendingImport.error}
  elseif pendingImport.data then
    local data = pendingImport.data
    local target = data.id and FindEncounter(data.id)
    local summary =
      target and L["Replaces the plan of %s."]:format(target.name or "?") or L["%s: becomes a new encounter."]:format(data.name or "?")
    rows[#rows + 1] = {type = "notice", tone = "ok", label = summary}
    rows[#rows + 1] = {
      type = "button",
      label = L["Add"],
      buttonText = L["Import"],
      layout = true,
      onClick = function()
        local function Import()
          local imported = ImportPlan(pendingImport.data)
          CheckImport("")
          PRT.Info(L["Imported into %s."]:format(PRT.HighlightString(imported.name)))
          UI.Navigate("encounters", imported.id)
        end
        if target then
          UI.Confirm(L["Replace the plan of %s?"]:format(target.name or "?"), L["Replace"], Import)
        else
          Import()
        end
      end
    }
  end
  return rows
end

-------------------------------------------------------------------------------
-- List of encounters

local function EncounterItem(encounter)
  local note = L["%d assignment(s)"]:format(CountAssignments(Version(encounter)))
  if not encounter.enabled then
    note = note .. " · " .. L["off"]
  end
  return {
    label = encounter.name or tostring(encounter.id),
    note = note,
    icon = BossIcon(encounter),
    dim = not encounter.enabled
  }
end

-- Encounters per instance, instances by name; the ones without at the end.
local function EncountersByInstance()
  local groups, byName = {}, {}
  for _, encounter in ipairs(Encounters()) do
    local name = Instance(encounter) or ""
    if not byName[name] then
      byName[name] = {name = name, icon = InstanceIcon(encounter), encounters = {}}
      groups[#groups + 1] = byName[name]
    end
    tinsert(byName[name].encounters, encounter)
  end
  table.sort(
    groups,
    function(a, b)
      if (a.name == "") ~= (b.name == "") then
        return b.name == ""
      end
      return a.name < b.name
    end
  )
  return groups
end

local function InstanceCard(group)
  local encounters = group.encounters
  return {
    title = group.name ~= "" and WithIcon(group.icon, group.name) or L["Other encounters"],
    fullWidth = true,
    rows = {
      {
        type = "list",
        items = function()
          local items = {}
          for index, encounter in ipairs(encounters) do
            items[index] = EncounterItem(encounter)
          end
          return items
        end,
        onClick = function(index)
          UI.Push(encounters[index].id)
        end,
        onRemove = function(index)
          local _, position = FindEncounter(encounters[index].id)
          tremove(Encounters(), position)
        end,
        confirmRemove = function(index)
          return L["Delete %s with its assignments?"]:format(encounters[index].name or "?")
        end
      }
    }
  }
end

local function ListPage()
  local cards = {
    {
      title = L["Encounters"],
      note = L["Enabled encounters are sent to the group and run on the pull."],
      fullWidth = true,
      rows = {
        {
          type = "button",
          label = L["New encounter"],
          note = L["From the bosses of the current raids, by its encounter ID or from an export string."],
          buttonText = L["New"],
          onClick = function()
            UI.Push("new")
          end
        }
      }
    }
  }
  local groups = EncountersByInstance()
  for _, group in ipairs(groups) do
    cards[#cards + 1] = InstanceCard(group)
  end
  if #groups == 0 then
    cards[1].rows[#cards[1].rows + 1] = {type = "hint", label = L["No encounter yet."]}
  end
  return L["Encounters"], L["Plans per boss: what happens when, for whom"], cards
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
        label = WithIcon(boss.icon, boss.name),
        value = existing and L["added"] or nil,
        onClick = function()
          if existing then
            UI.Navigate("encounters", boss.id)
          else
            CreateEncounter(boss.id, boss.name, raid.name)
          end
        end
      }
    end
    cards[#cards + 1] = {title = WithIcon(raid.icon, raid.name), rows = rows}
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
  cards[#cards + 1] = {
    title = L["Import"],
    note = L["An encounter exported from PRT. Replaces the plan of the same encounter if you have it."],
    rows = ImportRows()
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

local function ShareCard(encounter)
  local rows = {
    {
      type = "textarea",
      label = L["Export"],
      note = L["Click to select, then copy with Ctrl+C."],
      readOnly = true,
      get = function()
        local plan = PRT.TableUtils.Clone(Version(encounter))
        plan.id, plan.name = encounter.id, encounter.name
        return PRT.Serialize(plan)
      end
    }
  }
  return {title = L["Share"], note = L["Import on the New encounter page."], rows = rows}
end

local function LaneKey(message)
  local key = Messages.TargetLabels(message)
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
    local message = assignment.message
    local off = assignment.timing.difficulties ~= nil and next(assignment.timing.difficulties) == nil
    for _, second in ipairs(assignment.timing.seconds or {}) do
      local at = math.max(0, second + (assignment.timing.offset or 0) + (message.delay or 0))
      length = math.max(length, at + 30)
      local markers = Lane(LaneKey(message)).markers
      markers[#markers + 1] = {
        time = at,
        color = off and colors.control or message.type == "cooldown" and Widgets.brand or colors.accent,
        icon = Messages.Icon(message),
        dim = off,
        tooltipTitle = Widgets.FormatTime(at) .. (Messages.DifficultyText(assignment.timing) and " · " .. Messages.DifficultyText(assignment.timing) or ""),
        tooltip = ("%s\n\n%s"):format(
          Messages.DisplayText(message),
          L["For: %s"]:format(Messages.TargetsText(message) ~= "" and Messages.TargetsText(message) or L["nobody"])
        ),
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
  for _, assignment in ipairs(Assignments(version, onlyTimer)) do
    local message = assignment.message
    local note = Messages.WhenText(assignment.timing)
    local difficulties = Messages.DifficultyText(assignment.timing)
    local off = difficulties == L["off"]
    if difficulties then
      note = note .. " · " .. difficulties
    end
    items[#items + 1] = {
      label = Messages.Summary(message),
      note = note,
      icon = Messages.Icon(message),
      dim = off,
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
      AddAssignment(encounter, NextFreeTime(version, onlyTimer))
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
    MRTOption("withEmptyLines", L["Empty lines"]),
    MRTOption("withPersonalization", L["Personalized"], L["Each player sees only their own lines."]),
    {
      type = "textarea",
      label = L["Note"],
      note = L["The cooldown assignments of this encounter."],
      readOnly = true,
      height = 90,
      get = function()
        return PRT.MethodRaidToolsNote(encounter, options)
      end
    }
  }
  local hasMRT = PRT.HasMethodRaidTools()
  local tagOption = MRTOption("updatePRTTag", L["Only between the PRT tags"], L["Replaces only the part between `{prtstart}` and `{prtend}` in your note."])
  tagOption.disabled = not hasMRT
  rows[#rows + 1] = tagOption
  rows[#rows + 1] = {
    type = "button",
    label = L["Write into your MRT note"],
    note = not hasMRT and L["Needs MethodRaidTools."] or nil,
    buttonText = L["Write"],
    disabled = not hasMRT,
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
  return {title = L["MethodRaidTools note"], rows = rows}
end

local function EncounterPage(encounter)
  local cards = {
    TimelineCard(encounter),
    AssignmentsCard(encounter),
    SettingsCard(encounter),
    MRTCard(encounter),
    ShareCard(encounter)
  }
  local status = encounter.enabled and L["enabled"] or L["off"]
  return encounter.name or "?", encounter.instance and encounter.instance .. " · " .. status or status, cards
end

-------------------------------------------------------------------------------
-- Assignment

local function AssignmentPage(encounter, timerIndex, timingIndex)
  local version = Version(encounter)
  local timer = version.Timers[timerIndex]
  local timing = timer.timings[timingIndex]
  local message = timing.messages[1]
  local context = {
    version = version,
    timing = timing,
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
