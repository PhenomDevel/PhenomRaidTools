local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Core = {
  openFrames = {

  }
}

-- Create local copies of API functions which we use
local UIParent = UIParent
local UISpecialFrames = UISpecialFrames


-------------------------------------------------------------------------------
-- Local Helper

local function RegisterESCHandler(name, container)
  _G[name] = container.frame
  tinsert(UISpecialFrames, name)
end

function Core.RegisterFrame(id, frame)
  Core.openFrames[id] = frame
end

function Core.UnregisterFrame(id)
  Core.openFrames[id] = nil
end

function Core.FrameExists(text)
  local frame = Core.openFrames[text]

  if frame then
    return true
  else
    return false
  end
end

function Core.CloseAllOpenFrames()
  for _, frame in pairs(Core.openFrames) do
    frame:Hide()
  end

  wipe(Core.openFrames)
end

function Core.DisabledText(text, enabled)
  if enabled then
    return text
  else
    return PRT.ColoredString(text, PRT.db.profile.colors.disabled)
  end
end

function Core.WithDifficultiesText(text, trigger)
  local updatedText = text

  if not trigger.enabledDifficulties then
    return updatedText
  else
    local difficultiesShorthands = {}
    if trigger.enabledDifficulties.Normal then
      tinsert(difficultiesShorthands, "N")
    end

    if trigger.enabledDifficulties.Heroic then
      tinsert(difficultiesShorthands, "H")
    end

    if trigger.enabledDifficulties.Mythic then
      tinsert(difficultiesShorthands, "M")
    end

    updatedText = updatedText.." ("..strjoin(", ", unpack(difficultiesShorthands))..")"

    return updatedText
  end
end

function Core.GeneratePercentageTree(percentage)
  local t = {
    value = percentage.name,
    text = Core.DisabledText(Core.WithDifficultiesText(percentage.name, percentage), percentage.enabled)
  }

  return t
end

function Core.GeneratePercentagesTree(percentages)
  local children = {}
  local t = {
    }

  if percentages then
    if getn(percentages) > 0 then
      PRT.TableUtils.SortByKey(percentages, "name")
      t.children = children
      for _, percentage in ipairs(percentages) do
        tinsert(children, Core.GeneratePercentageTree(percentage))
      end
    end
  end

  return t
end

function Core.GeneratePowerPercentagesTree(percentages)
  local tree = Core.GeneratePercentagesTree(percentages)
  tree.value = "powerPercentages"
  tree.text = L["Power Percentage"]
  tree.icon = 132849
  tree.iconCoords = {0.1, 0.9, 0.1, 0.9}

  return tree
end

function Core.GenerateHealthPercentagesTree(percentages)
  local tree = Core.GeneratePercentagesTree(percentages)
  tree.value = "healthPercentages"
  tree.text = L["Health Percentage"]
  tree.icon = 648207
  tree.iconCoords = {0.1, 0.9, 0.1, 0.9}

  return tree
end

function Core.GenerateRotationTree(rotation)
  local t = {
    value = rotation.name,
    text = Core.DisabledText(Core.WithDifficultiesText(rotation.name, rotation), rotation.enabled)
  }

  if rotation.triggerCondition then
    if rotation.triggerCondition.spellIcon then
      t.icon = rotation.triggerCondition.spellIcon
      t.iconCoords = {0.1, 0.9, 0.1, 0.9}
    end
  end

  return t
end

function Core.GenerateRotationsTree(rotations)
  local children = {}
  local t = {
    value = "rotations",
    text = L["Rotation"],
    icon = 450907,
    iconCoords = {0.1, 0.9, 0.1, 0.9}
  }

  if rotations then
    if getn(rotations) > 0 then
      PRT.TableUtils.SortByKey(rotations, "name")
      t.children = children
      for _, rotation in ipairs(rotations) do
        tinsert(children, Core.GenerateRotationTree(rotation))
      end
    end
  end
  return t
end

function Core.GenerateTimerTree(timer)
  local t = {
    value = timer.name,
    text = Core.DisabledText(Core.WithDifficultiesText(timer.name, timer), timer.enabled)
  }

  if timer.startCondition then
    if timer.startCondition.spellIcon then
      t.icon = timer.startCondition.spellIcon
      t.iconCoords = {0.1, 0.9, 0.1, 0.9}
    end
  end

  return t
end

function Core.GenerateTimersTree(timers)
  local children = {}
  local t = {
    value = "timers",
    text = L["Timer"],
    icon = 237538,
    iconCoords = {0.1, 0.9, 0.1, 0.9}
  }

  if timers then
    if getn(timers) > 0 then
      PRT.TableUtils.SortByKey(timers, "name")
      t.children = children
      for _, timer in ipairs(timers) do
        tinsert(children, Core.GenerateTimerTree(timer))
      end
    end
  end

  return t
end

function Core.GenerateCustomPlaceholdersTree()
  local t = {
    value = "customPlaceholders",
    text = L["Placeholder"],
    icon = 134400,
    iconCoords = {0.1, 0.9, 0.1, 0.9}
  }

  return t
end

function Core.GenerateEncounterTree(encounter)
  local selectedEncounter = encounter.versions[(encounter.selectedVersion or 1)]
  -- Ensure that encounter has all trigger tables!
  PRT.EnsureEncounterTrigger(selectedEncounter)

  local t = {
    value = encounter.id,
    text = Core.DisabledText(encounter.name.." (v"..encounter.selectedVersion..")", encounter.enabled),
  }

  if selectedEncounter then
    t.children =  {
      Core.GenerateTimersTree(selectedEncounter.Timers),
      Core.GenerateRotationsTree(selectedEncounter.Rotations),
      Core.GenerateHealthPercentagesTree(selectedEncounter.HealthPercentages),
      Core.GeneratePowerPercentagesTree(selectedEncounter.PowerPercentages),
      Core.GenerateCustomPlaceholdersTree()
    }
  end

  return t
end

function Core.GenerateEncountersTree(encounters)
  local children = {}

  local t = {
    value  = "encounters",
    text = L["Encounter"],
    children = children
  }

  PRT.TableUtils.SortByKey(encounters, "name")

  for _, encounter in ipairs(encounters) do
    if encounter.versions then
      tinsert(children, Core.GenerateEncounterTree(encounter))
    end
  end

  return t
end

function Core.GenerateOptionsTree()
  local t = {
    value = "options",
    text = L["Options"]
  }
  return t
end

function Core.GenerateTemplatesTree(profile)
  if PRT.IsSender() then
    return {
      value = "templates",
      text = L["Templates"]
    }
  else

    return nil
  end
end

function Core.GenerateTreeByProfile(profile)
  local t = {
    Core.GenerateOptionsTree(),
    Core.GenerateTemplatesTree(profile)
  }

  if PRT.IsSender() then
    tinsert(t, Core.GenerateEncountersTree(profile.encounters))
  end

  return t
end

function Core.OnGroupSelected(container, key, profile)
  container:ReleaseChildren()

  local mainKey, encounterID, triggerType, triggerName = strsplit("\001", key)

  if encounterID then
    local _, selectedEncounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))
    PRT.currentEncounter = {}
    PRT.currentEncounter.encounter = selectedEncounter
    PRT.currentEncounter.encounter.id = encounterID
  end

  -- options selected
  if mainKey == "options" then
    PRT.AddOptionWidgets(container, profile)

    -- templates selected
  elseif mainKey == "templates" then
    PRT.AddTemplateWidgets(container, profile)

    -- encounters selected
  elseif mainKey == "encounters" and not triggerType and not triggerName and not encounterID then
    PRT.AddEncountersWidgets(container, profile)

    -- single encounter selected
  elseif encounterID and not triggerType and not triggerName then
    PRT.AddEncounterOptions(container, profile, encounterID)

    -- TODO Provide encounter directly

    -- encounter trigger type selected
  elseif triggerType and not triggerName then
    if triggerType == "timers" then
      PRT.AddTimerOptionsWidgets(container, profile, encounterID)
    elseif triggerType == "rotations" then
      PRT.AddRotationOptions(container, profile, encounterID)
    elseif triggerType == "healthPercentages" then
      PRT.AddHealthPercentageOptions(container, profile, encounterID)
    elseif triggerType == "powerPercentages" then
      PRT.AddPowerPercentageOptions(container, profile, encounterID)
    elseif triggerType == "bossMods" then
      PRT.AddBossModOptions(container, profile, encounterID)
    elseif triggerType == "customPlaceholders" then
      PRT.AddCustomPlaceholderOptions(container, profile, encounterID)
    end

    -- single timer selected
  elseif triggerType == "timers" and triggerName then
    PRT.AddTimerWidget(container, profile, tonumber(encounterID), triggerName)

    -- single rotaion selected
  elseif triggerType == "rotations" and triggerName then
    PRT.AddRotationWidget(container, profile, tonumber(encounterID), triggerName)

    -- single healthPercentages selected
  elseif triggerType == "healthPercentages" and triggerName then
    PRT.AddHealthPercentageWidget(container, profile, tonumber(encounterID), triggerName)

    -- single powerPercentages selected
  elseif triggerType == "powerPercentages" and triggerName then
    PRT.AddPowerPercentageWidget(container, profile, tonumber(encounterID), triggerName)
  end

  container:DoLayout()
  PRT.mainWindowContent:RefreshTree()
end

function Core.ReselectCurrentValue()
  if PRT.mainWindowContent.selectedValue then
    PRT.mainWindowContent:SelectByValue(PRT.mainWindowContent.selectedValue)
  end
end

function Core.ReselectExchangeLast(last)
  if PRT.mainWindowContent.selectedValue then
    local xs = { strsplit("\001", PRT.mainWindowContent.selectedValue) }
    tremove(xs, #xs)
    tinsert(xs, last)
    local selectValue = strjoin("\001", unpack(xs))
    PRT.mainWindowContent:SelectByValue(selectValue)
    PRT.mainWindowContent.selectedValue = selectValue
  end
end

function Core.UpdateTree()
  PRT.mainWindowContent:SetTree(Core.GenerateTreeByProfile(PRT.db.profile))
end

function Core.UpdateScrollFrame()
  local scrollvalueBefore = PRT.mainWindowContent.scrollFrame.localstatus.scrollvalue
  PRT.mainWindowContent.scrollFrame:FixScroll()
  PRT.mainWindowContent.scrollFrame:DoLayout()

  if scrollvalueBefore and scrollvalueBefore > 0 then
    PRT.mainWindowContent.scrollFrame:SetScroll(scrollvalueBefore)
  end
end

local function ExpandTreeEntry(statusTable, key)
  local mainKey, encounterID, triggerType, triggerName = strsplit("\001", key)

  -- Always expoand the clicked entry if not top level
  if mainKey and encounterID and not triggerType then
    statusTable.groups[key] = not statusTable.groups[key]
  end

  -- Only expand if we clicked an encounter
  if mainKey and encounterID and not triggerType and not triggerName and statusTable.groups[key] then
    local timerKey = key.."\001".."timers"
    local rotationKey = key.."\001".."rotations"
    local healthPercentageKey = key.."\001".."healthPercentages"
    local powerPercentageKey = key.."\001".."powerPercentages"

    statusTable.groups[timerKey] = true
    statusTable.groups[rotationKey] = true
    statusTable.groups[healthPercentageKey] = true
    statusTable.groups[powerPercentageKey] = true
  end
end

function Core.CreateMainWindowContent(profile)
  -- Create a sroll frame for the tree group content
  local treeContentScrollFrame = PRT.ScrollFrame()

  -- Generate tree group for the main menue structure
  local tree = Core.GenerateTreeByProfile(profile)
  local treeGroup = PRT.TreeGroup(tree)
  local treeGroupStatus = { groups = {} }
  treeGroup:SetTreeWidth(600)
  PRT.mainWindowContent = treeGroup
  treeGroup:SetCallback("OnClick",
    function(_, _, key)
      ExpandTreeEntry(treeGroupStatus, key)
      treeGroup:RefreshTree()
    end)
  treeGroup:SetCallback("OnGroupSelected",
    function(_, _, key)
      treeGroup.selectedValue = key
      Core.OnGroupSelected(treeContentScrollFrame, key, profile)
    end)

  -- Expand encounters by default

  treeGroup:SetStatusTable(treeGroupStatus)
  treeGroupStatus.groups["encounters"] = true
  treeGroup:SelectByValue("options")
  treeGroup:RefreshTree()

  PRT.mainWindowContent.scrollFrame = treeContentScrollFrame

  treeGroup:AddChild(treeContentScrollFrame)

  return treeGroup
end

-------------------------------------------------------------------------------
-- Public API

function PRT.CreateMainWindow(profile)
  local mainWindow = PRT.Window("PhenomRaidTools".." - v"..PRT.db.profile.version)
  local mainWindowContent = Core.CreateMainWindowContent(profile)

  mainWindow:SetCallback("OnClose",
    function(widget)
      PRT.Release(widget)
      PRT.ReceiverOverlay.HideAll()
      PRT.SenderOverlay.Hide()
      Core.CloseAllOpenFrames()

      local frame = mainWindow.frame
      local height, width, left, top = frame:GetHeight(), frame:GetWidth(), frame:GetLeft(), frame:GetTop()
      profile.mainWindow.height = height
      profile.mainWindow.width = width
      profile.mainWindow.left = left
      profile.mainWindow.top = UIParent:GetHeight() - top

      profile.mainWindowContent.treeGroup.width = mainWindowContent.treeframe:GetWidth()
    end)

  mainWindow:SetWidth(profile.mainWindow.width or 970)
  mainWindow:SetHeight(profile.mainWindow.height or 600)
  if profile.mainWindow.left or profile.mainWindow.top then
    mainWindow.frame:SetPoint("TOPLEFT",UIParent,"TOPLEFT", profile.mainWindow.left or 0, -(profile.mainWindow.top or 0))
  end
  mainWindow.frame:SetMinResize(1000, 600)
  RegisterESCHandler("mainWindow", mainWindow)

  -- Initialize sender and receiver frames
  PRT.ReceiverOverlay.ShowAll()
  PRT.SenderOverlay.Show()
  PRT.SenderOverlay.ShowPlaceholder(PRT.SenderOverlay.overlayFrame, profile.overlay.sender)

  for i, receiverOverlay in ipairs(profile.overlay.receivers) do
    local frame = PRT.ReceiverOverlay.overlayFrames[i]
    PRT.ReceiverOverlay.ShowPlaceholder(frame, receiverOverlay)
  end

  mainWindow:AddChild(mainWindowContent)

  -- We hold the frame reference for some hacky rerendering usages :(
  PRT.mainWindow = mainWindow
  PRT.mainWindowContent = mainWindowContent

  mainWindowContent.treeframe:SetWidth(profile.mainWindowContent.treeGroup.width or 175)
end

-- Make functions publicly available
PRT.Core = Core
