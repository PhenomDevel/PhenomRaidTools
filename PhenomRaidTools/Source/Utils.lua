local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

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
  [12] = "FFA330C9"
}

-- Create local copies of API functions which we use
local UnitClass, GetSpellInfo, UnitExists, UnitIsDead, UnitName = UnitClass, GetSpellInfo, UnitExists, UnitIsDead, UnitName
local GetRaidRosterInfo, GetUnitName, GetNumGroupMembers, UnitInParty, UnitInRaid = GetRaidRosterInfo, GetUnitName, GetNumGroupMembers, UnitInParty, UnitInRaid


-------------------------------------------------------------------------------
-- Public API

-------------------------------------------------------------------------------
-- Misc

function PRT.MaybeAddStartCondition(container, trigger)
  if trigger.hasStartCondition then
    local startConditionGroup = PRT.ConditionWidget(trigger.startCondition, "conditionStartHeading")
    startConditionGroup:SetLayout("Flow")

    local removeStartConditionButton = PRT.Button("conditionRemoveStartCondition")
    removeStartConditionButton:SetCallback("OnClick",
      function()
        trigger.hasStartCondition = false
        trigger.startCondition = nil
        PRT.Core.ReselectCurrentValue()
      end)
    startConditionGroup:AddChild(removeStartConditionButton)
    container:AddChild(startConditionGroup)
  else
    local addStartConditionButton = PRT.Button("conditionAddStartCondition")
    addStartConditionButton:SetCallback("OnClick",
      function()
        trigger.hasStartCondition = true
        trigger.startCondition = PRT.EmptyCondition()
        PRT.Core.ReselectCurrentValue()
      end)
    container:AddChild(addStartConditionButton)
  end
end

function PRT.MaybeAddStopCondition(container, trigger)
  if trigger.hasStopCondition then
    local stopConditionGroup = PRT.ConditionWidget(trigger.stopCondition, "conditionStopHeading")
    stopConditionGroup:SetLayout("Flow")

    local removeStopConditionButton = PRT.Button("conditionRemoveStopCondition")
    removeStopConditionButton:SetCallback("OnClick",
      function()
        trigger.hasStopCondition = false
        trigger.stopCondition = nil
        PRT.Core.ReselectCurrentValue()
      end)
    stopConditionGroup:AddChild(removeStopConditionButton)
    container:AddChild(stopConditionGroup)
  else
    local addStopConditionButton = PRT.Button("conditionAddStopCondition")
    addStopConditionButton:SetCallback("OnClick",
      function()
        trigger.hasStopCondition = true
        trigger.stopCondition = PRT.EmptyCondition()
        PRT.Core.ReselectCurrentValue()
      end)
    container:AddChild(addStopConditionButton)
  end
end

function PRT.NewTriggerDeleteButton(container, t, idx, textID, entityName)
  local deleteButton = PRT.Button(textID)
  deleteButton:SetCallback("OnClick",
    function()
      local text = L["deleteConfirmationText"]
      if entityName then
        text = text.." "..PRT.HighlightString(entityName)
      end
      PRT.ConfirmationDialog(text,
        function()
          tremove(t, idx)
          PRT.Core.UpdateTree()
          PRT.mainWindowContent:DoLayout()
          container:ReleaseChildren()
        end)
    end)

  return deleteButton
end

function PRT.NewCloneButton(container, t, idx, textID, entityName)
  local cloneButton = PRT.Button(textID)

  cloneButton:SetCallback("OnClick",
    function()
      local text = L["cloneConfirmationText"]
      if entityName then
        text = text.." "..PRT.HighlightString(entityName)
      end
      PRT.ConfirmationDialog(text,
        function()
          local clone = PRT.TableUtils.CopyTable(t[idx])
          clone.name = clone.name.."- Clone"..random(0,100000)
          tinsert(t, clone)
          PRT.Core.UpdateTree()
          PRT.mainWindowContent:DoLayout()
          container:ReleaseChildren()
        end)
    end)

  return cloneButton
end

function PRT.ConfirmationDialog(text, successFn, bodyWidgets, ...)
  if not PRT.Core.FrameExists(text) then
    local args = {...}
    local confirmationFrame = PRT.Window("confirmationWindow")
    confirmationFrame:SetLayout("Flow")
    confirmationFrame:EnableResize(false)
    confirmationFrame.frame:SetFrameStrata("DIALOG")
    confirmationFrame:SetCallback("OnClose",
      function()
        confirmationFrame:Hide()
        PRT.Core.UnregisterFrame(text)
      end)

    local textLabel = PRT.Label(text)
    textLabel:SetRelativeWidth(1)

    confirmationFrame:SetWidth(max(430, textLabel.label:GetStringWidth() + 50))

    local okButton = PRT.Button("confirmationDialogOk")
    okButton:SetCallback("OnClick",
      function(_)
        if successFn then
          successFn(unpack(args))
          confirmationFrame:Hide()
          PRT.Core.UnregisterFrame(text)
        end
      end)

    local cancelButton = PRT.Button("confirmationDialogCancel")
    cancelButton:SetCallback("OnClick",
      function(_)
        confirmationFrame:Hide()
        PRT.Core.UnregisterFrame(text)
      end)

    confirmationFrame:AddChild(textLabel)

    local widgetHeight = 0

    if bodyWidgets then
      for _, widget in ipairs(bodyWidgets) do
        widget:SetRelativeWidth(1)
        confirmationFrame:AddChild(widget)
        widgetHeight = widgetHeight + widget.frame:GetHeight()
      end
    end

    confirmationFrame:SetHeight(max(100, textLabel.label:GetStringHeight() + textLabel.frame:GetHeight() + widgetHeight + okButton.frame:GetHeight() + 37))

    confirmationFrame:AddChild(okButton)
    confirmationFrame:AddChild(cancelButton)
    confirmationFrame:Show()
    PRT.Core.RegisterFrame(text, confirmationFrame)
  end
end

function PRT.Round(num, decimals)
  local mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult
end

function PRT.SecondsToClock(input)
  local seconds = tonumber(input)

  if seconds <= 0 then
    return "00:00:00";
  else
    local mins = string.format("%02.f", math.floor(seconds / 60));
    local secs = string.format("%02.f", math.floor(seconds - mins * 60));
    return mins..":"..secs
  end
end


-------------------------------------------------------------------------------
-- Table Helper

function PRT.TableToString(t)
  local serialized = AceSerializer:Serialize(t)
  local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})

  return LibDeflate:EncodeForPrint(compressed)
end

function PRT.StringToTable(s)
  if s and s ~= "" then
    local decoded = LibDeflate:DecodeForPrint(s)
    if decoded then
      local decompressed = LibDeflate:DecompressDeflate(decoded)

      if decompressed then
        local worked, t = AceSerializer:Deserialize(decompressed)

        return worked, t
      else
        PRT.Error("String could not be decompressed. Aborting import.")
      end
    else
      PRT.Error("String could not be decoded. Aborting import.")
    end
  end

  return nil
end

function table.mergemany(...)
  local tNew = {}

  for _, t in ipairs({...}) do
    for _, v in ipairs(t) do
      tinsert(tNew, v)
    end
  end

  return tNew
end

function table.mergecopy(t1, t2)
  local t3 = {}

  for _, v in ipairs(t1) do
    tinsert(t3, v)
  end

  for _, v in ipairs(t2) do
    tinsert(t3, v)
  end

  return t3
end

function PRT.FilterEncounterTable(encounters, id)
  if encounters then
    for i, v in ipairs(encounters) do
      if v.id == id then
        return i, v
      end
    end
  end
end

function PRT.FilterTableByName(t, name)
  if t then
    for i, v in ipairs(t) do
      if v.name == name then
        return i, v
      end
    end
  end
end

function PRT.FilterTableByID(t, id)
  if t then
    for i, v in ipairs(t) do
      if v.id == id then
        return i, v
      end
    end
  end
end

function PRT.CompareByName(a, b)
  return a.name < b.name
end

function PRT.SortTableByName(t)
  table.sort(t, PRT.CompareByName)
end


-------------------------------------------------------------------------------
-- Debug Helper

function PRT.PrintTable(t, maxRecursionDepth, recursionDepth)
  local recursionDepth = recursionDepth or 0
  local maxRecursionDepth = maxRecursionDepth or 3
  recursionDepth = recursionDepth + 1

  local prefix = ""
  if recursionDepth > 1 then
    for _ = 1, recursionDepth do
      prefix = prefix.." "
    end
    prefix = prefix.."- "
  end

  if recursionDepth == 1 then
    print("-----------------")
    print("PrintTable: "..PRT.HighlightString(tostring(t)))
  end

  if t and (recursionDepth <= maxRecursionDepth) then
    for k, v in pairs(t) do
      if type(v) == "table" then
        print(prefix.."["..k.."]")
        PRT.PrintTable(v, maxRecursionDepth, recursionDepth)
      else
        print(prefix.."["..k.."]"..": "..PRT.HighlightString(tostring(v)))
      end
    end
  end
end

function PRT.Info(...)
  if PRT.db.profile.enabled then
    PRT:Print(PRT.ColoredString("[Info]", PRT.db.profile.colors.info), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Info]", PRT.db.profile.colors.info), ...})
    end
  end
end

function PRT.Warn(...)
  if PRT.db.profile.enabled then
    PRT:Print(PRT.ColoredString("[Warn]", PRT.db.profile.colors.warn), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Warn]", PRT.db.profile.colors.warn), ...})
    end
  end
end

function PRT.Error(...)
  if PRT.db.profile.enabled then
    PRT:Print(PRT.ColoredString("[Error]", PRT.db.profile.colors.error), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Error]", PRT.db.profile.colors.error), ...})
    end
  end
end

function PRT.Debug(...)
  if PRT.db.profile.enabled then
    if PRT.db.profile.debugMode then
      PRT:Print(PRT.ColoredString("[Debug]", PRT.db.profile.colors.debug), ...)

      if PRT.currentEncounter and PRT.currentEncounter.inFight then
        tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Debug]", PRT.db.profile.colors.debug), ...})
      end
    end
  end
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


-------------------------------------------------------------------------------
-- String Helper

function PRT.ClassColoredName(name)
  if name then
    local _, _, classIndex = UnitClass(string.gsub(name, "-.*", ""))
    local color = classColors[classIndex]
    local coloredName

    if color then
      coloredName = PRT.ColoredString(name, color)
    else
      coloredName = name
    end
    return coloredName
  else
    return name
  end
end

function PRT.ColoredString(s, color)
  return "|c"..(color or "FFFFFFFF")..tostring(s).."|r"
end

function PRT.HighlightString(s)
  return "`"..PRT.ColoredString(s, PRT.db.profile.colors.highlight).."`"
end

function PRT.TextureStringBySpellID(spellID, size)
  local _, _, texture = GetSpellInfo(tonumber(spellID))

  return PRT.TextureString(texture, size)
end

function PRT.TextureString(id, size)
  if id then
    return "|T"..id..":"..(size or 16)..":"..(size or 16)..":0:0:64:64:6:58:6:58|t"
  end
end

function PRT.ExchangeRaidMarker(s)
  return string.gsub(s, "{rt([^}])}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:16|t")
end

function PRT.ExchangeSpellIcons(s)
  return string.gsub(s, "{spell:([^}]+)}",
    function(match)
      local _, _, texture = GetSpellInfo(tonumber(match))
      return "|T"..(texture or "Interface\\Icons\\INV_MISC_QUESTIONMARK")..":16:16:0:0:64:64:6:58:6:58|t"
    end)
end

function PRT.AddCustomPlaceholdersToPlayerNames(token, t, customPlaceholders)
  if customPlaceholders then
    for _, customPlaceholder in ipairs(customPlaceholders) do
      if customPlaceholder.name == token then
        if customPlaceholder.type == "group" then
          for i = #customPlaceholder.names, 1, -1 do
            tinsert(t, strtrim(customPlaceholder.names[i], " "))
          end
        else
          for _, name in ipairs(customPlaceholder.names) do
            if (PRT.UnitInParty(name) or UnitExists(name)) and not UnitIsDead(name) then
              tinsert(t, strtrim(name, " "))
              break
            end
          end
        end
      end
    end
  end
end

function PRT.PlayerNamesByToken(token)
  token = strtrim(token, " ")
  local playerNames = {}

  if token == "me" then
    tinsert(playerNames, strtrim(UnitName("player"), " "))
  elseif PRT.db.profile.raidRoster[token] then
    local name = PRT.db.profile.raidRoster[token]
    tinsert(playerNames, strtrim(name, " "))
  elseif string.find(token, "group") then
    local groupNumber = tonumber(string.match(token, "%d+"))

    for i = 1, 40, 1 do
      local name, _, group = GetRaidRosterInfo(i)
      if name and group and (groupNumber == group) then
        tinsert(playerNames, strtrim(name, " "))
      end
    end
  elseif PRT.db.profile.customPlaceholders then
    PRT.AddCustomPlaceholdersToPlayerNames(token, playerNames, PRT.db.profile.customPlaceholders)

    if PRT.currentEncounter and PRT.currentEncounter.encounter then
      if PRT.currentEncounter.encounter.CustomPlaceholders then
        PRT.AddCustomPlaceholdersToPlayerNames(token, playerNames, PRT.currentEncounter.encounter.CustomPlaceholders)
      end
    end
  else
    tinsert(playerNames, "N/A")
  end

  if PRT.TableUtils.IsEmpty(playerNames) then
    tinsert(playerNames, "N/A")
  end

  return playerNames
end

function PRT.ReplaceToken(token)
  local playerNames = PRT.PlayerNamesByToken(token)
  return strjoin(", ", unpack(playerNames))
end

function PRT.ReplacePlayerNameTokens(s)
  return string.gsub(s, "[$]+([^$, ]*)", PRT.ReplaceToken)
end

function PRT.PrepareMessageForDisplay(s)
  if s then
    return PRT.ReplacePlayerNameTokens(PRT.ExchangeSpellIcons(PRT.ExchangeRaidMarker(s:gsub("||", "|"))))
  else
    return ""
  end
end

function PRT.RGBAToHex(r,g,b,a)
  return format("%02x%02x%02x%02x", (a * 255), (r * 255), (g * 255), (b * 255))
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

    if not (playerName == myName) then
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
    return "raid"..idx
  elseif UnitInParty("player") then
    return "party"..idx
  end
end
