local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Rotation = {}


-------------------------------------------------------------------------------
-- Local Helper

function Rotation.RotationEntryWidget(entry, container, _, entries)
  local messagesTabs = PRT.TableToTabs(entry.messages, true)
  local messagesTabGroup = PRT.TabGroup(L["Messages"], messagesTabs)
  messagesTabGroup:SetLayout("List")
  messagesTabGroup:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, true, L["Delete"], true, L["Clone"])
    end)

  PRT.SelectFirstTab(messagesTabGroup, entry.messages)

  container:AddChild(messagesTabGroup)
end

function Rotation.RotationWidget(rotationName, rotations, container)
  local _, rotation = PRT.TableUtils.GetBy(rotations, "name", rotationName)

  -- General Options
  PRT.AddGeneralOptionsWidgets(container, rotationName, rotations, "rotation")

  -- Rotation Options
  local rotationOptionsGroup = PRT.InlineGroup(L["Options"])
  rotationOptionsGroup:SetLayout("Flow")

  local shouldRestartCheckBox =  PRT.CheckBox(L["Restart"], L["Restarts the rotation when\nno more entries are found."], rotation.shouldRestart)
  local ignoreAfterActivationCheckBox = PRT.CheckBox(L["Ignore after activation"], L["Ignore all events for X seconds."], rotation.ignoreAfterActivation)
  local ignoreDurationSlider = PRT.Slider(L["Ignore for"], nil, rotation.ignoreDuration)

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

  rotationOptionsGroup:AddChild(shouldRestartCheckBox)
  rotationOptionsGroup:AddChild(ignoreAfterActivationCheckBox)
  rotationOptionsGroup:AddChild(ignoreDurationSlider)
  container:AddChild(rotationOptionsGroup)

  -- Trigger Condition
  local triggerConditionGroup = PRT.ConditionWidget(rotation.triggerCondition, "Trigger Condition")
  triggerConditionGroup:SetLayout("Flow")
  container:AddChild(triggerConditionGroup)

  -- Start Condition
  PRT.MaybeAddStartCondition(container, rotation)

  -- Stop Condition
  PRT.MaybeAddStopCondition(container, rotation)

  -- Rotationentries
  local tabs = PRT.TableToTabs(rotation.entries, true)
  local entriesTabGroupWidget = PRT.TabGroup(L["Rotation Entry"], tabs)
  entriesTabGroupWidget:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, rotation.entries, key, Rotation.RotationEntryWidget, PRT.EmptyRotationEntry, true, L["Delete"], true, L["Clone"])
    end)

  PRT.SelectFirstTab(entriesTabGroupWidget, rotation.entries)
  container:AddChild(entriesTabGroupWidget)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddRotationOptions(container, profile, encounterID)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))
  local rotations = encounter.Rotations

  local rotationOptionsGroup = PRT.InlineGroup(L["Options"])
  rotationOptionsGroup:SetLayout("Flow")

  local addButton = PRT.Button(L["New"])
  addButton:SetCallback("OnClick",
    function()
      local newRotation = PRT.EmptyRotation()
      tinsert(rotations, newRotation)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "rotations", newRotation.name)
    end)

  local hasClipboardRotation = (not PRT.TableUtils.IsEmpty(PRT.db.profile.clipboard.rotation))
  local pasteButtonText = PRT.StringUtils.WrapColorByBoolean(L["Paste"], hasClipboardRotation, "FF696969")
  local pasteButton = PRT.Button(pasteButtonText)
  pasteButton:SetDisabled(not hasClipboardRotation)
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

function PRT.AddRotationWidget(container, profile, encounterID, rotationName)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, encounterID)
  local rotations = encounter.Rotations

  Rotation.RotationWidget(rotationName, rotations, container)
end
