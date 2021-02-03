local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


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
    { id = "group", name = L["optionsCustomPlaceholderTypeGroup"]},
    { id = "player", name = L["optionsCustomPlaceholderTypePlayer"]}
  }

  local placeholderTypeSelect = PRT.Dropdown("optionsCustomPlaceholderType", placeholderTypesDropdownItems, (customPlaceholder.type or "Player"))
  placeholderTypeSelect:SetCallback("OnValueChanged",
    function(widget)
      local text = widget:GetValue()
      customPlaceholder.type = text
    end)

  local placeholderNameEditBox = PRT.EditBox("optionsCustomPlaceholderName", customPlaceholder.name, true)
  placeholderNameEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      local cleanedText = string.gsub(text, " ", "")
      customPlaceholder.name = cleanedText
      widget:SetText(cleanedText)
      widget:ClearFocus()
    end)

  local clearEmptyNamesButton = PRT.Button("optionsCustomPlaceholderRemoveEmptyNames")
  clearEmptyNamesButton:SetCallback("OnClick",
    function()
      PRT.TableUtils.Remove(customPlaceholder.names, PRT.StringUtils.IsEmpty)
      PRT.ReSelectTab(container)
    end)

  local addNameButton = PRT.Button("optionsCustomPlaceholderAddNameButton")
  addNameButton:SetCallback("OnClick",
    function()
      tinsert(customPlaceholder.names, "")
      PRT.ReSelectTab(container)
    end)

  local namesGroup = PRT.InlineGroup("Names")
  namesGroup:SetLayout("Flow")
  for idx, name in ipairs(customPlaceholder.names) do
    local nameEditBox = PRT.EditBox("name"..idx, name)
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
  local placeholdersTabGroup = PRT.TabGroup("optionsCustomPlaceholdersHeading", placeholderTabs)
  placeholdersTabGroup:SetTitle(nil)
  placeholdersTabGroup:SetLayout("Flow")
  placeholdersTabGroup:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, customPlaceholders, key, addCustomPlaceholderWidget , newCustomPlaceholder, true, "optionsCustomPlaceholderDeleteButton")
    end)

  PRT.SelectFirstTab(placeholdersTabGroup, customPlaceholders)
  container:AddChild(placeholdersTabGroup)
end

function PRT.AddCustomPlaceholderDescription(container)
  local description = PRT.Label("optionsCustomPlaceholdersDescription", 16)
  local subDescription = PRT.Label("optionsCustomPlaceholdersSubDescription", 14)
  description:SetRelativeWidth(1)
  subDescription:SetRelativeWidth(1)
  container:AddChild(description)
  container:AddChild(subDescription)
end

function PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
  PRT.AddCustomPlaceholderDescription(container)
  local importButton = PRT.Button("importButton")
  importButton:SetCallback("OnClick",
    function()
      PRT.CreateImportFrame(
        function(t)
          importSuccess(container, customPlaceholders, t)
        end)
    end)

  local exportButton = PRT.Button("exportButton")
  exportButton:SetCallback("OnClick",
    function()
      PRT.CreateExportFrame(customPlaceholders)
    end)

  container:AddChild(importButton)
  container:AddChild(exportButton)
  PRT.AddCustomPlaceholdersTabGroup(container, customPlaceholders)
end
