local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local AceGUI = LibStub("AceGUI-3.0")
local AceTimer = LibStub("AceTimer-3.0")
local Media = LibStub("LibSharedMedia-3.0")

local AceHelper = {
  widgetDefaultWidth = 350,
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
    widget:SetCallback(
      "OnEnter",
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
      end
    )

    widget:SetCallback(
      "OnLeave",
      function()
        GameTooltip:FadeOut()
      end
    )
  end
end

function AceHelper.AddNewTab(widget, t, item)
  if not t then
    t = {}
  end

  if item.name then
    t[item.name] = item
  else
    tinsert(t, item)
  end

  widget:SetTabs(PRT.TableToTabs(t, true))
  widget:DoLayout()

  if item.name then
    widget:SelectTab(item.name)
  else
    widget:SelectTab(getn(t))
  end

  PRT.Core.UpdateScrollFrame()
end

function AceHelper.ReIndexTable(t)
  local backup = PRT.TableUtils.Clone(t)
  local index = 1

  wipe(t)

  for _, v in pairs(backup) do
    t[index] = v
    index = index + 1
  end
end

function AceHelper.RemoveTab(widget, t, item)
  t[item] = nil

  if PRT.TableUtils.EveryKey(t, tonumber) then
    AceHelper.ReIndexTable(t)
  end

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
    widget:SetCallback(
      "OnEnter",
      function()
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink("spell:" .. spellID)
        GameTooltip:Show()
      end
    )

    widget:SetCallback(
      "OnLeave",
      function()
        GameTooltip:Hide()
      end
    )
  end
  return widget
end

function PRT.SelectFirstTab(container, t)
  container:SelectTab(nil)
  if t then
    if PRT.TableUtils.Count(t) > 0 then
      for k, _ in pairs(t) do
        container:SelectTab(k)
        break
      end
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

function PRT.TabGroupDeleteButton(container, tabGroup, t, key, label)
  local item = t[key]
  local deleteButton = AceGUI:Create("Button")
  deleteButton:SetText(label)
  deleteButton:SetCallback(
    "OnClick",
    function()
      local confirmationLabel
      if item.name then
        confirmationLabel = "Are you sure you want to delete %s?"
      else
        confirmationLabel = "Are you sure you want to delete this item?"
      end
      PRT.ConfirmationDialog(
        L[confirmationLabel]:format(PRT.HighlightString(item.name)),
        function()
          AceHelper.RemoveTab(tabGroup, t, key)
          PRT.SelectFirstTab(tabGroup, t)
        end
      )
    end
  )
  AceHelper.AddTooltip(deleteButton, label)
  container:AddChild(deleteButton)
end

function PRT.TabGroupCloneButton(container, tabGroup, t, key, label)
  local item = t[key]
  local cloneButton = AceGUI:Create("Button")
  cloneButton:SetText(label)
  cloneButton:SetCallback(
    "OnClick",
    function()
      local confirmationLabel
      if item.name then
        confirmationLabel = "Are you sure you want to clone %s?"
      else
        confirmationLabel = "Are you sure you want to clone this item?"
      end
      PRT.ConfirmationDialog(
        L[confirmationLabel]:format(PRT.HighlightString(item.name)),
        function()
          local clonedItem = PRT.TableUtils.Clone(item)
          local clonedName = clonedItem.name
          clonedItem.name = nil
          AceHelper.AddNewTab(tabGroup, t, clonedItem)

          if clonedName then
            clonedItem.name = PRT.NewCloneName()
          end
        end
      )
    end
  )
  AceHelper.AddTooltip(cloneButton, label)
  container:AddChild(cloneButton)
end

function PRT.TabGroupSelected(widget, t, key, itemFunction, emptyItemFunction, withDeleteButton, deleteButtonLabel, withCloneButton, cloneButtonLabel)
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

    local actionGroup = PRT.SimpleGroup()
    actionGroup:SetLayout("Flow")

    if withDeleteButton then
      PRT.TabGroupDeleteButton(actionGroup, widget, t, key, deleteButtonLabel)
    end

    if withCloneButton then
      PRT.TabGroupCloneButton(actionGroup, widget, t, key, cloneButtonLabel)
    end

    widget:AddChild(actionGroup)
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
  container:SelectTab(nil)

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
    if container.frame then
      if container.frame.SetBackdrop then
        container.frame:SetBackdrop({})
      end
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

function PRT.Heading(label, fontSize)
  local widget = AceGUI:Create("Heading")

  widget:SetText(label)
  widget.label:SetFont(GameFontHighlightSmall:GetFont(), (fontSize or 14), "OUTLINE")
  widget:SetFullWidth(true)
  widget:SetHeight(40)

  return widget
end

function PRT.UpdateLabelWidth(widget)
  widget:SetWidth(widget.label:GetStringWidth())
end

function PRT.Label(label, fontSize)
  local widget = AceGUI:Create("Label")
  widget:SetText(label)
  widget:SetFont(GameFontHighlightSmall:GetFont(), (fontSize or 14), "OUTLINE")
  widget:SetWidth(widget.label:GetStringWidth())

  return widget
end

function PRT.InteractiveLabel(label, fontSize)
  local widget = AceGUI:Create("InteractiveLabel")
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

function PRT.MultiLineEditBox(label, value, tooltip)
  local widget = AceGUI:Create("MultiLineEditBox")
  widget:SetLabel(label)

  if value then
    widget:SetText(value)
  end

  AceHelper.AddTooltip(widget, tooltip)

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

function PRT.MultiDropdown(label, tooltip, possibleValues, selectedValues, withEmpty, orderByKey)
  return PRT.Dropdown(label, tooltip, possibleValues, selectedValues, withEmpty, orderByKey, true)
end

function PRT.Dropdown(label, tooltip, possibleValues, selectedValue, withEmpty, orderByKey, multiSelect)
  local dropdownItems = {}

  if withEmpty then
    dropdownItems[PRT.Static.TargetNoneNumber] = L["None"]
  end

  for k, v in pairs(possibleValues) do
    if type(v) == "string" then
      dropdownItems[v] = v
    else
      dropdownItems[v.id or v.name or k] = v.name or v.id or k
    end
  end

  local widget = AceGUI:Create("Dropdown")

  if multiSelect then
    widget:SetMultiselect(multiSelect)
  end

  if orderByKey then
    local order = {}

    for _, v in pairs(possibleValues) do
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
  widget:SetValue(selectedValue)
  widget:SetWidth(AceHelper.widgetDefaultWidth)

  for _, v in pairs(possibleValues) do
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

  -- If multiselect and value is a table
  if widget:GetMultiselect() and type(possibleValues) == "table" then
    for _, value in pairs(selectedValue) do
      widget:SetItemValue(value, true)
    end
  end

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

function PRT.Icon(spellID)
  if spellID then
    local widget = AceGUI:Create("Icon")
    local spellInfo = C_Spell.GetSpellInfo(tonumber(spellID))
    local texture = spellInfo.originalIconID
    widget:SetImage(texture, 0.1, 0.9, 0.1, 0.9)
    PRT.AddSpellTooltip(widget, spellID)

    return widget
  end
end

function PRT.UpdateIcon(widget, spellID)
  if spellID then
    local spellInfo = C_Spell.GetSpellInfo(tonumber(spellID))
    local texture = spellInfo.originalIconID
    widget:SetImage(texture, 0.1, 0.9, 0.1, 0.9)
    PRT.AddSpellTooltip(widget, spellID)
  end
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

local function tabGroupContainerContent(container, options, dataTable, itemRenderFn, newItemFn)
  PRT.TableUtils.SortByKey(dataTable, "name")

  local refreshContainer = function()
    container:ReleaseChildren()
    tabGroupContainerContent(container, options, dataTable, itemRenderFn, newItemFn)
    PRT.Core.UpdateScrollFrame()
  end

  local tabGroup = PRT.TabGroup(nil, PRT.TableToTabs(dataTable))
  tabGroup:SetLayout("Flow")
  tabGroup:SetCallback(
    "OnGroupSelected",
    function(widget, _, value)
      local selectedItem = dataTable[value]
      widget:ReleaseChildren()

      -- Make sure the item has a name
      if not selectedItem.name then
        selectedItem.name = value
      end
      itemRenderFn(widget, refreshContainer, dataTable, selectedItem)

      -- Delay rerendering of scrollframe a little.
      AceTimer:ScheduleTimer(PRT.Core.UpdateScrollFrame, 50)
    end
  )

  local newButton = PRT.Button(L["Add"])
  newButton:SetCallback(
    "OnClick",
    function()
      local newItem = newItemFn()

      if newItem.name then
        dataTable[newItem.name] = newItem
        refreshContainer()
        tabGroup:SelectTab(newItem.name)
      else
        PRT.Debug("The new item does not have a name. Therefore the creation was skipped.")
      end
    end
  )

  local deleteDropdown = PRT.Dropdown(L["Delete"], nil, dataTable, nil)
  deleteDropdown:SetDisabled(PRT.TableUtils.IsEmpty(dataTable))
  deleteDropdown:SetCallback(
    "OnValueChanged",
    function(widget, _, value)
      local deleteItem = function()
        dataTable[value] = nil
        refreshContainer()
      end
      if not options.confirmDelete then
        deleteItem()
      else
        local confirmationLabel = "Are you sure you want to delete %s?"

        PRT.ConfirmationDialog(
          L[confirmationLabel]:format(PRT.HighlightString(value)),
          function()
            deleteItem()
          end
        )
      end
      widget:SetValue(nil)
    end
  )
  container:AddChild(deleteDropdown)

  local removeAllButton = PRT.Button(L["Delete all"])
  removeAllButton:SetCallback(
    "OnClick",
    function()
      PRT.ConfirmationDialog(
        L["Are you sure you want to remove all entries?"],
        function()
          wipe(dataTable)
          refreshContainer()
        end
      )
    end
  )

  container:AddChild(removeAllButton)

  if options.withClone then
    local cloneDropdown = PRT.Dropdown(L["Clone"], nil, dataTable, nil)
    cloneDropdown:SetDisabled(PRT.TableUtils.IsEmpty(dataTable))
    cloneDropdown:SetCallback(
      "OnValueChanged",
      function(_, _, value)
        local selectedItem = dataTable[value]
        local clone = PRT.TableUtils.Clone(selectedItem)
        clone.name = PRT.NewCloneName()
        dataTable[clone.name] = clone
        refreshContainer()
        tabGroup:SelectTab(clone.name)
      end
    )
    container:AddChild(cloneDropdown)
  end

  container:AddChild(newButton)

  if PRT.TableUtils.Count(dataTable) > 0 then
    container:AddChild(tabGroup)
  else
    local noEntriesLabel = PRT.Label(L["There are currently no entries."])
    container:AddChild(noEntriesLabel)
  end
  PRT.SelectFirstTab(tabGroup, dataTable)
end

function PRT.TabGroupContainer(options, dataTable, itemRenderFn, newItemFn)
  local container = PRT.SimpleGroup()
  container:SetLayout("List")

  tabGroupContainerContent(container, options, dataTable, itemRenderFn, newItemFn)

  return container
end

function PRT.AddHelpContainer(container, text)
  local helpContainer = PRT.SimpleGroup()
  helpContainer:SetLayout("Flow")

  local iconLabel = PRT.Label(PRT.TextureString(134400, 14) .. PRT.ColoredString(L["Help"], "c9c904"))
  iconLabel:SetRelativeWidth(1)
  helpContainer:AddChild(iconLabel)

  if type(text) ~= "table" then
    local helpLabel = PRT.Label(text)
    helpLabel:SetRelativeWidth(1)
    helpContainer:AddChild(helpLabel)
  else
    for _, v in pairs(text) do
      local helpLabel = PRT.Label(v)
      helpLabel:SetRelativeWidth(1)
      helpContainer:AddChild(helpLabel)
    end
  end

  helpContainer:AddChild(PRT.Heading())
  container:AddChild(helpContainer)
end
