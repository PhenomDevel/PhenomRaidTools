-- luacheck: read globals EJ_GetCurrentTier EJ_SelectTier EJ_GetInstanceByIndex EJ_SelectInstance EJ_GetEncounterInfoByIndex EJ_GetNumTiers EJ_GetCreatureInfo
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI
local Widgets = PRT.Widgets
local colors = Widgets.colors
local Messages = UI.Messages
local Rehearsal = UI.Rehearsal

--[[
  Encounters and their plans, laid out like an editing desk: the bosses as
  tiles on top, a toolbar (rehearsal, view as, difficulty, zoom), the
  timeline across the whole width and below it the selected assignment as an
  editable sentence. Levels (UI.Navigate("encounters", ...)):

    {}                  the last shown encounter (or the first one)
    { "new" }           a new encounter: the raid bosses of the current tier
    { id }              one encounter: timeline, settings, MRT note, sharing
    { id, "a:3:2" }     the same with an assignment selected: timing 2 of timer 3

  Only "new" is a level of its own; an encounter and its selection keep the
  page flat (no back button).

  Since Midnight a plan is timers from the pull. Each timing holds exactly
  one message (PRT.CleanEncounterVersion), so the editor shows them as
  assignments.
]]

-- The timeline shows at least this much, so there is room to click.
local MIN_TIMELINE_LENGTH = 180
-- Zoomed in, the timeline shows at least this many seconds; zoomed out at
-- most this many (or the whole plan, if it is longer).
local MIN_ZOOM_SPAN = 20
local MAX_ZOOM_SPAN = 20 * 60

-- What the encounter page shows besides the plan, for this session.
local desk = {
  encounterID = nil,
  -- "View as": "" for all targets, a role or a player's name.
  view = "",
  -- "" for all difficulties, else "Normal", "Heroic" or "Mythic".
  difficulty = "",
  -- { from, to } while zoomed in.
  zoom = nil,
  -- The full editor below the sentence.
  details = false
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

-- A new assignment at `at` seconds after the pull, opened in the editor.
local function AddAssignment(encounter, at)
  local version = Version(encounter)
  local timer = version.Timers[1]
  timer.timings = timer.timings or {}
  tinsert(
    timer.timings,
    {
      seconds = {math.max(0, at)},
      difficulties = PRT.TableUtils.Clone(PRT.MessageDefaults().timing.difficulties),
      messages = {PRT.EmptyMessage()}
    }
  )
  UI.Navigate("encounters", encounter.id, AssignmentKey(1, #timer.timings))
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
-- Bosses

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

local function FirstEncounter()
  local group = EncountersByInstance()[1]
  return group and group.encounters[1]
end

local function BossTile(encounter, current)
  local note = L["%d assignment(s)"]:format(CountAssignments(Version(encounter)))
  if not encounter.enabled then
    note = note .. " · " .. L["off"]
  end
  return {
    label = encounter.name or tostring(encounter.id),
    note = note,
    icon = BossIcon(encounter),
    selected = encounter == current,
    dim = not encounter.enabled,
    onClick = function()
      UI.Navigate("encounters", encounter.id)
    end
  }
end

-- The bosses of the current encounter's instance as tiles; with several
-- instances, chips above switch between them.
local function BossCard(current)
  local groups = EncountersByInstance()
  local currentGroup = groups[1]
  for _, group in ipairs(groups) do
    for _, encounter in ipairs(group.encounters) do
      if encounter == current then
        currentGroup = group
      end
    end
  end
  local rows = {}
  if #groups > 1 then
    local values = {}
    for index, group in ipairs(groups) do
      values[index] = {value = group.name, label = group.name ~= "" and group.name or L["Other encounters"]}
    end
    rows[#rows + 1] = {
      type = "chips",
      values = values,
      get = function()
        return currentGroup.name
      end,
      set = function(name)
        for _, group in ipairs(groups) do
          if group.name == name and group ~= currentGroup then
            UI.Navigate("encounters", group.encounters[1].id)
          end
        end
      end
    }
  end
  rows[#rows + 1] = {
    type = "tiles",
    items = function()
      local items = {}
      for index, encounter in ipairs(currentGroup.encounters) do
        items[index] = BossTile(encounter, current)
      end
      return items
    end,
    addLabel = L["Boss"],
    onAdd = function()
      UI.Navigate("encounters", "new")
    end
  }
  return {fullWidth = true, rows = rows}
end

local function EmptyPage()
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
            UI.Navigate("encounters", "new")
          end
        },
        {type = "hint", label = L["No encounter yet."]}
      }
    }
  }
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
-- Encounter settings

local function SettingsCard(encounter)
  return {
    title = L["Encounter"],
    rows = {
      {
        type = "checkbox",
        label = L["Enabled"],
        note = L["Sent to the group and run on the pull."],
        layout = true,
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
      },
      {
        type = "button",
        label = L["Delete encounter"],
        buttonText = L["Delete"],
        danger = true,
        onClick = function()
          UI.Confirm(
            L["Delete %s with its assignments?"]:format(encounter.name or "?"),
            L["Delete"],
            function()
              local _, position = FindEncounter(encounter.id)
              if position then
                tremove(Encounters(), position)
              end
              desk.encounterID = nil
              UI.Navigate("encounters")
            end
          )
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

-------------------------------------------------------------------------------
-- View as, difficulty

local ROLES = {TANK = true, HEALER = true, DAMAGER = true}

local VIEW_ROLES = {
  {value = "TANK", label = L["Tanks"]},
  {value = "HEALER", label = L["Healer"]},
  {value = "DAMAGER", label = L["Damage"]}
}

local DIFFICULTIES = {
  {value = "", label = L["All"]},
  {value = "Normal", label = L["Normal"]},
  {value = "Heroic", label = L["Heroic"]},
  {value = "Mythic", label = L["Mythic"]}
}

-- The players a target stands for in the current group ("$group2" -> its
-- players, a name -> itself); roles and everyone are checked by the caller.
local function TokenNames(token)
  local names = {}
  if token ~= "ALL" and not ROLES[token] then
    for name in PRT.ReplacePlayerNameTokens(token):gmatch("[^,]+") do
      names[strtrim(name)] = true
    end
  end
  return names
end

-- Whether a message reaches the chosen view: everyone, a role or a player.
-- Roles of players are only known for the current group.
local function Reaches(message, view)
  if view == "" then
    return true
  end
  for _, token in ipairs(message.targets or {}) do
    if token == "ALL" or token == view then
      return true
    end
    if ROLES[view] then
      for name in pairs(TokenNames(token)) do
        if UnitGroupRolesAssigned(name) == view then
          return true
        end
      end
    elseif (ROLES[token] and UnitGroupRolesAssigned(view) == token) or TokenNames(token)[view] then
      return true
    end
  end
  return false
end

-- Whether an assignment runs on the chosen difficulty ("" = any).
local function RunsOn(timing, difficulty)
  local difficulties = timing.difficulties
  if difficulties == nil then
    return true
  elseif difficulty == "" then
    return next(difficulties) ~= nil
  end
  return difficulties[difficulty] == true
end

-- Everyone, the roles and every player of the group or the plan.
local function ViewValues(version)
  local names, seen = {}, {}
  local function Add(name)
    if name and name ~= "" and not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  for _, name in ipairs(PRT.PartyNames(false)) do
    Add(name)
  end
  for _, assignment in ipairs(Assignments(version)) do
    for _, token in ipairs(assignment.message.targets or {}) do
      if token ~= "ALL" and not ROLES[token] and token:sub(1, 1) ~= "$" then
        Add(token)
      end
    end
  end
  table.sort(names)
  local values = {{value = "", label = L["All targets"]}}
  for _, role in ipairs(VIEW_ROLES) do
    values[#values + 1] = role
  end
  for _, name in ipairs(names) do
    values[#values + 1] = {value = name, label = PRT.ClassColoredName(name)}
  end
  return values
end

-- When a message shows: its time plus the timing's offset and its delay.
local function ShowTimes(assignment)
  local times = {}
  local shift = (assignment.timing.offset or 0) + (assignment.message.delay or 0)
  for _, second in ipairs(assignment.timing.seconds or {}) do
    times[#times + 1] = math.max(0, second + shift)
  end
  return times
end

local function Length(version)
  local length = MIN_TIMELINE_LENGTH
  for _, assignment in ipairs(Assignments(version)) do
    for _, at in ipairs(ShowTimes(assignment)) do
      length = math.max(length, at + 30)
    end
  end
  return length
end

-- What the rehearsal plays: the assignments of the view on the difficulty.
local function RehearsalEvents(encounter)
  return function()
    local events = {}
    for _, assignment in ipairs(Assignments(Version(encounter))) do
      if RunsOn(assignment.timing, desk.difficulty) and Reaches(assignment.message, desk.view) then
        for _, at in ipairs(ShowTimes(assignment)) do
          events[#events + 1] = {at = at, message = assignment.message}
        end
      end
    end
    return events
  end
end

-------------------------------------------------------------------------------
-- Zoom

local function ZoomRange(length)
  if desk.zoom then
    return desk.zoom[1], desk.zoom[2]
  end
  return 0, length
end

-- Wider than the plan, the view starts at the pull and leaves room after the
-- last assignment.
local function SetZoom(length, from, span)
  from = math.max(0, math.min(from, length - span))
  desk.zoom = {from, from + span}
end

-- factor < 1 zooms in around `at` (default: the middle).
local function Zoom(length, factor, at)
  local from, to = ZoomRange(length)
  local span = math.max(MIN_ZOOM_SPAN, math.min(math.max(MAX_ZOOM_SPAN, length), (to - from) * factor))
  at = at or (from + to) / 2
  SetZoom(length, at - (at - from) / (to - from) * span, span)
end

local function Pan(length, seconds)
  local from, to = ZoomRange(length)
  if desk.zoom then
    SetZoom(length, from + seconds, to - from)
  end
end

-------------------------------------------------------------------------------
-- Toolbar

local SPEEDS = {
  {value = 1, label = "1×", tooltip = L["Real time, with sounds."]},
  {value = 4, label = "4×", tooltip = L["Four times as fast, without sounds."]}
}

local function ToolbarCard(encounter)
  local version = Version(encounter)
  local length = Length(version)
  local items = {
    {
      kind = "button",
      label = Rehearsal.IsPlaying() and L["Pause"] or L["Demo playback"],
      tooltipTitle = L["Demo playback"],
      tooltip = L["Plays the plan from the playhead on your overlays, as the chosen target sees it.\n<Click> on the time axis to move the playhead."],
      onClick = function()
        if Rehearsal.IsPlaying() then
          Rehearsal.Pause()
        else
          Rehearsal.Play(RehearsalEvents(encounter), length)
        end
      end
    },
    {
      kind = "chips",
      values = SPEEDS,
      get = function()
        return Rehearsal.speed
      end,
      set = function(speed)
        Rehearsal.SetSpeed(speed)
      end
    },
    {
      kind = "text",
      width = 44,
      text = function()
        return ("|cff%s%s|r"):format(Widgets.BRAND_HEX, Widgets.FormatTime(math.floor(Rehearsal.Position())))
      end
    },
    {kind = "space"},
    {kind = "text", text = L["View as"], dim = true},
    {
      kind = "dropdown",
      width = 150,
      values = function()
        return ViewValues(version)
      end,
      tooltipTitle = L["View as"],
      tooltip = L["Shows only the lanes and assignments this role or player gets, also in the demo playback."],
      get = function()
        return desk.view
      end,
      set = function(value)
        desk.view = value
      end
    },
    {kind = "space"},
    {
      kind = "chips",
      values = DIFFICULTIES,
      get = function()
        return desk.difficulty
      end,
      set = function(value)
        desk.difficulty = value
      end
    }
  }
  return {fullWidth = true, rows = {{type = "flow", items = items}}}
end

-------------------------------------------------------------------------------
-- Timeline

local function LaneKey(message)
  local key = Messages.TargetLabels(message)
  return key ~= "" and key or L["nobody"]
end

-- Everyone first, then roles, raid groups, "me", classes and players.
local function LaneOrder(message)
  local token = message.targets and message.targets[1]
  if not token then
    return 9
  elseif token == "ALL" then
    return 1
  elseif ROLES[token] then
    return token == "TANK" and 2 or token == "HEALER" and 3 or 4
  elseif token:match("^%$group") then
    return 5
  elseif token == "$me" then
    return 6
  elseif token:sub(1, 1) == "$" then
    return 7
  end
  return 8
end

local MAX_LANES = 16

-- Moves the time `from` of a timing to `to`; a repeating one moves as a whole.
local function MoveTiming(timing, from, to)
  local shift = to - from
  if timing.repeating then
    timing.repeating.from = math.max(0, (timing.repeating.from or 0) + shift)
    timing.repeating.to = math.max(timing.repeating.from, (timing.repeating.to or 0) + shift)
    for index, second in ipairs(timing.seconds) do
      timing.seconds[index] = math.max(0, second + shift)
    end
  else
    for index, second in ipairs(timing.seconds) do
      if second == from then
        timing.seconds[index] = math.max(0, to)
        break
      end
    end
    table.sort(timing.seconds)
  end
end

-- Dragged from `shownAt` (the marker's time) to `seconds`; with copy as a new
-- assignment.
local function MoveAssignment(encounter, assignment, second, shownAt, seconds, copy)
  local timing = assignment.timing
  local timerIndex, timingIndex = assignment.timerIndex, assignment.timingIndex
  if copy then
    timing = PRT.TableUtils.Clone(timing)
    tinsert(assignment.timer.timings, timing)
    timingIndex = #assignment.timer.timings
  end
  MoveTiming(timing, second, second + seconds - shownAt)
  UI.Navigate("encounters", encounter.id, AssignmentKey(timerIndex, timingIndex))
end

local function Marker(encounter, assignment, second, at, selectedKey)
  local message, timing = assignment.message, assignment.timing
  local key = AssignmentKey(assignment.timerIndex, assignment.timingIndex)
  local off = not RunsOn(timing, desk.difficulty)
  local difficulties = Messages.DifficultyText(timing)
  local targets = Messages.TargetsText(message)
  return {
    time = at,
    color = off and colors.control or message.type == "cooldown" and Widgets.brand or colors.accent,
    icon = Messages.Icon(message),
    dim = off,
    selected = key == selectedKey,
    tooltipTitle = Widgets.FormatTime(at) .. (difficulties and " · " .. difficulties or ""),
    tooltip = ("%s\n\n%s\n\n%s"):format(
      Messages.DisplayText(message),
      L["For: %s"]:format(targets ~= "" and targets or L["nobody"]),
      L["<Click> to edit it.\n<Drag> to move it, with <Alt> to copy it.\n<Middle-click> to delete it."]
    ),
    onClick = function()
      UI.Navigate("encounters", encounter.id, key)
    end,
    onMove = function(seconds, copy)
      MoveAssignment(encounter, assignment, second, at, seconds, copy)
    end,
    confirmRemove = L["Delete this assignment?"],
    onRemove = function()
      tremove(assignment.timer.timings, assignment.timingIndex)
      UI.Navigate("encounters", encounter.id)
    end
  }
end

-- Lanes by target, a marker per time of each assignment, a band over the
-- span of a repeating one. Only what reaches the view.
local function Lanes(encounter, selectedKey)
  local lanes, laneByKey = {}, {}
  local function Lane(message)
    local key = LaneKey(message)
    if not laneByKey[key] and #lanes >= MAX_LANES then
      key = L["Others"]
    end
    local lane = laneByKey[key]
    if not lane then
      lane = {label = key, order = key == L["Others"] and 10 or LaneOrder(message), markers = {}, bands = {}}
      laneByKey[key] = lane
      lanes[#lanes + 1] = lane
    end
    return lane
  end
  for _, assignment in ipairs(Assignments(Version(encounter))) do
    local message = assignment.message
    if Reaches(message, desk.view) then
      local lane = Lane(message)
      local shift = (assignment.timing.offset or 0) + (message.delay or 0)
      local first, last
      for _, second in ipairs(assignment.timing.seconds or {}) do
        local at = math.max(0, second + shift)
        first, last = math.min(first or at, at), math.max(last or at, at)
        lane.markers[#lane.markers + 1] = Marker(encounter, assignment, second, at, selectedKey)
      end
      if assignment.timing.repeating and first and last > first then
        lane.bands[#lane.bands + 1] = {from = first, to = last}
      end
    end
  end
  table.sort(
    lanes,
    function(a, b)
      if a.order ~= b.order then
        return a.order < b.order
      end
      return a.label < b.label
    end
  )
  return lanes
end

local function TimelineCard(encounter, selectedKey)
  local version = Version(encounter)
  local length = Length(version)
  local from, to = ZoomRange(length)
  local note = table.concat(
    {
      L["<Click> into the timeline to add an assignment there."],
      L["<Drag> a marker to move it, with <Alt> to copy it."],
      L["<Middle-click> a marker to delete it."],
      L["<Mouse wheel> zooms (up to 20:00), with <Shift> it scrolls the time."]
    },
    "\n"
  )
  if desk.view ~= "" then
    note = note .. "\n" .. L["Lanes the chosen target doesn't see are hidden."]
  end
  return {
    title = L["Timeline"],
    note = note,
    fullWidth = true,
    rows = {
      {
        type = "timeline",
        laneHeight = 30,
        -- Zoomed out further than the plan: room to add more after it.
        length = math.max(length, to),
        view = {from = from, to = to},
        empty = L["Nothing planned yet: click where the first assignment belongs."],
        lanes = function()
          return Lanes(encounter, selectedKey)
        end,
        playhead = Rehearsal.Position,
        axisTooltipTitle = L["Playhead"],
        axisTooltip = L["<Click> to move the playhead of the demo playback here."],
        onClickAxis = Rehearsal.Seek,
        onZoom = function(factor, at)
          Zoom(length, factor, at)
        end,
        onPan = function(seconds)
          Pan(length, seconds)
        end,
        onClickTime = function(seconds)
          AddAssignment(encounter, seconds)
        end
      }
    }
  }
end

-------------------------------------------------------------------------------
-- Selected assignment

local function RemoveAssignment(encounter, timer, timingIndex)
  tremove(timer.timings, timingIndex)
  UI.Navigate("encounters", encounter.id)
end

-- The assignment as one sentence below the timeline; More shows the full
-- editor (repeating, difficulties, more targets, own sound, templates).
local function AssignmentCards(encounter, timerIndex, timingIndex)
  local version = Version(encounter)
  local timer = version.Timers[timerIndex]
  local timing = timer.timings[timingIndex]
  local message = timing.messages[1]
  local difficulties = Messages.DifficultyText(timing)
  local actions = {
    Messages.TypeItem(message),
    {kind = "space"},
    {
      kind = "button",
      label = desk.details and L["Less"] or L["More"],
      tooltip = L["Repeating, several times, difficulties, more targets, own sound and templates."],
      onClick = function()
        desk.details = not desk.details
      end
    },
    {
      kind = "button",
      label = L["Close"],
      onClick = function()
        UI.Navigate("encounters", encounter.id)
      end
    },
    {
      kind = "button",
      label = L["Delete"],
      danger = true,
      onClick = function()
        UI.Confirm(
          L["Delete this assignment?"],
          L["Delete"],
          function()
            RemoveAssignment(encounter, timer, timingIndex)
          end
        )
      end
    }
  }
  if difficulties then
    tinsert(actions, 2, {kind = "text", text = difficulties, dim = true})
  end
  local cards = {
    {
      title = L["Assignment"],
      fullWidth = true,
      rows = {
        {type = "flow", items = Messages.SentenceItems(message, timing)},
        {type = "flow", items = actions}
      }
    }
  }
  if desk.details then
    local context = {
      version = version,
      timing = timing,
      onRemove = function()
        RemoveAssignment(encounter, timer, timingIndex)
      end
    }
    for _, card in ipairs(Messages.Cards(message, context)) do
      cards[#cards + 1] = card
    end
  else
    UI.SetPreview({kind = "message", message = message})
  end
  return cards
end

-------------------------------------------------------------------------------
-- Encounter

-- Another encounter starts with a fresh view of it.
local function Select(encounter)
  if desk.encounterID ~= encounter.id then
    desk.encounterID = encounter.id
    desk.zoom = nil
    Rehearsal.Stop()
  end
end

local function EncounterPage(encounter, timerIndex, timingIndex)
  local cards = {BossCard(encounter), ToolbarCard(encounter)}
  local selectedKey = timerIndex and AssignmentKey(timerIndex, timingIndex)
  cards[#cards + 1] = TimelineCard(encounter, selectedKey)
  if timerIndex then
    for _, card in ipairs(AssignmentCards(encounter, timerIndex, timingIndex)) do
      cards[#cards + 1] = card
    end
  else
    cards[#cards + 1] = SettingsCard(encounter)
    cards[#cards + 1] = MRTCard(encounter)
    cards[#cards + 1] = ShareCard(encounter)
  end
  local status = encounter.enabled and L["enabled"] or L["off"]
  return encounter.name or "?", encounter.instance and encounter.instance .. " · " .. status or status, cards
end

-------------------------------------------------------------------------------

-- Resolves the path to the deepest level that still exists.
local function Build(path)
  if path[1] == "new" then
    return NewEncounterPage()
  end
  local encounter = path[1] and FindEncounter(path[1]) or desk.encounterID and FindEncounter(desk.encounterID) or FirstEncounter()
  if not encounter then
    return EmptyPage()
  end
  Select(encounter)
  local version = Version(encounter)
  local kind, key = ParseKey(path[2])
  if kind == "a" then
    local timerIndex, timingIndex = key:match("^(%d+):(%d+)$")
    timerIndex, timingIndex = tonumber(timerIndex), tonumber(timingIndex)
    local timer = version.Timers[timerIndex or 0]
    local timing = timer and timer.timings and timer.timings[timingIndex]
    if timing and timing.messages and timing.messages[1] then
      return EncounterPage(encounter, timerIndex, timingIndex)
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
    flat = function(path)
      return path[1] ~= "new"
    end,
    build = Build
  }
)
