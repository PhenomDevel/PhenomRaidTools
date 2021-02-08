local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

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
    { id = 2417, name = L["CN - Stoneborne Generals"] },
    { id = 2407, name = L["CN - Sire Denathrius"] },

    -- De Other Side
    { id = 20000, name = L["--- De Other Side ---"], disabled = true},
    { id = 2395, name = L["DOS - Hakkar the Soulflayer"] },
    { id = 2394, name = L["DOS - The Manastorms"] },
    { id = 2400, name = L["DOS - Dealer Xy'exa"] },
    { id = 2396, name = L["DOS - Mueh'zala"] },

    -- Halls of Atonement
    { id = 30000, name = L["--- Halls of Atonement ---"], disabled = true},
    { id = 2401, name = L["HOA - Halkias, the Sin-Stained Goliath"] },
    { id = 2380, name = L["HOA - Echelon"] },
    { id = 2403, name = L["HOA - High Adjudicator Aleez"] },
    { id = 2381, name = L["HOA - Lord Chamberlain"] },

    -- Mists of Tirna Scithe
    { id = 40000, name = L["--- Mists of Tirna Scithe ---"], disabled = true},
    { id = 2397, name = L["MOTS - Ingra Maloch"] },
    { id = 2392, name = L["MOTS - Mistcaller"] },
    { id = 2393, name = L["MOTS - Tred'ova"] },

    -- Necrotic Wake
    { id = 50000, name = L["--- Necrotic Wake ---"], disabled = true},
    { id = 2387, name = L["NW - Blightbone"] },
    { id = 2388, name = L["NW - Amarth, The Reanimator"] },
    { id = 2389, name = L["NW - Surgeon Stitchflesh"] },
    { id = 2390, name = L["NW - Nalthor the Rimebinder"] },

    -- Plaguefall
    { id = 60000, name = L["--- Plaguefall ---"], disabled = true},
    { id = 2382, name = L["PF - Globgrog"] },
    { id = 2384, name = L["PF - Doctor Ickus"] },
    { id = 2385, name = L["PF - Domina Venomblade"] },
    { id = 2386, name = L["PF - Margrave Stradama"] },

    -- Sanguine Depths
    { id = 70000, name = L["--- Sanguine Depths ---"], disabled = true},
    { id = 2360, name = L["SD - Kryxis the Voracious"] },
    { id = 2361, name = L["SD - Executor Tarvold"] },
    { id = 2362, name = L["SD - Grand Proctor Beryllia"] },
    { id = 2363, name = L["SD - General Kaal"] },

    -- Spires of Ascension
    { id = 80000, name = L["--- Spires of Ascension ---"], disabled = true},
    { id = 2357, name = L["SOA - Kin-Tara"] },
    { id = 2356, name = L["SOA - Ventunax"] },
    { id = 2358, name = L["SOA - Oryphrion"] },
    { id = 2359, name = L["SOA - Devos, Paragon of Doubt"] },

    -- Theater of Pain
    { id = 90000, name = L["--- Theater of Pain ---"], disabled = true},
    { id = 2391, name = L["TOP - An Affront of Challengers"] },
    { id = 2365, name = L["TOP - Gorechop"] },
    { id = 2366, name = L["TOP - Xav the Unfallen"] },
    { id = 2364, name = L["TOP - Kul'tharok"] },
    { id = 2404, name = L["TOP - Mordretha, the Endless Empress"] },
  }
}

local function addOverviewHeader(container, header, enabled)
  local coloredText

  if not enabled then
    coloredText = PRT.ColoredString(header..L["encounterOverviewDisabled"], PRT.db.profile.colors.disabled)
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
  local conditionString = name.." "..PRT.HighlightString(condition.event)..L["encounterOverviewOf"].." "

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

  addStringByCondition(container, L["encounterOverviewStartTimerOn"], timer.startCondition)

  if timer.hasStopCondition then
    addStringByCondition(container, L["encounterOverviewStopTimerOn"], timer.stopCondition)
  end
  addOverviewLine(container, L["encounterOverviewTimings"]..PRT.HighlightString(#timer.timings))
  addOverviewEmptyLine(container)
end

local function addRotationOverviewEntry(container, rotation)
  addOverviewHeader(container, rotation.name, rotation.enabled)

  if rotation.hasStartCondition then
    addStringByCondition(container, L["encounterOverviewStartTriggerOn"], rotation.startCondition)
  end

  if rotation.hasStopCondition then
    addStringByCondition(container, L["encounterOverviewStopTriggerOn"], rotation.stopCondition)
  end

  addStringByCondition(container, L["encounterOverviewTriggerOn"], rotation.triggerCondition)

  addOverviewLine(container, L["encounterOverviewEntries"]..PRT.HighlightString(#rotation.entries))
  addOverviewEmptyLine(container)
end

local function addPercentageOverviewEntry(container, prefix, percentage)
  addOverviewHeader(container, percentage.name, percentage.enabled)

  if percentage.hasStartCondition then
    addStringByCondition(container, L["encounterOverviewStartTriggerOn"], percentage.startCondition)
  end

  if percentage.hasStopCondition then
    addStringByCondition(container, L["encounterOverviewStopTriggerOn"], percentage.stopCondition)
  end

  for _, value in ipairs(percentage.values) do
    addOverviewLine(container, L["encounterOverviewTriggerOn"].." "..prefix.." "..value.operator.." "..value.value)
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
    PRT.ConfirmationDialog(L["importConfirmationMergeEncounter"],
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
  local overviewGroup = PRT.InlineGroup("encounterOverview")
  local timerGroup = PRT.InlineGroup(PRT.TextureString(237538).." "..L["timerOverview"])
  local rotationsGroup = PRT.InlineGroup(PRT.TextureString(450907).." "..L["rotationOverview"])
  local healthPercentageGroup = PRT.InlineGroup(PRT.TextureString(648207).." "..L["healthPercentageOverview"])
  local powerPercentageGroup = PRT.InlineGroup(PRT.TextureString(132849).." "..L["powerPercentageOverview"])

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
      addPercentageOverviewEntry(healthPercentageGroup, L["encounterOverviewPercentagePrefixHealth"], v)
    end

    overviewGroup:AddChild(healthPercentageGroup)
  end

  -- Power Percentages
  if not PRT.TableUtils.IsEmpty(encounter.PowerPercentages) then
    for _, v in ipairs(encounter.PowerPercentages) do
      addPercentageOverviewEntry(powerPercentageGroup, L["encounterOverviewPercentagePrefixPower"], v)
    end

    overviewGroup:AddChild(powerPercentageGroup)
  end

  return overviewGroup
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddEncountersWidgets(container, profile)
  local encounterOptionsGroup = PRT.InlineGroup("encounterHeading")

  local addButton = PRT.Button("newEncounter")
  addButton:SetCallback("OnClick",
    function()
      local newEncounter = PRT.EmptyEncounter()
      tinsert(profile.encounters, newEncounter)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:SelectByPath("encounters", newEncounter.id)
    end)

  local importButton = PRT.Button("importEncounter")
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

  local encounterOptionsGroup = PRT.InlineGroup("encounterHeading")
  local enabledCheckBox = PRT.CheckBox("encounterEnabled", encounter.enabled)
  local encounterIDEditBox = PRT.EditBox("encounterID", encounter.id)
  local encounterNameEditBox = PRT.EditBox("encounterName", encounter.name)
  local encounterSelectDropdown = PRT.Dropdown("encounterSelectDropdown", Encounter.currentEncounters, nil, nil, true)
  local exportButton = PRT.Button("exportEncounter")
  local deleteButton = PRT.NewTriggerDeleteButton(container, profile.encounters, encounterIndex, "deleteEncounter", encounter.name)
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
