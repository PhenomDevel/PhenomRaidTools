local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Private Helper

local function treeEntryByField(key, data, field)
  local treeEntry = {
    value = key,
    text = PRT.ClassColoredName(key)
  }

  if field == "spellID" then
    local spellID = data[1].spellID or -1
    local spellInfo = C_Spell.GetSpellInfo(tonumber(spellID))
    local spellName = spellInfo.name
    local icon = spellInfo.originalIconID

    treeEntry.text = " " .. (spellID or "-1") .. " - " .. (spellName or "N/A") .. " (" .. PRT.TableUtils.Count(data) .. ")"
    treeEntry.value = spellID or 0
    treeEntry.icon = icon
    treeEntry.iconCoords = {0.1, 0.9, 0.1, 0.9}
  end

  return treeEntry
end

local function generateTree(data, fields)
  local tree = {}
  local field = fields[1]
  local nextField = fields[2]
  local groupedData = PRT.TableUtils.GroupByField(data, field)

  for k, v in pairs(groupedData) do
    local treeEntry = treeEntryByField(k, v, field)

    if nextField then
      local nextFields = PRT.TableUtils.Clone(fields)
      tremove(nextFields, 1)
      local subTree = generateTree(v, nextFields)
      treeEntry.children = subTree
    end

    tinsert(tree, treeEntry)
  end

  PRT.TableUtils.SortByKey(tree, "value")

  return tree
end

local function addSpellDetailWidget(container, spellEntries)
  local entry = PRT.TableUtils.First(spellEntries)

  if entry then
    local spellIcon = PRT.Icon(entry.spellID)
    local spellIDEditBox = PRT.EditBox(L["Spell-ID"], nil, entry.spellID)
    local sourceLabel = PRT.Label(L["Source"] .. ": " .. entry.sourceName)

    spellIDEditBox:SetCallback(
      "OnTextChanged",
      function(widget)
        widget:SetText(entry.spellID)
      end
    )

    container:AddChild(spellIcon)
    container:AddChild(spellIDEditBox)
    container:AddChild(sourceLabel)
  end

  local entries = PRT.TableUtils.Vals(spellEntries)
  PRT.TableUtils.SortByKey(entries, "ts")

  container:AddChild(PRT.Heading(L["Ocurrences"], 14))

  local rowLegendContainer = PRT.SimpleGroup()
  rowLegendContainer:SetLayout("Flow")
  local datetimeLegendLabel = PRT.Label(L["Date - Time"])
  datetimeLegendLabel:SetRelativeWidth(0.3)
  local targetLegendLabel = PRT.Label(L["Target"])
  targetLegendLabel:SetRelativeWidth(0.6)

  rowLegendContainer:AddChild(datetimeLegendLabel)
  rowLegendContainer:AddChild(targetLegendLabel)
  container:AddChild(rowLegendContainer)

  for _, v in pairs(entries) do
    local rowContainer = PRT.SimpleGroup()
    rowContainer:SetLayout("Flow")
    local datetimeLabel = PRT.Label(v.dateTime)
    datetimeLabel:SetRelativeWidth(0.3)
    local targetLabel = PRT.Label(PRT.ColoredString((v.targetName or "N/A"), PRT.Static.Colors.Error))
    targetLabel:SetRelativeWidth(0.6)

    rowContainer:AddChild(datetimeLabel)
    rowContainer:AddChild(targetLabel)

    container:AddChild(rowContainer)
  end
end

local function addOptionsWidget(container, options)
  container:SetLayout("List")

  PRT.AddHelpContainer(
    container,
    {
      L["For the Combat Event Recorder to work, PRT has to be in an encounter scenario. Either on a real configured encounter or in test mode with any encounter."],
      L["The events will be cleared when a new combat is started."],
      PRT.ColoredString(L["Please make sure to only add the units you really want to track because the amount of data will skyrocket otherwise."], PRT.Static.Colors.Error)
    }
  )

  local enabledCheckBox = PRT.CheckBox(L["Enabled"], nil, options.enabled)
  enabledCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.enabled = widget:GetValue()
    end
  )

  local resetDataButton = PRT.Button(L["Reset Data"])
  resetDataButton:SetCallback(
    "OnClick",
    function()
      PRT.GetProfileDB().combatEventRecorder.data = {}
      PRT.Core.ReselectCurrentValue()
    end
  )

  local trackedUnitsAndEventsContainer = PRT.SimpleGroup()
  trackedUnitsAndEventsContainer:SetLayout("Flow")

  local unitsToRecordEditbox =
    PRT.MultiLineEditBox(
    L["Units to track"],
    strjoin("\n", unpack(options.unitsToRecord)),
    {
      L["Each unit has to be in a seperate line."],
      L["If you want to track all units put `ALL` in the editbox."],
      L["If you want to track all units in your raid put `RAID` in the editbox."]
    }
  )
  unitsToRecordEditbox:SetRelativeWidth(0.5)
  unitsToRecordEditbox:SetHeight(200)
  unitsToRecordEditbox:SetCallback(
    "OnTextChanged",
    function(widget)
      local text = strtrim(widget:GetText(), "\n")
      local unitsToRecord = {strsplit("\n", text)}
      PRT.TableUtils.Map(
        unitsToRecord,
        function(x)
          return strtrim(x)
        end
      )
      table.sort(unitsToRecord)
      options.unitsToRecord = unitsToRecord
    end
  )
  unitsToRecordEditbox:SetCallback(
    "OnEditFocusLost",
    function()
      PRT.Core.ReselectCurrentValue()
    end
  )

  local eventsToRecordEditbox =
    PRT.MultiLineEditBox(
    L["Events to track"],
    strjoin("\n", unpack(options.eventsToRecord)),
    {L["Each event has to be in a seperate line."], L["If you want to track all events put `ALL` in the editbox."]}
  )
  eventsToRecordEditbox:SetRelativeWidth(0.5)
  eventsToRecordEditbox:SetHeight(200)
  eventsToRecordEditbox:SetCallback(
    "OnTextChanged",
    function(widget)
      local text = strtrim(widget:GetText(), "\n")
      local eventsToRecord = {strsplit("\n", text)}
      PRT.TableUtils.Map(
        eventsToRecord,
        function(x)
          return strtrim(x)
        end
      )
      table.sort(eventsToRecord)
      options.eventsToRecord = eventsToRecord
    end
  )
  eventsToRecordEditbox:SetCallback(
    "OnEditFocusLost",
    function()
      PRT.Core.ReselectCurrentValue()
    end
  )

  container:AddChild(resetDataButton)
  container:AddChild(enabledCheckBox)
  trackedUnitsAndEventsContainer:AddChild(unitsToRecordEditbox)
  trackedUnitsAndEventsContainer:AddChild(eventsToRecordEditbox)
  container:AddChild(trackedUnitsAndEventsContainer)
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddCombatEventRecorderWidgets(container)
  container:SetLayout("Fill")
  local treeContentScrollFrame = PRT.ScrollFrame()
  treeContentScrollFrame:SetFullHeight(true)
  treeContentScrollFrame:SetFullWidth(true)

  local optionsEntry = {
    value = "options",
    text = L["Options"]
  }

  local tree = generateTree(PRT.GetProfileDB().combatEventRecorder.data, {"zoneName", "sourceName", "event", "spellID"})
  local treeGroupStatus = {groups = {}}
  local treeGroup = PRT.TreeGroup(tree)
  tinsert(tree, 1, optionsEntry)
  treeGroup:SetLayout("Fill")
  treeGroup:AddChild(treeContentScrollFrame)
  treeGroup:RefreshTree()
  treeGroup:SetCallback(
    "OnGroupSelected",
    function(_, _, key)
      treeContentScrollFrame:ReleaseChildren()
      treeGroup.selectedValue = key

      local zone, unit, event, spell = strsplit("\001", key)

      if key == "options" then
        addOptionsWidget(treeContentScrollFrame, PRT.GetProfileDB().combatEventRecorder.options)
      elseif zone and unit and event and spell then
        local groupedData = PRT.TableUtils.GroupByField(PRT.GetProfileDB().combatEventRecorder.data, "spellID")
        local entries = groupedData[tonumber(spell)]
        local filteredEntriesByEvent = PRT.TableUtils.FilterByKey(entries, "event", event)
        local filteredEntriesBySourceName = PRT.TableUtils.FilterByKey(filteredEntriesByEvent, "sourceName", unit)

        addSpellDetailWidget(treeContentScrollFrame, filteredEntriesBySourceName)
      end
    end
  )

  treeGroup:SetCallback(
    "OnTreeResize",
    function(_, _, width)
      PRT.GetProfileDB().combatEventRecorder.options.width = width
    end
  )

  treeGroup:SelectByValue("options")

  treeGroup:SetCallback(
    "OnClick",
    function(_, _, key)
      treeGroupStatus.groups[key] = not treeGroupStatus.groups[key]
      treeGroup:RefreshTree()
    end
  )

  treeGroup:SetStatusTable(treeGroupStatus)
  treeGroup.treeframe:SetWidth(PRT.GetProfileDB().combatEventRecorder.options.width or 300)

  container:AddChild(treeGroup)
  PRT.Core.UpdateScrollFrame()
end
