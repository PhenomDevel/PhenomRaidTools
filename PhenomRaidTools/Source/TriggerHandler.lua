local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local TriggerHandler = {}


-------------------------------------------------------------------------------
-- Local Helper

TriggerHandler.CheckCurrentDifficulty = function(trigger)
    if trigger.enabledDifficulties and PRT.currentDifficulty then
        return trigger.enabledDifficulties[PRT.currentDifficulty]
    end
end

TriggerHandler.CheckCondition = function(condition, event, combatEvent, spellID, targetGUID, sourceGUID)
    if condition ~= nil then
        if condition.event ~= nil and (condition.event == event or condition.event == combatEvent) then   
            if condition.spellID == nil or condition.spellID == spellID then
                if condition.source == nil or UnitGUID(condition.source or "") == sourceGUID then     
                    if condition.target == nil or UnitGUID(condition.target or "") == targetGUID then      
                        return true
                    end
                end
            end         
        end
    end
    return false
end

TriggerHandler.FilterTimingsTable = function(timings, timeOffset)
    local value        
    if timings then        
        for i, v in ipairs(timings) do
            local secondsWithOffset
            
            if v.offset then
                secondsWithOffset = {}
                for i, second in ipairs(v.seconds) do 
                    tinsert(secondsWithOffset, second + (v.offset or 0))
                end
            else
                secondsWithOffset = v.seconds
            end

            if tContains(secondsWithOffset, timeOffset) then
                if not value then
                    value = v
                end
            end
        end
    end
    return value
end

TriggerHandler.FilterPercentagesTable = function(percentages, percent)
    local value
    
    if percentages then
        for i, v in ipairs(percentages) do
            if v.operator == "greater" then
                if percent >= v.value then
                    if not value then
                        value = v
                    end
                end
            elseif v.operator == "less" then
                if percent <= v.value then
                    if not value then
                        value = v
                    end
                end
            elseif v.operator == "equals" then
                if v.value == percent then
                    if not value then
                        value = v
                    end
                end
            end
        end
    end
    return value
end

TriggerHandler.GetTriggerCounter = function(trigger)
    if trigger ~= nil then
        if trigger.counter ~= nil then
            return trigger.counter
        else
            return 0
        end
    end
end

TriggerHandler.GetRotationMessages = function(rotation)
    local rotationCounter = TriggerHandler.GetTriggerCounter(rotation)
    if rotation ~= nil then
        if rotation.entries ~= nil then
            if rotationCounter <=  table.getn(rotation.entries) then
                local messagesByCounter = rotation.entries[rotationCounter]         

                if messagesByCounter.messages ~= nil then
                    return messagesByCounter.messages
                end
            end
        end
    end
end

TriggerHandler.IncrementTriggerCounter = function(trigger)
    local triggerCounter = TriggerHandler.GetTriggerCounter(trigger)
    local newValue = triggerCounter + 1
        
    PRT.Debug("Incrementing trigger counter ("..(trigger.name or "NO NAME")..") to", newValue)
    trigger.counter = newValue
end 

TriggerHandler.UpdateRotationCounter = function(rotation)
    if rotation ~= nil then
        if rotation.entries ~= nil then
            local rotationCurrentCount = TriggerHandler.GetTriggerCounter(rotation)
            local rotationMaxCount = table.getn(rotation.entries)
            if rotationCurrentCount >= rotationMaxCount then
                if rotation.shouldRestart == true then
                    PRT.Debug("Resetting rotation counter to 1")
                    rotation.counter = 1
                else                   
                    TriggerHandler.IncrementTriggerCounter(rotation)
                end
            else                
                TriggerHandler.IncrementTriggerCounter(rotation)
            end
        end
    end
end

TriggerHandler.CheckStopIgnoreRotationCondition = function(trigger)
    if trigger.ignoreAfterActivation and trigger.ignored == true then
        if ((trigger.lastActivation or 0) + (trigger.ignoreDuration or 5)) < GetTime() then
            trigger.ignored = false
            PRT.Debug("Stopped ignoring trigger", trigger.name)
        end 
    end 
end

TriggerHandler.CheckStopIgnorePercentageCondition = function(trigger)
    if trigger.checkAgain and trigger.ignored == true then
        if ((trigger.lastActivation or 0) + (trigger.checkAgainAfter or 5)) < GetTime() then
            trigger.ignored = false
            PRT.Debug("Stopped ignoring trigger", trigger.name)
        end 
    end 
end

TriggerHandler.SendMessagesAfterDelay = function(messages)
    for i, message in ipairs(messages) do
        AceTimer:ScheduleTimer(
            function()
                PRT.ExecuteMessage(message)
            end,
            message.delay or 0
        )
    end
end

TriggerHandler.SendMessagesAfterDelayWithEventInfo = function(messages, event, combatEvent, eventSpellID, targetName, sourceName)
    for i, message in ipairs(messages) do
        AceTimer:ScheduleTimer(
            function()  
                -- Make sure we are not changing the configured message itself
                local messageForReceiver = PRT.CopyTable(message)
                
                if targetName then       
                    messageForReceiver.message = messageForReceiver.message:gsub("$target", targetName)
                else
                    messageForReceiver.message = messageForReceiver.message:gsub("$target", "N/A")
                end
                if sourceName then
                    messageForReceiver.message = messageForReceiver.message:gsub("$source", sourceName)
                else
                    messageForReceiver.message = messageForReceiver.message:gsub("$source", "N/A")
                end
                if tContains(messageForReceiver.targets, "$target") then
                    messageForReceiver.eventTarget = targetName
                end
                PRT.ExecuteMessage(messageForReceiver)
            end,
            message.delay or 0
        )
    end
end


-------------------------------------------------------------------------------
-- Public API

PRT.IsTriggerActive = function(trigger)    
    return 
    (
        (
            trigger.enabled == true or trigger.enabled == nil
        ) 
        and
            (TriggerHandler.CheckCurrentDifficulty(trigger) or PRT.db.profile.testMode)
        and
        (
            trigger.active == true
            or 
            (
                not trigger.hasStartCondition and 
                not trigger.hasStopCondition and 
                (
                    trigger.active or 
                    trigger.active == nil
                )
            )
            or 
            (
                not trigger.hasStartCondition and 
                trigger.hasStopCondition and 
                (
                    trigger.active or 
                    trigger.active == nil
                )
            )
        )
    )
end

-- Timer

PRT.CheckTimerStartConditions = function(timers, event, combatEvent, spellID, targetGUID, sourceGUID)   
    if timers ~= nil then
        for i, timer in ipairs(timers) do    
            if timer.enabled == true or timer.enabled == nil then                       
                if timer.startCondition ~= nil and timer.started ~= true then     
                    if TriggerHandler.CheckCondition(timer.startCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
                        TriggerHandler.IncrementTriggerCounter(timer)
                        if (timer.triggerAtOccurence or 1) == timer.counter then
                            PRT.Debug("Started timer `"..(timer.name or "NO NAME").."`")
                            timer.started = true
                            timer.startedAt = GetTime()
                        end
                    end
                end
            end
        end
    end
end

PRT.CheckTimerStopConditions = function(timers, event, combatEvent, spellID, targetGUID, sourceGUID)
    if timers ~= nil then
        for i, timer in ipairs(timers) do
            if timer.enabled == true or timer.enabled == nil then
                if timer.stopCondition ~= nil and timer.started == true then
                    if TriggerHandler.CheckCondition(timer.stopCondition, event, combatEvent, spellID, sourceGUID, targetGUID) then
                        PRT.Debug("Stopped timer `"..(timer.name or "NO NAME").."`")
                        timer.started = false
                        timer.startedAt = nil

                        if timer.resetCounterOnStop then
                            timer.counter = 0
                        end
                        
                        for i, timing in pairs(timer.timings) do
                            timing.executed = false  

                            if timing.messages then
                                timing.messages.executionTimes = {}
                            end
                        end   
                    end
                end
            end
        end
    end
end

PRT.CheckTriggersStartConditions = function(triggers, event, combatEvent, spellID, targetGUID, sourceGUID)
    if triggers ~= nil then
        for i, trigger in ipairs(triggers) do                
            if trigger.enabled == true or trigger.enabled == nil then                                       
                if trigger.startCondition ~= nil and trigger.active ~= true then    
                    if TriggerHandler.CheckCondition(trigger.startCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
                        PRT.Debug("Started trigger `"..(trigger.name or "NO NAME").."`")
                        trigger.active = true
                    end
                end
            end
        end
    end 
end

PRT.CheckTriggersStopConditions = function(triggers, event, combatEvent, spellID, targetGUID, sourceGUID)
    if triggers ~= nil then
        for i, trigger in ipairs(triggers) do
            if trigger.enabled == true or trigger.enabled == nil then
                if trigger.stopCondition ~= nil and (trigger.active == true or trigger.active == nil) then                    
                    if TriggerHandler.CheckCondition(trigger.stopCondition, event, combatEvent, spellID, sourceGUID, targetGUID) then
                        PRT.Debug("Stopped trigger `"..(trigger.name or "NO NAME").."`")
                        trigger.active = false
                    end
                end
            end
        end
    end
end

PRT.CheckTimerTimings = function(timers)
    local currentTime = GetTime()    
    if timers ~= nil then
        for i, timer in ipairs(timers) do
            if PRT.IsTriggerActive(timer) then
                if timer.started == true and timer.timings ~= nil then                
                    local elapsedTime = PRT.Round(currentTime - timer.startedAt)
                    local timings = timer.timings
                    local timingByTime = TriggerHandler.FilterTimingsTable(timings, elapsedTime)                

                    if timingByTime then
                        local messagesByTime = timingByTime.messages
                        
                        if messagesByTime ~= nil then      
                            messagesByTime.executionTimes = messagesByTime.executionTimes or {}                  
                            if messagesByTime.executionTimes[elapsedTime] ~= true then
                                TriggerHandler.SendMessagesAfterDelay(messagesByTime)                 
                                messagesByTime.executionTimes[elapsedTime] = true
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Rotations
PRT.CheckRotationTriggerCondition = function(rotations, event, combatEvent, eventSpellID, targetGUID, targetName, sourceGUID, sourceName)  
    if rotations ~= nil then
        for i, rotation in ipairs(rotations) do
            if PRT.IsTriggerActive(rotation) then                
                if rotation.triggerCondition ~= nil then
                    TriggerHandler.CheckStopIgnoreRotationCondition(rotation)
                    
                    if rotation.ignored ~= true then
                        if TriggerHandler.CheckCondition(rotation.triggerCondition, event, combatEvent, eventSpellID, targetGUID, sourceGUID) then                        
                            TriggerHandler.UpdateRotationCounter(rotation)

                            local messages = TriggerHandler.GetRotationMessages(rotation)                        					    
                            TriggerHandler.SendMessagesAfterDelayWithEventInfo(messages, event, combatEvent, eventSpellID, targetName, sourceName)
                            
                            rotation.lastActivation = GetTime()

                            if rotation.ignoreAfterActivation == true then
                                rotation.ignored = true
                                PRT.Debug("Started ignoring rotation", rotation.name, "for", rotation.ignoreDuration)
                            end 
                        end
                    end     
                end
            end
        end
    end
end

-- Health Percentages

PRT.GetEffectiveUnitID = function(unitID)
    if UnitExists(unitID) then
        return unitID
    elseif PRT.currentEncounter.trackedUnits then
        for guid, t in pairs(PRT.currentEncounter.trackedUnits) do
            if t.name == unitID then
                if UnitExists(t.unitID) and not UnitIsDead(t.unitID) then
                    return t.unitID
                end
            end
        end
    end
end

PRT.CheckUnitHealthPercentages = function(percentages)
    if percentages ~= nil then
        for i, percentage in ipairs(percentages) do
            if PRT.IsTriggerActive(percentage) then
                if percentage.enabled == true or percentage.enabled == nil then
                    TriggerHandler.CheckStopIgnorePercentageCondition(percentage)

                    if percentage.ignored ~= true and percentage.executed ~= true then
                        local unitID = PRT.GetEffectiveUnitID(percentage.unitID)

                        if UnitExists(unitID) and (not UnitIsDead(unitID)) then
                            local unitCurrentHP = UnitHealth(unitID)
                            local unitMaxHP = UnitHealthMax(unitID)
                            local unitHPPercent = PRT.Round(unitCurrentHP / unitMaxHP * 100, 0)                
                            local messagesByHP = TriggerHandler.FilterPercentagesTable(percentage.values, unitHPPercent)

                            if messagesByHP then
                                if messagesByHP.messages ~= nil then
                                    TriggerHandler.SendMessagesAfterDelay(messagesByHP.messages)

                                    percentage.lastActivation = GetTime()
                                    if percentage.checkAgain == true then
                                        percentage.ignored = true
                                        PRT.Debug("Started ignoring percentage", percentage.name, "for", percentage.checkAgainAfter)
                                    else
                                        percentage.executed = true
                                    end
                                end
                            end
                        end 
                    end 
                end          
            end
        end
    end
end

PRT.CheckUnitPowerPercentages = function(percentages)
    if percentages ~= nil then
        for i, percentage in ipairs(percentages) do
            if PRT.IsTriggerActive(percentage) then
                if percentage.enabled == true or percentage.enabled == nil then
                    TriggerHandler.CheckStopIgnorePercentageCondition(percentage)

                    if percentage.ignored ~= true and percentage.executed ~= true then
                        local unitID = PRT.GetEffectiveUnitID(percentage.unitID)

                        if UnitExists(unitID) and (not UnitIsDead(unitID)) then
                            local unitCurrentPower = UnitPower(percentage.unitID)
                            local unitMaxPower = UnitPowerMax(percentage.unitID)
                            local unitPowerPercent = PRT.Round(unitCurrentPower / unitMaxPower * 100, 0)                
                            local messagesByPower = TriggerHandler.FilterPercentagesTable(percentage.values, unitPowerPercent)

                            if messagesByPower then
                                if messagesByPower.messages ~= nil and not messagesByPower.executed == true then
                                    TriggerHandler.SendMessagesAfterDelay(messagesByPower.messages)
                                    
                                    percentage.lastActivation = GetTime()
                                    if percentage.ignoreAfterActivation == true then
                                        percentage.ignored = true
                                        PRT.Debug("Started ignoring percentage", percentage.name, "for", percentage.ignoreDuration)
                                    else
                                        messagesByPower.executed = true
                                    end
                                end
                            end
                        end 
                    end   
                end        
            end
        end
    end
end


-------------------------------------------------------------------------------
-- Message Queue Processing

PRT.ProcessMessage = function(message)
    PRT.ExecuteMessage(message)
end

PRT.ProcessMessageQueue = function()
    if PRT.MessageQueue ~= nil then
        if table.getn(PRT.MessageQueue) > 0 then
            local currentTime = GetTime()
            for i, message in ipairs(PRT.MessageQueue) do
                if message.executionTime < currentTime then
                    PRT.ProcessMessage(message)
                    tremove(PRT.MessageQueue, i)
                end
            end
        end
    end
end