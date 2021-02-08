local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Trigger = {}

local enabledDifficultiesDefaults = {
  Normal = true,
  Heroic = true,
  Mythic = true
}

local function EnsureEnabledDifficulties(trigger)
  if not trigger.enabledDifficulties then
    local defaults = PRT.TableUtils.CopyTable(enabledDifficultiesDefaults)
    trigger.enabledDifficulties = defaults
  end
end

local function AddActionsWidgets(container, triggerName, triggers, copyStorePath)
  local triggerIndex, trigger = PRT.FilterTableByName(triggers, triggerName)

  local actionsGroup = PRT.SimpleGroup(nil)
  actionsGroup:SetLayout("Flow")

  -- Clone
  local cloneButton = PRT.Button("triggerCloneButton")
  cloneButton:SetCallback("OnClick",
    function()
      local text = L["cloneConfirmationText"]
      if triggerName then
        text = text.." "..PRT.HighlightString(triggerName)
      end
      PRT.ConfirmationDialog(text,
        function()
          local clone = PRT.TableUtils.CopyTable(triggers[triggerIndex])
          clone.name = clone.name.."- Clone"..random(0,100000)
          tinsert(triggers, clone)
          PRT.Core.UpdateTree()
          PRT.mainWindowContent:DoLayout()
          container:ReleaseChildren()
        end)
    end)

  -- Copy
  local copyButton = PRT.Button("copyTimer")
  copyButton:SetCallback("OnClick",
    function()
      local copy = PRT.TableUtils.CopyTable(trigger)
      copy.name = copy.name.." Copy"..random(0,100000)
      PRT.db.profile.clipboard[copyStorePath] = copy
      PRT.Debug("Copied trigger", PRT.HighlightString(trigger.name), "to clipboard")
    end)

  -- Delete
  local deleteButton = PRT.Button("triggerDeleteButton")
  deleteButton:SetCallback("OnClick",
    function()
      local text = L["deleteConfirmationText"]
      if triggerName then
        text = text.." "..PRT.HighlightString(triggerName)
      end
      PRT.ConfirmationDialog(text,
        function()
          tremove(triggers, triggerIndex)
          PRT.Core.UpdateTree()
          PRT.mainWindowContent:DoLayout()
          container:ReleaseChildren()
        end)
    end)

  actionsGroup:AddChild(cloneButton)
  actionsGroup:AddChild(copyButton)
  actionsGroup:AddChild(deleteButton)
  container:AddChild(actionsGroup)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddEnabledDifficultiesGroup(container, trigger)
  EnsureEnabledDifficulties(trigger)

  local enabledDifficultiesGroup = PRT.InlineGroup("Enable for")
  enabledDifficultiesGroup:SetLayout("Flow")

  local normalCheckbox = PRT.CheckBox("dungeonDifficultyNormal", trigger.enabledDifficulties.Normal or nil)
  normalCheckbox:SetRelativeWidth(0.33)
  normalCheckbox:SetCallback("OnValueChanged",
    function(widget)
      trigger.enabledDifficulties.Normal = widget:GetValue()
      PRT.Core.UpdateTree()
    end)

  local heroicCheckbox = PRT.CheckBox("dungeonDifficultyHeroic", trigger.enabledDifficulties.Heroic or nil)
  heroicCheckbox:SetRelativeWidth(0.33)
  heroicCheckbox:SetCallback("OnValueChanged",
    function(widget)
      trigger.enabledDifficulties.Heroic = widget:GetValue()
      PRT.Core.UpdateTree()
    end)

  local mythicCheckbox = PRT.CheckBox("dungeonDifficultyMythic", trigger.enabledDifficulties.Mythic or nil)
  mythicCheckbox:SetRelativeWidth(0.33)
  mythicCheckbox:SetCallback("OnValueChanged",
    function(widget)
      trigger.enabledDifficulties.Mythic = widget:GetValue()
      PRT.Core.UpdateTree()
    end)

  enabledDifficultiesGroup:AddChild(normalCheckbox)
  enabledDifficultiesGroup:AddChild(heroicCheckbox)
  enabledDifficultiesGroup:AddChild(mythicCheckbox)

  container:AddChild(enabledDifficultiesGroup)
end

function PRT.AddDescription(container, trigger)
  local descriptionMultiLineEditBox = PRT.MultiLineEditBox("descriptionMultiLineEditBox", trigger.description or "")
  descriptionMultiLineEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      trigger.description = text
      widget:ClearFocus()
    end)
  descriptionMultiLineEditBox:SetRelativeWidth(1)
  container:AddChild(descriptionMultiLineEditBox)
end

function PRT.AddGeneralOptionsWidgets(container, triggerName, triggers, copyStorePath)
  local _, trigger = PRT.FilterTableByName(triggers, triggerName)

  local generalOptionsGroup = PRT.SimpleGroup()

  local enabledCheckbox = PRT.CheckBox("triggerEnabled", trigger.enabled)
  enabledCheckbox:SetRelativeWidth(1)
  enabledCheckbox:SetCallback("OnValueChanged",
    function(widget)
      trigger.enabled = widget:GetValue()
      PRT.Core.UpdateTree()
    end)

  local nameEditBox = PRT.EditBox("triggerName", trigger.name)
  nameEditBox:SetRelativeWidth(1)
  nameEditBox:SetCallback("OnEnterPressed",
    function(widget)
      trigger.name = widget:GetText()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectExchangeLast(trigger.name)
      widget:ClearFocus()
    end)

  generalOptionsGroup:AddChild(enabledCheckbox)
  PRT.AddEnabledDifficultiesGroup(generalOptionsGroup, trigger)
  generalOptionsGroup:AddChild(nameEditBox)
  PRT.AddDescription(generalOptionsGroup, trigger)
  container:AddChild(generalOptionsGroup)
  AddActionsWidgets(container, triggerName, triggers, copyStorePath)
end
