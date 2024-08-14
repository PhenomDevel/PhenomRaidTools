local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local EJ_SelectTier, EJ_GetCurrentTier, EJ_GetInstanceByIndex, EJ_SelectInstance, EJ_GetInstanceInfo, EJ_GetEncounterInfoByIndex =
  EJ_SelectTier,
  EJ_GetCurrentTier,
  EJ_GetInstanceByIndex,
  EJ_SelectInstance,
  EJ_GetInstanceInfo,
  EJ_GetEncounterInfoByIndex

local Encounter = {
  currentEncounters = {}
}

if PRT.IsClassic() then
  Encounter.currentEncounters = {
    -- Naxxramas
    {id = 9999, name = L["--- Naxxramas ---"], disabled = true},
    {id = 1107, name = L["NAX - Anub'rekhan"]},
    {id = 1110, name = L["NAX - Grand Widow Faerlina"]},
    {id = 1116, name = L["NAX - Maexxna"]},
    {id = 1117, name = L["NAX - Noth the Plaguebringer"]},
    {id = 1112, name = L["NAX - Heigan the Unclean"]},
    {id = 1115, name = L["NAX - Loatheb"]},
    {id = 1113, name = L["NAX - Instructor Razuvious"]},
    {id = 1109, name = L["NAX - Gothik the Harvester"]},
    {id = 1121, name = L["NAX - The Four Horsemen"]},
    {id = 1118, name = L["NAX - Patchwerk"]},
    {id = 1111, name = L["NAX - Grobbulus"]},
    {id = 1108, name = L["NAX - Gluth"]},
    {id = 1120, name = L["NAX - Thaddius"]},
    {id = 1119, name = L["NAX - Sapphiron"]},
    {id = 1114, name = L["NAX - Kel'Thuzad"]},
    -- Obsidian Sanctum
    {id = 109999, name = L["--- OS ---"], disabled = true},
    {id = 1090, name = L["OS - Sartharion"]},
    -- Eye of Eternity
    {id = 209999, name = L["--- EoE ---"], disabled = true},
    {id = 1094, name = L["EoE - Malygos"]},
    -- Ulduar
    {id = 309999, name = L["--- Ulduar ---"], disabled = true},
    {id = 1132, name = L["ULD - Flame Leviathan"]},
    {id = 1136, name = L["ULD - Ignis the Furnace Master"]},
    {id = 1139, name = L["ULD - Razorscale"]},
    {id = 1142, name = L["ULD - XT-002 Deconstructor"]},
    {id = 1140, name = L["ULD - Assembly of Iron"]},
    {id = 1137, name = L["ULD - Kologarn"]},
    {id = 1131, name = L["ULD - Auriaya"]},
    {id = 1133, name = L["ULD - Freya"]},
    {id = 1135, name = L["ULD - Hodir"]},
    {id = 1138, name = L["ULD - Mimiron"]},
    {id = 1141, name = L["ULD - Thorim"]},
    {id = 1134, name = L["ULD - General Vezax"]},
    {id = 1143, name = L["ULD - Yogg-Saron"]},
    {id = 1130, name = L["ULD - Algalon the Observer"]},
    -- Icecrown Citadel
    {id = 40999, name = L["--- Icecrown Citadel ---"], disabled = true},
    {id = 1101, name = L["ICC - Lord Marrowgar"]},
    {id = 1100, name = L["ICC - Lady Deathwhisper"]},
    {id = 1099, name = L["ICC - Icecrown Gunship Battle"]},
    {id = 1096, name = L["ICC - Deathbringer Saurfang"]},
    {id = 1097, name = L["ICC - Festergut"]},
    {id = 1104, name = L["ICC - Rotface"]},
    {id = 1102, name = L["ICC - Professor Putricide"]},
    {id = 1095, name = L["ICC - Blood Prince Council"]},
    {id = 1103, name = L["ICC - Blood-Queen Lana'thel"]},
    {id = 1098, name = L["ICC - Valithria Dreamwalker"]},
    {id = 1105, name = L["ICC - Sindragosa"]},
    {id = 1106, name = L["ICC - The Lich King"]},
    -- Zul'gurub
    {id = 50999, name = L["--- Zul'Gurub ---"], disabled = true},
    {id = 1178, name = L["High Priest Venoxis"]},
   }
elseif PRT.IsRetail() then
  Encounter.currentEncounters = {
    -- Vault of the Incarnates
    {id = 9999, name = L["--- Vault of the Incarnates ---"], disabled = true},
    {id = 2587, name = L["VotI - Eranog"]},
    {id = 2639, name = L["VotI - Terros"]},
    {id = 2590, name = L["VotI - The Primal Council"]},
    {id = 2592, name = L["VotI - Sennarth, The Cold Breath"]},
    {id = 2635, name = L["VotI - Dathea, Ascended"]},
    {id = 2605, name = L["VotI - Kurog Grimtotem"]},
    {id = 2614, name = L["VotI - Broodkeeper Diurna"]},
    {id = 2607, name = L["VotI - Raszageth the Storm-Eater"]}
  }
end

local function GenerateEncounterList()
  if PRT.IsClassic() then
    return Encounter.currentEncounters
  end

  local currentEncounters = {}

  EJ_SelectTier(EJ_GetCurrentTier())

  for _, inRaid in ipairs({false, true}) do
    local instanceIndex = 1
    local instanceId = EJ_GetInstanceByIndex(instanceIndex, inRaid)

    while instanceId do
      EJ_SelectInstance(instanceId)
      local instanceName, _, _, _, _, _, _ = EJ_GetInstanceInfo(instanceId)

      tinsert(currentEncounters, {id = 9000 + instanceId, name = instanceName, disabled = true})

      local bossIndex = 1
      local boss, _, _, _, _, _, encounterId = EJ_GetEncounterInfoByIndex(bossIndex, instanceId)

      while boss do
        if encounterId then
          boss, _, _, _, _, _, encounterId = EJ_GetEncounterInfoByIndex(bossIndex, instanceId)

          if boss and encounterId then
            tinsert(currentEncounters, {id = encounterId, name = ("%s (%s)"):format(boss, encounterId)})
          end
          bossIndex = bossIndex + 1
        end
      end
      instanceIndex = instanceIndex + 1
      instanceId = EJ_GetInstanceByIndex(instanceIndex, inRaid)
    end
  end

  Encounter.currentEncounters = currentEncounters
end

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
    local spellInfo = C_Spell.GetSpellInfo(condition.spellID)
    local spellName = spellInfo.name
    local texture = spellInfo.originalIconID
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
  if PRT.IsRetail() then
    GenerateEncounterList()
  end
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
