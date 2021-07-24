local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Encounter = {
  currentEncounters = {
    -- Castle Nathria
    {id = 9999, name = L["--- Castle Nathria ---"], disabled = true},
    {id = 2398, name = L["CN - Shriekwing"]},
    {id = 2418, name = L["CN - Altimor the Huntsman"]},
    {id = 2383, name = L["CN - Hungering Destroyer"]},
    {id = 2405, name = L["CN - Artificer Xy'Mox"]},
    {id = 2402, name = L["CN - Sun King's Salvation"]},
    {id = 2406, name = L["CN - Lady Inerva Darkvein"]},
    {id = 2412, name = L["CN - The Council of Blood"]},
    {id = 2399, name = L["CN - Sludgefist"]},
    {id = 2417, name = L["CN - Stone Legion Generals"]},
    {id = 2407, name = L["CN - Sire Denathrius"]},
    -- Sanctum of Domination
    {id = 10999, name = L["--- Sanctum of Domination ---"], disabled = true},
    {id = 2423, name = L["SoD - The Tarragrue"]},
    {id = 2433, name = L["SoD - The Eye of the Jailer"]},
    {id = 2429, name = L["SoD - The Nine"]},
    {id = 2432, name = L["SoD - Remnant of Ner'zhul"]},
    {id = 2434, name = L["SoD - Soulrender Dormazain"]},
    {id = 2430, name = L["SoD - Painsmith Raznal"]},
    {id = 2436, name = L["SoD - Guardian of the First Ones"]},
    {id = 2431, name = L["SoD - Fatescribe Roh-Kalo"]},
    {id = 2422, name = L["SoD - Kel'Thuzad"]},
    {id = 2435, name = L["SoD - Sylvanas Windrunner"]}
  }
}

local function addOverviewHeader(container, header, enabled)
  local coloredText

  if not enabled then
    coloredText = PRT.ColoredString(header .. " " .. L["Disabled"], PRT.Static.Colors.Inactive)
  else
    coloredText = PRT.ColoredString(header, PRT.Static.Colors.Success)
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
  local conditionString = name .. " " .. PRT.HighlightString(condition.event) .. L["of"] .. " "

  if condition.spellID then
    local spellName, _, texture = GetSpellInfo(condition.spellID)
    conditionString = conditionString .. PRT.TextureString(texture, 14) .. (spellName or "N/A") .. " ( " .. PRT.HighlightString(condition.spellID) .. " )"
  else
    conditionString = conditionString .. "N/A"
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
    addStringByCondition(container, L["Start on"], rotation.startCondition)
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

local function importVersionSuccess(encounter, encounterVersionData)
  if encounter then
    PRT.ConfirmationDialog(
      L["Encounter found. Do you want to import the new version?"],
      function()
        local migratedPlaceholders = PRT.MigratePlaceholdersAfter2160({}, encounterVersionData.CustomPlaceholders)
        encounterVersionData.CustomPlaceholders = migratedPlaceholders

        encounterVersionData.name = encounterVersionData.name .. " - Import: " .. PRT.Now()
        encounterVersionData.createdAt = PRT.Now()
        tinsert(encounter.versions, encounterVersionData)
        encounter.selectedVersion = PRT.TableUtils.Count(encounter.versions)
        PRT.Info("Encounter version imported successfully.")
        PRT.Core.UpdateTree()
        PRT.Core.ReselectCurrentValue()
      end
    )
  else
    PRT.Warn("There was no encounter found. Therefore the version was not imported.")
  end
end

local function AddVersionWidgets(container, profile, encounterID)
  local refreshContainer = function()
    container:ReleaseChildren()
    AddVersionWidgets(container, profile, encounterID)
  end

  local _, encounter = PRT.GetEncounterById(profile.encounters, tonumber(encounterID))
  local _, selectedVersionEncounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))
  local versionNames = {}

  for i = 1, PRT.TableUtils.Count(encounter.versions) do
    tinsert(versionNames, {id = i, name = i .. " - " .. encounter.versions[i].name})
  end

  local selectedVersionEncounterName = ""

  if selectedVersionEncounter then
    selectedVersionEncounterName = selectedVersionEncounter.name
  end

  local activeVersionDropdown = PRT.Dropdown(L["Select version"], nil, versionNames)
  local versionNameEditBox = PRT.EditBox(L["Version name"], nil, selectedVersionEncounterName)

  local createdAt = "N/A"

  if selectedVersionEncounter and selectedVersionEncounter.createdAt then
    createdAt = selectedVersionEncounter.createdAt
  end

  local versionCreatedAtLabel = PRT.Label(L["Created at:"] .. " " .. createdAt)
  local newVersionButton = PRT.Button(L["New"])
  local cloneVersionButton = PRT.Button(L["Clone"])
  local deleteVersionButton = PRT.Button(L["Delete"])
  local importVersionButton = PRT.Button(L["Import"])
  local exportVersionButton = PRT.Button(L["Export"])

  versionCreatedAtLabel:SetRelativeWidth(1)

  activeVersionDropdown:SetDisabled(not selectedVersionEncounter)
  activeVersionDropdown:SetRelativeWidth(1)

  versionNameEditBox:SetDisabled(not selectedVersionEncounter)
  versionNameEditBox:SetRelativeWidth(1)

  deleteVersionButton:SetDisabled(not selectedVersionEncounter)

  activeVersionDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      encounter.selectedVersion = widget:GetValue()
      PRT.Core.UpdateTree()
      refreshContainer()
    end
  )

  versionNameEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local value = widget:GetText()
      selectedVersionEncounter.name = value
      widget:ClearFocus()
      refreshContainer()
    end
  )

  newVersionButton:SetCallback(
    "OnClick",
    function()
      local newEncounterVersion = PRT.NewEncounterVersion(encounter)
      tinsert(encounter.versions, newEncounterVersion)
      encounter.selectedVersion = PRT.TableUtils.Count(encounter.versions)
      PRT.Core.UpdateTree()
      refreshContainer()
    end
  )

  cloneVersionButton:SetCallback(
    "OnClick",
    function()
      local clonedEncounterVersion = PRT.TableUtils.Clone(selectedVersionEncounter)
      clonedEncounterVersion.name = "Clone " .. PRT.Now()
      clonedEncounterVersion.createdAt = PRT.Now()
      tinsert(encounter.versions, clonedEncounterVersion)
      encounter.selectedVersion = PRT.TableUtils.Count(encounter.versions)
      PRT.Core.UpdateTree()
      refreshContainer()
    end
  )

  deleteVersionButton:SetCallback(
    "OnClick",
    function()
      PRT.ConfirmationDialog(
        L["Are you sure you want to delete %s?"]:format(PRT.HighlightString(selectedVersionEncounterName)),
        function()
          tremove(encounter.versions, encounter.selectedVersion)
          encounter.selectedVersion = PRT.TableUtils.Count(encounter.versions)
          PRT.Core.UpdateTree()
          refreshContainer()
        end
      )
    end
  )

  importVersionButton:SetCallback(
    "OnClick",
    function()
      PRT.CreateImportFrame(
        function(encounterVersionData)
          importVersionSuccess(encounter, encounterVersionData)
        end
      )
    end
  )

  exportVersionButton:SetCallback(
    "OnClick",
    function()
      PRT.CreateExportFrame(selectedVersionEncounter)
    end
  )

  container:AddChild(versionNameEditBox)
  container:AddChild(activeVersionDropdown)

  if selectedVersionEncounter then
    container:AddChild(versionCreatedAtLabel)
  end

  container:AddChild(newVersionButton)
  container:AddChild(cloneVersionButton)
  container:AddChild(deleteVersionButton)
  container:AddChild(importVersionButton)
  container:AddChild(exportVersionButton)
end

-------------------------------------------------------------------------------
-- Local Helper

function Encounter.OverviewWidget(encounter)
  local overviewGroup = PRT.InlineGroup(L["Overview"])
  local timerGroup = PRT.InlineGroup(PRT.TextureString(237538) .. " " .. L["Timers"])
  local rotationsGroup = PRT.InlineGroup(PRT.TextureString(450907) .. " " .. L["Rotations"])
  local healthPercentageGroup = PRT.InlineGroup(PRT.TextureString(648207) .. " " .. L["Health Percentages"])
  local powerPercentageGroup = PRT.InlineGroup(PRT.TextureString(132849) .. " " .. L["Power Percentages"])

  if encounter then
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
  end

  return overviewGroup
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddEncountersWidgets(container, profile)
  local encounterOptionsGroup = PRT.SimpleGroup()

  local addButton = PRT.Button(L["New"])
  addButton:SetCallback(
    "OnClick",
    function()
      local newEncounter = PRT.EmptyEncounter()
      tinsert(profile.encounters, newEncounter)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:SelectByPath("encounters", newEncounter.id)
    end
  )

  encounterOptionsGroup:SetLayout("Flow")
  encounterOptionsGroup:AddChild(addButton)

  container:AddChild(encounterOptionsGroup)
end

function PRT.AddEncounterOptions(container, profile, encounterID)
  local encounterIndex, encounter = PRT.TableUtils.GetBy(profile.encounters, "id", tonumber(encounterID))
  local _, selectedVersionEncounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))

  local encounterOptionsGroup = PRT.InlineGroup(L["Options"])
  local enabledCheckBox = PRT.CheckBox(L["Enabled"], nil, encounter.enabled)
  local encounterIDEditBox = PRT.EditBox(L["Encounter-ID"], nil, encounter.id)
  local encounterNameEditBox = PRT.EditBox(L["Name"], nil, encounter.name)
  local encounterSelectDropdown = PRT.Dropdown(L["Select Encounter"], nil, Encounter.currentEncounters, nil, nil, true)
  local deleteButton = PRT.NewTriggerDeleteButton(container, profile.encounters, encounterIndex, L["Delete"], encounter.name)
  local overviewGroup = Encounter.OverviewWidget(selectedVersionEncounter)

  encounterOptionsGroup:SetLayout("Flow")

  encounterIDEditBox:SetRelativeWidth(0.5)
  encounterIDEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local id = tonumber(widget:GetText())
      local _, existingEncounter = PRT.GetEncounterById(profile.encounters, id)

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
    end
  )
  encounterNameEditBox:SetRelativeWidth(0.5)
  encounterNameEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      encounter.name = widget:GetText()
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.Core.ReselectExchangeLast(encounter.id)
      widget:ClearFocus()
    end
  )

  encounterSelectDropdown:SetRelativeWidth(0.5)
  encounterSelectDropdown:SetCallback(
    "OnValueChanged",
    function(widget, _, id)
      local _, entry = PRT.TableUtils.GetBy(Encounter.currentEncounters, "id", id)
      local _, existingEncounter = PRT.GetEncounterById(profile.encounters, id)

      if not existingEncounter then
        if id ~= "" and id ~= nil then
          encounter.id = id
          encounter.name = entry.name
          selectedVersionEncounter.name = entry.name
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
        PRT.Error("The encounter id you entered was already taken by ", encounter.name)
      end

      widget:SetValue(nil)
    end
  )

  enabledCheckBox:SetRelativeWidth(1)
  enabledCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      encounter.enabled = widget:GetValue()
      PRT.Core.UpdateTree()
    end
  )

  local encounterVersionOptionsGroup = PRT.InlineGroup(L["Versions"])
  encounterVersionOptionsGroup:SetLayout("Flow")
  AddVersionWidgets(encounterVersionOptionsGroup, profile, encounterID)

  encounterOptionsGroup:AddChild(enabledCheckBox)
  encounterOptionsGroup:AddChild(encounterIDEditBox)
  encounterOptionsGroup:AddChild(encounterNameEditBox)
  encounterOptionsGroup:AddChild(encounterSelectDropdown)
  encounterOptionsGroup:AddChild(deleteButton)
  PRT.AddMethodRaidToolsExportWidget(encounterOptionsGroup, encounter)

  container:AddChild(encounterOptionsGroup)
  container:AddChild(encounterVersionOptionsGroup)
  container:AddChild(overviewGroup)
end
