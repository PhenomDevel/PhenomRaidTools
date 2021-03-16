local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Condition = {
  defaultEvents = {
    "SPELL_CAST_SUCCESS",
    "SPELL_CAST_START",
    "SPELL_CAST_FAILED",
    "SPELL_AURA_REMOVED",
    "SPELL_AURA_APPLIED",
    "SPELL_AURA_APPLIED_DOSE",
    "SPELL_AURA_REMOVED_DOSE",
    "SPELL_AURA_REFRESH",
    "SPELL_INTERRUPT",
    "ENCOUNTER_START",
    "ENCOUNTER_END",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "UNIT_DIED",
    "PARTY_KILL"
  }
}

local encounterPhaseMapping = {
  -- Shriekwing
  [2398] = {
    { id = "phase2start", name = L["Phase 2 Start"], event = "SPELL_AURA_APPLIED", spellID = 328921 },
    { id = "phase1start", name = L["Phase 2 End / Phase 1 Restart"], event = "SPELL_AURA_REMOVED", spellID = 328921 },
  },
  -- Altimor the Huntsman
  [2418] = {
    { id = "phase2start", name = L["Phase 2 Start (Bargast)"], event = "UNIT_DIED", target = L["Margore"]},
    { id = "phase3start", name = L["Phase 3 Start (Hercutis)"], event = "UNIT_DIED", target = L["Bargast"]},
  },
  -- Hungering Destroyer
  [2383] = {
    { id = "consumeIntermission", name = L["Consume Intermission"], event = "SPELL_CAST_START", spellID = 334522},
  },
  -- Artificer Xy'Mox
  [2405] = {
    { id = "phase2start", name = "Phase 2 Start", event = "SPELL_CAST_SUCCESS", spellID = 329770},
    { id = "phase3start", name = "Phase 3 Start", event = "SPELL_CAST_SUCCESS", spellID = 328880},
  },
  -- Sun King's Salvation
  [2402] = {
    { id = "intermissionStart", name = "Intermission Start (Shade of Kael'thas)", event = "SPELL_AURA_APPLIED", spellID = 323402},
    { id = "intermissionStop", name = "Intermission Stop", event = "SPELL_AURA_REMOVED", spellID = 323402},
  },
  -- Lady Inerva Darkvein
  [2406] = {},
  -- The Council of Blood
  [2412] = {
    { id = "phase2NiklausSecond", name = L["Phase 2 (Castellan Niklaus second)"], event = "SPELL_AURA_APPLIED", spellID = 332535, target = L["Castellan Niklaus"]},
    { id = "phase2FriedaSecond", name = L["Phase 2 (Baroness Frieda second)"], event = "SPELL_AURA_APPLIED", spellID = 332535, target = L["Baroness Frieda"]},
    { id = "phase2StavrosSecond", name = L["Phase 2 (Lord Stavros second)"], event = "SPELL_AURA_APPLIED", spellID = 332535, target = L["Lord Stavros"]},

    { id = "phase3NiklausLast", name = L["Phase 3 (Castellan Niklaus last)"], event = "SPELL_AURA_APPLIED", spellID = 346709, target = L["Castellan Niklaus"]},
    { id = "phase3FriedaLast", name = L["Phase 3 (Baroness Frieda last)"], event = "SPELL_AURA_APPLIED", spellID = 346709, target = L["Baroness Frieda"]},
    { id = "phase3StavrosLast", name = L["Phase 3 (Lord Stavros last)"], event = "SPELL_AURA_APPLIED", spellID = 346709, target = L["Lord Stavros"]},
  },
  -- Sludgefist
  [2399] = {
    { id = "intermissionStart", name = L["Intermission Start"], event = "SPELL_AURA_APPLIED", spellID = 331314},
    { id = "intermissionEnd", name = L["Intermission End"], event = "SPELL_AURA_REMOVED", spellID = 331314},
  },
  -- Stone Legion Generals
  [2417] = {
    { id = "intermission1Start", name = L["Intermission 1 Start"], event = "SPELL_AURA_APPLIED", spellID = 329636},
    { id = "intermission1End", name = L["Intermission 1 End"], event = "SPELL_AURA_REMOVED", spellID = 329636},
    { id = "intermission2Start", name = L["Intermission 2 Start"], event = "SPELL_AURA_APPLIED", spellID = 329808},
    { id = "intermission2End", name = L["Intermission 2 End"], event = "SPELL_AURA_REMOVED", spellID = 329808},
    { id = "phase2start", name = L["Phase 2 Start"], event = "SPELL_AURA_REMOVED", spellID = 343135},
    { id = "phase3start", name = L["Phase 3 Start"], event = "SPELL_AURA_REMOVED", spellID = 343126},
  },
  -- Sire Denathrius
  [2407] = {
    { id = "phase2start", name = L["Phase 2 Start"], event = "SPELL_CAST_START", spellID = 328276},
    { id = "phase3start", name = L["Phase 3 Start"], event = "SPELL_CAST_SUCCESS", spellID = 326005},
  }
}


-------------------------------------------------------------------------------
-- Private Helper

local function SetValueIfPresent(targetTable, sourceTable, value)
  if sourceTable[value] then
    targetTable[value] = sourceTable[value]
  end
end

local function ClearConditionValues(condition)
  condition.event = nil
  condition.spellID = nil
  condition.source = nil
  condition.target = nil
end


-------------------------------------------------------------------------------
-- Public API

function PRT.ConditionWidget(condition, textID)
  local conditionGroup = PRT.InlineGroup(textID)

  -- Generate event list
  local additionalEvents = PRT.db.profile.triggerDefaults.conditionDefaults.additionalEvents
  local conditionEventsFull = table.mergecopy(Condition.defaultEvents, additionalEvents)

  -- Create new group for spell inputs
  local eventDropDown = PRT.Dropdown(L["Event"], nil, conditionEventsFull, condition.event, true)
  local spellIDEditBox = PRT.EditBox(L["Spell"], L["Can be either of\n- valid unique spell ID\n- spell name known to the player character"], condition.spellID, true)

  local eventGroup = PRT.SimpleGroup()
  local spellIcon = PRT.Icon(condition.spellID)

  local targetEditBox = PRT.EditBox(L["Target"], L["Can be either of\n- Unit-Name\n- Unit-ID (boss1, player ...)\n- Numeric Unit-ID"], condition.target, true)
  local sourceEditBox = PRT.EditBox(L["Source"], L["Can be either of\n- Unit-Name\n- Unit-ID (boss1, player ...)\n- Numeric Unit-ID"], condition.source, true)
  local unitGroup = PRT.SimpleGroup()

  -- Maybe add preset Dropdown select if anything is define for the currently selected encounter id
  local encounterPresets = encounterPhaseMapping[PRT.currentEncounter.encounter.id]
  if not PRT.TableUtils.IsEmpty(encounterPresets) then
    local presetsDropdown = PRT.Dropdown(L["Encounter Presets"], nil, encounterPresets, true)
    presetsDropdown:SetWidth(300)

    presetsDropdown:SetCallback("OnValueChanged",
      function(widget, _, key)
        local _, phasePreset = PRT.FilterTableByID(encounterPresets, key)
        local icon = select(3, GetSpellInfo(phasePreset.spellID))
        ClearConditionValues(condition)
        SetValueIfPresent(condition, phasePreset, "event")
        SetValueIfPresent(condition, phasePreset, "spellID")
        SetValueIfPresent(condition, phasePreset, "source")
        SetValueIfPresent(condition, phasePreset, "target")
        condition.spellIcon = icon
        PRT.UpdateIcon(spellIcon, phasePreset.spellID)

        eventDropDown:SetText(condition.event)
        spellIDEditBox:SetText(condition.spellID)
        targetEditBox:SetText(condition.target)
        sourceEditBox:SetText(condition.source)

        PRT.Core.UpdateTree()
        widget:SetValue(nil)
        widget:SetText(nil)
      end)

    conditionGroup:AddChild(presetsDropdown)
  end

  eventGroup:SetLayout("Flow")
  spellIcon:SetHeight(40)
  spellIcon:SetWidth(40)
  spellIcon:SetImageSize(30,30)

  eventDropDown:SetCallback("OnValueChanged",
    function(widget)
      local text = widget:GetValue()

      if text == "" then
        condition.event = nil
      else
        condition.event = text
      end

      widget:ClearFocus()
    end)

  spellIDEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()

      local _, _, icon, _, _, _, spellId = GetSpellInfo(text)

      if not spellId then
        condition.spellID = nil
        condition.spellIcon = nil
        spellIcon:SetImage(nil)
        widget:SetText(nil)

        if not PRT.StringUtils.IsEmpty(text) then
          PRT.Warn("Your entered spell id", PRT.HighlightString(text), "does not exist.")
        end
      else
        condition.spellID = spellId
        condition.spellIcon = icon
        PRT.UpdateIcon(spellIcon, spellId)
        spellIDEditBox:SetText(condition.spellID)
      end

      PRT.Core.UpdateTree()
      widget:ClearFocus()
    end)

  -- Add unit group
  unitGroup:SetLayout("Flow")

  targetEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      if text == "" then
        condition.target = nil
      else
        condition.target = text
      end
      widget:ClearFocus()
    end)

  sourceEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      if text == "" then
        condition.source = nil
      else
        condition.source = text
      end
      widget:ClearFocus()
    end)

  eventGroup:AddChild(eventDropDown)
  eventGroup:AddChild(spellIDEditBox)
  eventGroup:AddChild(spellIcon)
  unitGroup:AddChild(targetEditBox)
  unitGroup:AddChild(sourceEditBox)

  conditionGroup:AddChild(eventGroup)
  conditionGroup:AddChild(unitGroup)

  return conditionGroup
end
