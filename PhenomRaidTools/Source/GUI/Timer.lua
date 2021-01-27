local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Timer = {}


-------------------------------------------------------------------------------
-- Local Helper

Timer.ParseTiming = function(timing)
    if strmatch(timing, ":") then
        local minute, second = strsplit(":", timing)
        return tonumber(minute) * 60 + tonumber(second)
    else
        return tonumber(timing)
    end
end

Timer.ComposeTimingString = function(timings)
    sort(timings)
    local timingsStrings = {}

    for i, timing in ipairs(timings) do
        local minutes = math.floor(timing / 60)
        local seconds = timing % 60
        local timingString = minutes..":"

        if seconds < 10 then 
            timingString = timingString.."0"..seconds
        else
            timingString = timingString..seconds
        end
        
        tinsert(timingsStrings, timingString)
    end

    return strjoin(", ", unpack(timingsStrings))
end

Timer.TimingWidget = function(timing, container, key, timings)
    local timingOptionsGroup = PRT.InlineGroup("timingOptionsHeading")
    timingOptionsGroup:SetLayout("Flow")

    sort(timing.seconds)

    local nameEditBox = PRT.EditBox("timingName", (timing.name or ""))
    nameEditBox:SetCallback("OnEnterPressed",
        function(widget)
            local text = widget:GetText()
            timing.name = text
            widget:ClearFocus()
        end)

    local secondsEditBox = PRT.EditBox("timingSeconds", strjoin(", ", Timer.ComposeTimingString(timing.seconds)), true)    
    secondsEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            local text = widget:GetText()
            local times = {strsplit(",", text)}

            timing.seconds = {}

            for i, timingEntry in ipairs(times) do
                local timingSecond = Timer.ParseTiming(timingEntry)                
                tinsert(timing.seconds, timingSecond)
            end

            if not timing.name then
                timing.name = strjoin(", ", strsplit(",", text))
            end
            
            widget:SetText(Timer.ComposeTimingString(timing.seconds))

			widget:ClearFocus()
        end)

    local messagesTabs = PRT.TableToTabs(timing.messages, true)    
    local messagesTabGroup = PRT.TabGroup("messageHeading", messagesTabs)
    messagesTabGroup:SetLayout("List")
    messagesTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, timing.messages, key, PRT.MessageWidget, PRT.EmptyMessage, true, "messageDeleteButton") 
        end)

    local offsetSlider = PRT.Slider("timingOffset", timing.offset, true)	
    offsetSlider:SetSliderValues(-60, 60, 1)
    offsetSlider:SetCallback("OnValueChanged", 
        function(widget)
            timing.offset = tonumber(widget:GetValue()) 
        end)

    PRT.SelectFirstTab(messagesTabGroup, timing.messages)  
    timingOptionsGroup:AddChild(nameEditBox)
    timingOptionsGroup:AddChild(secondsEditBox)
    timingOptionsGroup:AddChild(offsetSlider)
    container:AddChild(timingOptionsGroup)
    container:AddChild(messagesTabGroup)    

    local cloneButton = PRT.Button("cloneTiming")
    cloneButton:SetCallback("OnClick",
        function()
            local clone = PRT.CopyTable(timing)
            tinsert(timings, clone)
            PRT.Core.ReselectCurrentValue()
        end)
    container:AddChild(cloneButton)  
end

Timer.TimerWidget = function(timer, container, deleteButton, cloneButton)    
    local timerOptionsGroup = PRT.InlineGroup("timerOptionsHeading")
    timerOptionsGroup:SetLayout("Flow")    

    local copyButton = PRT.Button("copyTimer")
    copyButton:SetCallback("OnClick", 
        function(widget)
            local copy = PRT.CopyTable(timer)
            copy.name = copy.name.." Copy"..random(0,100000)
            PRT.db.profile.clipboard.timer = copy
            PRT.Debug("Copied timer", PRT.HighlightString(timer.name), "to clipboard")
        end)

    local enabledCheckbox = PRT.CheckBox("timerEnabled", timer.enabled)
    enabledCheckbox:SetRelativeWidth(1)
    enabledCheckbox:SetCallback("OnValueChanged", 
        function(widget) 
            timer.enabled = widget:GetValue()    
            PRT.Core.UpdateTree()       
        end)

    local nameEditBox = PRT.EditBox("timerName", timer.name)
    nameEditBox:SetRelativeWidth(1)
    nameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            timer.name = widget:GetText()             
            PRT.Core.UpdateTree()
            PRT.Core.ReselectExchangeLast(timer.name)            
            widget:ClearFocus()
        end)

    local triggerAtOccurenceSlider = PRT.Slider("timerOptionsTriggerAtOccurence", (timer.triggerAtOccurence or 1))
    triggerAtOccurenceSlider:SetSliderValues(1, 20, 1)
    triggerAtOccurenceSlider:SetCallback("OnValueChanged",
        function(widget)
            local value = widget:GetValue()
            timer.triggerAtOccurence = value
        end)

    local resetCounterOnStopCheckbox = PRT.CheckBox("timerOptionsResetCounterOnStop", timer.resetCounterOnStop)
    resetCounterOnStopCheckbox:SetCallback("OnValueChanged", 
        function(widget) 
            timer.resetCounterOnStop = widget:GetValue()    
            PRT.Core.UpdateTree()       
        end)
    
    local startConditionGroup = PRT.ConditionWidget(timer.startCondition, "conditionStartHeading")
    startConditionGroup:SetLayout("Flow")

    local timingsTabs = PRT.TableToTabs(timer.timings, true)
    local timingsTabGroup = PRT.TabGroup("timingOptions", timingsTabs)
    timingsTabGroup:SetCallback("OnGroupSelected", 
    function(widget, event, key) 
        PRT.TabGroupSelected(widget, timer.timings, key, Timer.TimingWidget, PRT.EmptyTiming, true, "timingDeleteButton") 
    end)        
    PRT.SelectFirstTab(timingsTabGroup, timer.timings)  

    timerOptionsGroup:AddChild(enabledCheckbox)    
    PRT.AddEnabledDifficultiesGroup(timerOptionsGroup, timer)      
    timerOptionsGroup:AddChild(nameEditBox)
    PRT.AddDescription(timerOptionsGroup, timer)  
    timerOptionsGroup:AddChild(triggerAtOccurenceSlider)
    timerOptionsGroup:AddChild(resetCounterOnStopCheckbox)      
    container:AddChild(timerOptionsGroup)
    container:AddChild(startConditionGroup)
    timerOptionsGroup:AddChild(cloneButton)
    timerOptionsGroup:AddChild(deleteButton)  
    timerOptionsGroup:AddChild(copyButton)  

    PRT.MaybeAddStopCondition(container, timer)

    container:AddChild(timingsTabGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddTimerOptionsWidgets = function(container, profile, encounterID)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local timers = encounter.Timers

    local timerOptionsGroup = PRT.InlineGroup("Options")
    timerOptionsGroup:SetLayout("Flow")

    local hasClipboardTimer = not PRT.TableUtils.IsEmpty(PRT.db.profile.clipboard.timer)
    local pasteButton = PRT.Button("pasteTimer")
    pasteButton:SetDisabled(hasClipboardTimer)
    pasteButton:SetCallback("OnClick",
        function(widget)
            tinsert(timers, PRT.db.profile.clipboard.timer)            
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "timers", PRT.db.profile.clipboard.timer.name)
            PRT.Debug("Pasted timer", PRT.HighlightString(PRT.db.profile.clipboard.timer.name), "to", PRT.HighlightString(encounter.name))
            PRT.db.profile.clipboard.timer = nil            
        end)

    local addButton = PRT.Button("newTimer")
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newTimer = PRT.EmptyTimer()
            tinsert(timers, newTimer)
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "timers", newTimer.name)
        end)

    timerOptionsGroup:AddChild(addButton)
    timerOptionsGroup:AddChild(pasteButton)
    container:AddChild(timerOptionsGroup)
end

PRT.AddTimerWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local timers = encounter.Timers
    local timerIndex, timer = PRT.FilterTableByName(timers, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, timers, timerIndex, "deleteTimer", timer.name)
    local cloneButton = PRT.NewCloneButton(container, timers, timerIndex, "cloneTimer", timer.name)

    Timer.TimerWidget(timer, container, deleteButton, cloneButton)        
end