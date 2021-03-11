local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local AceGUI = LibStub("AceGUI-3.0")
local Media = LibStub("LibSharedMedia-3.0")

local AceHelper = {
  widgetDefaultWidth = 250,
  LSMLists = {
    font = Media:HashTable("font"),
    sound = Media:HashTable("sound")
  }
}

PRT.AceHelper = AceHelper
-- Create local copies of API functions which we use
local UIParent = UIParent
local GameTooltip = GameTooltip
local GameFontHighlightSmall = GameFontHighlightSmall


-------------------------------------------------------------------------------
-- Local Helper

function AceHelper.AddTooltip(widget, tooltip)
  if widget then
    widget:SetCallback("OnEnter",
      function()
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")

        if widget.label and widget.label:GetText() then
          GameTooltip:AddLine(widget.label:GetText())
        elseif widget.text and widget.text:GetText() then
          GameTooltip:AddLine(widget.text:GetText())
        end

        if tooltip then
          if type(tooltip) == "table" then
            for _, entry in ipairs(tooltip) do
              GameTooltip:AddLine(entry, 1, 1, 1)
            end
          else
            GameTooltip:AddLine(tooltip, 1, 1, 1)
          end
        end

        GameTooltip:Show()
      end)

    widget:SetCallback("OnLeave",
      function()
        GameTooltip:FadeOut()
      end)
  end
end

function AceHelper.AddNewTab(widget, t, item)
  if not t then
    t = {}
  end
  tinsert(t, item)
  widget:SetTabs(PRT.TableToTabs(t, true))
  widget:DoLayout()
  widget:SelectTab(getn(t))

  PRT.Core.UpdateScrollFrame()
end

function AceHelper.RemoveTab(widget, t, item)
  tremove(t, item)
  widget:SetTabs(PRT.TableToTabs(t, true))
  widget:DoLayout()
  widget:SelectTab(1)

  if getn(t) == 0 then
    widget:ReleaseChildren()
  end

  PRT.Core.UpdateScrollFrame()
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddSpellTooltip(widget, spellID)
  if spellID then
    widget:SetCallback("OnEnter",
      function()
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink("spell:"..spellID)
        GameTooltip:Show()
      end)

    widget:SetCallback("OnLeave",
      function()
        GameTooltip:Hide()
      end)
  end
  return widget
end

function PRT.SelectFirstTab(container, t)
  container:SelectTab(nil)
  if t then
    if getn(t) > 0 then
      container:SelectTab(1)
    end
  end
end

function PRT.TableToTabs(t, withNewTab, newTabText)
  local tabs = {}

  if t then
    for k, v in pairs(t) do
      if v.name then
        tinsert(tabs, {value = k, text = v.name})
      else
        tinsert(tabs, {value = k, text = k})
      end
    end
  end

  PRT.TableUtils.SortByKey(tabs, "text")

  if withNewTab then
    tinsert(tabs, {value = "new", text = (newTabText or "+")})
  end

  return tabs
end

function PRT.TabGroupSelected(widget, t, key, itemFunction, emptyItemFunction, withDeleteButton, deleteButtonLabel)
  widget:ReleaseChildren()

  if key == "new" then
    local emptyItem = emptyItemFunction() or {}

    AceHelper.AddNewTab(widget, t, emptyItem)
  else
    local item = nil

    if t then
      item = t[key]
    end

    if item then
      itemFunction(item, widget, key, t)
    end

    if withDeleteButton then
      local deleteButton = AceGUI:Create("Button")
      deleteButton:SetText(deleteButtonLabel)
      deleteButton:SetCallback("OnClick",
        function()
          PRT.ConfirmationDialog(L["Are you sure you want to delete %s?"]:format(PRT.HighlightString(item.name)),
            function()
              AceHelper.RemoveTab(widget, t, key)
            end)
        end)
      AceHelper.AddTooltip(deleteButton, deleteButtonLabel)
      widget:AddChild(deleteButton)
    end
  end

  PRT.Core.UpdateScrollFrame()
end

function PRT.ReSelectTab(container)
  container:SelectTab(container.localstatus.selected)
end

function PRT.Release(widget)
  widget:ReleaseChildren()
  widget:Release()
end


-------------------------------------------------------------------------------
-- Container

function PRT.TabGroup(label, tabs)
  local container = AceGUI:Create("TabGroup")

  container:SetTitle(label)
  container:SetTabs(tabs)
  container:SetLayout("List")
  container:SetFullWidth(true)
  container:SetFullHeight(true)
  container:SetAutoAdjustHeight(true)

  return container
end

function PRT.InlineGroup(label)
  local container = AceGUI:Create("InlineGroup")

  container:SetFullWidth(true)
  container:SetLayout("List")
  container:SetTitle(label)

  return container
end

function PRT.SimpleGroup()
  local container = AceGUI:Create("SimpleGroup")
  container:SetFullWidth(true)
  container:SetLayout("List")

  -- NOTE: Make sure a simple group is displayed without backdrop even for ElvUI users
  -- since we just use it to structure some controls and not to actually group them
  if container.frame then
    if container.frame.backdrop then
      container.frame.backdrop:SetBackdrop({})
    end
  end

  return container
end

function PRT.ScrollFrame()
  local container = AceGUI:Create("ScrollFrame")

  container:SetLayout("List")
  container:SetFullHeight(true)
  container:SetAutoAdjustHeight(true)

  return container
end

function PRT.Frame(label)
  local container = AceGUI:Create("Frame")

  container:SetLayout("List")
  container:SetFullHeight(true)
  container:SetAutoAdjustHeight(true)
  container:SetTitle(label)

  return container
end

function PRT.TreeGroup(tree)
  local container = AceGUI:Create("TreeGroup")

  container:SetLayout("Fill")
  container:SetTree(tree)

  return container
end

function PRT.Window(label)
  local container = AceGUI:Create("Window")
  container.frame:SetFrameStrata("HIGH")

  container:SetTitle(label)
  container:SetLayout("Fill")

  return container
end


-------------------------------------------------------------------------------
-- Widgets

function PRT.Button(label, tooltip)
  local widget = AceGUI:Create("Button")
  widget:SetText(label)
  AceHelper.AddTooltip(widget, tooltip)

  return widget
end

function PRT.Heading(textID)
  local text = L[textID]

  local widget = AceGUI:Create("Heading")

  widget:SetText(text)
  widget:SetFullWidth(true)

  return widget
end

function PRT.Label(label, fontSize)
  local widget = AceGUI:Create("Label")
  widget:SetJustifyV("CENTER")

  widget:SetText(label)
  widget:SetFont(GameFontHighlightSmall:GetFont(), (fontSize or 14), "OUTLINE")
  widget:SetWidth(widget.label:GetStringWidth())

  return widget
end

function PRT.EditBox(label, tooltip, value)
  local widget = AceGUI:Create("EditBox")
  widget:SetLabel(label)
  widget:SetText(value)
  widget:SetWidth(AceHelper.widgetDefaultWidth)
  AceHelper.AddTooltip(widget, tooltip)

  return widget
end

function PRT.MultiLineEditBox(label, value)
  local widget = AceGUI:Create("MultiLineEditBox")
  widget:SetLabel(label)

  if value then
    widget:SetText(value)
  end

  return widget
end

function PRT.ColorPicker(label, value)
  local widget = AceGUI:Create("ColorPicker")
  widget:SetLabel(label)
  widget:SetColor((value.r or 0), (value.g or 0), (value.b or 0), (value.a or 0))
  widget:SetHasAlpha(false)
  widget:SetWidth(AceHelper.widgetDefaultWidth)
  AceHelper.AddTooltip(widget, nil)

  return widget
end

function PRT.Dropdown(label, tooltip, dropdownValues, dropdownValue, withEmpty, orderByKey)
  local dropdownItems = {}
  if withEmpty then
    dropdownItems[999] = ""
  end

  for _, v in ipairs(dropdownValues) do
    if type(v) == "string" then
      dropdownItems[v] = v
    else
      dropdownItems[v.id] = v.name
    end
  end

  local widget = AceGUI:Create("Dropdown")

  if orderByKey then
    local order = {}

    for _, v in ipairs(dropdownValues) do
      local value
      if type(v) == "string" then
        value = v
      else
        value = v.id
      end
      tinsert(order, value)
    end
    widget:SetList(dropdownItems, order)
  else
    widget:SetList(dropdownItems)
  end

  widget:SetLabel(label)
  widget:SetText(dropdownItems[dropdownValue])
  widget:SetWidth(AceHelper.widgetDefaultWidth)

  for _, v in ipairs(dropdownValues) do
    if v.disabled then
      local id
      if type(v) == "string" then
        id = v
      else
        id = v.id
      end
      widget:SetItemDisabled(id, true)
    end
  end

  AceHelper.AddTooltip(widget, tooltip)

  return widget
end

function PRT.CheckBox(label, tooltip, value)
  local widget = AceGUI:Create("CheckBox")
  widget:SetLabel(label)
  widget:SetValue(value)
  widget:SetWidth(AceHelper.widgetDefaultWidth)
  AceHelper.AddTooltip(widget, tooltip)

  return widget
end

function PRT.Icon(value, spellID)
  local widget = AceGUI:Create("Icon")
  widget:SetImage(value, 0.1, 0.9, 0.1, 0.9)
  PRT.AddSpellTooltip(widget, spellID)

  return widget
end

function PRT.Slider(label, tooltip, value)
  local widget = AceGUI:Create("Slider")

  widget:SetSliderValues(0, 60, 1)
  widget:SetLabel(label)
  if value then
    widget:SetValue(value)
  end
  widget:SetWidth(AceHelper.widgetDefaultWidth)
  AceHelper.AddTooltip(widget, tooltip)

  return widget
end

function PRT.SoundSelect(label, value)
  local widget = AceGUI:Create("LSM30_Sound")
  widget:SetList(AceGUIWidgetLSMlists.sound)
  widget:SetLabel(label)
  widget:SetText(value)
  widget:SetWidth(AceHelper.widgetDefaultWidth)
  AceHelper.AddTooltip(widget, nil)

  return widget
end

function PRT.FontSelect(label, value)
  local widget = AceGUI:Create("LSM30_Font")
  widget:SetList(AceGUIWidgetLSMlists.font)
  widget:SetLabel(label)
  widget:SetText(value)
  widget:SetWidth(AceHelper.widgetDefaultWidth)
  AceHelper.AddTooltip(widget, nil)

  return widget
end
