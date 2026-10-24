local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI

--[[
  Players and groups: the raid roster ($tank1, $heal1, $dd1, ...) and the
  profile's custom placeholders. Both resolve to player names when a message
  is shown. Encounter specific placeholders live on the encounter page.
]]

local ROLES = {
  {key = "tank", role = "TANK", title = L["Tanks"], slots = 3},
  {key = "heal", role = "HEALER", title = L["Healer"], slots = 6},
  {key = "dd", role = "DAMAGER", title = L["Damage"], slots = 21}
}

local PLACEHOLDER_TYPES = {
  {value = "player", label = L["Player"]},
  {value = "group", label = L["Group"]}
}

local function Roster()
  return PRT.GetProfileDB().raidRoster
end

local function Placeholders()
  local profile = PRT.GetProfileDB()
  profile.customPlaceholders = profile.customPlaceholders or {}
  return profile.customPlaceholders
end

local function SortedPlaceholderNames()
  local names = {}
  for name in pairs(Placeholders()) do
    names[#names + 1] = name
  end
  table.sort(names)
  return names
end

local function SplitNames(text)
  local names = {}
  for name in (text or ""):gmatch("[^,]+") do
    name = strtrim(name)
    if name ~= "" then
      names[#names + 1] = name
    end
  end
  return names
end

-------------------------------------------------------------------------------
-- Raid roster

-- Highest slot in use, so gaps stay visible and editable.
local function HighestSlot(key)
  local highest = 0
  for id in pairs(Roster()) do
    local slot = tonumber(id:match("^" .. key .. "(%d+)$"))
    if slot and slot > highest then
      highest = slot
    end
  end
  return highest
end

local function ImportGroup()
  local roster = Roster()
  wipe(roster)
  local counts, skipped = {}, 0
  for _, name in ipairs(PRT.PartyNames(false)) do
    local role = UnitGroupRolesAssigned(name)
    local key
    for _, entry in ipairs(ROLES) do
      if entry.role == role then
        key = entry.key
      end
    end
    if key then
      counts[key] = (counts[key] or 0) + 1
      roster[key .. counts[key]] = name
    else
      skipped = skipped + 1
    end
  end
  if skipped > 0 then
    PRT.Warn(L["%d player(s) without a group role were skipped."]:format(skipped))
  end
end

local function RoleCard(entry)
  local rows = {}
  local count = math.min(math.max(HighestSlot(entry.key) + 1, 1), math.max(entry.slots, HighestSlot(entry.key)))
  for slot = 1, count do
    local id = entry.key .. slot
    rows[#rows + 1] = {
      type = "text",
      label = ("%s %d"):format(entry.title, slot),
      note = ("`$%s`"):format(id),
      placeholder = L["Name"],
      layout = true,
      get = function()
        return Roster()[id] or ""
      end,
      set = function(value)
        value = strtrim(value or "")
        Roster()[id] = value ~= "" and value or nil
      end
    }
  end
  return {title = entry.title, rows = rows}
end

local function RosterCards()
  local cards = {
    {
      title = L["Raid roster"],
      note = L["Name the players of your raid once and use their slot as target in any message, e.g. `$tank1`."],
      rows = {
        {
          type = "button",
          label = L["Import current group"],
          note = L["Uses the group roles. Players without a role (common in WoW: Forever) are skipped."],
          buttonText = L["Import"],
          onClick = function()
            UI.Confirm(L["Replace the raid roster with your current group?"], L["Import"], ImportGroup)
          end
        },
        {
          type = "button",
          label = L["Clear raid roster"],
          buttonText = L["Clear"],
          danger = true,
          onClick = function()
            UI.Confirm(
              L["Clear the raid roster?"],
              L["Clear"],
              function()
                wipe(Roster())
              end
            )
          end
        }
      }
    }
  }
  for _, entry in ipairs(ROLES) do
    cards[#cards + 1] = RoleCard(entry)
  end
  return cards
end

-------------------------------------------------------------------------------
-- Custom placeholders

local function Changed()
  PRT.SetupGlobalCustomPlaceholders()
end

local function NewPlaceholderName()
  local placeholders, index = Placeholders(), 1
  while placeholders["Group" .. index] do
    index = index + 1
  end
  return "Group" .. index
end

local function PlaceholderItems()
  local items = {}
  for _, name in ipairs(SortedPlaceholderNames()) do
    local placeholder = Placeholders()[name]
    local count = #(placeholder.characterNames or {})
    items[#items + 1] = {
      label = "$" .. name,
      note = ("%s · %s"):format(placeholder.type == "group" and L["Group"] or L["Player"], L["%d name(s)"]:format(count))
    }
  end
  return items
end

-- Who the placeholder stands for in the current group.
local function Resolved(name)
  local names = {}
  PRT.AddCustomPlaceholdersToPlayerNames(name, names, true)
  if #names == 0 then
    return L["Nobody of these is in your group."]
  end
  return L["Right now: %s"]:format(table.concat(names, ", "))
end

local function PlaceholderPage(name)
  local placeholder = Placeholders()[name]
  return "$" .. name, L["Custom placeholder"], {
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
            if value == "" or value == name then
              return
            end
            if Placeholders()[value] then
              PRT.Error(L["A placeholder named %s already exists."]:format(PRT.HighlightString(value)))
              return
            end
            PRT.TableUtils.SwapKey(Placeholders(), name, value)
            placeholder.name = value
            Changed()
            UI.Navigate("players", value)
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
            placeholder.characterNames = SplitNames(value)
            Changed()
          end
        },
        {
          type = "live",
          get = function()
            return Resolved(name)
          end
        }
      }
    }
  }, {name}
end

-- Pasted import string and what it contains, until imported or cleared.
local pendingImport = {text = "", placeholders = nil, error = nil}

local function CheckImport(text)
  pendingImport.text, pendingImport.placeholders, pendingImport.error = text or "", nil, nil
  if pendingImport.text == "" then
    return
  end
  local ok, data = PRT.Deserialize(pendingImport.text)
  if not ok or type(data) ~= "table" then
    pendingImport.error = L["This is no PRT import string."]
  elseif data.customPlaceholders or data.CustomPlaceholders or data.encounters or data.versions then
    pendingImport.error = L["This string contains no placeholders. Did you paste an encounter?"]
  else
    pendingImport.placeholders = data
  end
end

-- Adds imported placeholders; for an existing name only the missing character
-- names. Accepts the pre-2.16 format (list, `names`) as well.
local function MergePlaceholders(imported)
  local placeholders = Placeholders()
  for _, entry in pairs(imported) do
    if type(entry) == "table" and type(entry.name) == "string" then
      local names = entry.characterNames or entry.names or {}
      local existing = placeholders[entry.name]
      if existing then
        existing.characterNames = existing.characterNames or {}
        for _, name in ipairs(names) do
          if not tContains(existing.characterNames, name) then
            tinsert(existing.characterNames, name)
          end
        end
      else
        placeholders[entry.name] = {name = entry.name, type = entry.type or "player", characterNames = PRT.TableUtils.Clone(names)}
      end
    end
  end
end

local function ImportSummary()
  local names = {}
  for _, placeholder in pairs(pendingImport.placeholders) do
    names[#names + 1] = "$" .. tostring(placeholder.name)
  end
  table.sort(names)
  return L["%d placeholder(s): %s. Existing ones with the same name get the new names added."]:format(#names, table.concat(names, ", "))
end

local function ShareCard()
  local rows = {
    {
      type = "textarea",
      label = L["Export"],
      note = L["Click to select, then copy with Ctrl+C."],
      readOnly = true,
      get = function()
        return PRT.Serialize(Placeholders())
      end
    },
    {
      type = "textarea",
      label = L["Import"],
      placeholder = L["Paste an export string"],
      layout = true,
      get = function()
        return pendingImport.text
      end,
      set = CheckImport
    }
  }
  if pendingImport.error then
    rows[#rows + 1] = {type = "notice", tone = "danger", label = pendingImport.error}
  elseif pendingImport.placeholders then
    rows[#rows + 1] = {type = "notice", tone = "ok", label = ImportSummary()}
    rows[#rows + 1] = {
      type = "button",
      label = L["Add to my placeholders"],
      buttonText = L["Import"],
      layout = true,
      onClick = function()
        MergePlaceholders(pendingImport.placeholders)
        Changed()
        CheckImport("")
        PRT.Info(L["Placeholders imported."])
      end
    }
  end
  return {title = L["Share"], rows = rows}
end

local function PlaceholderCards()
  return {
    {
      title = L["Custom placeholders"],
      note = L["Names for players or groups of players, used as message targets. An encounter can add its own."],
      rows = {
        {
          type = "list",
          items = PlaceholderItems,
          empty = L["No placeholders yet."],
          onClick = function(index)
            UI.Push(SortedPlaceholderNames()[index])
          end,
          onRemove = function(index)
            Placeholders()[SortedPlaceholderNames()[index]] = nil
            Changed()
          end,
          confirmRemove = function(index)
            return L["Remove %s?"]:format("$" .. SortedPlaceholderNames()[index])
          end,
          onAdd = function()
            local name = NewPlaceholderName()
            Placeholders()[name] = {name = name, type = "group", characterNames = {}}
            Changed()
            UI.Push(name)
          end,
          addLabel = L["New placeholder"]
        }
      }
    },
    ShareCard()
  }
end

-------------------------------------------------------------------------------

local function Concat(...)
  local result = {}
  for _, list in ipairs({...}) do
    for _, entry in ipairs(list) do
      result[#result + 1] = entry
    end
  end
  return result
end

UI.RegisterPage(
  {
    id = "players",
    label = L["Players & groups"],
    order = 30,
    build = function(path)
      if path[1] and Placeholders()[path[1]] then
        return PlaceholderPage(path[1])
      end
      return L["Players & groups"], L["Raid roster and placeholders for message targets"], Concat(PlaceholderCards(), RosterCards())
    end
  }
)
