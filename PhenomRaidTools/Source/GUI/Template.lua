local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Private Helper

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

    local deleteDropdown = PRT.Dropdown("templateMessagesDeleteDropdown", messageTemplatesDropdownItems)
    deleteDropdown:SetCallback("OnValueChanged",
      function(widget)
        PRT.ConfirmationDialog("templateMessagesDeleteConfirmation",
          function()
            messages[widget:GetValue()] = nil
            container:ReleaseChildren()
            AddMessageTemplateWidgets(container, messages)
          end)
      end)

    local templatesGroup = PRT.TabGroup(nil, templateTabs)
    templatesGroup:SetCallback("OnGroupSelected",
      function(widget, _, key)
        widget:ReleaseChildren()
        PRT.MessageWidget(messages[key], widget)
      end)

    templatesGroup:SelectTab(templateTabs[1].value)

    container:AddChild(deleteDropdown)
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
