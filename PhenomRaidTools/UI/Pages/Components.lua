local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI

--[[
  All controls of the new window on one page, with throwaway values, to check
  them in game while the real pages are being built. Development versions
  only (TOC version not replaced by the packager).
]]

if not (C_AddOns.GetAddOnMetadata("PhenomRaidTools", "Version") or ""):find("@project", 1, true) then
  return
end

local demo = {
  toggle = true,
  slider = 5,
  choice = "anchor",
  filter = "all",
  roles = {TANK = true, HEALER = true},
  text = "",
  times = {30, 75, 160},
  spellID = 31821,
  color = {r = 1, g = 0.82, b = 0.3, a = 1},
  sound = "PRT: Default",
  encounters = {
    {name = "Encounter A", triggers = {"Pull", "Phase 2"}},
    {name = "Encounter B", triggers = {"Pull"}}
  }
}

local function Bind(key)
  return function()
    return demo[key]
  end, function(value)
    demo[key] = value
  end
end

local function ControlsCards()
  local getToggle, setToggle = Bind("toggle")
  local getSlider, setSlider = Bind("slider")
  local getChoice, setChoice = Bind("choice")
  local getFilter, setFilter = Bind("filter")
  local getText, setText = Bind("text")
  local getTimes, setTimes = Bind("times")
  local getSpell, setSpell = Bind("spellID")
  local getSound, setSound = Bind("sound")
  return {
    {
      title = "Filter",
      fullWidth = true,
      rows = {
        {
          type = "chips",
          values = {{value = "all", label = "All"}, {value = "timers", label = "Timers"}, {value = "legacy", label = "Legacy"}},
          get = getFilter,
          set = setFilter
        }
      }
    },
    {
      title = "Basic controls",
      toggle = {get = getToggle, set = setToggle},
      rows = {
        {type = "checkbox", label = "Checkbox", tooltip = "Tooltip text.", get = getToggle, set = setToggle},
        {type = "slider", label = "Slider", min = 0, max = 10, step = 0.5, get = getSlider, set = setSlider},
        {
          type = "dropdown",
          label = "Dropdown",
          values = {{value = "anchor", label = "From anchor"}, {value = "center", label = "Centered"}},
          get = getChoice,
          set = setChoice
        },
        {type = "text", label = "Text", placeholder = "Type something", get = getText, set = setText},
        {type = "button", label = "Button", buttonText = "Danger", danger = true, onClick = function()
            end},
        {type = "notice", label = "Notice with `markup` and {Option}."},
        {type = "live", get = function()
              return ("Live: %d"):format(GetTime())
            end}
      }
    },
    {
      title = "PRT editors",
      rows = {
        {
          type = "multiselect",
          label = "Multi-select",
          values = {{value = "TANK", label = "Tanks"}, {value = "HEALER", label = "Healers"}, {value = "DAMAGER", label = "Damage"}},
          get = function(value)
            return demo.roles[value]
          end,
          set = function(value, selected)
            demo.roles[value] = selected or nil
          end
        },
        {type = "timelist", label = "Times after pull", note = "m:ss or seconds, separated by commas.", get = getTimes, set = setTimes},
        {type = "spell", label = "Spell", get = getSpell, set = setSpell},
        {
          type = "color",
          label = "Color",
          hasAlpha = true,
          get = function()
            return demo.color
          end,
          set = function(r, g, b, a)
            demo.color = {r = r, g = g, b = b, a = a}
          end
        },
        {type = "sound", label = "Sound", get = getSound, set = setSound}
      }
    }
  }
end

local function EncounterList()
  local items = {}
  for _, encounter in ipairs(demo.encounters) do
    items[#items + 1] = {label = encounter.name, note = ("%d triggers"):format(#encounter.triggers), icon = 134400}
  end
  return items
end

local function MoveEntry(list, index, delta)
  local target = index + delta
  list[index], list[target] = list[target], list[index]
end

UI.RegisterPage(
  {
    id = "components",
    label = "Components",
    section = "Development",
    order = 1000,
    build = function(path)
      local encounter = demo.encounters[path[1]]
      local trigger = encounter and encounter.triggers[path[2]]
      if trigger then
        return trigger, "Third level", {
          {title = "Trigger", rows = {{type = "description", label = "Breadcrumb and back button go up one level."}}}
        }, {encounter.name}
      end
      if encounter then
        return encounter.name, "Second level", {
          {
            title = "Triggers",
            rows = {
              {
                type = "list",
                items = function()
                  local items = {}
                  for _, name in ipairs(encounter.triggers) do
                    items[#items + 1] = {label = name}
                  end
                  return items
                end,
                onClick = UI.Push,
                onRemove = function(index)
                  table.remove(encounter.triggers, index)
                end,
                onAdd = function()
                  encounter.triggers[#encounter.triggers + 1] = "Trigger " .. (#encounter.triggers + 1)
                end
              }
            }
          }
        }
      end
      local cards = ControlsCards()
      table.insert(
        cards,
        2,
        {
          title = "List editor",
          note = "Click an entry to go one level deeper.",
          rows = {
            {
              type = "list",
              items = EncounterList,
              onClick = UI.Push,
              onMove = function(index, delta)
                MoveEntry(demo.encounters, index, delta)
              end,
              onRemove = function(index)
                table.remove(demo.encounters, index)
              end,
              confirmRemove = function(index)
                return ("Remove %s?"):format(demo.encounters[index].name)
              end,
              onAdd = function()
                demo.encounters[#demo.encounters + 1] = {name = "Encounter " .. (#demo.encounters + 1), triggers = {}}
              end,
              addLabel = L["Add"]
            }
          }
        }
      )
      return "Components", "All controls of the new window", cards
    end
  }
)
