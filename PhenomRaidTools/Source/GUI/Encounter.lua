local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Encounter = {
  currentEncounters = {
    -- Castle Nathria
    { id = 9999, name = L["--- Castle Nathria ---"], disabled = true},
    { id = 2398, name = L["CN - Shriekwing"] },
    { id = 2418, name = L["CN - Altimor the Huntsman"] },
    { id = 2383, name = L["CN - Hungering Destroyer"] },
    { id = 2405, name = L["CN - Artificer Xy'Mox"] },
    { id = 2402, name = L["CN - Sun King's Salvation"] },
    { id = 2406, name = L["CN - Lady Inerva Darkvein"] },
    { id = 2412, name = L["CN - The Council of Blood"] },
    { id = 2399, name = L["CN - Sludgefist"] },
    { id = 2417, name = L["CN - Stone Legion Generals"] },
    { id = 2407, name = L["CN - Sire Denathrius"] },
  }
}

local function addOverviewHeader(container, header, enabled)
  local coloredText

  if not enabled then
    coloredText = PRT.ColoredString(header.." "..L["Disabled"], PRT.db.profile.colors.disabled)
  else
    coloredText = PRT.ColoredString(header, PRT.db.profile.colors.success)
  end

  local headerLabel = PRT.Label(coloredText)
  headerLabel:SetRelativeWidth(1)

  container:AddChild(headerLabel)
end

local function addOverviewLine(container, text)
  local textLabel = PRT.Label(text, 12)
  textLabel:SetRelativeWidth(1)

  container:AddChild(textLabel)
end

local function addOverviewEmptyLine(container)
  local textLabel = PRT.Label(" ", 12)
  textLabel:SetRelativeWidth(1)

  container:AddChild(textLabel)
end

local function addStringByCondition(container, name, condition)
  local conditionString = name.." "..PRT.HighlightString(condition.event)..L["of"].." "

  if condition.spellID then
    local spellName, _, texture = GetSpellInfo(condition.spellID)
    conditionString = conditionString..PRT.TextureString(texture, 14)..spellName.." ( "..PRT.HighlightString(condition.spellID).." )"
  else
    conditionString = conditionString.."N/A"
  end

  addOverviewLine(container, conditionString)
end

local function addTimerOverviewEntry(container, timer)
  addOverviewHeader(container, timer.name, timer.enabled)

  addStringByCondition(container, L["Start on"], timer.startCondition)

  if timer.hasStopCondition then
    addStringByCondition(container, L["Stop on"], timer.stopCondition)
  end
  addOverviewLine(container, L["Timings %s"]:format(PRT.HighlightString(#timer.timings)))

  addOverviewEmptyLine(container)
end

local function addRotationOverviewEntry(container, rotation)
  addOverviewHeader(container, rotation.name, rotation.enabled)

  if rotation.hasStartCondition then
    addStringByCondition(container, L["Timings %s"], rotation.startCondition)
  end

  if rotation.hasStopCondition then
    addStringByCondition(container, L["Stop on"], rotation.stopCondition)
  end

  addStringByCondition(container, L["Trigger on"], rotation.triggerCondition)

  addOverviewLine(container, L["Entries %s"]:format(PRT.HighlightString(#rotation.entries)))
  addOverviewEmptyLine(container)
end

local function addPercentageOverviewEntry(container, prefix, percentage)
  addOverviewHeader(container, percentage.name, percentage.enabled)

  if percentage.hasStartCondition then
    addStringByCondition(container, L["Start on"], percentage.startCondition)
  end

  if percentage.hasStopCondition then
    addStringByCondition(container, L["Stop on"], percentage.stopCondition)
  end

  for _, value in ipairs(percentage.values) do
    addOverviewLine(container, L["Trigger On %s %s %s"]:format(prefix, value.operator, value.value))
  end

  addOverviewEmptyLine(container)
end

local function MergeTriggers(a, b)
  if b then
    for _, bTrigger in ipairs(b) do
      local newName = "* "..bTrigger.name

      if not a then
        a = {}
      end

      for _, aTrigger in ipairs(a) do
        if aTrigger.name == newName then
          newName = "*"..newName
        end
      end

      bTrigger.name = newName
      tinsert(a, bTrigger)
    end
  end
end

local function MergeEncounters(a, b)
  MergeTriggers(a.Timers, b.Timers)
  MergeTriggers(a.Rotations, b.Rotations)
  MergeTriggers(a.HealthPercentages, b.HealthPercentages)
  MergeTriggers(a.PowerPercentages, b.PowerPercentages)
  MergeTriggers(a.CustomPlaceholders, b.CustomPlaceholders)
end

local function importSuccess(encounter)
  local _, existingEncounter = PRT.FilterEncounterTable(PRT.db.profile.encounters, encounter.id)

  if not existingEncounter then
    tinsert(PRT.db.profile.encounters, encounter)
    PRT.mainWindow:ReleaseChildren()
    PRT.mainWindow:AddChild(PRT.Core.CreateMainWindowContent(PRT.db.profile))
    PRT.Info("Encounter imported successfully.")
  else
    PRT.ConfirmationDialog(L["Are you sure you want to merge encounters?"],
      function()
        MergeEncounters(existingEncounter, encounter)
        PRT.Info("Encounter was successfully merged.")
        PRT.Core.UpdateTree()
      end)
  end
end


-------------------------------------------------------------------------------
-- Local Helper

function Encounter.OverviewWidget(encounter)
  local overviewGroup = PRT.InlineGroup(L["Overview"])
  local timerGroup = PRT.InlineGroup(PRT.TextureString(237538).." "..L["Timers"])
  local rotationsGroup = PRT.InlineGroup(PRT.TextureString(450907).." "..L["Rotations"])
  local healthPercentageGroup = PRT.InlineGroup(PRT.TextureString(648207).." "..L["Health Percentages"])
  local powerPercentageGroup = PRT.InlineGroup(PRT.TextureString(132849).." "..L["Power Percentages"])

  -- Timers
  if not PRT.TableUtils.IsEmpty(encounter.Timers) then
    for _, v in ipairs(encounter.Timers) do
      addTimerOverviewEntry(timerGroup, v)
    end

    overviewGroup:AddChild(timerGroup)
  end

  -- Rotations
  if not PRT.TableUtils.IsEmpty(encounter.Rotations) then
    for _, v in ipairs(encounter.Rotations) do
      addRotationOverviewEntry(rotationsGroup, v)
    end

    overviewGroup:AddChild(rotationsGroup)
  end

  -- Health Percentages
  if not PRT.TableUtils.IsEmpty(encounter.HealthPercentages) then
    for _, v in ipairs(encounter.HealthPercentages) do
      addPercentageOverviewEntry(healthPercentageGroup, L["Health"], v)
    end

    overviewGroup:AddChild(healthPercentageGroup)
  end

  -- Power Percentages
  if not PRT.TableUtils.IsEmpty(encounter.PowerPercentages) then
    for _, v in ipairs(encounter.PowerPercentages) do
      addPercentageOverviewEntry(powerPercentageGroup, L["Power"], v)
    end

    overviewGroup:AddChild(powerPercentageGroup)
  end

  return overviewGroup
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddEncountersWidgets(container, profile)
  local encounterOptionsGroup = PRT.SimpleGroup()

  local addButton = PRT.Button(L["New"])
  addButton:SetCallback("OnClick",
    function()
      local newEncounter = PRT.EmptyEncounter()
      tinsert(profile.encounters, newEncounter)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:SelectByPath("encounters", newEncounter.id)
    end)

  local importButton = PRT.Button(L["Import"])
  importButton:SetCallback("OnClick",
    function()
      PRT.CreateImportFrame(importSuccess)
    end)

  encounterOptionsGroup:SetLayout("Flow")
  encounterOptionsGroup:AddChild(importButton)
  encounterOptionsGroup:AddChild(addButton)

  container:AddChild(encounterOptionsGroup)
end

function PRT.AddEncounterOptions(container, profile, encounterID)
  local encounterIndex, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))

  local encounterOptionsGroup = PRT.InlineGroup(L["Options"])
  local enabledCheckBox = PRT.CheckBox(L["Enabled"], nil, encounter.enabled)
  local encounterIDEditBox = PRT.EditBox(L["Encounter-ID"], nil, encounter.id)
  local encounterNameEditBox = PRT.EditBox(L["Name"], nil, encounter.name)
  local encounterSelectDropdown = PRT.Dropdown(L["Select Encounter"], nil, Encounter.currentEncounters, nil, nil, true)
  local exportButton = PRT.Button(L["Export"])
  local deleteButton = PRT.NewTriggerDeleteButton(container, profile.encounters, encounterIndex, L["Delete"], encounter.name)
  local overviewGroup = Encounter.OverviewWidget(encounter)

  encounterOptionsGroup:SetLayout("Flow")

  encounterIDEditBox:SetRelativeWidth(0.5)
  encounterIDEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local id = tonumber(widget:GetText())
      local _, existingEncounter = PRT.FilterEncounterTable(profile.encounters, id)

      if not existingEncounter then
        if id ~= "" and id ~= nil then
          encounter.id = id
          PRT.Core.UpdateTree()
          PRT.Core.ReselectExchangeLast(id)
        else
          PRT.Error("Encounter id can not be empty")
          if encounter.id then
            widget:SetText(encounter.id)
          end
        end
      else
        if encounter.id then
          widget:SetText(encounter.id)
        end
        PRT.Error("The encounter id you entered was already taken by ", PRT.HighlightString(existingEncounter.name))
      end
      widget:ClearFocus()
    end)
  encounterNameEditBox:SetRelativeWidth(0.5)
  encounterNameEditBox:SetCallback("OnEnterPressed",
    function(widget)
      encounter.name = widget:GetText()
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.Core.ReselectExchangeLast(encounter.id)
      widget:ClearFocus()
    end)

  encounterSelectDropdown:SetRelativeWidth(0.5)
  encounterSelectDropdown:SetCallback("OnValueChanged",
    function(widget, _, id)
      local _, entry = PRT.FilterTableByID(Encounter.currentEncounters, id)
      -- TODO: Refactor and put together with above id function
      local _, existingEncounter = PRT.FilterEncounterTable(profile.encounters, id)

      if not existingEncounter then
        if id ~= "" and id ~= nil then
          encounter.id = id
          encounter.name = entry.name
          PRT.Core.UpdateTree()
          PRT.Core.ReselectExchangeLast(id)
        else
          PRT.Error("Encounter id can not be empty")
          if encounter.id then
            encounterIDEditBox:SetText(encounter.id)
            encounterNameEditBox:SetText(encounter.name)
          end
        end
      else
        if encounter.id then
          encounterIDEditBox:SetText(encounter.id)
          encounterNameEditBox:SetText(encounter.name)
        end
        PRT.Error("The encounter id you entered was already taken by ", existingEncounter.name)
      end

      widget:SetValue(nil)
    end)

  exportButton:SetCallback("OnClick",
    function()
      PRT.CreateExportFrame(encounter)
    end)

  enabledCheckBox:SetRelativeWidth(1)
  enabledCheckBox:SetCallback("OnValueChanged",
    function(widget)
      encounter.enabled = widget:GetValue()
      PRT.Core.UpdateTree()
    end)

  encounterOptionsGroup:AddChild(enabledCheckBox)
  encounterOptionsGroup:AddChild(encounterIDEditBox)
  encounterOptionsGroup:AddChild(encounterNameEditBox)
  encounterOptionsGroup:AddChild(encounterSelectDropdown)
  encounterOptionsGroup:AddChild(exportButton)
  encounterOptionsGroup:AddChild(deleteButton)

  container:AddChild(encounterOptionsGroup)
  container:AddChild(overviewGroup)
end
