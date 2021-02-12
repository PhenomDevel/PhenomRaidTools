local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

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


-------------------------------------------------------------------------------
-- Public API

function PRT.ConditionWidget(condition, textID)
  local conditionGroup = PRT.InlineGroup(textID)

  -- Generate event list
  local additionalEvents = PRT.db.profile.triggerDefaults.conditionDefaults.additionalEvents
  local conditionEventsFull = table.mergecopy(Condition.defaultEvents, additionalEvents)

  -- Create new group for spell inputs
  local eventDropDown = PRT.Dropdown("conditionEvent", conditionEventsFull, condition.event, true)
  local spellIDEditBox = PRT.EditBox("conditionSpellID", condition.spellID, true)
  local eventGroup = PRT.SimpleGroup()
  eventGroup:SetLayout("Flow")

  local spellIcon = PRT.Icon(condition.spellIcon, condition.spellID)
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
      local text = tonumber(widget:GetText())

      local _, _, icon, _, _, _, spellId = GetSpellInfo(text)

      if not spellId then
        PRT.Warn("Your entered spell id", PRT.HighlightString(text), "does not exist.")
        widget:SetText(nil)
      else

        if spellId then
          condition.spellID = spellId
        end

        if icon then
          condition.spellIcon = icon
        end

        if not (spellId and icon) then
          condition.spellIcon = nil
          condition.spellID = nil
        end

        spellIcon:SetImage(condition.spellIcon, 0.1, 0.9, 0.1, 0.9)
        PRT.AddSpellTooltip(spellIcon, condition.spellID)
        spellIDEditBox:SetText(condition.spellID)
        PRT.Core.UpdateTree()
      end
      widget:ClearFocus()
    end)

  -- Add unit group
  local targetEditBox = PRT.EditBox("conditionTarget", condition.target, true)
  local sourceEditBox = PRT.EditBox("conditionSource", condition.source, true)
  local unitGroup = PRT.SimpleGroup()
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
