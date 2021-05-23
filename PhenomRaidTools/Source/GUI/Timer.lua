local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Timer = {}

local IsAddOnLoaded = IsAddOnLoaded

-------------------------------------------------------------------------------
-- Local Helper

local function AddExRTExportOptionsWidget(container, context)
  local optionsGroup = PRT.InlineGroup(L["Options"])
  optionsGroup:SetLayout("Flow")

  local withEncounterName = PRT.CheckBox(L["Include title"], L["Shows the encounter name on top of the note."], context.withEncounterName)
  local withTimerNames = PRT.CheckBox(L["Include section names"], L["Shows the prt timer names on top of each group of note timers."], context.withTimerNames)
  local withTimingNames = PRT.CheckBox(L["Include line prefix"], L["Shows the timing names before each line of a given prt timer."], context.withTimingNames)
  local withEmptyLines = PRT.CheckBox(L["Include empty lines"], L["Includes lines even if there are no entries within the prt timer."], context.withEmptyLines)
  local withPersonalization = PRT.CheckBox(L["Personalize note"], L["This will hide all entries which are not interesting for the given player."], context.withPersonalization)
  local forceExRTUpdate = PRT.CheckBox(L["Force ExRT note update"], L["This will try and force ExRT to directly update the note."], context.forceExRTUpdate)
  local updatePRTTag =
    PRT.CheckBox(
    L["Replace PRT tag content"],
    L["This will update the existing ExRT note and just replace the content between %s and %s tag with the generated content."]:format(
      PRT.HighlightString("{prtstart}"),
      PRT.HighlightString("{prtend}")
    ),
    context.updatePRTTag
  )

  -- Include Encounter name
  withEncounterName:SetRelativeWidth(0.5)
  withEncounterName:SetCallback(
    "OnValueChanged",
    function(widget)
      context.withEncounterName = widget:GetValue()
    end
  )

  -- Include timer names
  withTimerNames:SetRelativeWidth(0.5)
  withTimerNames:SetCallback(
    "OnValueChanged",
    function(widget)
      context.withTimerNames = widget:GetValue()
    end
  )

  -- Include timing names
  withTimingNames:SetRelativeWidth(0.5)
  withTimingNames:SetCallback(
    "OnValueChanged",
    function(widget)
      context.withTimingNames = widget:GetValue()
    end
  )

  -- Include empty lines
  withEmptyLines:SetRelativeWidth(0.5)
  withEmptyLines:SetCallback(
    "OnValueChanged",
    function(widget)
      context.withEmptyLines = widget:GetValue()
    end
  )

  -- Personalize Note
  withPersonalization:SetRelativeWidth(0.5)
  withPersonalization:SetCallback(
    "OnValueChanged",
    function(widget)
      context.withPersonalization = widget:GetValue()
    end
  )

  -- Directly Update ExRT Note
  forceExRTUpdate:SetDisabled(not IsAddOnLoaded("ExRT"))
  forceExRTUpdate:SetRelativeWidth(0.5)
  forceExRTUpdate:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      context.forceExRTUpdate = value
      updatePRTTag:SetDisabled(not value)
    end
  )

  -- Update ExRT and replace tag content
  updatePRTTag:SetDisabled(not context.forceExRTUpdate)
  updatePRTTag:SetRelativeWidth(0.5)
  updatePRTTag:SetCallback(
    "OnValueChanged",
    function(widget)
      context.updatePRTTag = widget:GetValue()
    end
  )

  optionsGroup:AddChild(withEncounterName)
  optionsGroup:AddChild(withTimerNames)
  optionsGroup:AddChild(withTimingNames)
  optionsGroup:AddChild(withEmptyLines)
  optionsGroup:AddChild(withPersonalization)
  optionsGroup:AddChild(forceExRTUpdate)
  optionsGroup:AddChild(updatePRTTag)

  container:AddChild(optionsGroup)
end

local function AddExRTExportSelectorWidget(container, context)
  local timerGroup = PRT.InlineGroup(L["Select Timers"])
  timerGroup:SetLayout("Flow")

  local checkboxes = {}

  for _, timer in ipairs(context.timers) do
    local timerCheckbox = PRT.CheckBox(timer.name, nil, true)
    timerCheckbox:SetRelativeWidth(0.5)
    timerCheckbox:SetCallback(
      "OnValueChanged",
      function(widget)
        local value = widget:GetValue()
        if value then
          context.selectedTimers[timer.name] = timer
        elseif context.selectedTimers[timer.name] then
          context.selectedTimers[timer.name] = nil
        end
      end
    )

    -- Initially all timers are selected
    context.selectedTimers[timer.name] = timer
    tinsert(checkboxes, timerCheckbox)
    timerGroup:AddChild(timerCheckbox)
  end

  local unselectAllButton = PRT.Button(L["Unselect all"])
  unselectAllButton:SetCallback(
    "OnClick",
    function()
      for _, cb in ipairs(checkboxes) do
        cb:SetValue(false)
        wipe(context.selectedTimers)
      end
    end
  )

  timerGroup:AddChild(unselectAllButton)
  container:AddChild(timerGroup)
end

local function UpdateExRTNote()
  -- We use this function to FORCE exrt to update the note.
  PRT.Debug("Forcing ExRT Note to update.")
  DEFAULT_CHAT_FRAME.editBox:SetText("/exrt note timer")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)

  DEFAULT_CHAT_FRAME.editBox:SetText("/exrt note timer")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

local function injectPRTExRTNoteExportIntoNote(export)
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
      UpdateExRTNote()
    else
      PRT.Error(
        string.format(
          "Couldn't find either %s or %s. Aborting ExRT force update. Please make sure you have put both tag into your current note.",
          PRT.HighlightString("{prtstart}"),
          PRT.HighlightString("{prtend}")
        )
      )
    end
  else
    PRT.Error(
      string.format(
        "Couldn't find either %s or %s. Aborting ExRT force update. Please make sure you have put both tag into your current note.",
        PRT.HighlightString("{prtstart}"),
        PRT.HighlightString("{prtend}")
      )
    )
  end
end

local function AddExRTExportResultWidget(container, encounter, context)
  local timers = {}

  for _, timer in pairs(context.selectedTimers) do
    tinsert(timers, timer)
  end

  PRT.TableUtils.SortByKey(timers, "name")

  local exportString = PRT.ExRTExportFromTimers(context, timers, PRT.ColoredString(encounter.name, PRT.Static.Colors.Primary))
  exportString = string.gsub(exportString, "|", "||")
  container:ReleaseChildren()
  container:SetLayout("Fill")

  local exportTextBox = PRT.MultiLineEditBox(L["ExRT Note"], exportString)
  exportTextBox:SetFocus()
  exportTextBox:DisableButton(true)
  exportTextBox:HighlightText()

  if context.forceExRTUpdate and IsAddOnLoaded("ExRT") then
    if context.updatePRTTag then
      injectPRTExRTNoteExportIntoNote(exportString)
    else
      _G.VExRT.Note.Text1 = exportString
      UpdateExRTNote()
    end
  end

  container:AddChild(exportTextBox)
end

local function AddExRTExportWidget(container, encounter, timers)
  local exrtExportButton = PRT.Button(L["Generate ExRT Note"])
  exrtExportButton:SetCallback(
    "OnClick",
    function()
      local exrtExportContext = {
        timers = timers,
        selectedTimers = {},
        withEmptyLines = false,
        withEncounterName = true,
        withTimerNames = true,
        withTimingNames = true,
        forceExRTUpdate = false,
        updatePRTTag = true
      }

      local modalContainer = PRT.SimpleGroup()
      local description =
        PRT.Label(
        L[
          "This feature will export your selected timers to a ExRT note. This will only work for message of type %s.\n\nIf you want" ..
            " to keep your current note you can use %s and %s. The prt generated note will be put inbetween those tags."
        ]:format(PRT.HighlightString("cooldown"), PRT.HighlightString("{prtstart}"), PRT.HighlightString("{prtend}"))
      )
      local exportButton = PRT.Button(L["Export"])

      description:SetRelativeWidth(1)
      exportButton:SetCallback(
        "OnClick",
        function()
          if exrtExportContext.forceExRTUpdate and not exrtExportContext.updatePRTTag then
            PRT.ConfirmationDialog(
              L["You want to force update ExRT note without replacing PRT tag content. This will overwrite the whole note. Are you sure about that?"],
              function()
                AddExRTExportResultWidget(modalContainer, encounter, exrtExportContext)
              end
            )
          else
            AddExRTExportResultWidget(modalContainer, encounter, exrtExportContext)
          end
        end
      )

      -- Add widgets to modal container
      modalContainer:AddChild(description)
      AddExRTExportOptionsWidget(modalContainer, exrtExportContext)
      AddExRTExportSelectorWidget(modalContainer, exrtExportContext)
      modalContainer:AddChild(exportButton)

      local modal = PRT.CreateModal(modalContainer, L["ExRT Note Generator"])
      modal:EnableResize(false)
    end
  )

  container:AddChild(exrtExportButton)
end

function Timer.ParseTiming(timing)
  if strmatch(timing, ":") then
    local minute, second = strsplit(":", timing)
    return tonumber(minute) * 60 + tonumber(second)
  else
    return tonumber(timing)
  end
end

function Timer.ComposeTimingString(timings)
  sort(timings)
  local timingsStrings = {}

  for _, timing in ipairs(timings) do
    local minutes = math.floor(timing / 60)
    local seconds = timing % 60
    local timingString = minutes .. ":"

    if seconds < 10 then
      timingString = timingString .. "0" .. seconds
    else
      timingString = timingString .. seconds
    end

    tinsert(timingsStrings, timingString)
  end

  return strjoin(", ", unpack(timingsStrings))
end

function Timer.TimingWidget(timing, container, _)
  local timingOptionsGroup = PRT.InlineGroup(L["Options"])
  timingOptionsGroup:SetLayout("Flow")

  sort(timing.seconds)

  local nameEditBox = PRT.EditBox(L["Name"], nil, (timing.name or ""))
  nameEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      timing.name = text
      widget:ClearFocus()
    end
  )

  local secondsEditBox =
    PRT.EditBox(
    L["Timings"],
    L["Comma separated list of timings\nsupports different formats\n- 69\n- 1:09\n- 00:09"],
    strjoin(", ", Timer.ComposeTimingString(timing.seconds)),
    true
  )
  secondsEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      local times = {strsplit(",", text)}

      timing.seconds = {}

      for _, timingEntry in ipairs(times) do
        local timingSecond = Timer.ParseTiming(timingEntry)
        tinsert(timing.seconds, timingSecond)
      end

      if not timing.name then
        timing.name = strjoin(", ", strsplit(",", text))
      end

      widget:SetText(Timer.ComposeTimingString(timing.seconds))

      widget:ClearFocus()
    end
  )

  local messagesTabs = PRT.TableToTabs(timing.messages, true)
  local messagesTabGroup = PRT.TabGroup(L["Messages"], messagesTabs)
  messagesTabGroup:SetLayout("List")
  messagesTabGroup:SetCallback(
    "OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, timing.messages, key, PRT.MessageWidget, PRT.EmptyMessage, true, L["Delete"], true, L["Clone"])
    end
  )

  local offsetSlider = PRT.Slider(L["Offset"], L["Offset will be applied to all timings."], timing.offset, true)
  offsetSlider:SetSliderValues(-60, 60, 1)
  offsetSlider:SetCallback(
    "OnValueChanged",
    function(widget)
      timing.offset = tonumber(widget:GetValue())
    end
  )

  PRT.SelectFirstTab(messagesTabGroup, timing.messages)
  timingOptionsGroup:AddChild(nameEditBox)
  timingOptionsGroup:AddChild(secondsEditBox)
  timingOptionsGroup:AddChild(offsetSlider)
  container:AddChild(timingOptionsGroup)
  container:AddChild(messagesTabGroup)
end

function Timer.TimerWidget(timerName, timers, container)
  local _, timer = PRT.TableUtils.GetBy(timers, "name", timerName)

  -- General Options
  PRT.AddGeneralOptionsWidgets(container, timerName, timers, "timer")

  -- Timer Options
  local timerOptionsGroup = PRT.InlineGroup(L["Options"])
  timerOptionsGroup:SetLayout("Flow")

  local triggerAtOccurenceSlider = PRT.Slider(L["Occurrence"], L["After how many occurrences of\nstart condition the timer should start."], (timer.triggerAtOccurence or 1))
  triggerAtOccurenceSlider:SetSliderValues(1, 20, 1)
  triggerAtOccurenceSlider:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      timer.triggerAtOccurence = value
    end
  )

  local resetCounterOnStopCheckbox = PRT.CheckBox(L["Reset counter on stop"], L["Resets the counter of start conditions\nwhen the timer is stopped."], timer.resetCounterOnStop)
  resetCounterOnStopCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      timer.resetCounterOnStop = widget:GetValue()
      PRT.Core.UpdateTree()
    end
  )

  timerOptionsGroup:AddChild(triggerAtOccurenceSlider)
  timerOptionsGroup:AddChild(resetCounterOnStopCheckbox)
  container:AddChild(timerOptionsGroup)

  -- Start Condition
  local startConditionGroup = PRT.ConditionWidget(timer.startCondition, L["Start Condition"])
  startConditionGroup:SetLayout("Flow")
  container:AddChild(startConditionGroup)

  -- Stop Condition
  PRT.MaybeAddStopCondition(container, timer)

  -- Timings
  local timingsTabs = PRT.TableToTabs(timer.timings, true)
  local timingsTabGroup = PRT.TabGroup(L["Timings"], timingsTabs)
  timingsTabGroup:SetCallback(
    "OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, timer.timings, key, Timer.TimingWidget, PRT.EmptyTiming, true, L["Delete"], true, L["Clone"])
    end
  )
  PRT.SelectFirstTab(timingsTabGroup, timer.timings)
  container:AddChild(timingsTabGroup)
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddTimerOptionsWidgets(container, profile, encounterID)
  local _, encounter = PRT.GetEncounterById(profile.encounters, tonumber(encounterID))
  local _, selectedEncounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, tonumber(encounterID))
  local timers = selectedEncounter.Timers

  local timerOptionsGroup = PRT.InlineGroup(L["Options"])
  timerOptionsGroup:SetLayout("Flow")

  local hasClipboardTimer = (not PRT.TableUtils.IsEmpty(PRT.GetProfileDB().clipboard.timer))
  local pasteButtonText = PRT.StringUtils.WrapColorByBoolean(L["Paste"], hasClipboardTimer, "FF696969")
  local pasteButton = PRT.Button(pasteButtonText)
  pasteButton:SetDisabled(not hasClipboardTimer)
  pasteButton:SetCallback(
    "OnClick",
    function()
      tinsert(timers, PRT.GetProfileDB().clipboard.timer)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "timers", PRT.GetProfileDB().clipboard.timer.name)
      PRT.Debug("Pasted timer", PRT.HighlightString(PRT.GetProfileDB().clipboard.timer.name), "to", PRT.HighlightString(selectedEncounter.name))
      PRT.GetProfileDB().clipboard.timer = nil
    end
  )

  local addButton = PRT.Button(L["New"])
  addButton:SetCallback(
    "OnClick",
    function()
      local newTimer = PRT.EmptyTimer()
      tinsert(timers, newTimer)
      PRT.Core.UpdateTree()
      PRT.mainWindowContent:DoLayout()
      PRT.mainWindowContent:SelectByPath("encounters", encounterID, "timers", newTimer.name)
    end
  )

  timerOptionsGroup:AddChild(addButton)
  timerOptionsGroup:AddChild(pasteButton)
  AddExRTExportWidget(timerOptionsGroup, encounter, timers)
  container:AddChild(timerOptionsGroup)
end

function PRT.AddTimerWidget(container, profile, encounterID, timerName)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, encounterID)
  local timers = encounter.Timers

  Timer.TimerWidget(timerName, timers, container)
end
