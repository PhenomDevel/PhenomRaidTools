local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local LSM = LibStub("LibSharedMedia-3.0")

local UI = PRT.UI
local Widgets = PRT.Widgets

--[[
  Assignment editor: one message (what, for whom, when, how) as cards,
  shared by the encounter timings, rotations and the templates. The first
  card reads as a sentence and updates live; "Show on my overlay" sends the
  message to this client only.

  UI.Messages.Cards(message, context) -> cards
    context = { at = seconds after the pull (optional), version = encounter
                version (its placeholders become targets) }
  UI.Messages.Summary(message) -> one line for lists and the timeline
]]

local Messages = {}
UI.Messages = Messages

local TYPES = {
  {value = "advanced", label = L["Message"]},
  {value = "cooldown", label = L["Cooldown"]},
  {value = "raidwarning", label = L["Raid warning"]},
  {value = "raidtarget", label = L["Raid marker"]}
}

local ROLE_TARGETS = {
  {value = "ALL", label = L["Everyone"]},
  {value = "TANK", label = L["Tanks"]},
  {value = "HEALER", label = L["Healer"]},
  {value = "DAMAGER", label = L["Damage"]},
  {value = "$me", label = L["Me"]}
}

local COOLDOWNS = {
  -- Raid
  64843, 265202, 740, 108280, 115310, 31884, 33891, 197721, 62618, 98008, 31821, 196718, 51052, 97462, 359816, 363534, 370960,
  -- Externals
  33206, 47788, 102342, 6940, 1022, 204018, 116849,
  -- Utility
  192077, 106898, 16191, 64901, 108281, 15286, 374968,
  -- Immunities
  642, 45438, 186265, 196555, 31224
}

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
  if message.type == "raidtarget" then
    local marker = tonumber(message.raidtarget)
    local icon = marker and marker ~= PRT.Static.TargetNoneNumber and RAID_TARGET_ICON:format(marker) or L["no marker"]
    return L["Mark %s with %s"]:format(PRT.ReplacePlayerNameTokens((message.targets or {})[1] or "?"), icon)
  end
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
  if message.type == "raidwarning" then
    return L["Raid warning: %s"]:format(text)
  elseif message.type == "raidtarget" then
    return text
  end
  local targets = table.concat(message.targets, ", ")
  return ("%s  |cff%s→ %s|r"):format(text ~= "" and text or L["(empty)"], Widgets.ACCENT_HEX, targets ~= "" and targets or L["nobody"])
end

-- The first card as a sentence: "At 1:15 show ... to ... on overlay 2 for 5 s".
local function Sentence(message, context)
  local parts = {}
  if context.at then
    parts[#parts + 1] = L["At %s"]:format(Widgets.FormatTime(context.at + (message.delay or 0)))
  end
  if message.type == "raidwarning" then
    parts[#parts + 1] = L["send the raid warning %s"]:format(Messages.DisplayText(message))
  elseif message.type == "raidtarget" then
    parts[#parts + 1] = Messages.DisplayText(message)
  else
    local overlay = PRT.GetProfileDB().overlay.receivers[message.targetOverlay or 1]
    parts[#parts + 1] =
      L["show %s to %s on %s for %s s"]:format(
      Messages.DisplayText(message),
      Messages.TargetsText(message) ~= "" and Messages.TargetsText(message) or L["nobody"],
      overlay and overlay.label or "?",
      message.duration or 5
    )
  end
  return table.concat(parts, " ")
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

local function RosterTargets()
  local values = {}
  for _, slot in ipairs(SortedKeys(PRT.GetProfileDB().raidRoster)) do
    values[#values + 1] = {value = "$" .. slot, label = ("$%s %s"):format(slot, PRT.ClassColoredName(PRT.GetProfileDB().raidRoster[slot]))}
  end
  return values
end

local function PlaceholderTargets(version, onlyPlayers)
  local values = {}
  local function Add(placeholders)
    for _, name in ipairs(SortedKeys(placeholders)) do
      if not onlyPlayers or placeholders[name].type ~= "group" then
        values[#values + 1] = {value = "$" .. name, label = "$" .. name}
      end
    end
  end
  Add(version and version.CustomPlaceholders)
  Add(PRT.GetProfileDB().customPlaceholders)
  return values
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

local function TargetGroups(version)
  return {
    {label = L["Roles"], values = ROLE_TARGETS},
    {label = L["Raid roster"], values = RosterTargets()},
    {label = L["Placeholders"], values = PlaceholderTargets(version)},
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

local function TargetRows(message, version)
  local groups = TargetGroups(version)
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
    note = L["Names or placeholders, separated by commas."],
    placeholder = "Name, $placeholder",
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
  for _, spellID in ipairs(COOLDOWNS) do
    local name = SpellName(spellID)
    if name then
      values[#values + 1] = {value = spellID, label = PRT.TextureStringBySpellID(spellID, 14) .. " " .. name}
    end
  end
  return values
end

local function TextRows(message)
  return {
    {
      type = "textarea",
      label = L["Text"],
      note = L["`{rt1}` raid marker, `{spell:31821}` spell icon, `$tank1` names, `%.0f` remaining seconds."],
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
        elseif value == "raidtarget" then
          message.raidtarget = message.raidtarget or 8
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
  elseif message.type == "raidtarget" then
    local values = {}
    for _, list in ipairs({RosterTargets(), PlaceholderTargets(nil, true), MemberTargets()}) do
      for _, entry in ipairs(list) do
        values[#values + 1] = entry
      end
    end
    Add(
      {
        type = "dropdown",
        label = L["Player"],
        values = values,
        placeholder = L["Choose"],
        layout = true,
        get = function()
          return (message.targets or {})[1]
        end,
        set = function(value)
          message.targets = {value}
        end
      }
    )
    local markers = {{value = PRT.Static.TargetNoneNumber, label = L["Remove marker"]}}
    for marker = 1, 8 do
      markers[#markers + 1] = {value = marker, label = RAID_TARGET_ICON:format(marker) .. " " .. PRT.Static.Tables.RaidTargets[marker].name:gsub(" |T.*", "")}
    end
    Add(
      {
        type = "dropdown",
        label = L["Marker"],
        values = markers,
        layout = true,
        get = function()
          return tonumber(message.raidtarget)
        end,
        set = function(value)
          message.raidtarget = value
        end
      }
    )
    Add({type = "notice", label = L["Only the lead's own plan sets markers. Setting markers during encounters may be blocked since Midnight."]})
  else
    for _, row in ipairs(TextRows(message)) do
      Add(row)
    end
    if message.type == "raidwarning" then
      Add({type = "notice", label = L["Raid warnings can't be sent during encounters since Midnight. They work before the pull and in test mode."]})
    else
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
      label = L["Try it"],
      note = L["Shows the message on your overlay, only for you."],
      buttonText = L["Show"],
      onClick = function()
        PRT.ShowTestMessage(message)
      end
    },
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
  return {title = L["Tools"], rows = rows}
end

-------------------------------------------------------------------------------
-- Cards

function Messages.Cards(message, context)
  context = context or {}
  PRT.NormalizeTargets(message)
  message.type = message.type or "advanced"
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

  if message.type ~= "raidwarning" and message.type ~= "raidtarget" then
    local whoRows = TargetRows(message, context.version)
    whoRows[#whoRows + 1] = {
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
    }
    cards[#cards + 1] = {title = L["For whom"], note = L["Everyone selected sees the message. Placeholders resolve on the pull."], rows = whoRows}
  end

  local timingRows = {
    {
      type = "slider",
      label = L["Delay"],
      note = L["Seconds after the timing."],
      min = 0,
      max = 60,
      step = 0.5,
      layout = context.at ~= nil,
      get = function()
        return message.delay or 0
      end,
      set = function(value)
        message.delay = value
      end
    }
  }
  if message.type ~= "raidwarning" and message.type ~= "raidtarget" then
    timingRows[#timingRows + 1] = {
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
    }
    timingRows[#timingRows + 1] = {
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
    if message.useCustomSound then
      timingRows[#timingRows + 1] = {
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
  end
  cards[#cards + 1] = {title = L["When and how"], rows = timingRows}
  cards[#cards + 1] = ToolsCard(message, context)
  return cards
end

