local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Local Helper

local function newCustomPlaceholder()
  return {
    type = "player",
    name = "Placeholder" .. PRT.RandomNumber(),
    characterNames = {
      "Change me"
    }
  }
end

local function addCustomPlaceholderWidget(customPlaceholder, container, _, placeholders)
  local placeholderTypesDropdownItems = {
    {id = "group", name = L["Group"]},
    {id = "player", name = L["Player"]}
  }

  local placeholderTypeSelect = PRT.Dropdown(L["Type"], nil, placeholderTypesDropdownItems, (customPlaceholder.type or "Player"))
  placeholderTypeSelect:SetCallback(
    "OnValueChanged",
    function(widget)
      local text = widget:GetValue()
      customPlaceholder.type = text
    end
  )

  local placeholderNameEditBox = PRT.EditBox(L["Name"], nil, customPlaceholder.name, true)
  placeholderNameEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      local cleanedText = string.gsub(text, " ", "")

      if placeholders[cleanedText] and (customPlaceholder.name ~= cleanedText) then
        PRT.Error("A placeholder with this name already exists.")
      else
        PRT.TableUtils.SwapKey(placeholders, customPlaceholder.name, cleanedText)
        customPlaceholder.name = cleanedText

        widget:SetText(cleanedText)
        widget:ClearFocus()
      end

      -- Update global placeholders
      PRT.SetupGlobalCustomPlaceholders()
      container:SetTabs(PRT.TableToTabs(placeholders, true))
      container:SelectTab(cleanedText)
    end
  )

  local clearEmptyNamesButton = PRT.Button(L["Remove empty names"])
  clearEmptyNamesButton:SetCallback(
    "OnClick",
    function()
      PRT.TableUtils.Remove(customPlaceholder.characterNames, PRT.StringUtils.IsEmpty)
      PRT.ReSelectTab(container)
    end
  )

  local addNameButton = PRT.Button(L["Add Name"])
  addNameButton:SetCallback(
    "OnClick",
    function()
      tinsert(customPlaceholder.characterNames, "")
      PRT.ReSelectTab(container)
    end
  )

  local namesGroup = PRT.InlineGroup(L["Names"])
  namesGroup:SetLayout("Flow")

  for idx, name in ipairs(customPlaceholder.characterNames or {}) do
    local nameEditBox = PRT.EditBox(L["Name" .. idx], nil, name)
    nameEditBox:SetRelativeWidth(0.333)
    nameEditBox:SetCallback(
      "OnEnterPressed",
      function(widget)
        local text = widget:GetText()
        customPlaceholder.characterNames[idx] = text
        widget:ClearFocus()

        -- Update global placeholders
        PRT.SetupGlobalCustomPlaceholders()
      end
    )
    namesGroup:AddChild(nameEditBox)
  end

  container:AddChild(placeholderNameEditBox)
  container:AddChild(placeholderTypeSelect)
  container:AddChild(namesGroup)
  container:AddChild(addNameButton)
  container:AddChild(clearEmptyNamesButton)
end

local function importSuccess(container, customPlaceholders, importedCustomPlaceholders)
  if
    customPlaceholders.customPlaceholders or customPlaceholders.CustomPlaceholders or importedCustomPlaceholders.customPlaceholders or importedCustomPlaceholders.CustomPlaceholders
   then
    PRT.Error("Import data is not in the right format. Did you try importing an encounter into placeholders?")
  else
    local migratedPlaceholders = PRT.MigratePlaceholdersAfter2160(customPlaceholders, importedCustomPlaceholders)

    wipe(customPlaceholders)
    for name, placeholder in pairs(migratedPlaceholders) do
      customPlaceholders[name] = placeholder
    end

    container:ReleaseChildren()
    PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
    PRT.Info("Custom placeholders imported successfully.")
  end
end

function PRT.MigratePlaceholdersAfter2160(oldPlaceholders, placeholders)
  local migratedPlaceholders = PRT.TableUtils.Clone(oldPlaceholders) or {}

  -- if the index is a number proceed. If not we already did this migration (most likely)
  for _, placeholder in pairs(placeholders) do
    if migratedPlaceholders[placeholder.name] then
      -- There has to be a duplicate placeholder. So stop processing!
      PRT.Debug(string.format("Placeholder %s already exists. Merging character names.", PRT.HighlightString(placeholder.name)))
      migratedPlaceholders[placeholder.name].characterNames =
        PRT.TableUtils.MergeMany(migratedPlaceholders[placeholder.name].characterNames, placeholder.names, placeholder.characterNames)
    else
      migratedPlaceholders[placeholder.name] = {
        type = placeholder.type,
        characterNames = placeholder.names or placeholder.characterNames or {},
        name = placeholder.name
      }
    end
  end

  return migratedPlaceholders
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddCustomPlaceholdersTabGroup(container, customPlaceholders)
  local placeholderTabs = PRT.TableToTabs(customPlaceholders, true)
  local placeholdersTabGroup = PRT.TabGroup(L["Custom Placeholders"], placeholderTabs)
  placeholdersTabGroup:SetTitle(nil)
  placeholdersTabGroup:SetLayout("Flow")
  placeholdersTabGroup:SetCallback(
    "OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, customPlaceholders, key, addCustomPlaceholderWidget, newCustomPlaceholder, true, L["Delete"], true, L["Clone"])
    end
  )

  if placeholderTabs[1] and PRT.TableUtils.Count(placeholderTabs) > 1 then
    placeholdersTabGroup:SelectTab(placeholderTabs[1].value)
  end

  container:AddChild(placeholdersTabGroup)
end

function PRT.AddCustomPlaceholderDescription(container)
  PRT.AddHelpContainer(
    container,
    {
      L["You can define custom placeholder which can be used as message targets."],
      L["Types\n%s - Only the first player found within the group will be messaged\n%s - All players will be messaged"]:format(
        PRT.HighlightString(L["Player"]),
        PRT.HighlightString(L["Group"])
      )
    }
  )
end

local function renderPlaceholder(container, refreshContainerFn, placeholders, placeholder)
  local placeholderTypesDropdownItems = {
    {id = "group", name = L["Group"]},
    {id = "player", name = L["Player"]}
  }

  local placeholderTypeSelect = PRT.Dropdown(L["Type"], nil, placeholderTypesDropdownItems, (placeholder.type or "player"))
  placeholderTypeSelect:SetCallback(
    "OnValueChanged",
    function(widget)
      local text = widget:GetValue()
      placeholder.type = text
    end
  )

  local placeholderNameEditBox = PRT.EditBox(L["Name"], nil, placeholder.name, true)
  placeholderNameEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      local cleanedText = string.gsub(text, " ", "")

      if placeholders[cleanedText] and placeholder.name ~= cleanedText then
        PRT.Error("A placeholder with this name already exists.")
      else
        PRT.TableUtils.SwapKey(placeholders, placeholder.name, cleanedText)
        placeholder.name = cleanedText

        widget:SetText(cleanedText)
        widget:ClearFocus()
      end

      -- Update global placeholders
      PRT.SetupGlobalCustomPlaceholders()
      refreshContainerFn()
    end
  )

  local clearEmptyNamesButton = PRT.Button(L["Remove empty names"])
  clearEmptyNamesButton:SetCallback(
    "OnClick",
    function()
      PRT.TableUtils.Remove(placeholder.characterNames, PRT.StringUtils.IsEmpty)
      PRT.ReSelectTab(container)
    end
  )

  local addNameButton = PRT.Button(L["Add Name"])
  addNameButton:SetCallback(
    "OnClick",
    function()
      tinsert(placeholder.characterNames, "")
      PRT.ReSelectTab(container)
    end
  )

  local namesGroup = PRT.InlineGroup(L["Names"])
  namesGroup:SetLayout("Flow")

  for idx, name in ipairs(placeholder.characterNames or {}) do
    local nameEditBox = PRT.EditBox(L["Name" .. idx], nil, name)
    nameEditBox:SetRelativeWidth(0.333)
    nameEditBox:SetCallback(
      "OnEnterPressed",
      function(widget)
        local text = widget:GetText()
        placeholder.characterNames[idx] = text
        widget:ClearFocus()

        -- Update global placeholders
        PRT.SetupGlobalCustomPlaceholders()
      end
    )
    namesGroup:AddChild(nameEditBox)
  end

  container:AddChild(placeholderNameEditBox)
  container:AddChild(placeholderTypeSelect)
  container:AddChild(namesGroup)
  container:AddChild(addNameButton)
  container:AddChild(clearEmptyNamesButton)
end

function PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
  PRT.AddCustomPlaceholderDescription(container)
  local actionsGroup = PRT.SimpleGroup()
  actionsGroup:SetLayout("Flow")

  local importButton = PRT.Button(L["Import"])
  importButton:SetCallback(
    "OnClick",
    function()
      PRT.CreateImportFrame(
        function(t)
          importSuccess(container, customPlaceholders, t)
        end
      )
    end
  )

  local exportButton = PRT.Button(L["Export"])
  exportButton:SetCallback(
    "OnClick",
    function()
      PRT.CreateExportFrame(customPlaceholders)
    end
  )

  actionsGroup:AddChild(importButton)
  actionsGroup:AddChild(exportButton)
  container:AddChild(actionsGroup)
  container:AddChild(PRT.TabGroupContainer({confirmDelete = true, withClone = true}, customPlaceholders, renderPlaceholder, newCustomPlaceholder))
end

function PRT.AddCustomPlaceholderOptions(container, profile, encounterID)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))

  if not encounter.CustomPlaceholders then
    encounter.CustomPlaceholders = {}
  end

  PRT.AddCustomPlaceholderDescription(container)
  container:AddChild(PRT.TabGroupContainer({confirmDelete = true, withClone = true}, encounter.CustomPlaceholders, renderPlaceholder, newCustomPlaceholder))
end
