local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI

--[[
  Message templates (templateStore.messages, keyed by name): saved from the
  assignment editor and loaded into any message there.
]]

local function Store()
  return PRT.GetProfileDB().templateStore.messages
end

local function SortedNames()
  local names = {}
  for name in pairs(Store()) do
    names[#names + 1] = name
  end
  table.sort(names)
  return names
end

local function TemplatePage(name)
  local template = Store()[name]
  local cards = UI.Messages.Cards(template, {isTemplate = true})
  table.insert(
    cards,
    1,
    {
      title = L["Template"],
      rows = {
        {
          type = "text",
          label = L["Name"],
          get = function()
            return name
          end,
          set = function(value)
            if value == "" or value == name then
              return
            end
            if Store()[value] then
              PRT.Error(L["A template named %s already exists."]:format(PRT.HighlightString(value)))
              return
            end
            Store()[value], Store()[name] = template, nil
            template.name = value
            UI.Navigate("templates", value)
          end
        }
      }
    }
  )
  return name, L["Template"], cards, {}
end

local function ListPage()
  return L["Templates"], L["Messages you use again and again"], {
    {
      title = L["Templates"],
      note = L["Load a template in any message with {Load template}."],
      rows = {
        {
          type = "list",
          items = function()
            local items = {}
            for _, name in ipairs(SortedNames()) do
              items[#items + 1] = {label = name, note = UI.Messages.DisplayText(Store()[name])}
            end
            return items
          end,
          empty = L["No templates yet. Save one from any message."],
          onClick = function(index)
            UI.Push(SortedNames()[index])
          end,
          onRemove = function(index)
            Store()[SortedNames()[index]] = nil
          end,
          confirmRemove = function(index)
            return L["Delete %s?"]:format(SortedNames()[index])
          end,
          onAdd = function()
            local index = 1
            while Store()[L["Template %d"]:format(index)] do
              index = index + 1
            end
            local name = L["Template %d"]:format(index)
            local template = PRT.EmptyMessage()
            template.name = name
            Store()[name] = template
            UI.Push(name)
          end,
          addLabel = L["New template"]
        }
      }
    }
  }
end

UI.RegisterPage(
  {
    id = "templates",
    label = L["Templates"],
    order = 40,
    build = function(path)
      if path[1] and Store()[path[1]] then
        return TemplatePage(path[1])
      end
      return ListPage()
    end
  }
)
