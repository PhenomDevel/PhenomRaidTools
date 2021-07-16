local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local enabledDifficultiesDefaults = {
  Normal = true,
  Heroic = true,
  Mythic = true
}

local function EnsureEnabledDifficulties(trigger)
  if not trigger.enabledDifficulties then
    local defaults = PRT.TableUtils.Clone(enabledDifficultiesDefaults)
    trigger.enabledDifficulties = defaults
  end
end

local function AddActionsWidgets(container, triggerName, triggers, copyStorePath)
  local triggerIndex, trigger = PRT.TableUtils.GetBy(triggers, "name", triggerName)

  local actionsGroup = PRT.SimpleGroup(nil)
  actionsGroup:SetLayout("Flow")

  -- Clone
  local cloneButton = PRT.Button(L["Clone"])
  cloneButton:SetCallback(
    "OnClick",
    function()
      PRT.ConfirmationDialog(
        L["Are you sure you want to clone %s?"]:format(PRT.HighlightString(triggerName)),
        function()
          local clone = PRT.TableUtils.Clone(triggers[triggerIndex])
          clone.name = PRT.NewCloneName()
          tinsert(triggers, clone)
          PRT.Core.UpdateTree()
          PRT.mainWindowContent:DoLayout()
          container:ReleaseChildren()
        end
      )
    end
  )

  -- Copy
  local copyButton = PRT.Button(L["Copy"])
  copyButton:SetCallback(
    "OnClick",
    function()
      local copy = PRT.TableUtils.Clone(trigger)
      copy.name = copy.name .. " Copy" .. PRT.RandomNumber()
      PRT.GetProfileDB().clipboard[copyStorePath] = copy
      PRT.Debug("Copied trigger", PRT.HighlightString(trigger.name), "to clipboard")
    end
  )

  -- Delete
  local deleteButton = PRT.Button(L["Delete"])
  deleteButton:SetCallback(
    "OnClick",
    function()
      local text = L["Are you sure you want to delete %s?"]:format(PRT.HighlightString(triggerName))

      PRT.ConfirmationDialog(
        text,
        function()
          tremove(triggers, triggerIndex)
          PRT.Core.UpdateTree()
          PRT.mainWindowContent:DoLayout()
          container:ReleaseChildren()
        end
      )
    end
  )

  actionsGroup:AddChild(cloneButton)
  actionsGroup:AddChild(copyButton)
  actionsGroup:AddChild(deleteButton)
  container:AddChild(actionsGroup)
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddEnabledDifficultiesGroup(container, trigger)
  EnsureEnabledDifficulties(trigger)

  local enabledDifficultiesGroup = PRT.InlineGroup(L["Enable on"])
  enabledDifficultiesGroup:SetLayout("Flow")

  local normalCheckbox = PRT.CheckBox(L["Normal"], nil, trigger.enabledDifficulties.Normal or nil)
  normalCheckbox:SetRelativeWidth(0.33)
  normalCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      trigger.enabledDifficulties.Normal = widget:GetValue()
      PRT.Core.UpdateTree()
    end
  )

  local heroicCheckbox = PRT.CheckBox(L["Heroic"], nil, trigger.enabledDifficulties.Heroic or nil)
  heroicCheckbox:SetRelativeWidth(0.33)
  heroicCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      trigger.enabledDifficulties.Heroic = widget:GetValue()
      PRT.Core.UpdateTree()
    end
  )

  local mythicCheckbox = PRT.CheckBox(L["Mythic"], nil, trigger.enabledDifficulties.Mythic or nil)
  mythicCheckbox:SetRelativeWidth(0.33)
  mythicCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      trigger.enabledDifficulties.Mythic = widget:GetValue()
      PRT.Core.UpdateTree()
    end
  )

  enabledDifficultiesGroup:AddChild(normalCheckbox)
  enabledDifficultiesGroup:AddChild(heroicCheckbox)
  enabledDifficultiesGroup:AddChild(mythicCheckbox)

  container:AddChild(enabledDifficultiesGroup)
end

function PRT.AddDescription(container, trigger)
  local descriptionMultiLineEditBox = PRT.MultiLineEditBox(L["Description"], trigger.description or "")
  descriptionMultiLineEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      trigger.description = text
      widget:ClearFocus()
    end
  )
  descriptionMultiLineEditBox:SetRelativeWidth(1)
  container:AddChild(descriptionMultiLineEditBox)
end

function PRT.AddGeneralOptionsWidgets(container, triggerName, triggers, copyStorePath)
  local _, trigger = PRT.TableUtils.GetBy(triggers, "name", triggerName)

  local generalOptionsGroup = PRT.SimpleGroup()

  local enabledCheckbox = PRT.CheckBox(L["Enabled"], nil, trigger.enabled)
  enabledCheckbox:SetRelativeWidth(1)
  enabledCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      trigger.enabled = widget:GetValue()
      PRT.Core.UpdateTree()
    end
  )

  local nameEditBox = PRT.EditBox(L["Name"], nil, trigger.name)
  nameEditBox:SetRelativeWidth(1)
  nameEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      trigger.name = widget:GetText()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectExchangeLast(trigger.name)
      widget:ClearFocus()
    end
  )

  generalOptionsGroup:AddChild(enabledCheckbox)
  PRT.AddEnabledDifficultiesGroup(generalOptionsGroup, trigger)
  generalOptionsGroup:AddChild(nameEditBox)
  PRT.AddDescription(generalOptionsGroup, trigger)
  container:AddChild(generalOptionsGroup)
  AddActionsWidgets(container, triggerName, triggers, copyStorePath)
end
