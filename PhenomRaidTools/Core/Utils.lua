local _, PRT = ...
local AceTimer = LibStub("AceTimer-3.0")

-- Own timer handles: CancelAllTimers() on the library itself would also cancel
-- timers that other addons schedule on the library directly.
PRT.Timer = {}
AceTimer:Embed(PRT.Timer)

-- Everything that belongs to the running encounter; cancelled when it ends.
PRT.EncounterTimer = {}
AceTimer:Embed(PRT.EncounterTimer)

local classColors = {
  [0] = nil,
  [1] = "FFC79C6E",
  [2] = "FFF58CBA",
  [3] = "FFABD473",
  [4] = "FFFFF569",
  [5] = "FFFFFFFF",
  [6] = "FFC41F3B",
  [7] = "FF0070DE",
  [8] = "FF69CCF0",
  [9] = "FF9482C9",
  [10] = "FF00FF96",
  [11] = "FFFF7D0A",
  [12] = "FFA330C9",
  [13] = "FF33937F"
}

-- Create local copies of API functions which we use
local UnitClass, UnitName = UnitClass, UnitName
local GetRaidRosterInfo, GetUnitName, GetNumGroupMembers, UnitInParty, UnitInRaid = GetRaidRosterInfo, GetUnitName, GetNumGroupMembers, UnitInParty, UnitInRaid

-------------------------------------------------------------------------------
-- Public API

-------------------------------------------------------------------------------
-- Misc

function PRT.Round(num, decimals)
  local mult = 10 ^ (decimals or 0)
  return math.floor(num * mult + 0.5) / mult
end

function PRT.SecondsToClock(input)
  local seconds = tonumber(input)

  if seconds <= 0 then
    return "00:00:00"
  else
    local mins = string.format("%02.f", math.floor(seconds / 60))
    local secs = string.format("%02.f", math.floor(seconds - mins * 60))
    return mins .. ":" .. secs
  end
end

-------------------------------------------------------------------------------
-- Table Helper

-------------------------------------------------------------------------------
-- Encounter Helper

function PRT.EnsureEncounterTrigger(encounter)
  if encounter and not encounter.Timers then
    encounter.Timers = {}
  end
end

function PRT.GetEncounterById(encounters, id)
  local _, encounter = PRT.TableUtils.GetBy(encounters, "id", id)
  return id, encounter
end

function PRT.GetSelectedVersionEncounterByID(encounters, id)
  local _, encounter = PRT.TableUtils.GetBy(encounters, "id", id)

  if encounter then
    return id, encounter.versions[encounter.selectedVersion]
  end
end

-------------------------------------------------------------------------------
-- String Helper

function PRT.ClassColoredName(name)
  if name then
    local _, _, classIndex = UnitClass(string.gsub(name, "-.*", ""))
    local color = classColors[classIndex]
    local coloredName

    if color then
      coloredName = PRT.ColoredString(name, color, true)
    else
      coloredName = name
    end
    return coloredName
  else
    return name
  end
end

function PRT.ColoredString(s, color, hasAlpha)
  if color then
    local finalColor = color

    if not hasAlpha then
      finalColor = "FF" .. finalColor
    end
    return "|c" .. finalColor .. tostring(s) .. "|r"
  else
    return "|c" .. "FFFFFFFF" .. tostring(s) .. "|r"
  end
end

function PRT.HighlightString(s)
  return "`" .. PRT.ColoredString(s, PRT.Static.Colors.Highlight) .. "`"
end

-- nil for unknown spells (C_Spell.GetSpellInfo returns nil, e.g. a typo or a
-- spell from another client).
function PRT.SpellIcon(spellID)
  local spellInfo = spellID and tonumber(spellID) and C_Spell.GetSpellInfo(tonumber(spellID))
  return spellInfo and (spellInfo.originalIconID or spellInfo.iconID)
end

function PRT.TextureStringBySpellID(spellID, size)
  return PRT.TextureString(PRT.SpellIcon(spellID), size)
end

function PRT.TextureString(id, size)
  return "|T" .. (id or "Interface\\Icons\\INV_MISC_QUESTIONMARK") .. ":" .. (size or 16) .. ":" .. (size or 16) .. ":0:0:64:64:6:58:6:58|t"
end

function PRT.ExchangeRaidTargets(s)
  return string.gsub(s, "{rt([^}])}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:16|t")
end

function PRT.ExchangeSpellIcons(s)
  return string.gsub(
    s,
    "{spell:([^}]+)}",
    function(match)
      return PRT.TextureString(PRT.SpellIcon(match))
    end
  )
end

function PRT.PlayerNamesByToken(token)
  local playerNames = {}

  if token == "me" then
    tinsert(playerNames, strtrim(UnitName("player"), " "))
  elseif token:match("^group%d$") then
    local groupNumber = tonumber(string.match(token, "%d+"))

    for i = 1, 40, 1 do
      local name, _, group = GetRaidRosterInfo(i)
      if name and group and (groupNumber == group) then
        tinsert(playerNames, strtrim(name, " "))
      end
    end
  elseif tContains(PRT.TableUtils.Keys(PRT.Static.ClassTokens), token) then
    -- Go through all raid players and check for class
    local tokenClassIndex = PRT.Static.ClassTokens[token]
    for i = 1, 40, 1 do
      local unitID = "raid" .. i
      local _, _, unitClass = UnitClass(unitID)
      if unitClass == tokenClassIndex then
        local unitName = UnitName(unitID)
        tinsert(playerNames, strtrim(unitName, " "))
      end
    end
  end

  if PRT.TableUtils.IsEmpty(playerNames) then
    tinsert(playerNames, PRT.ColoredString(token, PRT.Static.Colors.Inactive))
  end

  return playerNames
end

function PRT.ReplaceToken(token)
  local playerNames = PRT.PlayerNamesByToken(token)
  return strjoin(", ", unpack(playerNames))
end

function PRT.ReplacePlayerNameTokens(s)
  if s then
    return string.gsub(s, "[$]+([^$, ]*)", PRT.ReplaceToken)
  end
end

function PRT.PrepareMessageForDisplay(s)
  if s then
    local updatedString = PRT.ReplacePlayerNameTokens(PRT.ExchangeSpellIcons(PRT.ExchangeRaidTargets(s:gsub("||", "|"))))
    return updatedString
  else
    return ""
  end
end

function PRT.RGBAToHex(r, g, b, a)
  return format("%02x%02x%02x%02x", (a * 255), (r * 255), (g * 255), (b * 255))
end

function PRT.RandomNumber()
  return (PRT.Time() + random(100000))
end

-------------------------------------------------------------------------------
-- Date Helper

function PRT.Now()
  return date("%d.%m.%y - %H:%M:%S")
end

function PRT.Time()
  return time()
end

-------------------------------------------------------------------------------
-- Unit Helper

function PRT.UnitFullName(unitID)
  return GetUnitName(unitID, true)
end

function PRT.PartyNames(withServer)
  local names = {}
  local myName = UnitName("player")

  if withServer then
    myName = PRT.UnitFullName("player")
  end

  for i = 1, GetNumGroupMembers() do
    local index = PRT.UnitIDByGroupType(i)
    local playerName = UnitName(index)

    if withServer then
      playerName = PRT.UnitFullName(index)
    end

    if playerName ~= myName then
      tinsert(names, playerName)
    end
  end

  -- Always add the own character into the list
  tinsert(names, myName)

  return names
end

function PRT.UnitInParty(unit)
  if unit then
    return UnitInParty(unit) or UnitInRaid(unit)
  end
  return false
end

function PRT.PlayerInParty()
  return PRT.UnitInParty("player")
end

function PRT.UnitIDByGroupType(idx)
  if UnitInRaid("player") then
    return "raid" .. idx
  elseif UnitInParty("player") then
    return "party" .. idx
  end
end

function PRT.IsEnabled()
  return PRT.GetProfileDB().enabled
end

function PRT.IsSender()
  return PRT.GetProfileDB().senderMode
end

function PRT.IsReceiver()
  return PRT.GetProfileDB().receiverMode
end

function PRT.IsTestMode()
  return PRT.GetProfileDB().testMode
end

-- Version strings don't compare across clients (WoW: Forever reports 1.x), so
-- go by interface number.
function PRT.IsRetail()
  return select(4, GetBuildInfo()) >= 120000
end

-------------------------------------------------------------------------------
-- API compatibility (12.0 moved several globals into C_ namespaces; WoW: Forever
-- may not provide all of them)

local function FirstFunction(namespace, name, global)
  return (namespace and namespace[name]) or global
end

local getSpecialization = FirstFunction(C_SpecializationInfo, "GetSpecialization", _G.GetSpecialization)
local getSpecializationInfo = FirstFunction(C_SpecializationInfo, "GetSpecializationInfo", _G.GetSpecializationInfo)
local getNumSpecializations = FirstFunction(C_SpecializationInfo, "GetNumSpecializationsForClassID", nil)
local isEncounterInProgress = FirstFunction(C_InstanceEncounter, "IsEncounterInProgress", _G.IsEncounterInProgress)
local sendChatMessage = FirstFunction(C_ChatInfo, "SendChatMessage", _G.SendChatMessage)

function PRT.HasSpecializations()
  return getSpecialization ~= nil and getSpecializationInfo ~= nil
end

function PRT.GetSpecialization()
  return getSpecialization and getSpecialization()
end

function PRT.GetSpecializationInfo(specIndex)
  if getSpecializationInfo and specIndex then
    return getSpecializationInfo(specIndex)
  end
end

function PRT.GetNumSpecializations()
  if getNumSpecializations then
    return getNumSpecializations(select(3, UnitClass("player"))) or 0
  end

  return _G.GetNumSpecializations and _G.GetNumSpecializations() or 0
end

function PRT.IsBlizzardEncounterInProgress()
  return isEncounterInProgress ~= nil and isEncounterInProgress() == true
end

function PRT.SendChatMessage(...)
  if sendChatMessage then
    sendChatMessage(...)
  end
end
