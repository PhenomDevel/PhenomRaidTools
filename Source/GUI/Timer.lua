local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Timer = {}

-------------------------------------------------------------------------------
-- Local Helper

Timer.TimingWidget = function(timing, container)
    local timingOptionsGroup = PRT.InlineGroup("timingOptionsHeading")

    table.sort(timing.seconds)
    local secondsEditBox = PRT.EditBox("timingSeconds", strjoin(", ", unpack(timing.seconds)))    
    secondsEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            local times = {strsplit(",", widget:GetText())}
            
            timing.seconds = {}
            for i, second in ipairs(times) do
                table.insert(timing.seconds, tonumber(second))
            end
			widget:ClearFocus()
        end)

    local messagesTabs = PRT.TableToTabs(timing.messages, true)    
    local messagesTabGroup = PRT.TabGroup("Messages", messagesTabs)
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


-------------------------------------------------------------------------------
-- Public API

PRT.TimerWidget = function(timer, container)    
    local timerOptionsGroup = PRT.InlineGroup("timerOptionsHeading")

    local nameEditBox = PRT.EditBox("timerName", timer.name)
    nameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            timer.name = widget:GetText()             
            PRT.mainFrameContent:SetTree(PRT.Tree.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
    
            PRT.mainFrameContent:SelectByValue(timer.name)
        end)
    
    local startConditionGroup = PRT.ConditionWidget(timer.startCondition, "Start Condition")
    startConditionGroup:SetLayout("Flow")

    local stopConditionGroup = PRT.ConditionWidget(timer.stopCondition, "Stop Condition")
    stopConditionGroup:SetLayout("Flow")

    local timingsHeading = PRT.Heading("Timings")
        local timingsTabs = PRT.TableToTabs(timer.timings, true)
        local timingsTabGroup = PRT.TabGroup("Timings", timingsTabs)
        timingsTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, timer.timings, key, Timer.TimingWidget, PRT.EmptyTiming, "timingDeleteButton") 
        end)        
        PRT.SelectFirstTab(timingsTabGroup, timer.timings)  

    timerOptionsGroup:AddChild(nameEditBox)
    container:AddChild(timerOptionsGroup)
    container:AddChild(startConditionGroup)
    container:AddChild(stopConditionGroup)
    container:AddChild(timingsTabGroup)
end