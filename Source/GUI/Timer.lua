local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Timer = {}

-------------------------------------------------------------------------------
-- Local Helper

Timer.TimingWidget = function(timing, container)
    local timingOptionsGroup = PRT.InlineGroup("timingOptionsHeading")

    local secondsEditBox = PRT.EditBox("timingSeconds", timing.seconds)    
    secondsEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            timing.seconds = tonumber(widget:GetText()) 
        end)

    local messagesTabs = PRT.TableToTabs(timing.messages, true)    
    local messagesTabGroup = PRT.TabGroup(nil, messagesTabs)
    --messagesTabGroup:SetLayout("Flow")
    messagesTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, timing.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "messageDeleteButton") 
        end)

    PRT.SelectFirstTab(messagesTabGroup, timing.messages)  

    timingOptionsGroup:AddChild(secondsEditBox)

    container:AddChild(timingOptionsGroup)
    container:AddChild(messagesTabGroup)

	return container
end

Timer.TimerOptionsTabGroupSelected = function(container, timer, key)
	container:ReleaseChildren()

	if key == "startCondition" then
		PRT.ConditionWidget(timer.startCondition, container)
    elseif key == "stopCondition" then
        PRT.ConditionWidget(timer.stopCondition, container)
    elseif key == "timings" then
        local timingsHeading = PRT.Heading("Timings")
        local timingsTabs = PRT.TableToTabs(timer.timings, true)
        local timingsTabGroup = PRT.TabGroup(nil, timingsTabs)
        timingsTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, timer.timings, key, Timer.TimingWidget, PRT.EmptyTiming, "timingDeleteButton") 
        end)        
        PRT.SelectFirstTab(timingsTabGroup, timer.timings)  
        container:AddChild(timingsTabGroup)
	end

	PRT.mainFrameContent:DoLayout()
end

Timer.TimerWidget = function(timer, container)
    local timerOptionsGroup = PRT.InlineGroup("timerOptionsHeading")

    local nameEditBox = PRT.EditBox("timerName", timer.name)
    nameEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            timer.name = widget:GetText() 
        end)

    -- TODO: Übersetzen
    local tabs = {
		{value = "startCondition", text = "Start Condition"},
        {value = "stopCondition", text = "Stop Condition"},
        {value = "timings", text = "Timings"}
    }
    
    local timerOptionsTabGroup = PRT.TabGroup(nil, tabs)
    --timerOptionsTabGroup:SetLayout("Flow")
    timerOptionsTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            Timer.TimerOptionsTabGroupSelected(widget, timer, key) 
        end)

    timerOptionsTabGroup:SelectTab("startCondition")    

    timerOptionsGroup:AddChild(nameEditBox)
    container:AddChild(timerOptionsGroup)
    container:AddChild(timerOptionsTabGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.TimerTabGroup = function(timers)
	local tabs = PRT.TableToTabs(timers, true)
	local timersTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    timersTabGroupWidget:SetCallback("OnGroupSelected", 
    function(widget, event, key) 
        PRT.TabGroupSelected(widget, timers, key, Timer.TimerWidget, PRT.EmptyTimer, "timerDeleteButton") 
    end)

    PRT.SelectFirstTab(timersTabGroupWidget, timers)  

    return timersTabGroupWidget
end