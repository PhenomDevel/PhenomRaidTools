-- luacheck: read globals GetClassInfo RAID_CLASS_COLORS
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local LSM = LibStub("LibSharedMedia-3.0")

local UI = PRT.UI
local Widgets = PRT.Widgets

--[[
  Assignment editor: one message (what, when, for whom, how) as cards,
  shared by the encounter assignments and the templates. The first card
  reads as a sentence and updates live; the window's preview panel shows
  the message on its overlay.

  UI.Messages.Cards(message, context) -> cards
    context = { timing = the assignment's timing (encounters only),
                onRemove(), isTemplate, isDefaults }
  UI.Messages.Summary(message) -> one line for lists
  UI.Messages.WhenText(timing) -> "1:30", "every 0:30 from 0:45 to 4:00"
]]

local Messages = {}
UI.Messages = Messages

local TYPES = {
  {value = "advanced", label = L["Message"]},
  {value = "cooldown", label = L["Cooldown"]}
}

local ROLE_TARGETS = {
  {value = "ALL", label = L["Everyone"]},
  {value = "TANK", label = L["Tanks"]},
  {value = "HEALER", label = L["Healer"]},
  {value = "DAMAGER", label = L["Damage"]},
  {value = "$me", label = L["Me"]}
}

-- Chosen from the list, a cooldown goes on the overlay of its purpose
-- (ReceiverOverlay.DefaultReceivers) if the profile has one.
local COOLDOWNS = {
  healing = {
    -- Raid
    64843, 265202, 740, 108280, 115310, 31884, 33891, 197721, 62618, 98008, 31821, 196718, 51052, 97462, 359816, 363534, 370960,
    -- Externals
    33206, 47788, 102342, 6940, 1022, 204018, 116849
  },
  utility = {
    -- Movement and utility
    192077, 106898, 16191, 64901, 108281, 15286, 374968,
    -- Immunities
    642, 45438, 186265, 196555, 31224
  }
}

local COOLDOWN_PURPOSE = {}
for purpose, spellIDs in pairs(COOLDOWNS) do
  for _, spellID in ipairs(spellIDs) do
    COOLDOWN_PURPOSE[spellID] = purpose
  end
end

-- Spoken cooldown sounds that come with PRT (Media.lua).
local COOLDOWN_SOUNDS = {
  [64843] = "PRT: Divine Hymn",
  [265202] = "PRT: Holy Word: Salvation",
  [740] = "PRT: Tranquility",
  [108280] = "PRT: Healing Tide Totem",
  [115310] = "PRT: Revival",
  [62618] = "PRT: Power Word: Barrier",
  [98008] = "PRT: Spirit Link Totem",
  [31821] = "PRT: Aura Mastery",
  [196718] = "PRT: Darkness",
  [51052] = "PRT: Anti Magic Zone",
  [97462] = "PRT: Rallying Cry"
}

local RAID_TARGET_ICON = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:14|t"

local WHEN_MODES = {
  {value = "once", label = L["Once"]},
  {value = "repeat", label = L["Repeating"]},
  {value = "list", label = L["Several times"]}
}

local DIFFICULTIES = {
  {value = "Normal", label = L["Normal"]},
  {value = "Heroic", label = L["Heroic"]},
  {value = "Mythic", label = L["Mythic"]}
}

-- How a message sounds: the overlay's sound, its own or read aloud.
local SOUND_MODES = {
  {value = "overlay", label = L["Overlay"]},
  {value = "own", label = L["Own"]},
  {value = "tts", label = L["Read aloud"]}
}

local SOUND_NOTES = {
  overlay = L["The sound of the overlay plays."],
  own = L["Plays this sound instead of the overlay's."],
  tts = L["Reads the text aloud with the voice of the game's text to speech settings."]
}

local function SoundMode(message)
  if message.useTTS then
    return "tts"
  elseif message.useCustomSound then
    return "own"
  end
  return "overlay"
end

local function SetSound(message, value)
  message.useTTS = value == "tts" or nil
  message.useCustomSound = value == "own"
end

-- A repeating assignment never shows more often than this.
local MAX_REPEATS = 100

-------------------------------------------------------------------------------
-- Text


local function HasCountdown(text)
  return text and text:gsub("%%%%", ""):find("%%[-+ #0]*%d*%.?%d*[dfgs]") ~= nil
end

local CooldownText = PRT.CooldownMessageText
local SpellName = PRT.SpellName

-- What the player will see (names resolved in the current group).
function Messages.DisplayText(message)
  return PRT.ReceiverOverlay.WithoutTime(PRT.PrepareMessageForDisplay(message.message or ""))
end

-- Stands for a message without a spell.
Messages.TEXT_ICON = "Interface\\Icons\\INV_Misc_Note_01"

-- The spell's icon of a message: its cooldown, or the first spell in its
-- text; a note for plain text.
function Messages.Icon(message)
  local spellID = message.type == "cooldown" and message.spellID or (message.message or ""):match("{spell:(%d+)}")
  return spellID and PRT.SpellIcon(tonumber(spellID) or spellID) or Messages.TEXT_ICON
end

-- Nil on all difficulties, else e.g. "Heroic, Mythic" or "off".
function Messages.DifficultyText(timing)
  local difficulties = timing.difficulties
  if not difficulties then
    return nil
  end
  local names = {}
  for _, difficulty in ipairs(DIFFICULTIES) do
    if difficulties[difficulty.value] then
      names[#names + 1] = difficulty.label
    end
  end
  return #names > 0 and table.concat(names, ", ") or L["off"]
end

function Messages.TargetsText(message)
  local names = {}
  for _, target in ipairs(message.targets or {}) do
    for name in PRT.ReplacePlayerNameTokens(target):gmatch("[^,]+") do
      names[#names + 1] = PRT.ClassColoredName(strtrim(name))
    end
  end
  return table.concat(names, ", ")
end

-- A target as the chips name it: roles, "Me", "Group 3", class names; players as they are.
function Messages.TargetLabel(token)
  for _, role in ipairs(ROLE_TARGETS) do
    if role.value == token then
      return role.label
    end
  end
  local group = token:match("^%$group(%d)$")
  if group then
    return L["Group %d"]:format(tonumber(group))
  end
  local classID = token:sub(1, 1) == "$" and PRT.Static.ClassTokens[token:sub(2)]
  local name, classFile
  if classID then
    name, classFile = GetClassInfo(classID)
  end
  if name then
    local color = RAID_CLASS_COLORS[classFile]
    return color and color:WrapTextInColorCode(name) or name
  end
  return token
end

function Messages.TargetLabels(message)
  PRT.NormalizeTargets(message)
  local labels = {}
  for index, token in ipairs(message.targets) do
    labels[index] = Messages.TargetLabel(token)
  end
  return table.concat(labels, ", ")
end

function Messages.Summary(message)
  local text = Messages.DisplayText(message)
  local targets = Messages.TargetLabels(message)
  return ("%s  |cff%s→ %s|r"):format(text ~= "" and text or L["(empty)"], Widgets.ACCENT_HEX, targets ~= "" and targets or L["nobody"])
end

-------------------------------------------------------------------------------
-- When

local function RepeatTimes(repeating)
  local times = {}
  local every = math.max(1, repeating.every or 30)
  local last = math.max(repeating.from or 0, repeating.to or 0)
  local at = repeating.from or 0
  while at <= last and #times < MAX_REPEATS do
    times[#times + 1] = at
    at = at + every
  end
  return times
end

local function WhenMode(timing)
  if timing.repeating then
    return "repeat"
  elseif #(timing.seconds or {}) > 1 then
    return "list"
  end
  return "once"
end

function Messages.WhenText(timing)
  local times = {}
  for index, second in ipairs(timing.seconds or {}) do
    times[index] = second + (timing.offset or 0)
  end
  table.sort(times)
  if #times == 0 then
    return L["no time"]
  elseif timing.repeating and #times > 1 then
    return L["every %s from %s to %s"]:format(Widgets.FormatTime(timing.repeating.every), Widgets.FormatTime(times[1]), Widgets.FormatTime(times[#times]))
  end
  return Widgets.FormatTimeList(times)
end

-- The first card as a sentence: "At 1:15 show ... to ... on Messages for 5 s".
local function Sentence(message, context)
  local overlay = PRT.GetProfileDB().overlay.receivers[message.targetOverlay or 1]
  local lead = PRT.MessageLeadTime(message)
  local what =
    (lead > 0 and L["show %s to %s on %s %s s before"] or L["show %s to %s on %s for %s s"]):format(
    Messages.DisplayText(message),
    Messages.TargetsText(message) ~= "" and Messages.TargetsText(message) or L["nobody"],
    overlay and overlay.label or "?",
    lead > 0 and lead or message.duration or 5
  )
  if context.timing then
    return L["At %s %s"]:format(Messages.WhenText(context.timing), what)
  end
  return what
end

local function FirstSecond(timing)
  local first
  for _, second in ipairs(timing.seconds or {}) do
    first = first and math.min(first, second) or second
  end
  return first or 0
end

local function TimeRow(label, note, get, set)
  return {
    type = "text",
    label = label,
    note = note,
    placeholder = "1:30",
    layout = true,
    get = function()
      return Widgets.FormatTime(get())
    end,
    set = function(text)
      local times = Widgets.ParseTimeList(text)
      if times[1] then
        set(times[1])
      end
    end
  }
end

-- Difficulties of a timing (nil = all, {} = off); also the default of new
-- assignments on the "New messages" page.
function Messages.DifficultyRows(timing)
  local rows = {}
  rows[#rows + 1] = {
    type = "multiselect",
    label = L["Difficulties"],
    values = DIFFICULTIES,
    layout = true,
    get = function(value)
      return timing.difficulties == nil or timing.difficulties[value]
    end,
    set = function(value, selected)
      local difficulties = timing.difficulties or {Normal = true, Heroic = true, Mythic = true}
      difficulties[value] = selected or nil
      local all = true
      for _, difficulty in ipairs(DIFFICULTIES) do
        all = all and difficulties[difficulty.value]
      end
      timing.difficulties = not all and difficulties or nil
    end
  }
  if timing.difficulties and next(timing.difficulties) == nil then
    rows[#rows + 1] = {type = "notice", label = L["No difficulty: this assignment is off."]}
  end
  return rows
end

local function WhenCard(context)
  local timing = context.timing
  timing.offset = nil
  local mode = WhenMode(timing)
  local rows = {
    {
      type = "chips",
      values = WHEN_MODES,
      get = function()
        return WhenMode(timing)
      end,
      set = function(value)
        local first = FirstSecond(timing)
        if value == "repeat" then
          timing.repeating = {from = first, every = 30, to = first + 120}
          timing.seconds = RepeatTimes(timing.repeating)
        else
          timing.repeating = nil
          if value == "once" then
            timing.seconds = {first}
          elseif #timing.seconds < 2 then
            timing.seconds = {first, first + 60}
          end
        end
      end
    }
  }
  if mode == "once" then
    rows[#rows + 1] =
      TimeRow(
      L["Time"],
      L["After the pull, e.g. `1:30` or `90`."],
      function()
        return FirstSecond(timing)
      end,
      function(seconds)
        timing.seconds = {seconds}
      end
    )
  elseif mode == "repeat" then
    local repeating = timing.repeating
    local function Update()
      timing.seconds = RepeatTimes(repeating)
    end
    rows[#rows + 1] =
      TimeRow(
      L["First time"],
      nil,
      function()
        return repeating.from or 0
      end,
      function(seconds)
        repeating.from = seconds
        repeating.to = math.max(repeating.to or seconds, seconds)
        Update()
      end
    )
    rows[#rows + 1] = {
      type = "slider",
      label = L["Every"],
      note = L["Seconds between two times."],
      min = 5,
      max = 180,
      step = 1,
      layout = true,
      get = function()
        return repeating.every or 30
      end,
      set = function(value)
        repeating.every = value
        Update()
      end
    }
    rows[#rows + 1] =
      TimeRow(
      L["Last time"],
      L["Not after this time."],
      function()
        return repeating.to or repeating.from or 0
      end,
      function(seconds)
        repeating.to = seconds
        Update()
      end
    )
  else
    rows[#rows + 1] = {
      type = "timelist",
      key = tostring(timing),
      label = L["Times"],
      note = L["e.g. `0:30, 1:15, 90`."],
      layout = true,
      get = function()
        return timing.seconds
      end,
      set = function(times)
        timing.seconds = times
      end
    }
  end
  for _, row in ipairs(Messages.DifficultyRows(timing)) do
    rows[#rows + 1] = row
  end
  return {title = L["When"], note = L["Counted from the pull."], rows = rows}
end

-------------------------------------------------------------------------------
-- Targets

local function Has(list, value)
  for _, entry in ipairs(list) do
    if entry == value then
      return true
    end
  end
  return false
end

local function SetTarget(message, value, selected)
  PRT.NormalizeTargets(message)
  local targets = message.targets
  for index = #targets, 1, -1 do
    if targets[index] == value then
      tremove(targets, index)
    end
  end
  if selected then
    targets[#targets + 1] = value
  end
end

local function SortedKeys(t)
  local keys = {}
  for key in pairs(t or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function MemberTargets()
  local values = {}
  local names = PRT.PartyNames(false)
  table.sort(names)
  for _, name in ipairs(names) do
    values[#values + 1] = {value = name, label = PRT.ClassColoredName(name)}
  end
  return values
end

local function GroupTargets()
  local values = {}
  for group = 1, 8 do
    values[group] = {value = "$group" .. group, label = L["Group %d"]:format(group)}
  end
  return values
end

-- Class colored names; classes this client doesn't have are left out.
local function ClassTargets()
  local values = {}
  for token, classID in pairs(PRT.Static.ClassTokens) do
    local name, classFile = GetClassInfo(classID)
    if name then
      local color = RAID_CLASS_COLORS[classFile]
      values[#values + 1] = {value = "$" .. token, label = color and color:WrapTextInColorCode(name) or name, name = name}
    end
  end
  table.sort(
    values,
    function(a, b)
      return a.name < b.name
    end
  )
  return values
end

local function TargetGroups()
  return {
    {label = L["Roles"], values = ROLE_TARGETS},
    {label = L["Your group"], values = MemberTargets()},
    {label = L["Raid groups"], values = GroupTargets()},
    {label = L["Classes"], values = ClassTargets()}
  }
end

-- Targets that are no chip: typed by hand (e.g. a player outside the group).
local function OtherTargets(message, groups)
  local known = {}
  for _, group in ipairs(groups) do
    for _, entry in ipairs(group.values) do
      known[entry.value] = true
    end
  end
  local others = {}
  for _, target in ipairs(message.targets) do
    if not known[target] then
      others[#others + 1] = target
    end
  end
  return others, known
end

local function TargetRows(message)
  local groups = TargetGroups()
  local rows = {}
  for _, group in ipairs(groups) do
    if #group.values > 0 then
      rows[#rows + 1] = {
        type = "multiselect",
        label = group.label,
        values = group.values,
        layout = true,
        get = function(value)
          return Has(message.targets, value)
        end,
        set = function(value, selected)
          SetTarget(message, value, selected)
        end
      }
    end
  end
  rows[#rows + 1] = {
    type = "text",
    label = L["More targets"],
    note = L["Players outside your group, separated by commas."],
    placeholder = "Name, Name-Realm",
    layout = true,
    get = function()
      return table.concat((OtherTargets(message, groups)), ", ")
    end,
    set = function(value)
      local _, known = OtherTargets(message, groups)
      local targets = {}
      for _, target in ipairs(message.targets) do
        if known[target] then
          targets[#targets + 1] = target
        end
      end
      for name in (value or ""):gmatch("[^,]+") do
        name = strtrim(name)
        if name ~= "" and not Has(targets, name) then
          targets[#targets + 1] = name
        end
      end
      message.targets = targets
    end
  }
  return rows
end

-------------------------------------------------------------------------------
-- Rows per type

local function OverlayValues()
  local values = {}
  for index, receiver in ipairs(PRT.GetProfileDB().overlay.receivers) do
    values[#values + 1] = {value = index, label = ("%d: %s"):format(index, receiver.label or "")}
  end
  return values
end

local function RaidMarkerChips(message)
  local values = {}
  for marker = 1, 8 do
    values[marker] = {value = marker, label = RAID_TARGET_ICON:format(marker)}
  end
  return {
    type = "chips",
    values = values,
    get = function()
    end,
    set = function(marker)
      message.message = (message.message or "") .. ("{rt%d}"):format(marker)
    end
  }
end

local function SetCooldown(message, spellID)
  message.spellID = spellID
  local overlay = COOLDOWN_PURPOSE[spellID] and PRT.ReceiverOverlay.IndexForPurpose(COOLDOWN_PURPOSE[spellID])
  if overlay then
    message.targetOverlay = overlay
  end
  message.hasCustomSpellID = nil
  message.message = CooldownText(message)
  local sound = spellID and COOLDOWN_SOUNDS[spellID]
  if sound and LSM:Fetch("sound", sound, true) then
    message.useCustomSound = true
    message.soundFileName = sound
    message.soundFile = LSM:Fetch("sound", sound, true)
  end
end

local function CooldownValues()
  local values = {}
  for _, purpose in ipairs({"healing", "utility"}) do
    for _, spellID in ipairs(COOLDOWNS[purpose]) do
      local name = SpellName(spellID)
      if name then
        values[#values + 1] = {value = spellID, label = PRT.TextureStringBySpellID(spellID, 14) .. " " .. name}
      end
    end
  end
  return values
end

local function TextRows(message)
  return {
    {
      type = "textarea",
      label = L["Text"],
      note = L["`{rt1}` raid marker, `{spell:31821}` spell icon, `%.0f` remaining seconds."],
      height = 44,
      layout = true,
      get = function()
        return message.message or ""
      end,
      set = function(value)
        message.message = value
      end
    },
    RaidMarkerChips(message),
    {
      type = "spell",
      label = L["Add spell icon"],
      layout = true,
      get = function()
      end,
      set = function(spellID)
        if spellID then
          message.message = (message.message or "") .. ("{spell:%d}"):format(spellID)
        end
      end
    }
  }
end

local function SetType(message, value)
  message.type = value
  if value == "cooldown" then
    message.withCountdown = message.withCountdown ~= false
    message.message = CooldownText(message)
  end
end

local function TypeRows(message)
  local rows = {
    {
      type = "chips",
      values = TYPES,
      get = function()
        return message.type or "advanced"
      end,
      set = function(value)
        SetType(message, value)
      end
    }
  }
  local function Add(row)
    rows[#rows + 1] = row
  end

  if message.type == "cooldown" then
    Add(
      {
        type = "dropdown",
        label = L["Cooldown"],
        values = CooldownValues,
        placeholder = L["Choose"],
        layout = true,
        get = function()
          return message.spellID
        end,
        set = function(spellID)
          SetCooldown(message, spellID)
        end
      }
    )
    Add(
      {
        type = "spell",
        label = L["Other spell"],
        layout = true,
        get = function()
          return message.spellID
        end,
        set = function(spellID)
          SetCooldown(message, spellID)
        end
      }
    )
    Add(
      {
        type = "text",
        label = L["Text"],
        note = L["Empty: the spell's name."],
        placeholder = SpellName(message.spellID),
        get = function()
          return message.cooldownText or ""
        end,
        set = function(value)
          value = strtrim(value or "")
          message.cooldownText = value ~= "" and value or nil
          message.message = CooldownText(message)
        end
      }
    )
    Add(
      {
        type = "checkbox",
        label = L["Countdown"],
        note = L["Shows the remaining seconds after the text."],
        layout = true,
        get = function()
          return message.withCountdown
        end,
        set = function(value)
          message.withCountdown = value
          message.message = CooldownText(message)
        end
      }
    )
  else
    for _, row in ipairs(TextRows(message)) do
      Add(row)
    end
    do
      Add(
        {
          type = "checkbox",
          label = L["Countdown in the text"],
          note = L["Adds `%.0f`: the remaining seconds."],
          layout = true,
          get = function()
            return HasCountdown(message.message)
          end,
          set = function(value)
            if value then
              message.message = (message.message or "") .. " %.0f"
            else
              message.message = PRT.ReceiverOverlay.WithoutTime(message.message or "")
            end
          end
        }
      )
    end
  end
  return rows
end

-------------------------------------------------------------------------------
-- Undo and templates

-- State of each message when its editor was first opened in this session.
local snapshots = setmetatable({}, {__mode = "k"})

local function Overwrite(message, source)
  wipe(message)
  for key, value in pairs(PRT.TableUtils.Clone(source)) do
    message[key] = value
  end
end

local function TemplateValues()
  local values = {}
  for _, name in ipairs(SortedKeys(PRT.GetProfileDB().templateStore.messages)) do
    values[#values + 1] = {value = name, label = name}
  end
  return values
end

local function ToolsCard(message, context)
  local rows = {
    {
      type = "button",
      label = L["Undo changes"],
      note = L["Back to how it was when you opened it."],
      buttonText = L["Undo"],
      layout = true,
      onClick = function()
        if snapshots[message] then
          Overwrite(message, snapshots[message])
        end
      end
    }
  }
  if not context.isTemplate then
    if next(PRT.GetProfileDB().templateStore.messages) then
      rows[#rows + 1] = {
        type = "dropdown",
        label = L["Load template"],
        note = L["Replaces this message."],
        values = TemplateValues,
        placeholder = L["Choose"],
        layout = true,
        get = function()
        end,
        set = function(name)
          local template = PRT.GetProfileDB().templateStore.messages[name]
          if template then
            Overwrite(message, template)
            message.name = nil
          end
        end
      }
    end
    rows[#rows + 1] = {
      type = "button",
      label = L["Save as template"],
      note = L["Rename it on the Templates page."],
      buttonText = L["Save"],
      onClick = function()
        local store = PRT.GetProfileDB().templateStore.messages
        -- Named after its text without markers, icons and countdown.
        local text = (message.message or ""):gsub("{.-}", ""):gsub("%%%S*", ""):gsub("%s+", " ")
        local base = strtrim(text):sub(1, 40)
        if base == "" then
          base = L["Template"]
        end
        local name, index = base, 2
        while store[name] do
          name, index = ("%s (%d)"):format(base, index), index + 1
        end
        local template = PRT.TableUtils.Clone(message)
        template.name = name
        store[name] = template
        PRT.Info(L["Template %s saved."]:format(PRT.HighlightString(name)))
      end
    }
  end
  if context.onRemove then
    rows[#rows + 1] = {
      type = "button",
      label = L["Delete assignment"],
      buttonText = L["Delete"],
      danger = true,
      onClick = function()
        UI.Confirm(L["Delete this assignment?"], L["Delete"], context.onRemove)
      end
    }
  end
  return {title = L["Tools"], rows = rows}
end

-- On the defaults page it sets the lead time of cooldowns without their own.
local function LeadTimeRow(message, context)
  local row = {
    type = "slider",
    label = L["Warn earlier"],
    note = L["Shows the message this many seconds before its time and counts down to it, then \"Now\"."],
    min = 0,
    max = 30,
    step = 0.5,
    get = function()
      return PRT.MessageLeadTime(message)
    end,
    set = function(value)
      message.leadTime = value
    end,
    -- Cooldowns without their own lead time follow the default.
    reset = message.type == "cooldown" and {
      changed = function()
        return message.leadTime ~= nil
      end,
      reset = function()
        message.leadTime = nil
      end
    } or nil
  }
  if context.isDefaults then
    row.label = L["Warn cooldowns earlier"]
    row.note = L["Seconds before their time, for cooldowns without their own setting."]
    row.reset = nil
    row.get = PRT.CooldownLeadTime
    row.set = function(value)
      PRT.MessageDefaults().cooldownLeadTime = value
    end
  end
  return row
end

-------------------------------------------------------------------------------
-- Cards

function Messages.Cards(message, context)
  context = context or {}
  PRT.NormalizeTargets(message)
  if not PRT.IsMessageSupported(message) or not message.type then
    message.type = "advanced"
  end
  UI.SetPreview({kind = "message", message = message})
  if not snapshots[message] then
    snapshots[message] = PRT.TableUtils.Clone(message)
  end

  local whatRows = {
    {
      type = "live",
      get = function()
        return Sentence(message, context)
      end
    }
  }
  for _, row in ipairs(TypeRows(message)) do
    whatRows[#whatRows + 1] = row
  end
  local cards = {{title = L["Assignment"], rows = whatRows}}
  if context.timing then
    cards[#cards + 1] = WhenCard(context)
  end
  cards[#cards + 1] = {title = L["For whom"], note = L["Everyone selected sees the message."], rows = TargetRows(message)}

  local displayRows = {
    {
      type = "dropdown",
      label = L["Overlay"],
      values = OverlayValues,
      layout = true,
      get = function()
        return message.targetOverlay or 1
      end,
      set = function(value)
        message.targetOverlay = value
      end
    },
    LeadTimeRow(message, context),
    {
      type = "slider",
      label = L["Duration"],
      note = L["Seconds on the overlay."],
      min = 1,
      max = 60,
      step = 0.5,
      get = function()
        return message.duration or 5
      end,
      set = function(value)
        message.duration = value
      end
    },
    {
      type = "chips",
      label = L["Sound"],
      values = SOUND_MODES,
      get = function()
        return SoundMode(message)
      end,
      set = function(value)
        SetSound(message, value)
      end
    }
  }
  local soundMode = SoundMode(message)
  if soundMode == "own" then
    displayRows[#displayRows + 1] = {
      type = "sound",
      label = L["Own sound"],
      indent = 12,
      get = function()
        return message.soundFileName
      end,
      set = function(value)
        message.soundFileName = value
        message.soundFile = LSM:Fetch("sound", value, true)
      end
    }
  end
  displayRows[#displayRows + 1] = {type = "hint", label = SOUND_NOTES[soundMode]}
  cards[#cards + 1] = {title = L["Display"], rows = displayRows}
  cards[#cards + 1] = ToolsCard(message, context)
  return cards
end

-------------------------------------------------------------------------------
-- Sentence

-- Stands for several targets in the single choice of the sentence.
local SEVERAL_TARGETS = "\001several"

local function SentenceTargets(message)
  local values = {}
  if #message.targets ~= 1 then
    local labels = Messages.TargetLabels(message)
    values[1] = {value = SEVERAL_TARGETS, label = labels ~= "" and labels or L["nobody"]}
  end
  for _, list in ipairs({ROLE_TARGETS, MemberTargets(), GroupTargets()}) do
    for _, entry in ipairs(list) do
      values[#values + 1] = entry
    end
  end
  return values
end

-- The assignment as one editable sentence for a flow row: "At [1:05] show
-- [text] to [Healer] on [Messages] for [5] s · Sound [Overlay|Own|TTS]".
-- Times other than once are shown as text and edited in the full editor.
function Messages.SentenceItems(message, timing)
  PRT.NormalizeTargets(message)
  local items = {{kind = "text", text = L["At"]}}
  if WhenMode(timing) == "once" then
    items[#items + 1] = {
      kind = "input",
      width = 56,
      placeholder = "1:30",
      get = function()
        return Widgets.FormatTime(FirstSecond(timing) + (timing.offset or 0))
      end,
      set = function(text)
        local times = Widgets.ParseTimeList(text)
        if times[1] then
          timing.seconds, timing.offset = {times[1]}, nil
        end
      end
    }
  else
    items[#items + 1] = {kind = "text", text = ("|cff%s%s|r"):format(Widgets.BRAND_HEX, Messages.WhenText(timing))}
  end
  items[#items + 1] = {kind = "text", text = L["show"]}
  if message.type == "cooldown" then
    items[#items + 1] = {
      kind = "dropdown",
      width = 190,
      values = CooldownValues,
      placeholder = L["Choose"],
      get = function()
        return message.spellID
      end,
      set = function(spellID)
        SetCooldown(message, spellID)
      end
    }
  else
    items[#items + 1] = {
      kind = "input",
      width = 220,
      placeholder = L["Text"],
      tooltipTitle = L["Text"],
      tooltip = L["`{rt1}` raid marker, `{spell:31821}` spell icon, `%.0f` remaining seconds."],
      get = function()
        return message.message or ""
      end,
      set = function(value)
        message.message = value
      end
    }
  end
  items[#items + 1] = {kind = "text", text = L["to"]}
  items[#items + 1] = {
    kind = "dropdown",
    width = 150,
    values = function()
      return SentenceTargets(message)
    end,
    tooltipTitle = L["For whom"],
    tooltip = L["Several targets, classes and players outside your group: More."],
    get = function()
      return #message.targets == 1 and message.targets[1] or SEVERAL_TARGETS
    end,
    set = function(value)
      if value ~= SEVERAL_TARGETS then
        message.targets = {value}
      end
    end
  }
  items[#items + 1] = {kind = "text", text = L["on"]}
  items[#items + 1] = {
    kind = "dropdown",
    width = 140,
    values = OverlayValues,
    get = function()
      return message.targetOverlay or 1
    end,
    set = function(value)
      message.targetOverlay = value
    end
  }
  items[#items + 1] = {kind = "text", text = L["for"]}
  items[#items + 1] = {
    kind = "input",
    width = 40,
    get = function()
      return tostring(message.duration or 5)
    end,
    set = function(text)
      local seconds = tonumber((text or ""):match("^%s*(%d+%.?%d*)"))
      if seconds then
        message.duration = math.max(1, math.min(60, seconds))
      end
    end
  }
  items[#items + 1] = {kind = "text", text = L["s"]}
  items[#items + 1] = {kind = "space"}
  items[#items + 1] = {kind = "text", text = L["Sound"], dim = true}
  items[#items + 1] = {
    kind = "chips",
    values = SOUND_MODES,
    get = function()
      return SoundMode(message)
    end,
    set = function(value)
      SetSound(message, value)
    end
  }
  return items
end

-- Message or cooldown, as chips for a flow row.
function Messages.TypeItem(message)
  return {
    kind = "chips",
    values = TYPES,
    get = function()
      return message.type or "advanced"
    end,
    set = function(value)
      SetType(message, value)
    end
  }
end
