local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local IsAddOnLoaded = IsAddOnLoaded

-------------------------------------------------------------------------------
-- Local Helper

local MethodRaidToolsCombatEventTranslations = {
  ["SPELL_CAST_SUCCESS"] = "SCC",
  ["SPELL_CAST_START"] = "SCS",
  ["SPELL_AURA_APPLIED"] = "SAA",
  ["SPELL_AURA_REMOVED"] = "SAR"
}

local function IsValidMessage(message)
  return (message.type == "cooldown")
end

local function GetDistinctTargets(inputTargets)
  local targets = {}

  for _, target in pairs(inputTargets) do
    local updatedTarget = PRT.ReplacePlayerNameTokens(target)

    if (target ~= PRT.Static.TargetNone) and (target ~= PRT.Static.TargetNoneNumber) then
      tinsert(targets, updatedTarget)
    end
  end

  return PRT.TableUtils.Distinct(targets)
end

local function getTriggerEntryTargets(entry)
  local targets = {}

  for _, message in ipairs(entry.messages) do
    for _, target in pairs(message.targets) do
      local updatedTarget = PRT.ReplacePlayerNameTokens(target)

      if (target ~= PRT.Static.TargetNone) and (target ~= PRT.Static.TargetNoneNumber) then
        tinsert(targets, updatedTarget)
      end
    end
  end

  return PRT.TableUtils.Distinct(targets)
end

local function WrapPersonalization(contentString, targetString, options)
  local personalizedString = ""

  if options.withPersonalization then
    if PRT.StringUtils.IsEmpty(targetString) then
      targetString = "N/A"
    end
    personalizedString = string.format("{p:%s}", targetString)
  end

  personalizedString = personalizedString .. contentString

  if options.withPersonalization then
    personalizedString = personalizedString .. "{/p}"
  end

  return personalizedString
end

local function SecondsToTimePrefix(entry, options)
  local timePrefixString

  timePrefixString = string.format("{time:%s", PRT.SecondsToClock(entry.time))

  if entry.startCondition then
    local translatedEvent = MethodRaidToolsCombatEventTranslations[entry.startCondition.event]

    if translatedEvent and entry.startCondition.spellID then
      timePrefixString = timePrefixString .. string.format(",%s:%s:%s", translatedEvent, entry.startCondition.spellID, entry.triggerAtOccurence or 0)
    else
      PRT.Debug(
        string.format(
          "Could not translate start condition event %s to MethodRaidTools event. MethodRaidTools note timers might not work correctly.",
          PRT.HighlightString(entry.startCondition.event)
        )
      )
    end
  end

  timePrefixString = timePrefixString .. "}"

  if options.withLinePrefix then
    timePrefixString = timePrefixString .. string.format(" %s -> ", PRT.ColoredString((entry.name or "N/A"), PRT.Static.Colors.Tertiary))
  end

  return timePrefixString
end

local function GenerateTimingContent(messages, options)
  local contents = {}

  for _, message in ipairs(messages) do
    local distinctTargets = GetDistinctTargets(message.targets)
    local coloredTargets = {}

    for k, target in pairs(distinctTargets) do
      coloredTargets[k] = PRT.ClassColoredName(target)
    end

    local targetStringColored = strjoin(", ", unpack(coloredTargets))
    local targetString = strjoin(",", unpack(distinctTargets))

    if targetStringColored and message.spellID then
      local content = string.format("{spell:%s} %s", message.spellID, targetStringColored)
      local finalString = WrapPersonalization(content, targetString, options)

      if not PRT.TableUtils.IsEmpty(distinctTargets) then
        tinsert(contents, finalString)
      end
    end
  end

  return contents
end

local function CollectMessagesPerTiming(timer)
  local messagesPerTiming = {}

  for _, timing in pairs(timer.timings) do
    for _, timeInSeconds in pairs(timing.seconds) do
      if not messagesPerTiming[timeInSeconds] then
        messagesPerTiming[timeInSeconds] = {
          name = timing.name,
          triggerAtOccurence = timer.triggerAtOccurence,
          startCondition = timer.startCondition,
          messages = {}
        }
      end

      for _, message in ipairs(timing.messages) do
        if IsValidMessage(message) then
          tinsert(messagesPerTiming[timeInSeconds].messages, message)
        end
      end

      if PRT.TableUtils.Count(messagesPerTiming[timeInSeconds].messages) > 0 then
        messagesPerTiming[timeInSeconds] = messagesPerTiming[timeInSeconds]
      end
    end
  end

  local sortedEntries = {}
  for timeInSeconds, entry in pairs(messagesPerTiming) do
    entry.time = timeInSeconds

    tinsert(sortedEntries, entry)
  end

  PRT.TableUtils.SortByKey(sortedEntries, "time")

  return sortedEntries
end

local function GenerateTimingString(entry, options)
  local contents = GenerateTimingContent(entry.messages, options)
  local timingString = SecondsToTimePrefix(entry, options)

  local contentsString = strjoin(" ", unpack(contents))

  if not options.withEmptyLines and PRT.TableUtils.Count(contents) == 0 then
    return nil
  end

  local finalString = "\n" .. timingString .. " " .. contentsString
  local targetsString = strjoin(",", unpack(getTriggerEntryTargets(entry)))
  return WrapPersonalization(finalString, targetsString, options)
end

local function MessagePerStringToMethodRaidToolsNote(messagesPerTiming, options)
  local timingStrings = {}

  for _, entry in ipairs(messagesPerTiming) do
    local timingString = GenerateTimingString(entry, options)
    if timingString then
      tinsert(timingStrings, timingString)
    end
  end

  return timingStrings
end

-------------------------------------------------------------------------------
-- Public API

local function noteFromTimer(options, timer)
  local localTimer = PRT.TableUtils.Clone(timer)
  local collectedMessagePerTiming = CollectMessagesPerTiming(localTimer)
  local timingStrings = MessagePerStringToMethodRaidToolsNote(collectedMessagePerTiming, options)

  PRT.TableUtils.Remove(timingStrings, PRT.StringUtils.IsEmpty)

  local title

  if options.withTriggerNames then
    title = PRT.ColoredString(string.format("== %s ==", timer.name), PRT.Static.Colors.Secondary)
  end

  local content = strjoin("", unpack(timingStrings))
  local finalString = ""

  if not PRT.TableUtils.IsEmpty(timingStrings) then
    if title then
      if options.withPersonalization then
        finalString = string.format("%s\n\n%s", title or "", content)
      else
        finalString = string.format("%s\n%s", title or "", content)
      end
    else
      finalString = content
    end
  end

  return finalString
end

local function noteFromTimers(options, timers)
  local strings = {}
  local contentString

  for _, timer in ipairs(timers) do
    if timer.enabled and options.selectedTimers[timer.name] then
      tinsert(strings, noteFromTimer(options, timer))
    end
  end

  PRT.TableUtils.Remove(strings, PRT.StringUtils.IsEmpty)

  contentString = strjoin("\n\n", unpack(strings))

  return string.gsub(contentString, "\n\n\n", "\n\n")
end

local function noteFromRotation(options, rotation)
  local rotationNote
  local rotationNoteEntries = {}

  if not PRT.TableUtils.IsEmpty(rotation.entries) then
    if options.withTriggerNames then
      local rotationTitle = PRT.ColoredString(string.format("== %s ==", rotation.name), PRT.Static.Colors.Secondary)
      rotationNote = rotationTitle .. "\n"
    end

    for entryIndex, entry in ipairs(rotation.entries) do
      local validMessages = {}

      for _, message in ipairs(entry.messages) do
        if IsValidMessage(message) then
          tinsert(validMessages, message)
        end
      end

      if (options.withEmptyLines and PRT.TableUtils.IsEmpty(validMessages)) or (not PRT.TableUtils.IsEmpty(validMessages)) then
        local entryNote = ""

        for _, message in ipairs(validMessages) do
          local distinctTargets = GetDistinctTargets(message.targets)
          entryNote = string.format("%s {spell:%s} %s", entryNote, message.spellID, strjoin(" ", unpack(distinctTargets)))
        end

        if options.withPersonalization then
          local entryTargets = getTriggerEntryTargets(entry)
          local targetString = strjoin(",", unpack(entryTargets))
          entryNote = WrapPersonalization(entryNote, targetString, options)
        end

        if not PRT.StringUtils.IsEmpty(entryNote) then
          rotationNoteEntries[entryIndex] = entryNote
        end
      end
    end
  else
    return nil
  end

  if not PRT.TableUtils.IsEmpty(rotationNoteEntries) then
    for idx, entryNote in pairs(rotationNoteEntries) do
      rotationNote = rotationNote .. string.format("<%s> %s\n", idx, entryNote)
    end

    if rotation.shouldRestart then
      rotationNote = rotationNote .. "Repeat\n"
    end
  else
    return nil
  end

  return rotationNote
end

local function noteFromRotations(options, rotations)
  local noteParts = {}

  if rotations then
    for _, rotation in ipairs(rotations) do
      if rotation.enabled and options.selectedRotations[rotation.name] then
        local part = noteFromRotation(options, rotation)

        if not PRT.StringUtils.IsEmpty(part) then
          tinsert(noteParts, part)
        end
      end
    end
  end
  return strjoin("\n", unpack(noteParts))
end

local function noteFromEncounter(options, encounter)
  local encounterVersion = encounter.versions[encounter.selectedVersion]

  local note = ""

  -- Maybe add encounter name
  if options.withEncounterName and encounter.name then
    note = PRT.ColoredString(encounter.name, PRT.Static.Colors.Primary)
  end

  -- Maybe add rotations
  if options.includeRotations then
    local rotationsNote = noteFromRotations(options, encounterVersion.Rotations)

    if not PRT.StringUtils.IsEmpty(rotationsNote) then
      note = note .. "\n" .. rotationsNote
    end
  end

  -- Maybe add timers
  if options.includeTimers then
    local timersNote = noteFromTimers(options, encounterVersion.Timers)

    if not PRT.StringUtils.IsEmpty(timersNote) then
      note = note .. "\n" .. timersNote
    end
  end

  return note
end

local function AddMethodRaidToolsExportOptionsWidget(container, options)
  local optionsGroup = PRT.InlineGroup(L["Options"])
  optionsGroup:SetLayout("Flow")

  local includeTimers = PRT.CheckBox(L["Include timers"], nil, options.includeTimers)
  local includeRotations = PRT.CheckBox(L["Include rotations"], nil, options.includeRotations)
  local withEncounterName = PRT.CheckBox(L["Include encounter title"], L["Shows the encounter name on top of the note."], options.withEncounterName)
  local withTriggerNames = PRT.CheckBox(L["Include trigger names"], L["Shows the trigger name for each trigger."], options.withTriggerNames)
  local withLinePrefix = PRT.CheckBox(L["Include trigger entry prefix"], L["Shows the trigger entry name before each line."], options.withLinePrefix)
  local withEmptyLines = PRT.CheckBox(L["Include empty lines"], L["Includes lines even if there are no messages attached."], options.withEmptyLines)
  local withPersonalization = PRT.CheckBox(L["Personalize note"], L["This will hide all entries which are not interesting for the given player."], options.withPersonalization)
  local forceMethodRaidToolsUpdate =
    PRT.CheckBox(L["Force MethodRaidTools note update"], L["This will try and force MethodRaidTools to directly update the note."], options.forceMethodRaidToolsUpdate)
  local updatePRTTag =
    PRT.CheckBox(
    L["Replace PRT tag content"],
    L["This will update the existing MethodRaidTools note and just replace the content between %s and %s tag with the generated content."]:format(
      PRT.HighlightString("{prtstart}"),
      PRT.HighlightString("{prtend}")
    ),
    options.updatePRTTag
  )

  -- Include Timers
  includeTimers:SetRelativeWidth(0.5)
  includeTimers:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.includeTimers = value
      PRT.GetProfileDB().mrtExportDefaults.includeTimers = value
    end
  )

  -- Include Rotations
  includeRotations:SetRelativeWidth(0.5)
  includeRotations:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.includeRotations = value
      PRT.GetProfileDB().mrtExportDefaults.includeRotations = value
    end
  )

  -- Include Encounter name
  withEncounterName:SetRelativeWidth(0.5)
  withEncounterName:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.withEncounterName = value
      PRT.GetProfileDB().mrtExportDefaults.withEncounterName = value
    end
  )

  -- Include timer names
  withTriggerNames:SetRelativeWidth(0.5)
  withTriggerNames:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.withTriggerNames = value
      PRT.GetProfileDB().mrtExportDefaults.withTriggerNames = value
    end
  )

  -- Include timing names
  withLinePrefix:SetRelativeWidth(0.5)
  withLinePrefix:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.withLinePrefix = value
      PRT.GetProfileDB().mrtExportDefaults.withLinePrefix = value
    end
  )

  -- Include empty lines
  withEmptyLines:SetRelativeWidth(0.5)
  withEmptyLines:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.withEmptyLines = value
      PRT.GetProfileDB().mrtExportDefaults.withEmptyLines = value
    end
  )

  -- Personalize Note
  withPersonalization:SetRelativeWidth(0.5)
  withPersonalization:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.withPersonalization = value
      PRT.GetProfileDB().mrtExportDefaults.withPersonalization = value
    end
  )

  -- Directly Update MethodRaidTools Note
  forceMethodRaidToolsUpdate:SetDisabled(not IsAddOnLoaded("ExRT"))
  forceMethodRaidToolsUpdate:SetRelativeWidth(0.5)
  forceMethodRaidToolsUpdate:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.forceMethodRaidToolsUpdate = value
      PRT.GetProfileDB().mrtExportDefaults.forceMethodRaidToolsUpdate = value
      updatePRTTag:SetDisabled(not value)
    end
  )

  -- Update MethodRaidTools and replace tag content
  updatePRTTag:SetDisabled(not options.forceMethodRaidToolsUpdate)
  updatePRTTag:SetRelativeWidth(0.5)
  updatePRTTag:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.updatePRTTag = value
      PRT.GetProfileDB().mrtExportDefaults.updatePRTTag = value
    end
  )

  optionsGroup:AddChild(includeTimers)
  optionsGroup:AddChild(includeRotations)
  optionsGroup:AddChild(withEncounterName)
  optionsGroup:AddChild(withTriggerNames)
  optionsGroup:AddChild(withLinePrefix)
  optionsGroup:AddChild(withEmptyLines)
  optionsGroup:AddChild(withPersonalization)
  optionsGroup:AddChild(forceMethodRaidToolsUpdate)
  optionsGroup:AddChild(updatePRTTag)

  container:AddChild(optionsGroup)
end

local function AddMRTExportTriggerSelectorWidget(container, title, selectedTriggers, triggers)
  local triggerGroup = PRT.InlineGroup(title)
  triggerGroup:SetLayout("Flow")

  local checkboxes = {}

  for _, timer in ipairs(triggers) do
    local timerCheckbox = PRT.CheckBox(timer.name, nil, true)
    timerCheckbox:SetRelativeWidth(0.25)
    timerCheckbox:SetCallback(
      "OnValueChanged",
      function(widget)
        local value = widget:GetValue()
        if value then
          selectedTriggers[timer.name] = timer
        elseif selectedTriggers[timer.name] then
          selectedTriggers[timer.name] = nil
        end
      end
    )

    -- Initially all timers are selected
    selectedTriggers[timer.name] = timer
    tinsert(checkboxes, timerCheckbox)
    triggerGroup:AddChild(timerCheckbox)
  end

  local actionsGroup = PRT.SimpleGroup()
  actionsGroup:SetRelativeWidth(1)

  local unselectAllButton = PRT.Button(L["Unselect all"])
  unselectAllButton:SetCallback(
    "OnClick",
    function()
      for _, cb in ipairs(checkboxes) do
        cb:SetValue(false)
        wipe(selectedTriggers)
      end
    end
  )

  actionsGroup:AddChild(unselectAllButton)
  triggerGroup:AddChild(actionsGroup)
  container:AddChild(triggerGroup)
end

local function UpdateMethodRaidToolsNote()
  -- We use this function to FORCE exrt to update the note.
  PRT.Debug("Forcing MethodRaidTools Note to update.")
  DEFAULT_CHAT_FRAME.editBox:SetText("/exrt note timer")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)

  DEFAULT_CHAT_FRAME.editBox:SetText("/exrt note timer")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

local function injectPRTMethodRaidToolsNoteExportIntoNote(export)
  local currentNote = _G.VExRT.Note.Text1
  if currentNote then
    local tagLength = string.len("{prtend}")
    local prtStart = string.find(currentNote, "{prtstart}")
    local prtEnd = string.find(currentNote, "{prtend}")
    local newNote

    if prtStart and prtEnd then
      local noteStart = string.sub(currentNote, 0, prtStart - 1)
      local noteEnd = string.sub(currentNote, (prtEnd + tagLength))

      newNote = string.format("%s{prtstart}%s{prtend}%s", noteStart, export, noteEnd)
      _G.VExRT.Note.Text1 = newNote
      UpdateMethodRaidToolsNote()
    else
      PRT.Error(
        string.format(
          "Couldn't find either %s or %s. Aborting MethodRaidTools force update. Please make sure you have put both tag into your current note.",
          PRT.HighlightString("{prtstart}"),
          PRT.HighlightString("{prtend}")
        )
      )
    end
  else
    PRT.Error(
      string.format(
        "Couldn't find either %s or %s. Aborting MethodRaidTools force update. Please make sure you have put both tag into your current note.",
        PRT.HighlightString("{prtstart}"),
        PRT.HighlightString("{prtend}")
      )
    )
  end
end

local function AddMethodRaidToolsExportResultWidget(container, encounter, options)
  local timers = {}

  for _, timer in pairs(options.selectedTimers) do
    tinsert(timers, timer)
  end

  PRT.TableUtils.SortByKey(timers, "name")

  local exportString = noteFromEncounter(options, encounter)
  exportString = string.gsub(exportString, "|", "||")
  container:ReleaseChildren()
  container:SetLayout("Fill")

  local exportTextBox = PRT.MultiLineEditBox(L["MethodRaidTools Note"], exportString)
  exportTextBox:SetFocus()
  exportTextBox:DisableButton(true)
  exportTextBox:HighlightText()

  if options.forceMethodRaidToolsUpdate and IsAddOnLoaded("ExRT") then
    if options.updatePRTTag then
      injectPRTMethodRaidToolsNoteExportIntoNote(exportString)
    else
      _G.VExRT.Note.Text1 = exportString
      UpdateMethodRaidToolsNote()
    end
  end

  container:AddChild(exportTextBox)
end

function PRT.AddMethodRaidToolsExportWidget(container, encounter)
  local encounterVersion = encounter.versions[encounter.selectedVersion]
  local mrtExportButton = PRT.Button(L["Generate MethodRaidTools Note"])
  mrtExportButton:SetWidth(400)
  mrtExportButton:SetCallback(
    "OnClick",
    function()
      local mrtExportOptions = PRT.TableUtils.Clone(PRT.GetProfileDB().mrtExportDefaults)
      mrtExportOptions.selectedTimers = {}

      local modalContainer = PRT.SimpleGroup()
      local description =
        PRT.Label(
        L[
          "This feature will export your selected timers to a MethodRaidTools note. This will only work for message of type %s.\n\nIf you want" ..
            " to keep your current note you can use %s and %s. The prt generated note will be put inbetween those tags."
        ]:format(PRT.HighlightString("cooldown"), PRT.HighlightString("{prtstart}"), PRT.HighlightString("{prtend}"))
      )
      local exportButton = PRT.Button(L["Export"])

      description:SetRelativeWidth(1)
      exportButton:SetCallback(
        "OnClick",
        function()
          if mrtExportOptions.forceMethodRaidToolsUpdate and not mrtExportOptions.updatePRTTag then
            PRT.ConfirmationDialog(
              L["You want to force update MethodRaidTools note without replacing PRT tag content. This will overwrite the whole note. Are you sure about that?"],
              function()
                AddMethodRaidToolsExportResultWidget(modalContainer, encounter, mrtExportOptions)
              end
            )
          else
            AddMethodRaidToolsExportResultWidget(modalContainer, encounter, mrtExportOptions)
          end
        end
      )

      -- Add widgets to modal container
      modalContainer:AddChild(description)
      AddMethodRaidToolsExportOptionsWidget(modalContainer, mrtExportOptions)

      mrtExportOptions.selectedTimers = {}
      mrtExportOptions.selectedRotations = {}

      AddMRTExportTriggerSelectorWidget(modalContainer, L["Select timers"], mrtExportOptions.selectedTimers, encounterVersion.Timers)
      AddMRTExportTriggerSelectorWidget(modalContainer, L["Select rotations"], mrtExportOptions.selectedRotations, encounterVersion.Rotations)
      modalContainer:AddChild(exportButton)

      local modal = PRT.CreateModal(modalContainer, L["MethodRaidTools Note Generator"])
      modal:EnableResize(false)
    end
  )

  container:AddChild(mrtExportButton)
end

-- EncounterName
-- Rotation Name
-- Rotation Entry
-- ...
-- Space
-- Timer Name
-- Timer Entry
-- Timing
-- ...
