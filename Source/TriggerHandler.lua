local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local TriggerHandler = {}


-------------------------------------------------------------------------------
-- Local Helper

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
            if tContains(v.seconds, timeOffset) then
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

TriggerHandler.GetRotationCounter = function(rotation)
    if rotation ~= nil then
        if rotation.counter ~= nil then
            return rotation.counter
        else
            return 1
        end
    end
end

TriggerHandler.GetRotationMessages = function(rotation)
    local rotationCounter = TriggerHandler.GetRotationCounter(rotation)
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

TriggerHandler.IncrementRotationCounter = function(rotation)
    local rotationCurrentCount = TriggerHandler.GetRotationCounter(rotation)
    local newCounterValue = rotationCurrentCount + 1
        
    PRT.DebugRotation("Incrementing rotation counter to", rotation.counter)
    rotation.counter = newCounterValue
end 

TriggerHandler.UpdateRotationCounter = function(rotation)
    if rotation ~= nil then
        if rotation.entries ~= nil then
            local rotationCurrentCount = TriggerHandler.GetRotationCounter(rotation)
            local rotationMaxCount = table.getn(rotation.entries)
            if rotationCurrentCount >= rotationMaxCount then
                if rotation.shouldRestart == true then
                    PRT.DebugRotation("Resetting rotation counter to 1")
                    rotation.counter = 1
                else                   
                    TriggerHandler.IncrementRotationCounter(rotation)
                end
            else                
                TriggerHandler.IncrementRotationCounter(rotation)
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
                if targetName then       
                    message.message = message.message:gsub("$target", targetName)
                end
                if sourceName then
                    message.message = message.message:gsub("$source", sourceName)
                end
                if tContains(message.targets, "$target") then
                    message.eventTarget = targetName
                end
                PRT.ExecuteMessage(message)
            end,
            message.delay or 0
        )
    end
end


-------------------------------------------------------------------------------
-- Public API

-- Timer

PRT.CheckTimerStartConditions = function(timers, event, combatEvent, spellID, targetGUID, sourceGUID)   
    if timers ~= nil then
        for i, timer in ipairs(timers) do                     
            if timer.startCondition ~= nil and timer.started ~= true then     
                if TriggerHandler.CheckCondition(timer.startCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
                    PRT.DebugTimer("Started timer `"..(timer.name or "NO NAME").."` at "..GetTime())
                    timer.started = true
                    timer.startedAt = GetTime()
                end
            end
        end
    end
end

PRT.CheckTimerStopConditions = function(timers, event, combatEvent, spellID, targetGUID, sourceGUID)
    if timers ~= nil then
        for i, timer in ipairs(timers) do
            if timer.stopCondition ~= nil and timer.started == true then
                if TriggerHandler.CheckCondition(timer.stopCondition, event, combatEvent, spellID, sourceGUID, targetGUID) then
                    PRT.DebugTimer("Stopped timer `"..(timer.name or "NO NAME").."` at "..GetTime())
                    timer.started = false
                    
                    for i, timing in pairs(timer.timings) do
                        timing.executed = false  
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

-- Rotations
PRT.CheckRotationTriggerCondition = function(rotations, event, combatEvent, eventSpellID, targetGUID, targetName, sourceGUID, sourceName)  
    if rotations ~= nil then
        for i, rotation in ipairs(rotations) do
            if rotation.triggerCondition ~= nil then
                TriggerHandler.CheckStopIgnoreRotationCondition(rotation)
                
                if rotation.ignored ~= true then
                    if TriggerHandler.CheckCondition(rotation.triggerCondition, event, combatEvent, eventSpellID, targetGUID, sourceGUID) then                        
                        local messages = TriggerHandler.GetRotationMessages(rotation)
                        					    
                        TriggerHandler.SendMessagesAfterDelayWithEventInfo(messages, event, combatEvent, eventSpellID, targetName, sourceName)
                        TriggerHandler.UpdateRotationCounter(rotation)
                        rotation.lastActivation = GetTime()
                        if rotation.ignoreAfterActivation == true then
                            rotation.ignored = true
                            PRT.DebugRotation("Started ignoring rotation", rotation.name, "for", rotation.ignoreDuration)
                        end 
                    end
                end     
            end
        end
    end
end

-- Health Percentages
PRT.CheckUnitHealthPercentages = function(percentages)
    if percentages ~= nil then
        for i, percentage in ipairs(percentages) do

            TriggerHandler.CheckStopIgnoreRotationCondition(percentage)

            if percentage.ignored ~= true and percentage.executed ~= true then
                if UnitExists(percentage.unitID) then
                    local unitCurrentHP = UnitHealth(percentage.unitID)
                    local unitMaxHP = UnitHealthMax(percentage.unitID)
                    local unitHPPercent = PRT.Round(unitCurrentHP / unitMaxHP * 100, 0)                
                    local messagesByHP = TriggerHandler.FilterPercentagesTable(percentage.values, unitHPPercent)

                    if messagesByHP then
                        if messagesByHP.messages ~= nil then
                            TriggerHandler.SendMessagesAfterDelay(messagesByHP.messages)
                            
                            percentage.lastActivation = GetTime()
                            if percentage.ignoreAfterActivation == true then
                                percentage.ignored = true
                                PRT.DebugRotation("Started ignoring percentage", percentage.name, "for", percentage.ignoreDuration)
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

PRT.CheckUnitPowerPercentages = function(percentages)
    if percentages ~= nil then
        for i, percentage in ipairs(percentages) do

            TriggerHandler.CheckStopIgnoreRotationCondition(percentage)

            if percentage.ignored ~= true then
                if UnitExists(percentage.unitID) then
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
                                PRT.DebugRotation("Started ignoring percentage", percentage.name, "for", percentage.ignoreDuration)
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
                    table.remove(PRT.MessageQueue, i)
                end
            end
        end
    end
end