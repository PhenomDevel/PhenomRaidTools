local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local encounterPhaseMapping = {}

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

  -- Create new group for spell inputs
  local eventDropDown = PRT.Dropdown(L["Event"], nil, PRT.Static.Tables.SupportedEvents, condition.event, true)
  eventDropDown:SetWidth(400)
  local spellIDEditBox = PRT.EditBox(L["Spell"], L["Can be either of\n- valid unique spell ID\n- spell name known to the player character"], condition.spellID, true)
  spellIDEditBox:SetWidth(400)

  local eventGroup = PRT.SimpleGroup()
  local spellIcon = PRT.Icon(condition.spellID)

  local targetEditBox = PRT.EditBox(L["Target"], L["Can be either of\n- Unit-Name\n- Unit-ID (boss1, player ...)\n- NPC-ID"], condition.target, true)
  targetEditBox:SetWidth(400)
  local sourceEditBox = PRT.EditBox(L["Source"], L["Can be either of\n- Unit-Name\n- Unit-ID (boss1, player ...)\n- NPC-ID"], condition.source, true)
  sourceEditBox:SetWidth(400)
  local unitGroup = PRT.SimpleGroup()

  -- Maybe add preset Dropdown select if anything is define for the currently selected encounter id
  local encounterPresets = encounterPhaseMapping[tonumber(PRT.currentEncounter.encounter.id)]

  if not PRT.TableUtils.IsEmpty(encounterPresets) then
    local presetsDropdown = PRT.Dropdown(L["Encounter Presets"], nil, encounterPresets, true)
    presetsDropdown:SetWidth(400)

    presetsDropdown:SetCallback(
      "OnValueChanged",
      function(widget, _, key)
        local _, phasePreset = PRT.TableUtils.GetBy(encounterPresets, "id", key)
        local spellInfo = C_Spell.GetSpellInfo(tonumber(phasePreset.spellID))
        local texture = spellInfo.originalIconID
        ClearConditionValues(condition)
        SetValueIfPresent(condition, phasePreset, "event")
        SetValueIfPresent(condition, phasePreset, "spellID")
        SetValueIfPresent(condition, phasePreset, "source")
        SetValueIfPresent(condition, phasePreset, "target")
        condition.spellIcon = texture
        PRT.UpdateIcon(spellIcon, phasePreset.spellID)

        eventDropDown:SetValue(condition.event)
        spellIDEditBox:SetText(condition.spellID)
        targetEditBox:SetText(condition.target)
        sourceEditBox:SetText(condition.source)

        PRT.Core.UpdateTree()
        widget:SetValue(nil)
        widget:SetText(nil)
      end
    )

    conditionGroup:AddChild(presetsDropdown)
  end

  eventGroup:SetLayout("Flow")

  if spellIcon then
    spellIcon:SetHeight(40)
    spellIcon:SetWidth(40)
    spellIcon:SetImageSize(30, 30)
  end

  eventDropDown:SetCallback(
    "OnValueChanged",
    function(widget)
      local text = widget:GetValue()

      if text == "" then
        condition.event = nil
      else
        condition.event = text
      end

      widget:ClearFocus()
    end
  )

  spellIDEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()

      local spellInfo = C_Spell.GetSpellInfo(tonumber(text))
      local icon = spellInfo.originalIconID
      local spellId = spellInfo.spellID

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
    end
  )

  -- Add unit group
  unitGroup:SetLayout("Flow")

  targetEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      if text == "" then
        condition.target = nil
      else
        condition.target = text
      end
      widget:ClearFocus()
    end
  )

  sourceEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      if text == "" then
        condition.source = nil
      else
        condition.source = text
      end
      widget:ClearFocus()
    end
  )

  eventGroup:AddChild(eventDropDown)
  eventGroup:AddChild(spellIDEditBox)
  if spellIcon then
    eventGroup:AddChild(spellIcon)
  end
  unitGroup:AddChild(targetEditBox)
  unitGroup:AddChild(sourceEditBox)

  conditionGroup:AddChild(eventGroup)
  conditionGroup:AddChild(unitGroup)

  return conditionGroup
end
