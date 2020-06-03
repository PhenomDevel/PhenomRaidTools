local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Timer = {}


-------------------------------------------------------------------------------
-- Local Helper

Timer.TimingWidget = function(timing, container)
   local timingOptionsGroup = PRT.InlineGroup("timingOptionsHeading")

   sort(timing.seconds)
   local secondsEditBox = PRT.EditBox("timingSeconds", strjoin(", ", unpack(timing.seconds)), true)
   secondsEditBox:SetCallback("OnEnterPressed",
			      function(widget)
				 local text = widget:GetText()
				 local times = {strsplit(",", text)}

				 timing.seconds = {}
				 for i, second in ipairs(times) do
				    tinsert(timing.seconds, tonumber(second))
				 end
				 timing.name = strjoin(", ", strsplit(",", text))
				 widget:ClearFocus()
   end)

   local messagesTabs = PRT.TableToTabs(timing.messages, true)
   local messagesTabGroup = PRT.TabGroup("messageHeading", messagesTabs)
   messagesTabGroup:SetLayout("List")
   messagesTabGroup:SetCallback("OnGroupSelected",
				function(widget, event, key)
				   PRT.TabGroupSelected(widget, timing.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "messageDeleteButton")
   end)

   PRT.SelectFirstTab(messagesTabGroup, timing.messages)
   timingOptionsGroup:AddChild(secondsEditBox)
   container:AddChild(timingOptionsGroup)
   container:AddChild(messagesTabGroup)
end

Timer.TimerWidget = function(timer, container)
   local timerOptionsGroup = PRT.InlineGroup("timerOptionsHeading")
   timerOptionsGroup:SetLayout("Flow")

   local enabledCheckbox = PRT.CheckBox("timerEnabled", timer.enabled)
   enabledCheckbox:SetRelativeWidth(1)
   enabledCheckbox:SetCallback("OnValueChanged",
			       function(widget)
				  timer.enabled = widget:GetValue()
   end)

   local nameEditBox = PRT.EditBox("timerName", timer.name)
   nameEditBox:SetCallback("OnEnterPressed",
			   function(widget)
			      timer.name = widget:GetText()
			      PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
			      PRT.Core.ReselectExchangeLast(timer.name)
   end)

   local triggerAtOccurenceSlider = PRT.Slider("timerOptionsTriggerAtOccurence", (timer.triggerAtOccurence or 1))
   triggerAtOccurenceSlider:SetSliderValues(1, 20, 1)
   triggerAtOccurenceSlider:SetCallback("OnValueChanged",
					function(widget)
					   local value = widget:GetValue()
					   timer.triggerAtOccurence = value
   end)

   local startConditionGroup = PRT.ConditionWidget(timer.startCondition, "conditionStartHeading")
   startConditionGroup:SetLayout("Flow")

   local timingsTabs = PRT.TableToTabs(timer.timings, true)
   local timingsTabGroup = PRT.TabGroup("timingOptions", timingsTabs)
   timingsTabGroup:SetCallback("OnGroupSelected",
			       function(widget, event, key)
				  PRT.TabGroupSelected(widget, timer.timings, key, Timer.TimingWidget, PRT.EmptyTiming, "timingDeleteButton")
   end)
   PRT.SelectFirstTab(timingsTabGroup, timer.timings)

   timerOptionsGroup:AddChild(enabledCheckbox)
   timerOptionsGroup:AddChild(nameEditBox)
   timerOptionsGroup:AddChild(triggerAtOccurenceSlider)
   container:AddChild(timerOptionsGroup)
   container:AddChild(startConditionGroup)

   if timer.hasStopCondition then
      local stopConditionGroup = PRT.ConditionWidget(timer.stopCondition, "conditionStopHeading")
      stopConditionGroup:SetLayout("Flow")

      local removeStopConditionButton = PRT.Button("conditionRemoveStopCondition")
      removeStopConditionButton:SetCallback("OnClick",
					    function()
					       timer.hasStopCondition = false
					       timer.stopCondition = {}
					       PRT.Core.ReselectCurrentValue()
      end)
      stopConditionGroup:AddChild(removeStopConditionButton)
      container:AddChild(stopConditionGroup)
   else
      local addStopConditionButton = PRT.Button("conditionAddStopCondition")
      addStopConditionButton:SetCallback("OnClick",
					 function()
					    timer.hasStopCondition = true
					    timer.stopCondition = PRT.EmptyCondition()
					    PRT.Core.ReselectCurrentValue()
      end)
      container:AddChild(addStopConditionButton)
   end

   container:AddChild(timingsTabGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddTimerOptionsWidgets = function(container, profile, encounterID)
   local _, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
   local timers = encounter.Timers

   local timerOptionsGroup = PRT.InlineGroup("Options")
   timerOptionsGroup:SetLayout("Flow")

   local addButton = PRT.Button("newTimer")
   addButton:SetHeight(40)
   addButton:SetRelativeWidth(1)
   addButton:SetCallback("OnClick",
			 function(widget, event, key)
			    local newTimer = PRT.EmptyTimer()
			    tinsert(timers, newTimer)
			    PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
			    PRT.mainWindowContent:DoLayout()
			    PRT.mainWindowContent:SelectByPath("encounters", encounterID, "timers", newTimer.name)
   end)
   timerOptionsGroup:AddChild(addButton)
   container:AddChild(timerOptionsGroup)
end

PRT.AddTimerWidget = function(container, profile, encounterID, triggerName)
   local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)
   local timers = encounter.Timers
   local timerIndex, timer = PRT.FilterTableByName(timers, triggerName)
   local deleteButton = PRT.NewTriggerDeleteButton(container, timers, timerIndex, "deleteTimer")

   Timer.TimerWidget(timer, container)
   container:AddChild(deleteButton)
end
