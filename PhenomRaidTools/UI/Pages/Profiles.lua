local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI

--[[
  Profiles (AceDB): switch, create, copy, reset, delete; a profile per
  specialization; the whole profile as an export string.
]]

local newName = ""
local pendingImport = {text = "", data = nil, error = nil}

-- Session state that is not part of a shared profile.
local VOLATILE = {"debugLog", "versionCheck", "clipboard", "currentEncounter"}

local function ProfileValues(exceptCurrent)
  local values = {}
  local current = PRT.GetCurrentProfile()
  local profiles = PRT.GetProfiles()
  table.sort(profiles)
  for _, name in ipairs(profiles) do
    if not exceptCurrent or name ~= current then
      values[#values + 1] = {value = name, label = name}
    end
  end
  return values
end

local function ExportString()
  local profile = PRT.TableUtils.Clone(PRT.GetProfileDB())
  for _, key in ipairs(VOLATILE) do
    profile[key] = nil
  end
  return PRT.Serialize(profile)
end

local function IsValidImport(data)
  return data.encounters and data.overlay
end

local function CheckImport(text)
  pendingImport.text = text or ""
  pendingImport.data, pendingImport.error = PRT.ParseImport(pendingImport.text, IsValidImport, L["This string contains no profile."])
end

local function ImportProfile(data)
  local profile = PRT.GetProfileDB()
  for key, value in pairs(data) do
    profile[key] = value
  end
  PRT.MigrateProfileDB(profile)
  PRT.SetupGlobalCustomPlaceholders()
  PRT.ReceiverOverlay.Refresh()
end

local function ProfileCard()
  local rows = {
    {
      type = "dropdown",
      label = L["Active profile"],
      values = ProfileValues,
      layout = true,
      get = PRT.GetCurrentProfile,
      set = PRT.SetProfile
    },
    {
      type = "text",
      label = L["New profile"],
      note = L["Starts with the defaults."],
      placeholder = L["Name"],
      get = function()
        return newName
      end,
      set = function(value)
        newName = value
      end
    },
    {
      type = "button",
      label = "",
      buttonText = L["Create"],
      layout = true,
      onClick = function()
        local name = strtrim(newName or "")
        if name ~= "" then
          newName = ""
          PRT.SetProfile(name)
        end
      end
    }
  }
  local others = ProfileValues(true)
  if #others > 0 then
    rows[#rows + 1] = {
      type = "dropdown",
      label = L["Copy from"],
      note = L["Overwrites the active profile."],
      values = others,
      placeholder = L["Choose"],
      get = function()
      end,
      set = function(name)
        UI.Confirm(
          L["Overwrite %s with %s?"]:format(PRT.GetCurrentProfile(), name),
          L["Copy"],
          function()
            PRT.CopyProfile(name)
          end
        )
      end
    }
    rows[#rows + 1] = {
      type = "dropdown",
      label = L["Delete profile"],
      values = others,
      placeholder = L["Choose"],
      get = function()
      end,
      set = function(name)
        UI.Confirm(
          L["Delete %s?"]:format(name),
          L["Delete"],
          function()
            PRT.DeleteProfile(name)
            UI.Refresh()
          end
        )
      end
    }
  end
  rows[#rows + 1] = {
    type = "button",
    label = L["Reset profile"],
    note = L["Back to the defaults: encounters, overlays and settings are gone."],
    buttonText = L["Reset"],
    danger = true,
    onClick = function()
      UI.Confirm(
        L["Reset %s?"]:format(PRT.GetCurrentProfile()),
        L["Reset"],
        function()
          PRT.ResetProfile()
        end
      )
    end
  }
  return {title = L["Profile"], rows = rows}
end

local function SpecCard()
  local settings = PRT.GetCharDB().profileSettings.specSpecificProfiles
  local rows = {}
  if settings.enabled then
    for specIndex = 1, PRT.GetNumSpecializations() do
      local _, specName, _, icon = PRT.GetSpecializationInfo(specIndex)
      if specName then
        rows[#rows + 1] = {
          type = "dropdown",
          label = ("|T%s:14|t %s"):format(icon or "", specName),
          values = ProfileValues,
          placeholder = L["No change"],
          get = function()
            return settings.profileBySpec[specIndex]
          end,
          set = function(name)
            settings.profileBySpec[specIndex] = name
          end
        }
      end
    end
  end
  return {
    title = L["Profile per specialization"],
    note = L["Switches the profile when you change your specialization (this character)."],
    toggle = {
      get = function()
        return settings.enabled
      end,
      set = function(value)
        settings.enabled = value
      end
    },
    rows = rows
  }
end

local function ShareCard()
  local rows = {
    {
      type = "textarea",
      label = L["Export"],
      note = L["The whole profile. Click to select, then copy with Ctrl+C."],
      readOnly = true,
      get = ExportString
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
  elseif pendingImport.data then
    rows[#rows + 1] = {type = "notice", tone = "ok", label = L["A profile with %d encounter(s). Importing replaces the active profile."]:format(#pendingImport.data.encounters)}
    rows[#rows + 1] = {
      type = "button",
      label = L["Replace the active profile"],
      buttonText = L["Import"],
      danger = true,
      onClick = function()
        UI.Confirm(
          L["Replace %s with the imported profile?"]:format(PRT.GetCurrentProfile()),
          L["Import"],
          function()
            ImportProfile(pendingImport.data)
            CheckImport("")
            UI.Refresh()
          end
        )
      end
    }
  end
  return {title = L["Share"], rows = rows}
end

UI.RegisterPage(
  {
    id = "profiles",
    label = L["Profiles"],
    order = 70,
    build = function()
      local cards = {ProfileCard()}
      if PRT.HasSpecializations() then
        cards[#cards + 1] = SpecCard()
      end
      cards[#cards + 1] = ShareCard()
      return L["Profiles"], L["Active: %s"]:format(PRT.GetCurrentProfile()), cards
    end
  }
)
