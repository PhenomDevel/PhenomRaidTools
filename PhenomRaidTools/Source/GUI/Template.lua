local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Private Helper

local function AddTemplateNameWidgets(container, messages, messageName)
  local currentMessage = messages[messageName]

  local messageTemplateNameEditBox = PRT.EditBox("messageTemplateName", messageName)
  messageTemplateNameEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local newName = widget:GetText()
      if not (messageName == newName) then
        messages[messageName] = nil
        if not messages[newName] then
          messages[newName] = currentMessage
        else
          PRT.Error("Name already taken")
        end
      end

      widget:ClearFocus()
    end)

  container:AddChild(messageTemplateNameEditBox)
end

local function AddMessageTemplateWidgets(container, messages)
  if PRT.TableUtils.IsEmpty(messages) then
    local emptyLabel = PRT.Label("templateMessagesEmptyDescription")
    container:AddChild(emptyLabel)
  else
    local templateTabs = {}
    for name, _ in pairs(messages) do
      tinsert(templateTabs, { value = name, text = name})
    end

    local messageTemplatesDropdownItems = {}
    for name, _ in pairs(messages) do
      tinsert(messageTemplatesDropdownItems, name)
    end

    local actionsGroup = PRT.SimpleGroup()
    actionsGroup:SetLayout("Flow")
    local newButton = PRT.Button("templateMessageNewButton")
    local deleteDropdown = PRT.Dropdown("templateMessagesDeleteDropdown", messageTemplatesDropdownItems)
    local templatesGroup = PRT.TabGroup(nil, templateTabs)

    newButton:SetCallback("OnClick",
      function()
        local newMessage = PRT.EmptyMessage()
        local newMessageName = "template"..random(100000)

        messages[newMessageName] = newMessage
        container:ReleaseChildren()
        AddMessageTemplateWidgets(container, messages)
        templatesGroup:SelectTab(newMessageName)
      end)

    deleteDropdown:SetCallback("OnValueChanged",
      function(widget)
        PRT.ConfirmationDialog("templateMessagesDeleteConfirmation",
          function()
            messages[widget:GetValue()] = nil
            container:ReleaseChildren()
            AddMessageTemplateWidgets(container, messages)
            templatesGroup:SelectTab(templateTabs[1].value)
          end)
      end)

    templatesGroup:SetCallback("OnGroupSelected",
      function(widget, _, key)
        widget:ReleaseChildren()
        AddTemplateNameWidgets(widget, messages, key)
        PRT.MessageWidget(messages[key], widget)
      end)

    templatesGroup:SelectTab(templateTabs[1].value)

    actionsGroup:AddChild(deleteDropdown)
    actionsGroup:AddChild(newButton)
    container:AddChild(actionsGroup)
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
