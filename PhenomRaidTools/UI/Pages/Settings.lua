local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI
local LibDBIcon = LibStub("LibDBIcon-1.0")

--[[
  Addon wide settings of the profile: where PRT runs, test and debug mode,
  the defaults for new messages and the version. They have no page of their
  own: the overview shows them below the status (UI.SettingsCards).
]]

local DIFFICULTIES = {
  {value = "Normal", label = L["Normal"]},
  {value = "Heroic", label = L["Heroic"]},
  {value = "Mythic", label = L["Mythic"]}
}

local TARGETS = {
  {value = "ALL", label = L["Everyone"]},
  {value = "TANK", label = L["Tanks"]},
  {value = "HEALER", label = L["Healer"]},
  {value = "DAMAGER", label = L["Damage"]},
  {value = "$me", label = L["Me"]}
}

local function Profile()
  return PRT.GetProfileDB()
end

local function Bind(getTable, key, row)
  row.get = function()
    return getTable()[key]
  end
  local set = row.set
  row.set = function(value)
    getTable()[key] = value
    if set then
      set(value)
    end
  end
  return row
end

local function Version()
  local version = C_AddOns.GetAddOnMetadata("PhenomRaidTools", "Version") or ""
  if version:find("@project", 1, true) then
    return L["Development version"]
  end
  return version
end

local function AboutCard()
  local _, _, _, interface = GetBuildInfo()
  return {
    title = L["About"],
    note = ("%s %s · %s %d"):format(L["Version"], Version(), L["Interface"], interface),
    rows = {
      {
        type = "button",
        label = L["Notes of this version"],
        buttonText = L["What's new"],
        onClick = function()
          PRT.WhatsNew.Show()
        end
      },
      {type = "description", label = L["`/prt` opens this window."]},
      {type = "description", label = L["`/prt sync` sends your plans to the group (also on every ready check)."]},
      {type = "description", label = L["`/prt versions` checks the versions in your group."]},
      {type = "description", label = L["`/prt news` shows what's new."]},
      {type = "description", label = L["`/prt minimap` shows the minimap icon again."]}
    }
  }
end

local function GeneralCard()
  return {
    title = L["General"],
    rows = {
      {
        type = "checkbox",
        label = L["Minimap icon"],
        get = function()
          return not Profile().minimap.hide
        end,
        set = function(value)
          Profile().minimap.hide = not value
          if value then
            LibDBIcon:Show("PhenomRaidTools")
          else
            LibDBIcon:Hide("PhenomRaidTools")
          end
        end
      },
      {
        type = "checkbox",
        label = L["What's new after updates"],
        note = L["Opens with `/prt news` as well."],
        get = function()
          return PRT.GetGlobalDB().whatsNew ~= false
        end,
        set = function(value)
          PRT.GetGlobalDB().whatsNew = value
        end
      },
      {
        type = "button",
        label = L["Version check"],
        note = L["Prints the PRT version of everyone in your group."],
        buttonText = L["Check"],
        onClick = function()
          LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools"):VersionCheck()
        end
      },
      {
        type = "button",
        label = L["First start guide"],
        buttonText = L["Open"],
        onClick = function()
          UI.Navigate("welcome")
        end
      }
    }
  }
end

local function DifficultyRow(kind, label)
  return {
    type = "multiselect",
    label = label,
    values = DIFFICULTIES,
    get = function(value)
      return Profile().enabledDifficulties[kind][value]
    end,
    set = function(value, selected)
      Profile().enabledDifficulties[kind][value] = selected
    end
  }
end

local function DifficultiesCard()
  return {
    title = L["Difficulties"],
    note = L["PRT only runs in these. Applies when you enter the instance."],
    rows = {DifficultyRow("raid", L["Raids"]), DifficultyRow("dungeon", L["Dungeons"])}
  }
end

local function EncounterValues()
  local values = {}
  for _, encounter in ipairs(Profile().encounters) do
    values[#values + 1] = {value = encounter.id, label = encounter.name or tostring(encounter.id)}
  end
  return values
end

local function TestCard()
  return {
    title = L["Test mode"],
    note = L["Runs an encounter's plan on your next combat, e.g. on a target dummy."],
    toggle = {
      get = function()
        return Profile().testMode
      end,
      set = function(value)
        Profile().testMode = value
      end
    },
    rows = {
      Bind(Profile, "testEncounterID", {type = "dropdown", label = L["Encounter"], values = EncounterValues, placeholder = L["Choose"]})
    }
  }
end

local function DefaultsCard()
  local function MessageDefaults()
    return Profile().triggerDefaults.messageDefaults
  end
  local overlays = {}
  for index, receiver in ipairs(Profile().overlay.receivers) do
    overlays[#overlays + 1] = {value = index, label = ("%d: %s"):format(index, receiver.label or "")}
  end
  return {
    title = L["New messages"],
    note = L["What a new message starts with."],
    rows = {
      Bind(MessageDefaults, "defaultMessage", {type = "text", label = L["Text"]}),
      {
        type = "multiselect",
        label = L["For whom"],
        values = TARGETS,
        get = function(value)
          return tContains(MessageDefaults().defaultTargets or {}, value)
        end,
        set = function(value, selected)
          local targets = {}
          for _, target in ipairs(MessageDefaults().defaultTargets or {}) do
            if target ~= value then
              targets[#targets + 1] = target
            end
          end
          if selected then
            targets[#targets + 1] = value
          end
          MessageDefaults().defaultTargets = targets
        end
      },
      {
        type = "slider",
        label = L["Duration"],
        min = 1,
        max = 60,
        step = 0.5,
        get = function()
          return MessageDefaults().defaultDuration or 5
        end,
        set = function(value)
          MessageDefaults().defaultDuration = value
        end
      },
      {
        type = "dropdown",
        label = L["Overlay"],
        values = overlays,
        get = function()
          return MessageDefaults().defaultTargetOverlay or 1
        end,
        set = function(value)
          MessageDefaults().defaultTargetOverlay = value
        end
      }
    }
  }
end

local function DebugCard()
  local rows = {}
  if Profile().debugMode then
    rows[#rows + 1] = {
      type = "textarea",
      label = L["Log of the last encounter"],
      readOnly = true,
      height = 120,
      get = function()
        local lines = {}
        for _, entry in ipairs(Profile().debugLog or {}) do
          local parts = {}
          for index = 1, #entry do
            parts[index] = tostring(entry[index])
          end
          lines[#lines + 1] = table.concat(parts, " ")
        end
        return table.concat(lines, "\n")
      end
    }
  end
  return {
    title = L["Debug mode"],
    note = L["Prints what PRT does to the chat."],
    toggle = {
      get = function()
        return Profile().debugMode
      end,
      set = function(value)
        Profile().debugMode = value
        wipe(Profile().debugLog)
      end
    },
    rows = rows
  }
end

-- Shown below the status and plans on the overview page.
function UI.SettingsCards()
  return {
    GeneralCard(),
    DifficultiesCard(),
    TestCard(),
    DefaultsCard(),
    DebugCard(),
    AboutCard()
  }
end
