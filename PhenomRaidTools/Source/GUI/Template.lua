local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Private Helper

local function AddTemplateMessageWidgets(container, messages, messageName)
  local currentMessage = messages[messageName]

  local actionsGroup = PRT.SimpleGroup()
  local messageTemplateNameEditBox = PRT.EditBox(L["Template Name"], nil, messageName)
  messageTemplateNameEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local newName = widget:GetText()
      if not (messageName == newName) then
        messages[messageName] = nil
        if not messages[newName] then
          messages[newName] = currentMessage
          container:ReleaseChildren()
          container:SetTabs(PRT.TableToTabs(messages))
          AddTemplateMessageWidgets(container, messages, newName)
          PRT.Core.UpdateScrollFrame()
        else
          PRT.Error("Name already taken")
        end
      end
    end)

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

  local deleteDropdown = PRT.Dropdown(L["Delete"], nil, messageTemplatesDropdownItems)
  local newButton = PRT.Button(L["New"])

  deleteDropdown:SetCallback("OnValueChanged",
    function(widget)
      PRT.ConfirmationDialog(L["Are you sure you want to delete template %s?"]:format(PRT.HighlightString(widget:GetValue())),
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
    local emptyLabel = PRT.Label(L["There are currently no templates."])
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
      text = L["Messages"]
    },
    {
      value = "timers",
      text = L["Timers"],
      disabled = true
    },
    {
      value = "rotations",
      text = L["Rotations"],
      disabled = true
    },
    {
      value = "healthPercentages",
      text = L["Health Percentages"],
      disabled = true
    },
    {
      value = "powerPercentages",
      text = L["Power Percentages"],
      disabled = true
    }
  }

  local templatesTabGroup = PRT.TabGroup(L["Templates"], tabs)
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
