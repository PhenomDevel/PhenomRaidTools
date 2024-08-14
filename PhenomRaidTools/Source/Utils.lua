local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

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
local UnitClass, UnitExists, UnitName, UnitIsConnected, UnitIsDeadOrGhost = UnitClass, UnitExists, UnitName, UnitIsConnected, UnitIsDeadOrGhost
local GetRaidRosterInfo, GetUnitName, GetNumGroupMembers, UnitInParty, UnitInRaid = GetRaidRosterInfo, GetUnitName, GetNumGroupMembers, UnitInParty, UnitInRaid

-------------------------------------------------------------------------------
-- Public API

-------------------------------------------------------------------------------
-- Misc

function PRT.MaybeAddStartCondition(container, trigger)
  if trigger.hasStartCondition then
    local startConditionGroup = PRT.ConditionWidget(trigger.startCondition, L["Start Condition"])
    startConditionGroup:SetLayout("Flow")

    local removeStartConditionButton = PRT.Button(L["Remove"])
    removeStartConditionButton:SetCallback(
      "OnClick",
      function()
        trigger.hasStartCondition = false
        trigger.startCondition = nil
        PRT.Core.ReselectCurrentValue()
      end
    )
    startConditionGroup:AddChild(removeStartConditionButton)
    container:AddChild(startConditionGroup)
  else
    local addStartConditionButton = PRT.Button(L["Add Start Condition"])
    addStartConditionButton:SetCallback(
      "OnClick",
      function()
        trigger.hasStartCondition = true
        trigger.startCondition = PRT.EmptyCondition()
        PRT.Core.ReselectCurrentValue()
      end
    )
    container:AddChild(addStartConditionButton)
  end
end

function PRT.MaybeAddStopCondition(container, trigger)
  if trigger.hasStopCondition then
    local stopConditionGroup = PRT.ConditionWidget(trigger.stopCondition, L["Stop Condition"])
    stopConditionGroup:SetLayout("Flow")

    local removeStopConditionButton = PRT.Button(L["Remove"])
    removeStopConditionButton:SetCallback(
      "OnClick",
      function()
        trigger.hasStopCondition = false
        trigger.stopCondition = nil
        PRT.Core.ReselectCurrentValue()
      end
    )
    stopConditionGroup:AddChild(removeStopConditionButton)
    container:AddChild(stopConditionGroup)
  else
    local addStopConditionButton = PRT.Button(L["Add Stop Condition"])
    addStopConditionButton:SetCallback(
      "OnClick",
      function()
        trigger.hasStopCondition = true
        trigger.stopCondition = PRT.EmptyCondition()
        PRT.Core.ReselectCurrentValue()
      end
    )
    container:AddChild(addStopConditionButton)
  end
end

function PRT.NewTriggerDeleteButton(container, t, idx, label, entityName)
  local deleteButton = PRT.Button(label)
  deleteButton:SetCallback(
    "OnClick",
    function()
      PRT.ConfirmationDialog(
        L["Are you sure you want to delete %s?"]:format(PRT.HighlightString(entityName)),
        function()
          tremove(t, idx)
          PRT.Core.UpdateTree()
          PRT.mainWindowContent:DoLayout()
          container:ReleaseChildren()
        end
      )
    end
  )

  return deleteButton
end

function PRT.ConfirmationDialog(text, successFn, bodyWidgets, ...)
  if not PRT.Core.FrameExists(text) then
    local args = {...}
    local confirmationFrame = PRT.Window(L["Confirmation"])
    confirmationFrame:SetLayout("Flow")
    confirmationFrame:EnableResize(false)
    confirmationFrame.frame:SetFrameStrata("TOOLTIP")
    confirmationFrame:SetCallback(
      "OnClose",
      function()
        confirmationFrame:Hide()
        PRT.Core.UnregisterFrame(text)
      end
    )

    local textLabel = PRT.Label(text)
    textLabel:SetRelativeWidth(1)

    confirmationFrame:SetWidth(450)

    local confirmationActionsGroup = PRT.SimpleGroup()
    confirmationActionsGroup:SetLayout("Flow")
    confirmationActionsGroup:SetRelativeWidth(1)

    local okButton = PRT.Button(L["OK"])
    okButton:SetRelativeWidth(0.5)
    okButton:SetCallback(
      "OnClick",
      function(_)
        if successFn then
          successFn(unpack(args))
          confirmationFrame:Hide()
          PRT.Core.UnregisterFrame(text)
        end
      end
    )

    local cancelButton = PRT.Button(L["Cancel"])
    cancelButton:SetRelativeWidth(0.5)
    cancelButton:SetCallback(
      "OnClick",
      function(_)
        confirmationFrame:Hide()
        PRT.Core.UnregisterFrame(text)
      end
    )

    confirmationFrame:AddChild(textLabel)

    local widgetHeight = 0

    if bodyWidgets then
      for _, widget in ipairs(bodyWidgets) do
        widget:SetRelativeWidth(1)
        confirmationFrame:AddChild(widget)
        widgetHeight = widgetHeight + widget.frame:GetHeight() + 15
      end
    end

    confirmationFrame:SetHeight(max(100, textLabel.label:GetStringHeight() + textLabel.frame:GetHeight() + widgetHeight + okButton.frame:GetHeight() + 30))

    confirmationActionsGroup:AddChild(okButton)
    confirmationActionsGroup:AddChild(cancelButton)
    confirmationFrame:AddChild(confirmationActionsGroup)
    confirmationFrame:Show()
    PRT.Core.RegisterFrame(text, confirmationFrame)
  end
end

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

function PRT.CompareByName(a, b)
  return a.name < b.name
end

-------------------------------------------------------------------------------
-- Encounter Helper

function PRT.EnsureEncounterTrigger(encounter)
  if encounter then
    if not encounter.Rotations then
      encounter.Rotations = {}
    end

    if not encounter.Timers then
      encounter.Timers = {}
    end

    if not encounter.HealthPercentages then
      encounter.HealthPercentages = {}
    end

    if not encounter.PowerPercentages then
      encounter.PowerPercentages = {}
    end
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

function PRT.TextureStringBySpellID(spellID, size)
  local spellInfo = C_Spell.GetSpellInfo(tonumber(spellID))
  local texture = spellInfo.originalIconID

  return PRT.TextureString(texture, size)
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
      local spellInfo = C_Spell.GetSpellInfo(tonumber(match))
      local texture = spellInfo.originalIconID
      return "|T" .. (texture or "Interface\\Icons\\INV_MISC_QUESTIONMARK") .. ":16:16:0:0:64:64:6:58:6:58|t"
    end
  )
end

do
  local placeholders = {
    global = {},
    encounterSpecific = {}
  }

  function PRT.SetupGlobalCustomPlaceholders()
    wipe(placeholders.global)

    if PRT.GetProfileDB().customPlaceholders then
      for placeholderName, _ in pairs(PRT.GetProfileDB().customPlaceholders) do
        if not placeholders.global[placeholderName] then
          placeholders.global[placeholderName] = true
        end
      end
    end
  end

  function PRT.SetupEncounterSpecificCustomPlaceholders()
    wipe(placeholders.encounterSpecific)

    if PRT.currentEncounter.encounter.CustomPlaceholders then
      for placeholderName, _ in pairs(PRT.currentEncounter.encounter.CustomPlaceholders) do
        if not placeholders.encounterSpecific[placeholderName] then
          placeholders.encounterSpecific[placeholderName] = true
        end
      end
    end
  end

  function PRT.AddCustomPlaceholdersToPlayerNames(token, t, global)
    if not ((global and placeholders.global[token]) or (not global and placeholders.encounterSpecific[token])) then
      return
    end

    if (global and placeholders.global[token]) or placeholders.encounterSpecific[token] then
      local temp = global and PRT.GetProfileDB().customPlaceholders[token] or PRT.currentEncounter.encounter.CustomPlaceholders[token]

      if temp.type == "group" then
        for i = #temp.characterNames, 1, -1 do
          tinsert(t, strtrim(temp.characterNames[i], " "))
        end
      else
        local found = false
        local lastInPartyButDead
        for _, name in ipairs(temp.characterNames) do
          if UnitExists(name) and UnitIsConnected(name) then
            if not UnitIsDeadOrGhost(name) then
              tinsert(t, strtrim(name, " "))
              found = true
              break
            else -- so you can call for backup if needed
              lastInPartyButDead = name
            end
          end
        end
        if not found and lastInPartyButDead then
          tinsert(t, strtrim(lastInPartyButDead, " "))
        end
      end
    end
  end
end

function PRT.PlayerNamesByToken(token)
  local playerNames = {}

  if token == "me" then
    tinsert(playerNames, strtrim(UnitName("player"), " "))
  elseif PRT.GetProfileDB().raidRoster[token] then
    local name = PRT.GetProfileDB().raidRoster[token]
    tinsert(playerNames, strtrim(name, " "))
  elseif string.find(token, "group") then
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
  elseif PRT.GetProfileDB().customPlaceholders then
    PRT.AddCustomPlaceholdersToPlayerNames(token, playerNames, true)
    if PRT.currentEncounter and PRT.currentEncounter.encounter then
      if PRT.currentEncounter.encounter.CustomPlaceholders then
        PRT.AddCustomPlaceholdersToPlayerNames(token, playerNames, false)
      end
    end
  else
    tinsert(playerNames, PRT.ColoredString(token, PRT.Static.Colors.Inactive))
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

function PRT.NewCloneName()
  return "Clone " .. PRT.RandomNumber()
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

function PRT.GUIDToNPCID(guid)
  if not guid then
    return nil
  end
  return select(6, strsplit("-", guid))
end

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

function PRT.IsInFight()
  return UnitAffectingCombat("player")
end

function PRT.EncounterInProgress()
  if PRT.currentEncounter then
    return PRT.currentEncounter.inFight
  end
end

function PRT.IsTestMode()
  return PRT.GetProfileDB().testMode
end

function PRT.HasEncounter()
  return not PRT.TableUtils.IsEmpty(PRT.currentEncounter.encounter)
end

function PRT.ParseVersionString(s)
  local numericVersionString = string.gsub(s, "[.]", "")
  local numericVersion = tonumber(numericVersionString)

  return numericVersion
end

function PRT.IsDevelopmentVersion()
  local versionString = PRT.GetProfileDB().version
  local numericVersionString = string.gsub(versionString, "[.]", "")

  return (not tonumber(numericVersionString))
end

function PRT.IsClassic()
  local wowVersion = GetBuildInfo()
  local numericVersion = PRT.ParseVersionString(wowVersion)

  -- If version is smaller than WoW: Shadowlands we assume it must be classic
  return (numericVersion < 900)
end

function PRT.IsRetail()
  return (not PRT.IsClassic())
end
