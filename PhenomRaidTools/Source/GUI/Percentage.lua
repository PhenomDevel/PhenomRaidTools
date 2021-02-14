local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

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

function Percentage.PercentageEntryWidget(entry, container, _, entries)
  local percentageEntryOptionsGroup = PRT.InlineGroup("percentageEntryOptionsHeading")

  local operatorDropdown = PRT.Dropdown("percentageEntryOperatorDropdown", Percentage.operatorValues, entry.operator)
  operatorDropdown:SetCallback("OnValueChanged",
    function(_, _, key)
      entry.operator = key
    end)

  local valueSlider = PRT.Slider("percentageEntryPercent", entry.value)
  valueSlider:SetSliderValues(0, 100, 1)
  valueSlider:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      entry.value = value
      entry.name = value.." %"
    end)

  local messagesTabs = PRT.TableToTabs(entry.messages, true)
  local messagesTabGroup = PRT.TabGroup("messageHeading", messagesTabs)
  messagesTabGroup:SetLayout("List")
  messagesTabGroup:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, true, "messageDeleteButton")
    end)

  PRT.SelectFirstTab(messagesTabGroup, entry.messages)

  percentageEntryOptionsGroup:SetLayout("Flow")
  percentageEntryOptionsGroup:AddChild(operatorDropdown)
  percentageEntryOptionsGroup:AddChild(valueSlider)

  container:AddChild(percentageEntryOptionsGroup)
  container:AddChild(messagesTabGroup)

  local cloneButton = PRT.Button("clonePercentageEntry")
  cloneButton:SetCallback("OnClick",
    function()
      local clone = PRT.TableUtils.CopyTable(entry)
      tinsert(entries, clone)
      PRT.Core.ReselectCurrentValue()
    end)
  container:AddChild(cloneButton)
end

function Percentage.PercentageWidget(percentageName, percentages, container)
  local _, percentage = PRT.FilterTableByName(percentages, percentageName)

  -- General Options
  PRT.AddGeneralOptionsWidgets(container, percentageName, percentages, "percentage")

  -- Percentage Options
  local percentageOptionsGroup = PRT.InlineGroup("percentageOptionsHeading")
  percentageOptionsGroup:SetLayout("Flow")
  local unitIDEditBox = PRT.EditBox("percentageUnitID", percentage.unitID, true)
  local checkAgainCheckBox = PRT.CheckBox("percentageCheckAgain", percentage.checkAgain)
  local checkAgainAfterSlider = PRT.Slider("percentageCheckAgainAfter", percentage.checkAgainAfter)

  checkAgainAfterSlider:SetDisabled(not percentage.checkAgain)
  unitIDEditBox:SetCallback("OnEnterPressed",
    function(widget)
      percentage.unitID = widget:GetText()
      widget:ClearFocus()
    end)

  checkAgainCheckBox:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      percentage.checkAgain = value
      checkAgainAfterSlider:SetDisabled(not value)
    end)

  checkAgainAfterSlider:SetCallback("OnValueChanged",
    function(widget)
      percentage.checkAgainAfter = widget:GetValue()
    end)
  percentageOptionsGroup:AddChild(unitIDEditBox)
  percentageOptionsGroup:AddChild(checkAgainCheckBox)
  percentageOptionsGroup:AddChild(checkAgainAfterSlider)
  container:AddChild(percentageOptionsGroup)

  -- Start Condition
  PRT.MaybeAddStartCondition(container, percentage)

  -- Stop Condition
  PRT.MaybeAddStopCondition(container, percentage)

  -- Percentageentries
  local tabs = PRT.TableToTabs(percentage.values, true)
  local valuesTabGroupWidget = PRT.TabGroup(nil, tabs)
  valuesTabGroupWidget:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, percentage.values, key, Percentage.PercentageEntryWidget, PRT.EmptyPercentageEntry, true, "percentageEntryDeleteButton")
    end)

  PRT.SelectFirstTab(valuesTabGroupWidget, percentage.values)
  container:AddChild(valuesTabGroupWidget)
end


-------------------------------------------------------------------------------
-- Public API Power Percentage

function PRT.AddPowerPercentageOptions(container, profile, encounterID)
  local _, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
  local percentages = encounter.PowerPercentages

  local percentageOptionsGroup = PRT.InlineGroup("Options")
  percentageOptionsGroup:SetLayout("Flow")

  local hasClipboardPercentage = (not PRT.TableUtils.IsEmpty(PRT.db.profile.clipboard.percentage))
  local pasteButtonText = PRT.StringUtils.WrapColorByBoolean(L["pastePercentage"], hasClipboardPercentage, "FF696969")
  local pasteButton = PRT.Button(pasteButtonText)
  pasteButton:SetDisabled(not hasClipboardPercentage)
  pasteButton:SetCallback("OnClick",
    function()
      tinsert(percentages, PRT.db.profile.clipboard.percentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "percentages", PRT.db.profile.clipboard.percentage.name)
      PRT.Debug("Pasted percentage", PRT.HighlightString(PRT.db.profile.clipboard.percentage.name), "to", PRT.HighlightString(encounter.name))
      PRT.db.profile.clipboard.percentage = nil
    end)

  local addButton = PRT.Button("newPowerPercentage")
  addButton:SetCallback("OnClick",
    function()
      local newPercentage = PRT.EmptyPercentage()
      tinsert(percentages, newPercentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "powerPercentages", newPercentage.name)
    end)

  percentageOptionsGroup:AddChild(addButton)
  percentageOptionsGroup:AddChild(pasteButton)
  container:AddChild(percentageOptionsGroup)
end

function PRT.AddPowerPercentageWidget(container, profile, encounterID, percentageName)
  local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)
  local percentages = encounter.PowerPercentages

  Percentage.PercentageWidget(percentageName, percentages, container)
end


-------------------------------------------------------------------------------
-- Public API Health Percentage

function PRT.AddHealthPercentageOptions(container, profile, encounterID)
  local _, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
  local percentages = encounter.HealthPercentages

  local percentageOptionsGroup = PRT.InlineGroup("Options")
  percentageOptionsGroup:SetLayout("Flow")

  local hasClipboardPercentage = (not PRT.TableUtils.IsEmpty(PRT.db.profile.clipboard.percentage))
  local pasteButtonText = PRT.StringUtils.WrapColorByBoolean(L["pastePercentage"], hasClipboardPercentage, "FF696969")
  local pasteButton = PRT.Button(pasteButtonText)
  pasteButton:SetDisabled(not hasClipboardPercentage)
  pasteButton:SetCallback("OnClick",
    function()
      tinsert(percentages, PRT.db.profile.clipboard.percentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "percentages", PRT.db.profile.clipboard.percentage.name)
      PRT.Debug("Pasted percentage", PRT.HighlightString(PRT.db.profile.clipboard.percentage.name), "to", PRT.HighlightString(encounter.name))
      PRT.db.profile.clipboard.percentage = nil
    end)

  local addButton = PRT.Button("newHealthPercentage")
  addButton:SetCallback("OnClick",
    function()
      local newPercentage = PRT.EmptyPercentage()
      tinsert(percentages, newPercentage)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "healthPercentages", newPercentage.name)
    end)

  percentageOptionsGroup:AddChild(addButton)
  percentageOptionsGroup:AddChild(pasteButton)
  container:AddChild(percentageOptionsGroup)
end

function PRT.AddHealthPercentageWidget(container, profile, encounterID, percentageName)
  local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)
  local percentages = encounter.HealthPercentages

  Percentage.PercentageWidget(percentageName, percentages, container)
end
