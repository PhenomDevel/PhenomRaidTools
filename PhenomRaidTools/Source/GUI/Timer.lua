local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Timer = {}

-------------------------------------------------------------------------------
-- Local Helper

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

  local resetOccurenceOnStopCheckbox =
    PRT.CheckBox(L["Reset occurence counter on stop"], L["Resets the occurence counter of start conditions\nwhen the timer is stopped."], timer.resetOccurenceOnStop)
  resetOccurenceOnStopCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      timer.resetOccurenceOnStop = widget:GetValue()
      PRT.Core.UpdateTree()
    end
  )

  timerOptionsGroup:AddChild(triggerAtOccurenceSlider)
  timerOptionsGroup:AddChild(resetOccurenceOnStopCheckbox)
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
  container:AddChild(timerOptionsGroup)
end

function PRT.AddTimerWidget(container, profile, encounterID, timerName)
  local _, encounter = PRT.GetSelectedVersionEncounterByID(profile.encounters, encounterID)
  local timers = encounter.Timers

  Timer.TimerWidget(timerName, timers, container)
end
