local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Timer = {}

-------------------------------------------------------------------------------
-- Timer

Timer.TimingWidget = function(timing)
    local timingWidget = PRT:SimpleGroup() 

    -- Seconds
    local secondsEditBox = PRT.EditBox("Seconds", timing.seconds)    
    secondsEditBox:SetCallback("OnTextChanged", function(widget) timing.seconds = tonumber(widget:GetText()) end)

    -- Messages
    local messagesHeading = PRT.Heading("Messages")
    local messagesTabs = PRT.TableToTabs(timing.messages, true)
	local messagesTabGroup = PRT.TabGroup(nil, messagesTabs)
    messagesTabGroup:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, timing.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "Delete Message") end)
    PRT.SelectFirstTab(messagesTabGroup, timing.messages)  

    -- Setup Widget
    timingWidget:AddChild(secondsEditBox)

    timingWidget:AddChild(messagesHeading)
    timingWidget:AddChild(messagesTabGroup)

	return timingWidget
end

Timer.TimerOptionsTabGroupSelected = function(container, timer, key)
	container:ReleaseChildren()

	if key == "startCondition" then
		local widget = PRT.ConditionWidget(timer.startCondition)
		container:AddChild(widget)
    elseif key == "stopCondition" then
        local widget = PRT.ConditionWidget(timer.stopCondition)
		container:AddChild(widget)
    elseif key == "timings" then
        local timingsHeading = PRT.Heading("Timings")
        local timingsTabs = PRT.TableToTabs(timer.timings, true)
        local timingsTabGroup = PRT.TabGroup(nil, timingsTabs)
        timingsTabGroup:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, timer.timings, key, Timer.TimingWidget, PRT.EmptyTiming, "Delete Timing") end)        
        PRT.SelectFirstTab(timingsTabGroup, timer.timings)  
        container:AddChild(timingsTabGroup)
	end

	PRT.mainFrameContent:DoLayout()
end

Timer.TimerWidget = function(timer)
    local timerWidget = PRT:SimpleGroup()

    local nameEditBox = PRT.EditBox("Name", timer.name)
    nameEditBox:SetCallback("OnTextChanged", function(widget) timer.name = widget:GetText() end)

    local tabs = {
		{value = "startCondition", text = "Start Condition"},
        {value = "stopCondition", text = "Stop Condition"},
        {value = "timings", text = "Timings"}
    }
    
	local timerOptionsTabGroup = PRT.TabGroup(nil, tabs)
	timerOptionsTabGroup:SetCallback("OnGroupSelected", function(widget, event, key) Timer.TimerOptionsTabGroupSelected(widget, timer, key) end)
    timerOptionsTabGroup:SelectTab("startCondition")    

    -- Setup Widget
    timerWidget:AddChild(nameEditBox)

    timerWidget:AddChild(timerOptionsTabGroup)

	return timerWidget
end


-------------------------------------------------------------------------------
-- Public API

PRT.TimerTabGroup = function(timers)
	local tabs = PRT.TableToTabs(timers, true)
	local timersTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    timersTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, timers, key, Timer.TimerWidget, PRT.EmptyTimer, "Delete Timer") end)

    PRT.SelectFirstTab(timersTabGroupWidget, timers)  

    return timersTabGroupWidget
end