local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Helper

PRT.CheckCondition = function(condition, event, combatEvent, spellID, sourceGUID, targetGUID)
    if condition ~= nil then
        if condition.event == event or condition.event == combatEvent then
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


-------------------------------------------------------------------------------
-- Timer

PRT.CheckTimerStartConditions = function(timers, event, combatEvent, spellID, targetGUID, sourceGUID)   
    if timers ~= nil then
        for i, timer in ipairs(timers) do                     
            if timer.startCondition ~= nil and timer.started ~= true then     
                if PRT.CheckCondition(timer.startCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
                    PRT:DebugTimer("Started timer `"..(timer.name or "NO NAME").."` at "..GetTime())
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
                if PRT.CheckCondition(timer.stopCondition, event, combatEvent, spellID, sourceGUID, targetGUID) then
                    PRT:DebugTimer("Stopped timer `"..(timer.name or "NO NAME").."` at "..GetTime())
                    timer.started = false
                    
                    for i, timing in pairs(timer.timings) do
                        timing.executed = false  
                    end   
                end
            end
        end
    end
end

PRT.FilterTimingsTable = function(timings, timeOffset)
    local value
    if timings then
        for i, v in ipairs(timings) do
            if v.seconds == timeOffset then
                if not value then
                    value = v
                end
            end
        end
    end
    return value
end

PRT.CheckTimerTimings = function(timers)
    local currentTime = GetTime()    
    if timers ~= nil then
        for i, timer in ipairs(timers) do
            if timer.started == true and timer.timings ~= nil then                
                local elapsedTime = PRT.Round(currentTime - timer.startedAt)
                local timings = timer.timings
                local timingByTime = PRT.FilterTimingsTable(timings, elapsedTime)
                
                if timingByTime then
                    local messagesByTime = timingByTime.messages
                    if messagesByTime ~= nil and messagesByTime.executed ~= true then
                        PRT.AddMessagesToQueue(messagesByTime)
                        PRT:DebugTimer("Adding", table.getn(messagesByTime), "messages to message queue")                  
                        messagesByTime.executed = true
                    end
                end
            end
        end
    end
end


-------------------------------------------------------------------------------
-- Rotations

PRT.GetRotationCounter = function(rotation)
    if rotation ~= nil then
        if rotation.counter ~= nil then
            return rotation.counter
        else
            return 1
        end
    end
end

PRT.GetRotationMessages = function(rotation)
    local rotationCounter = PRT.GetRotationCounter(rotation)
    if rotation ~= nil then
        if rotation.entries ~= nil then
            local messagesByCounter = rotation.entries[rotationCounter]         

            if messagesByCounter.messages ~= nil then
                return messagesByCounter.messages
            end
        end
    end
end

PRT.IncrementRotationCounter = function(rotation)
    local rotationCurrentCount = PRT.GetRotationCounter(rotation)
    local newCounterValue = rotationCurrentCount + 1
    
    --PRT.Log(PRT.Highlight("[SpellRotation]", PRT.options.colors.spellRotation), "Increment spell rotation ("..(spellRotation.name or "")..")".."counter to `"..newCounterValue.."`")
    rotation.counter = newCounterValue
end 

PRT.UpdateRotationCounter = function(rotation)
    if rotation ~= nil then
        if rotation.entries ~= nil then
            local rotationCurrentCount = PRT.GetRotationCounter(rotation)
            local rotationMaxCount = table.getn(rotation.entries)
            if rotationCurrentCount >= rotationMaxCount then
                if rotation.shouldRestart == true then
                    PRT:DebugRotation("Resetting rotation counter to 1")
                    rotation.counter = 1
                else                   
                    PRT.IncrementRotationCounter(rotation)
                    PRT:DebugRotation("Incrementing rotation counter to", rotation.counter)
                end
            else                
                PRT.IncrementRotationCounter(rotation)
                PRT:DebugRotation("Incrementing rotation counter to", rotation.counter)
            end
        end
    end
end

PRT.CheckStopIgnoreRotationCondition = function(rotation)
    if rotation.ignoreAfterActivation and rotation.ignored == true then
        if ((rotation.lastActivation or 0) + (rotation.ignoreDuration or 5)) < GetTime() then
            rotation.ignored = false
            PRT:DebugRotation("Stopped ignoring rotation", rotation.name)
        end 
    end 
end

PRT.CheckRotationTriggerCondition = function(rotations, event, combatEvent, spellID, targetGUID, sourceGUID)  
    if rotations ~= nil then
        for i, rotation in ipairs(rotations) do
            if rotation.triggerCondition ~= nil then
                PRT.CheckStopIgnoreRotationCondition(rotation)
                
                if rotation.ignored ~= true then
                    if PRT.CheckCondition(rotation.triggerCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then                        
                        local messages = PRT.GetRotationMessages(rotation)
                        PRT.AddMessagesToQueue(messages)

                        PRT:DebugRotation("Rotation trigger condition met")
                        PRT:DebugRotation("Adding", table.getn(messages), "messages to message queue")

                        PRT.UpdateRotationCounter(rotation)
                        rotation.lastActivation = GetTime()
                        if rotation.ignoreAfterActivation == true then
                            rotation.ignored = true
                            PRT:DebugRotation("Started ignoring rotation", rotation.name, "for", rotation.ignoreDuration)
                        end 
                    end
                end     
            end
        end
    end
end


-------------------------------------------------------------------------------
-- Percentages

PRT.CheckUnitHealthTrackers = function(unitHealthTrackers)
    if unitHealthTrackers ~= nil then
        for i, unitHealthTracker in ipairs(unitHealthTrackers) do
            if UnitExists(unitHealthTracker.unitID) then
                local unitCurrentHP = UnitHealth(unitHealthTracker.unitID)
                local unitMaxHP = UnitHealthMax(unitHealthTracker.unitID)
                local unitHPPercent = PRT.Round(unitCurrentHP / unitMaxHP * 100, 0)                
                local messagesByHP = unitHealthTracker.hpValues[unitHPPercent]
                
                if messagesByHP ~= nil and not messagesByHP.executed == true then
                    PRT.AddMessagesToQueue(messagesByHP)
                    messagesByHP.executed = true             
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