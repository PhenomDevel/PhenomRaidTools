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
                groups, group, setGroup(index) = move it to another group,
                onRemove(), isTemplate }
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

-- A repeating assignment never shows more often than this.
local MAX_REPEATS = 100

-------------------------------------------------------------------------------
-- Text

local function MessageDefaults()
  return PRT.GetProfileDB().triggerDefaults.messageDefaults
end

local function HasCountdown(text)
  return text and text:gsub("%%%%", ""):find("%%[-+ #0]*%d*%.?%d*[dfgs]") ~= nil
end

-- Text of a cooldown message from the patterns of the defaults.
local function CooldownText(message)
  local defaults = MessageDefaults()
  local pattern
  if message.withCountdown then
    pattern = defaults.defaultCooldownWithCountdownPattern or "{spell:%s} %%.0f {spell:%s}"
  else
    pattern = defaults.defaultCooldownWithoutCountdownPattern or "{spell:%s}"
  end
  local ok, text = pcall(string.format, pattern, message.spellID or "", message.spellID or "")
  return ok and text or ("{spell:%s}"):format(message.spellID or "")
end

local function SpellName(spellID)
  local info = spellID and C_Spell.GetSpellInfo(tonumber(spellID) or spellID)
  return info and info.name
end

-- What the player will see (names resolved in the current group).
function Messages.DisplayText(message)
  local text = PRT.PrepareMessageForDisplay(message.message or "")
  if message.type == "cooldown" then
    local name = SpellName(message.spellID)
    if name then
      text = PRT.ReceiverOverlay.WithoutTime(text) .. " " .. name
    end
  end
  return PRT.ReceiverOverlay.WithoutTime(text)
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

function Messages.Summary(message)
  PRT.NormalizeTargets(message)
  local text = Messages.DisplayText(message)
  local targets = table.concat(message.targets, ", ")
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
  local what =
    L["show %s to %s on %s for %s s"]:format(
    Messages.DisplayText(message),
    Messages.TargetsText(message) ~= "" and Messages.TargetsText(message) or L["nobody"],
    overlay and overlay.label or "?",
    message.duration or 5
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
  if context.groups then
    rows[#rows + 1] = {
      type = "dropdown",
      label = L["Group"],
      values = context.groups,
      layout = true,
      get = function()
        return context.group
      end,
      set = context.setGroup
    }
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

local function ClassTargets()
  local values = {}
  for _, token in ipairs(SortedKeys(PRT.Static.ClassTokens)) do
    values[#values + 1] = {value = "$" .. token, label = "$" .. token}
  end
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

local function TypeRows(message)
  local rows = {
    {
      type = "chips",
      values = TYPES,
      get = function()
        return message.type or "advanced"
      end,
      set = function(value)
        message.type = value
        if value == "cooldown" then
          message.withCountdown = message.withCountdown ~= false
          message.message = CooldownText(message)
        end
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
        type = "checkbox",
        label = L["Countdown"],
        note = L["Shows the remaining seconds next to the icon."],
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

local templateName = ""

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
      type = "text",
      label = L["Save as template"],
      placeholder = L["Template name"],
      get = function()
        return templateName
      end,
      set = function(value)
        templateName = value
      end
    }
    rows[#rows + 1] = {
      type = "button",
      label = "",
      buttonText = L["Save"],
      layout = true,
      onClick = function()
        local name = strtrim(templateName or "")
        local store = PRT.GetProfileDB().templateStore.messages
        if name == "" then
          PRT.Warn(L["Enter a name for the template first."])
        elseif store[name] then
          PRT.Warn(L["A template named %s already exists."]:format(PRT.HighlightString(name)))
        else
          local template = PRT.TableUtils.Clone(message)
          template.name = name
          store[name] = template
          templateName = ""
          PRT.Info(L["Template %s saved."]:format(PRT.HighlightString(name)))
        end
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
      type = "checkbox",
      label = L["Own sound"],
      note = L["Otherwise the overlay's sound plays."],
      layout = true,
      get = function()
        return message.useCustomSound
      end,
      set = function(value)
        message.useCustomSound = value
      end
    }
  }
  if message.useCustomSound then
    displayRows[#displayRows + 1] = {
      type = "sound",
      label = L["Sound"],
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
  cards[#cards + 1] = {title = L["Display"], rows = displayRows}
  cards[#cards + 1] = ToolsCard(message, context)
  return cards
end

