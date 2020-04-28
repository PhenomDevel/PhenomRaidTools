local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

PRT.GetRotationCounter = function(rotation)
    if rotation ~= nil then
        if rotation.counter ~= nil then
            return rotation.counter
        else
            return 1
        end
    end
end

PRT.GetSpellRotationMessages = function(spellRotation)
    local spellRotationCounter = PRT.GetSpellRotationCounter(spellRotation)
    
    if spellRotation ~= nil then
        if spellRotation.rotation ~= nil then
            local messagesByCounter = spellRotation.rotation[spellRotationCounter]         
            
            if messagesByCounter ~= nil then
                return messagesByCounter
            end
        end
    end
end

PRT.IncrementSpellRotationCounter = function(spellRotation)
    local rotationCurrentCount = PRT.GetSpellRotationCounter(spellRotation)
    local newCounterValue = rotationCurrentCount + 1
    
    PRT.Log(PRT.Highlight("[SpellRotation]", PRT.options.colors.spellRotation), "Increment spell rotation ("..(spellRotation.name or "")..")".."counter to `"..newCounterValue.."`")
    spellRotation.counter = newCounterValue
end 

PRT.UpdateSpellRotationCounter = function(spellRotation)
    if spellRotation ~= nil then
        if spellRotation.rotation ~= nil then
            local rotationCurrentCount = PRT.GetSpellRotationCounter(spellRotation)
            local rotationMaxCount = table.getn(spellRotation.rotation)
            
            if rotationCurrentCount >= rotationMaxCount then
                if spellRotation.shouldRestart == true then
                    PRT.Log(PRT.Highlight("[SpellRotation]", PRT.options.colors.spellRotation), "Resetting spell rotation ("..(spellRotation.name or "")..")".."counter to 1")
                    spellRotation.counter = 1
                else
                    PRT.IncrementSpellRotationCounter(spellRotation)
                end
            else
                PRT.IncrementSpellRotationCounter(spellRotation)
            end
        end
    end
end

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

PRT.CheckTimerStartConditions = function(timers, event, combatEvent, spellID, targetGUID, sourceGUID)   
    if timers ~= nil then
        for i, timer in ipairs(timers) do                     
            if timer.startCondition ~= nil and timer.started ~= true then     
                if PRT.CheckCondition(timer.startCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
                    PRT:Print("[Timer]", "Started timer `"..(timer.name or "NO NAME").."` at "..GetTime())
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
                    PRT:Print("[Timer]", "Stopped timer `"..(timer.name or "NO NAME").."` at "..GetTime())
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
            print(v.seconds, timeOffset, v.seconds == timeOffset)
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
                        -- PRT.ExecuteMessages(messagesByTime)   
                        PRT.AddMessagesToQueue(messagesByTime)
                        PRT:Print("CheckTimerTimings - Execute Messages")                     
                        messagesByTime.executed = true
                    end
                end
            end
        end
    end
end

PRT.CheckStopIgnore = function(spellRotation)
    if spellRotation.ignoreAfterActivation and spellRotation.ignored == true then
        if ((spellRotation.lastActivation or 0) + (spellRotation.ignoreDuration or 5)) < GetTime() then
            spellRotation.ignored = false
            PRT.Log(PRT.Highlight("[SpellRotation]", PRT.options.colors.spellRotation), "Stopped ignoring spell rotation")
        end 
    end  
end 

PRT.CheckSpellRotationTriggerCondition = function(spellRotations, event, combatEvent, spellID, targetGUID, sourceGUID)
    if spellRotations ~= nil then
        for i, spellRotation in ipairs(spellRotations) do
            if spellRotation.triggerCondition ~= nil then
                PRT.CheckStopIgnore(spellRotation)
                if spellRotation.ignored ~= true then
                    if PRT.CheckCondition(spellRotation.triggerCondition, event, combatEvent, spellID, targetGUID, sourceGUID) then
                        local messages = PRT.GetSpellRotationMessages(spellRotation)
                        
                        PRT.AddMessagesToQueue(messages)
                        PRT.UpdateSpellRotationCounter(spellRotation)
                        spellRotation.lastActivation = GetTime()
                        if spellRotation.ignoreAfterActivation == true then
                            spellRotation.ignored = true
                            PRT.Log(PRT.Highlight("[SpellRotation]", PRT.options.colors.spellRotation), "Started ignoring spell rotation")
                        end 
                    end
                end     
            end
        end
    end
end

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