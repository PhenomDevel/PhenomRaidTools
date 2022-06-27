local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Private Helper

local function renderTemplate(container, refreshContainerFn, messages, message)
  local actionsGroup = PRT.SimpleGroup()
  local messageTemplateNameEditBox = PRT.EditBox(L["Template Name"], nil, message.name)
  messageTemplateNameEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local newName = widget:GetText()

      if message.name ~= newName then
        if not messages[newName] then
          PRT.TableUtils.SwapKey(messages, message.name, newName)
          message.name = newName
          refreshContainerFn()
        else
          PRT.Error("Name %s is already taken"):format(PRT.HighlightString(newName))
        end
      end
    end
  )

  actionsGroup:AddChild(messageTemplateNameEditBox)

  container:AddChild(actionsGroup)
  PRT.MessageWidget(message, container)
end

local function newTemplateMessage()
  local message = PRT.EmptyMessage()
  message.name = "Message " .. PRT.RandomNumber()

  return message
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

  local tabGroupContentOptions = {confirmDelete = true, withClone = true}

  local templatesTabGroup = PRT.TabGroup(L["Templates"], tabs)
  templatesTabGroup:SetFullHeight(true)
  templatesTabGroup:SetCallback(
    "OnGroupSelected",
    function(widget, _, key)
      widget:ReleaseChildren()
      if key == "messages" then
        widget:AddChild(PRT.TabGroupContainer(tabGroupContentOptions, profile.templateStore.messages, renderTemplate, newTemplateMessage))
      end
    end
  )

  templatesTabGroup:SelectTab("messages")
  container:AddChild(templatesTabGroup)
end
