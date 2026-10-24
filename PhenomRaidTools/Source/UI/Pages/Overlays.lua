local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local LSM = LibStub("LibSharedMedia-3.0")

local UI = PRT.UI
local Overlay = PRT.ReceiverOverlay

--[[
  Where messages show up: the message overlays (one per receiver, messages
  pick one), the combat view with the own next assignments and the lead's
  status overlay. Every change applies to the overlays right away.
]]

local STYLES = {
  {value = "text", label = L["Text"]},
  {value = "icons", label = L["Icons"]},
  {value = "bars", label = L["Bars"]}
}

local GROW = {
  {value = "UP", label = L["Up"]},
  {value = "DOWN", label = L["Down"]},
  {value = "LEFT", label = L["Left"]},
  {value = "RIGHT", label = L["Right"]}
}

local FROM = {
  {value = "anchor", label = L["From the anchor"]},
  {value = "center", label = L["Centered on it"]}
}

local PURPOSES = {
  {value = "none", label = L["None"]},
  {value = "healing", label = L["Healing cooldowns"]},
  {value = "utility", label = L["Utility cooldowns"]}
}

local ALIGN = {
  {value = "LEFT", label = L["Left"]},
  {value = "CENTER", label = L["Center"]},
  {value = "RIGHT", label = L["Right"]}
}

local function Receivers()
  return PRT.GetProfileDB().overlay.receivers
end

local function FontValues()
  local values = {}
  for _, name in ipairs(LSM:List("font")) do
    values[#values + 1] = {value = name, label = name}
  end
  return values
end

local function ColorGet(color, default)
  return function()
    local value = color() or default
    return {r = value.r or 1, g = value.g or 1, b = value.b or 1, a = value.a or 1}
  end
end

-- Binds a row to a field of a receiver and applies it to the overlays.
local function Field(config, key, row)
  row.get = row.get or function()
      return Overlay.Get(config, key)
    end
  row.set = row.set or function(value)
      config[key] = value
      Overlay.Refresh()
    end
  return row
end

-------------------------------------------------------------------------------
-- Message overlay

local function ReceiverPage(index)
  local config = Receivers()[index]
  UI.SetPreview({kind = "receiver", config = config})
  local style = Overlay.Get(config, "style")
  local vertical = Overlay.Get(config, "grow") == "UP" or Overlay.Get(config, "grow") == "DOWN"

  local layoutRows = {
    Field(config, "style", {type = "chips", values = STYLES}),
    {type = "description", label = L["Grows"]},
    Field(config, "grow", {type = "chips", values = GROW}),
    Field(config, "from", {type = "chips", values = FROM})
  }
  if vertical then
    layoutRows[#layoutRows + 1] = Field(config, "align", {type = "dropdown", label = L["Alignment"], values = ALIGN})
  end
  layoutRows[#layoutRows + 1] = Field(config, "spacing", {type = "slider", label = L["Spacing"], min = 0, max = 30})
  layoutRows[#layoutRows + 1] = Field(config, "maxEntries", {type = "slider", label = L["Messages at once"], min = 1, max = 10})
  if style ~= "text" then
    layoutRows[#layoutRows + 1] = Field(config, "iconSize", {type = "slider", label = L["Icon size"], min = 12, max = 80})
  end
  if style == "bars" then
    layoutRows[#layoutRows + 1] = Field(config, "barWidth", {type = "slider", label = L["Bar width"], min = 80, max = 500, step = 5})
    layoutRows[#layoutRows + 1] = {
      type = "color",
      label = L["Bar color"],
      hasAlpha = true,
      get = ColorGet(
        function()
          return config.barColor
        end,
        {r = 0.18, g = 0.6, b = 0.84, a = 0.9}
      ),
      set = function(r, g, b, a)
        config.barColor = {r = r, g = g, b = b, a = a}
        Overlay.Refresh()
      end
    }
  end

  return ("%d: %s"):format(index, config.label or ""), L["Message overlay"], {
    {
      title = L["Overlay"],
      rows = {
        Field(
          config,
          "label",
          {
            type = "text",
            label = L["Name"],
            layout = true,
            get = function()
              return config.label or ""
            end
          }
        ),
        {
          type = "dropdown",
          label = L["Cooldowns"],
          note = L["Cooldowns of this kind from the list go here."],
          values = PURPOSES,
          get = function()
            return config.purpose or "none"
          end,
          set = function(value)
            for _, other in ipairs(Receivers()) do
              if value ~= "none" and other.purpose == value then
                other.purpose = nil
              end
            end
            config.purpose = value ~= "none" and value or nil
          end
        },
        Field(config, "locked", {type = "checkbox", label = L["Locked"], note = L["Unlock to drag it to its place."], layout = true}),
        {
          type = "button",
          label = L["Show on screen"],
          note = L["Three sample messages where the overlay is."],
          buttonText = L["Test"],
          onClick = function()
            Overlay.Test(index)
          end
        },
        {
          type = "button",
          label = L["Reset position"],
          buttonText = L["Reset"],
          onClick = function()
            Overlay.ResetPosition(index)
          end
        },
        Field(config, "x", {type = "slider", label = L["Horizontal"], min = -1200, max = 1200}),
        Field(config, "y", {type = "slider", label = L["Vertical"], min = -800, max = 800})
      }
    },
    {title = L["Layout"], note = L["The message that ends first is next to the anchor."], rows = layoutRows},
    {
      title = L["Font"],
      rows = {
        Field(config, "fontName", {type = "dropdown", label = L["Font"], values = FontValues, placeholder = L["Default"]}),
        Field(config, "fontSize", {type = "slider", label = L["Size"], min = 8, max = 96}),
        {
          type = "color",
          label = L["Color"],
          hasAlpha = true,
          get = ColorGet(
            function()
              return config.fontColor
            end,
            {r = 1, g = 1, b = 1, a = 1}
          ),
          set = function(r, g, b, a)
            config.fontColor = {r = r, g = g, b = b, a = a, hex = PRT.RGBAToHex(r, g, b, a)}
            Overlay.Refresh()
          end
        }
      }
    },
    {
      title = L["Sound"],
      toggle = {
        get = function()
          return Overlay.Get(config, "enableSound")
        end,
        set = function(value)
          config.enableSound = value
        end
      },
      rows = {
        {
          type = "sound",
          label = L["Sound"],
          note = L["For messages without their own sound."],
          get = function()
            return config.defaultSoundFileName
          end,
          set = function(value)
            config.defaultSoundFileName = value
            config.defaultSoundFile = LSM:Fetch("sound", value, true)
          end
        }
      }
    }
  }, {}
end

-------------------------------------------------------------------------------
-- Overview

local function ReceiverItems()
  local items = {}
  for index, config in ipairs(Receivers()) do
    local style = Overlay.Get(config, "style")
    local styleLabel, growLabel = style, Overlay.Get(config, "grow")
    for _, entry in ipairs(STYLES) do
      if entry.value == style then
        styleLabel = entry.label
      end
    end
    for _, entry in ipairs(GROW) do
      if entry.value == growLabel then
        growLabel = entry.label
      end
    end
    local color = config.fontColor or {}
    items[#items + 1] = {
      label = ("%d: %s"):format(index, config.label or ""),
      note = ("%s · %s%s"):format(styleLabel, growLabel, Overlay.Get(config, "locked") and "" or (" · " .. L["unlocked"])),
      color = {color.r or 1, color.g or 1, color.b or 1, 1}
    }
  end
  return items
end

local function ReceiversCard()
  return {
    title = L["Message overlays"],
    note = L["Each message picks one. The number is what messages refer to."],
    rows = {
      {
        type = "list",
        items = ReceiverItems,
        onClick = function(index)
          UI.Push(index)
        end,
        onRemove = function(index)
          if index > 1 then
            tremove(Receivers(), index)
            Overlay.Refresh()
          end
        end,
        confirmRemove = function(index)
          return L["Remove %s? Its messages show on overlay 1."]:format(Receivers()[index].label or tostring(index))
        end,
        onAdd = function()
          local index = #Receivers() + 1
          Receivers()[index] = {
            id = index,
            name = index,
            label = L["Overlay %d"]:format(index),
            fontSize = 24,
            fontColor = {r = 1, g = 1, b = 1, a = 1, hex = "ffffffff"},
            locked = false,
            x = 0,
            y = 0,
            defaultSoundFileName = "PRT: Default",
            defaultSoundFile = LSM:Fetch("sound", "PRT: Default", true)
          }
          Overlay.Refresh()
          UI.Push(index)
        end,
        addLabel = L["New overlay"]
      },
      {
        type = "button",
        label = L["Unlock all"],
        note = L["Shows every anchor to drag it."],
        buttonText = L["Unlock"],
        onClick = function()
          Overlay.SetLocked(false)
        end
      },
      {
        type = "button",
        label = L["Lock all"],
        buttonText = L["Lock"],
        onClick = function()
          Overlay.SetLocked(true)
        end
      },
      {
        type = "button",
        label = L["Test all"],
        buttonText = L["Test"],
        onClick = function()
          Overlay.Test()
        end
      },
      {
        type = "button",
        label = L["Default overlays"],
        note = L["Messages at the top, healing cooldowns on the left, utility cooldowns on the right."],
        buttonText = L["Restore"],
        danger = true,
        onClick = function()
          UI.Confirm(
            L["Replace your overlays with the three default ones?"],
            L["Restore"],
            function()
              PRT.GetProfileDB().overlay.receivers = Overlay.DefaultReceivers()
              Overlay.Refresh()
              UI.Refresh()
            end
          )
        end
      }
    }
  }
end

local function UpcomingCard()
  local options = PRT.GetProfileDB().overlay.upcoming
  local function Set(key)
    return function(value)
      options[key] = value
      PRT.Upcoming.ShowPreview()
    end
  end
  local function Get(key)
    return function()
      return options[key]
    end
  end
  return {
    title = L["Your next assignments"],
    note = L["During an encounter: what's next for you with a countdown, read from the plan."],
    toggle = {get = Get("enabled"), set = Set("enabled")},
    rows = {
      {
        type = "checkbox",
        label = L["Locked"],
        note = L["Unlock to see and drag it."],
        get = function()
          return options.locked ~= false
        end,
        set = Set("locked")
      },
      {type = "slider", label = L["Lines"], min = 1, max = 6, get = Get("count"), set = Set("count")},
      {
        type = "slider",
        label = L["Look ahead"],
        note = L["Seconds before an assignment it appears."],
        min = 5,
        max = 120,
        step = 5,
        get = Get("leadTime"),
        set = Set("leadTime")
      },
      {type = "slider", label = L["Size"], min = 10, max = 48, get = Get("fontSize"), set = Set("fontSize")},
      {type = "dropdown", label = L["Font"], values = FontValues, placeholder = L["Default"], get = Get("fontName"), set = Set("fontName")}
    }
  }
end

local function SenderCard()
  local options = PRT.GetProfileDB().overlay.sender
  local function Set(key)
    return function(value)
      options[key] = value
      if PRT.SenderOverlay.IsShown() then
        PRT.SenderOverlay.Refresh()
      end
    end
  end
  local function Get(key)
    return function()
      return options[key]
    end
  end
  return {
    title = L["Lead status"],
    note = L["For the lead during the own plan: every group with the time to its next assignment."],
    toggle = {get = Get("enabled"), set = Set("enabled")},
    rows = {
      {
        type = "button",
        label = L["Place it"],
        note = L["Shows it to drag it."],
        buttonText = L["Show"],
        onClick = PRT.SenderOverlay.ShowPreview
      },
      {
        type = "button",
        label = L["Hide it"],
        buttonText = L["Hide"],
        onClick = PRT.SenderOverlay.Hide
      },
      {type = "checkbox", label = L["Hide after combat"], get = Get("hideAfterCombat"), set = Set("hideAfterCombat")},
      {type = "checkbox", label = L["Hide disabled groups"], get = Get("hideDisabledTriggers"), set = Set("hideDisabledTriggers")},
      {type = "slider", label = L["Size"], min = 8, max = 32, get = Get("fontSize"), set = Set("fontSize")},
      {
        type = "color",
        label = L["Background"],
        hasAlpha = true,
        get = ColorGet(Get("backdropColor"), {r = 0, g = 0, b = 0, a = 0.7}),
        set = function(r, g, b, a)
          options.backdropColor = {r = r, g = g, b = b, a = a}
          Set("backdropColor")(options.backdropColor)
        end
      }
    }
  }
end

UI.RegisterPage(
  {
    id = "overlays",
    label = L["Overlays"],
    order = 50,
    searchable = true,
    build = function(path)
      local index = path[1]
      if index and Receivers()[index] then
        return ReceiverPage(index)
      end
      return L["Overlays"], L["Where messages show up"], {ReceiversCard(), UpcomingCard(), SenderCard()}
    end
  }
)
