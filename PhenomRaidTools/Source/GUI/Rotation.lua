local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Rotation = {}


-------------------------------------------------------------------------------
-- Local Helper

function Rotation.RotationEntryWidget(entry, container, _, entries)
  local messagesTabs = PRT.TableToTabs(entry.messages, true)
  local messagesTabGroup = PRT.TabGroup("messageHeading", messagesTabs)
  messagesTabGroup:SetLayout("List")
  messagesTabGroup:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, true, "messageDeleteButton")
    end)

  PRT.SelectFirstTab(messagesTabGroup, entry.messages)

  container:AddChild(messagesTabGroup)

  local cloneButton = PRT.Button("cloneRotationEntry")
  cloneButton:SetCallback("OnClick",
    function()
      local clone = PRT.CopyTable(entry)
      tinsert(entries, clone)
      PRT.Core.ReselectCurrentValue()
    end)
  container:AddChild(cloneButton)
end

function Rotation.RotationWidget(rotation, container, deleteButton, cloneButton)
  local rotationOptionsGroup = PRT.InlineGroup("rotationOptionsHeading")
  rotationOptionsGroup:SetLayout("Flow")

  local enabledCheckbox = PRT.CheckBox("rotationEnabled", rotation.enabled)
  local nameEditBox = PRT.EditBox("rotationName", rotation.name)
  local shouldRestartCheckBox =  PRT.CheckBox("rotationShouldRestart", rotation.shouldRestart)
  local ignoreAfterActivationCheckBox = PRT.CheckBox("rotationIgnoreAfterActivation", rotation.ignoreAfterActivation)
  local ignoreDurationSlider = PRT.Slider("rotationIgnoreDuration", rotation.ignoreDuration)

  local copyButton = PRT.Button("copyRotation")
  copyButton:SetCallback("OnClick",
    function()
      local copy = PRT.CopyTable(rotation)
      copy.name = copy.name.." Copy"..random(0,100000)
      PRT.db.profile.clipboard.rotation = copy
      PRT.Debug("Copied rotation", PRT.HighlightString(rotation.name), "to clipboard")
    end)

  enabledCheckbox:SetRelativeWidth(1)
  enabledCheckbox:SetCallback("OnValueChanged",
    function(widget)
      rotation.enabled = widget:GetValue()
      PRT.Core.UpdateTree()
    end)

  nameEditBox:SetRelativeWidth(1)
  nameEditBox:SetCallback("OnEnterPressed",
    function(widget)
      rotation.name = widget:GetText()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectExchangeLast(rotation.name)
      widget:ClearFocus()
    end)
  shouldRestartCheckBox:SetRelativeWidth(1)
  shouldRestartCheckBox:SetCallback("OnValueChanged",
    function(widget)
      rotation.shouldRestart = widget:GetValue()
    end)

  ignoreAfterActivationCheckBox:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      rotation.ignoreAfterActivation = value
      ignoreDurationSlider:SetDisabled(not value)
    end)

  ignoreDurationSlider:SetDisabled(not rotation.ignoreAfterActivation)
  ignoreDurationSlider:SetCallback("OnValueChanged",
    function(widget)
      rotation.ignoreDuration = widget:GetValue()
    end)

  local triggerConditionGroup = PRT.ConditionWidget(rotation.triggerCondition, "Trigger Condition")
  triggerConditionGroup:SetLayout("Flow")

  local tabs = PRT.TableToTabs(rotation.entries, true)
  local entriesTabGroupWidget = PRT.TabGroup("rotationEntryHeading", tabs)
  entriesTabGroupWidget:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, rotation.entries, key, Rotation.RotationEntryWidget, PRT.EmptyRotationEntry, true, "rotationEntryDeleteButton")
    end)

  PRT.SelectFirstTab(entriesTabGroupWidget, rotation.entries)

  rotationOptionsGroup:AddChild(enabledCheckbox)
  PRT.AddEnabledDifficultiesGroup(rotationOptionsGroup, rotation)
  rotationOptionsGroup:AddChild(nameEditBox)
  PRT.AddDescription(rotationOptionsGroup, rotation)
  rotationOptionsGroup:AddChild(ignoreAfterActivationCheckBox)
  rotationOptionsGroup:AddChild(ignoreDurationSlider)
  rotationOptionsGroup:AddChild(shouldRestartCheckBox)
  rotationOptionsGroup:AddChild(cloneButton)
  rotationOptionsGroup:AddChild(deleteButton)
  rotationOptionsGroup:AddChild(copyButton)
  container:AddChild(rotationOptionsGroup)
  container:AddChild(triggerConditionGroup)
  PRT.MaybeAddStartCondition(container, rotation)
  PRT.MaybeAddStopCondition(container, rotation)
  container:AddChild(entriesTabGroupWidget)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddRotationOptions(container, profile, encounterID)
  local _, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
  local rotations = encounter.Rotations

  local rotationOptionsGroup = PRT.InlineGroup("Options")
  rotationOptionsGroup:SetLayout("Flow")

  local addButton = PRT.Button("newRotation")
  addButton:SetCallback("OnClick",
    function()
      local newRotation = PRT.EmptyRotation()
      tinsert(rotations, newRotation)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "rotations", newRotation.name)
    end)

  local hasClipboardRotation = not PRT.TableUtils.IsEmpty(PRT.db.profile.clipboard.rotation)
  local pasteButtonText = PRT.StringUtils.WrapColorByBoolean(L["pasteRotation"], hasClipboardRotation, "FF696969")
  local pasteButton = PRT.Button(pasteButtonText)
  pasteButton:SetDisabled(hasClipboardRotation)
  pasteButton:SetCallback("OnClick",
    function()
      tinsert(rotations, PRT.db.profile.clipboard.rotation)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "rotations", PRT.db.profile.clipboard.rotation.name)
      PRT.Debug("Pasted rotation", PRT.HighlightString(PRT.db.profile.clipboard.rotation.name), "to", PRT.HighlightString(encounter.name))
      PRT.db.profile.clipboard.rotation = nil
    end)

  rotationOptionsGroup:AddChild(addButton)
  rotationOptionsGroup:AddChild(pasteButton)
  container:AddChild(rotationOptionsGroup)
end

function PRT.AddRotationWidget(container, profile, encounterID, triggerName)
  local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)
  local rotations = encounter.Rotations
  local rotationIndex, rotation = PRT.FilterTableByName(rotations, triggerName)
  local deleteButton = PRT.NewTriggerDeleteButton(container, rotations, rotationIndex, "deleteRotation", rotation.name)
  local cloneButton = PRT.NewCloneButton(container, rotations, rotationIndex, "cloneRotation", rotation.name)

  Rotation.RotationWidget(rotation, container, deleteButton, cloneButton)
end
