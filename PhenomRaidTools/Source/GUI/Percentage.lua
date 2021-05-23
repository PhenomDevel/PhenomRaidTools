local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Percentage = {
  operatorValues = {
    {
      id = "greater",
      name = "> (greater)"
    },
    {
      id = "less",
      name = "< (less)"
    },
    {
      id = "greaterorequals",
      name = ">= (greater or equals)"
    },
    {
      id = "lessorequals",
      name = "<= (less or equals)"
    },
    {
      id = "equals",
      name = "= (equals)"
    }
  }
}

-------------------------------------------------------------------------------
-- Local Helper

function Percentage.PercentageEntryWidget(entry, container, _)
  local percentageEntryOptionsGroup = PRT.InlineGroup(L["Options"])

  local operatorDropdown = PRT.Dropdown(L["Operator"], nil, Percentage.operatorValues, entry.operator)
  operatorDropdown:SetCallback(
    "OnValueChanged",
    function(_, _, key)
      entry.operator = key
    end
  )

  local valueSlider = PRT.Slider(L["Percentage"], nil, entry.value)
  valueSlider:SetSliderValues(0, 100, 1)
  valueSlider:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      entry.value = value
      entry.name = value .. " %"
    end
  )

  local messagesTabs = PRT.TableToTabs(entry.messages, true)
  local messagesTabGroup = PRT.TabGroup(L["Messages"], messagesTabs)
  messagesTabGroup:SetLayout("List")
  messagesTabGroup:SetCallback(
    "OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, true, L["Delete"], true, L["Clone"])
    end
  )

  PRT.SelectFirstTab(messagesTabGroup, entry.messages)

  percentageEntryOptionsGroup:SetLayout("Flow")
  percentageEntryOptionsGroup:AddChild(operatorDropdown)
  percentageEntryOptionsGroup:AddChild(valueSlider)

  container:AddChild(percentageEntryOptionsGroup)
  container:AddChild(messagesTabGroup)
end

function Percentage.PercentageWidget(percentageName, percentages, container)
  local _, percentage = PRT.TableUtils.GetBy(percentages, "name", percentageName)

  -- General Options
  PRT.AddGeneralOptionsWidgets(container, percentageName, percentages, "percentage")

  -- Percentage Options
  local percentageOptionsGroup = PRT.InlineGroup(L["Options"])
  percentageOptionsGroup:SetLayout("Flow")
  local unitIDEditBox = PRT.EditBox(L["Unit"], L["Can be either of\n- Unit-Name\n- Unit-ID (boss1, player ...)\n- NPC-ID"], percentage.unitID, true)
  local checkAgainCheckBox = PRT.CheckBox(L["Check again"], nil, percentage.checkAgain)
  local checkAgainAfterSlider = PRT.Slider(L["Check after"], nil, percentage.checkAgainAfter)

  checkAgainAfterSlider:SetDisabled(not percentage.checkAgain)
  unitIDEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      percentage.unitID = widget:GetText()
      widget:ClearFocus()
    end
  )

  checkAgainCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      percentage.checkAgain = value
      checkAgainAfterSlider:SetDisabled(not value)
    end
  )

  checkAgainAfterSlider:SetCallback(
    "OnValueChanged",
    function(widget)
      percentage.checkAgainAfter = widget:GetValue()
    end
  )
  percentageOptionsGroup:AddChild(unitIDEditBox)

  local checkAgainGroup = PRT.SimpleGroup()
  checkAgainGroup:SetLayout("Flow")
  checkAgainGroup:AddChild(checkAgainCheckBox)
  checkAgainGroup:AddChild(checkAgainAfterSlider)
  percentageOptionsGroup:AddChild(checkAgainGroup)

  container:AddChild(percentageOptionsGroup)

  -- Start Condition
  PRT.MaybeAddStartCondition(container, percentage)

  -- Stop Condition
  PRT.MaybeAddStopCondition(container, percentage)

  -- Percentageentries
  local tabs = PRT.TableToTabs(percentage.values, true)
  local valuesTabGroupWidget = PRT.TabGroup(nil, tabs)
  valuesTabGroupWidget:SetCallback(
    "OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, percentage.values, key, Percentage.PercentageEntryWidget, PRT.EmptyPercentageEntry, true, L["Delete"], true, L["Clone"])
    end
  )

  PRT.SelectFirstTab(valuesTabGroupWidget, percentage.values)
  container:AddChild(valuesTabGroupWidget)
end

-------------------------------------------------------------------------------
-- Public API Power Percentage

function PRT.AddPowerPercentageOptions(container, profile, encounterID)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))
  local percentages = encounter.PowerPercentages

  local percentageOptionsGroup = PRT.InlineGroup(L["Options"])
  percentageOptionsGroup:SetLayout("Flow")

  local hasClipboardPercentage = (not PRT.TableUtils.IsEmpty(PRT.GetProfileDB().clipboard.percentage))
  local pasteButtonText = PRT.StringUtils.WrapColorByBoolean(L["Paste"], hasClipboardPercentage, "FF696969")
  local pasteButton = PRT.Button(pasteButtonText)
  pasteButton:SetDisabled(not hasClipboardPercentage)
  pasteButton:SetCallback(
    "OnClick",
    function()
      tinsert(percentages, PRT.GetProfileDB().clipboard.percentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "percentages", PRT.GetProfileDB().clipboard.percentage.name)
      PRT.Debug("Pasted percentage", PRT.HighlightString(PRT.GetProfileDB().clipboard.percentage.name), "to", PRT.HighlightString(encounter.name))
      PRT.GetProfileDB().clipboard.percentage = nil
    end
  )

  local addButton = PRT.Button(L["New"])
  addButton:SetCallback(
    "OnClick",
    function()
      local newPercentage = PRT.EmptyPercentage()
      tinsert(percentages, newPercentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "powerPercentages", newPercentage.name)
    end
  )

  percentageOptionsGroup:AddChild(addButton)
  percentageOptionsGroup:AddChild(pasteButton)
  container:AddChild(percentageOptionsGroup)
end

function PRT.AddPowerPercentageWidget(container, profile, encounterID, percentageName)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, encounterID)
  local percentages = encounter.PowerPercentages

  Percentage.PercentageWidget(percentageName, percentages, container)
end

-------------------------------------------------------------------------------
-- Public API Health Percentage

function PRT.AddHealthPercentageOptions(container, profile, encounterID)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))
  local percentages = encounter.HealthPercentages

  local percentageOptionsGroup = PRT.InlineGroup(L["Options"])
  percentageOptionsGroup:SetLayout("Flow")

  local hasClipboardPercentage = (not PRT.TableUtils.IsEmpty(PRT.GetProfileDB().clipboard.percentage))
  local pasteButtonText = PRT.StringUtils.WrapColorByBoolean(L["Paste"], hasClipboardPercentage, "FF696969")
  local pasteButton = PRT.Button(pasteButtonText)
  pasteButton:SetDisabled(not hasClipboardPercentage)
  pasteButton:SetCallback(
    "OnClick",
    function()
      tinsert(percentages, PRT.GetProfileDB().clipboard.percentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "percentages", PRT.GetProfileDB().clipboard.percentage.name)
      PRT.Debug("Pasted percentage", PRT.HighlightString(PRT.GetProfileDB().clipboard.percentage.name), "to", PRT.HighlightString(encounter.name))
      PRT.GetProfileDB().clipboard.percentage = nil
    end
  )

  local addButton = PRT.Button(L["New"])
  addButton:SetCallback(
    "OnClick",
    function()
      local newPercentage = PRT.EmptyPercentage()
      tinsert(percentages, newPercentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "healthPercentages", newPercentage.name)
    end
  )

  percentageOptionsGroup:AddChild(addButton)
  percentageOptionsGroup:AddChild(pasteButton)
  container:AddChild(percentageOptionsGroup)
end

function PRT.AddHealthPercentageWidget(container, profile, encounterID, percentageName)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, encounterID)
  local percentages = encounter.HealthPercentages

  Percentage.PercentageWidget(percentageName, percentages, container)
end
