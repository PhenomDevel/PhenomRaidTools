local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Local Helper

local function newCustomPlaceholder()
  return {
    type = "player",
    name = "Placeholder"..random(0,100000),
    names = {
      "Change me"
    }
  }
end

local function addCustomPlaceholderWidget(customPlaceholder, container, _)
  local placeholderTypesDropdownItems = {
    { id = "group", name = L["Group"]},
    { id = "player", name = L["Player"]}
  }

  local placeholderTypeSelect = PRT.Dropdown(L["Type"], nil, placeholderTypesDropdownItems, (customPlaceholder.type or "Player"))
  placeholderTypeSelect:SetCallback("OnValueChanged",
    function(widget)
      local text = widget:GetValue()
      customPlaceholder.type = text
    end)

  local placeholderNameEditBox = PRT.EditBox(L["Name"], nil, customPlaceholder.name, true)
  placeholderNameEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      local cleanedText = string.gsub(text, " ", "")
      customPlaceholder.name = cleanedText
      widget:SetText(cleanedText)
      widget:ClearFocus()
    end)

  local clearEmptyNamesButton = PRT.Button(L["Remove empty names"])
  clearEmptyNamesButton:SetCallback("OnClick",
    function()
      PRT.TableUtils.Remove(customPlaceholder.names, PRT.StringUtils.IsEmpty)
      PRT.ReSelectTab(container)
    end)

  local addNameButton = PRT.Button(L["Add Name"])
  addNameButton:SetCallback("OnClick",
    function()
      tinsert(customPlaceholder.names, "")
      PRT.ReSelectTab(container)
    end)

  local namesGroup = PRT.InlineGroup(L["Names"])
  namesGroup:SetLayout("Flow")
  for idx, name in ipairs(customPlaceholder.names) do
    local nameEditBox = PRT.EditBox(L["Name"..idx], nil, name)
    nameEditBox:SetRelativeWidth(0.333)
    nameEditBox:SetCallback("OnEnterPressed",
      function(widget)
        local text = widget:GetText()
        customPlaceholder.names[idx] = text
        widget:ClearFocus()
      end)
    namesGroup:AddChild(nameEditBox)
  end

  container:AddChild(placeholderNameEditBox)
  container:AddChild(placeholderTypeSelect)
  container:AddChild(namesGroup)
  container:AddChild(addNameButton)
  container:AddChild(clearEmptyNamesButton)
end

local function importSuccess(container, customPlaceholders, importedCustomPlaceholders)
  if customPlaceholders then
    for _, customPlaceholder in ipairs(importedCustomPlaceholders) do
      tinsert(customPlaceholders, customPlaceholder)
    end
    container:ReleaseChildren()
    PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
    PRT.Info("Custom placeholders imported successfully.")
  else
    PRT.Error("Something went wrong while importing custom placeholders.")
  end
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddCustomPlaceholdersTabGroup(container, customPlaceholders)
  local placeholderTabs = PRT.TableToTabs(customPlaceholders, true)
  local placeholdersTabGroup = PRT.TabGroup(L["Custom Placeholders"], placeholderTabs)
  placeholdersTabGroup:SetTitle(nil)
  placeholdersTabGroup:SetLayout("Flow")
  placeholdersTabGroup:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, customPlaceholders, key, addCustomPlaceholderWidget , newCustomPlaceholder, true, L["Delete"], true, L["Clone"])
    end)

  PRT.SelectFirstTab(placeholdersTabGroup, customPlaceholders)
  container:AddChild(placeholdersTabGroup)
end

function PRT.AddCustomPlaceholderDescription(container)
  local description = PRT.Label(L["You can define custom placeholder which can be used as message targets."])
  local subDescription = PRT.Label(L["Types\n%s - Only the first player found within the group will be messaged\n%s - All players will be messaged"]:format(
    PRT.HighlightString(L["Player"]), PRT.HighlightString(L["Group"])), 12)
  description:SetRelativeWidth(1)
  subDescription:SetRelativeWidth(1)
  container:AddChild(description)
  container:AddChild(subDescription)
end

function PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
  PRT.AddCustomPlaceholderDescription(container)
  local actionsGroup = PRT.SimpleGroup()
  actionsGroup:SetLayout("Flow")

  local importButton = PRT.Button(L["Import"])
  importButton:SetCallback("OnClick",
    function()
      PRT.CreateImportFrame(
        function(t)
          importSuccess(container, customPlaceholders, t)
        end)
    end)

  local exportButton = PRT.Button(L["Export"])
  exportButton:SetCallback("OnClick",
    function()
      PRT.CreateExportFrame(customPlaceholders)
    end)

  local removeAllButton = PRT.Button(L["Remove all"])
  removeAllButton:SetCallback("OnClick",
    function()
      PRT.ConfirmationDialog(L["Are you sure you want to remove all custom placeholders?"],
        function()
          wipe(customPlaceholders)
          container:ReleaseChildren()
          PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
        end)
    end)

  actionsGroup:AddChild(importButton)
  actionsGroup:AddChild(exportButton)
  actionsGroup:AddChild(removeAllButton)
  container:AddChild(actionsGroup)
  PRT.AddCustomPlaceholdersTabGroup(container, customPlaceholders)
end

function PRT.AddCustomPlaceholderOptions(container, profile, encounterID)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))
  local CustomPlaceholders = encounter.CustomPlaceholders

  if not CustomPlaceholders then
    encounter.CustomPlaceholders = {}
    CustomPlaceholders = {}
  end

  local removeAllButton = PRT.Button(L["Remove all"])
  removeAllButton:SetCallback("OnClick",
    function()
      PRT.ConfirmationDialog(L["Are you sure you want to remove all custom placeholders?"],
        function()
          wipe(CustomPlaceholders)
          container:ReleaseChildren()
          PRT.AddCustomPlaceholderOptions(container, profile, encounterID)
        end)
    end)

  PRT.AddCustomPlaceholderDescription(container)
  container:AddChild(removeAllButton)
  PRT.AddCustomPlaceholdersTabGroup(container, CustomPlaceholders)
end
