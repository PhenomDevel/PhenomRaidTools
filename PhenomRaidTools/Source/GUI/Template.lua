local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Private Helper

local function AddTemplateMessageWidgets(container, messages, messageName)
  local actionsGroup = PRT.SimpleGroup()
  local messageTemplateNameEditBox = PRT.EditBox("messageTemplateName", messageName)

  actionsGroup:AddChild(messageTemplateNameEditBox)

  container:AddChild(actionsGroup)
  PRT.MessageWidget(messages[messageName], container)
end

local function AddTemplateActions(container, entities, widgetUpdateFn)
  local actionsGroup = PRT.SimpleGroup()
  actionsGroup:SetLayout("Flow")

  local messageTemplatesDropdownItems = {}
  for name, _ in pairs(entities) do
    tinsert(messageTemplatesDropdownItems, name)
  end

  local deleteDropdown = PRT.Dropdown("templateMessagesDeleteDropdown", messageTemplatesDropdownItems)
  local newButton = PRT.Button("templateMessageNewButton")

  deleteDropdown:SetCallback("OnValueChanged",
    function(widget)
      PRT.ConfirmationDialog("templateMessagesDeleteConfirmation",
        function()
          entities[widget:GetValue()] = nil
          widgetUpdateFn()
        end)
    end)

  newButton:SetCallback("OnClick",
    function()
      local newMessage = PRT.EmptyMessage()
      local newMessageName = "template"..random(100000)

      entities[newMessageName] = newMessage
      widgetUpdateFn()
    end)

  actionsGroup:AddChild(deleteDropdown)
  actionsGroup:AddChild(newButton)
  container:AddChild(actionsGroup)
end

local function AddMessageTemplateWidgets(container, messages)
  local widgetUpdateFn = function()
    container:ReleaseChildren()
    AddMessageTemplateWidgets(container, messages)
  end

  if PRT.TableUtils.IsEmpty(messages) then
    local emptyLabel = PRT.Label("templateMessagesEmptyDescription")
    container:AddChild(emptyLabel)
    AddTemplateActions(container, messages, widgetUpdateFn)
  else
    local templateTabs = PRT.TableToTabs(messages)
    local templatesGroup = PRT.TabGroup(nil, templateTabs)

    templatesGroup:SetCallback("OnGroupSelected",
      function(widget, _, key)
        widget:ReleaseChildren()
        AddTemplateMessageWidgets(widget, messages, key)
        PRT.Core.UpdateScrollFrame()
      end)

    templatesGroup:SelectTab(templateTabs[1].value)

    AddTemplateActions(container, messages, widgetUpdateFn)
    container:AddChild(templatesGroup)
  end
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddTemplateWidgets(container, profile)
  local tabs = {
    {
      value = "messages",
      text = L["templatesTabGroupMessages"]
    },
    {
      value = "timers",
      text = L["templatesTabGroupTimers"],
      disabled = true
    },
    {
      value = "rotations",
      text = L["templatesTabGroupRotations"],
      disabled = true
    },
    {
      value = "healthPercentages",
      text = L["templatesTabGroupHealthPercentages"],
      disabled = true
    },
    {
      value = "powerPercentages",
      text = L["templatesTabGroupPowerPercentages"],
      disabled = true
    }
  }

  local templatesTabGroup = PRT.TabGroup("templatesTabGroup", tabs)
  templatesTabGroup:SetFullHeight(true)
  templatesTabGroup:SetCallback("OnGroupSelected",
    function(widget, _, key)
      widget:ReleaseChildren()
      if key == "messages" then
        AddMessageTemplateWidgets(widget, profile.templateStore.messages)
      end
    end)

  templatesTabGroup:SelectTab("messages")
  container:AddChild(templatesTabGroup)
end
