local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

function PRT:NewCondition(event, spellID, target, source)
    if event == nil then
        self:Print("[NewCondition] `event` should not be empty! -- skipping condition")
        
        return {}
    else
        local condition = {
            event = event
        }
        
        if spellID ~= nil then
            condition.spellID = spellID
        end
        
        if target ~= nil then
            condition.target = target
        end
        
        if source ~= nil then
            condition.source = source
        end
        
        return condition
    end
end

function PRT:AddEmptyTiming(timings)
    local timing = {
        timeIntoTimer = nil,
        messages = {
            {}
        }
    }

    table.insert(timings, timing)
end

function PRT:AddNewTimer(encounter, name, startCondition, stopCondition, timings)
    local timer = {
        startCondition = startCondition,
        stopCondition = stopCondition,
        name = name,
        timings = timings,
        type = "TIMER"
    }

    if stopCondition == nil then
        timer.stopCondition = PRT:NewCondition()
    end
    
    if encounter.Timers == nil then
        encounter.Timers = {}
    end
    
    encounter.Timers[name] = timer
    table.insert(encounter.Timers, timer)
    return encounter
end

function PRT:AddNewUnitHealthTracker(encounter, name, unitID, hpValues)
    local hpTracker = {
        unitID = unitID,
        hpValues = hpValues,
        name = name
    }
    
    if encounter.UnitHealthTrackers == nil then
        encounter.UnitHealthTrackers = {}
    end
    
    encounter.UnitHealthTrackers[name] = hpTracker
    table.insert(encounter.UnitHealthTrackers, hpTracker)
    return encounter
end

function PRT:AddNewSpellRotation(encounter, name, triggerCondition, shouldRestart, rotation, ignoreAfterActivation, ignoreDuration)
    local spellRotation = {
        triggerCondition = triggerCondition,
        name = name,
        rotation = rotation,
        type = "SPELL_ROTATION",
        shouldRestart = shouldRestart,
        ignoreAfterActivation = ignoreAfterActivation or false,
        ignoreDuration = ignoreDuration or 5
    }
    
    if encounter.SpellRotations == nil then
        encounter.SpellRotations = {}
    end
    
    encounter.SpellRotations[name] = spellRotation
    table.insert(encounter.SpellRotations, spellRotation)
    return encounter
end

function PRT:NewEncounter(encounterName, id)
    local encounter = {
        Timers = {},
        SpellRotations = {},
        UnitHealthTrackers = {},
        name = encounterName,
        id = 42
    }

    return encounter
end

function PRT:Message(targets, message, timer, delay)
    if targets == nil or message == nil then
        return nil
    end
    
    local targetTable = nil
    
    if type(targets) ~= "table" then
        targetTable = {targets}
    else
        targetTable = targets
    end
    
    local message = {
        message = message,
        timer = timer or 5,
        targets = targetTable,
        delay = delay or 0
    }
    
    --if PhenomRaidTools.options.alwaysSendToRaidlead == true and PhenomRaidTools.options.raidlead ~= nil then
    --    table.insert(message.targets, PhenomRaidTools.options.raidlead)
    --end
    
    return message
end




PRT.NewEncounter = function(name)
end




-------------------------------------------------------------------------------
-- Condition

PRT.EmptyCondition = function()
    return {
        event = "ENCOUNTER_START",
        spellID = nil,
        source = nil,
        target = nil,
    }
end


-------------------------------------------------------------------------------
-- Timing

PRT.EmptyTiming = function()
    return {
        seconds = 1,
        messages = {
            PRT.EmptyMessage()
        }
    }
end


-------------------------------------------------------------------------------
-- Message

PRT.EmptyMessage = function()
    return {
        message = "TODO",
        duration = 5,
        targets = {
            "TODO"
        },
        delay = 0
    }
end


-------------------------------------------------------------------------------
-- Timer

PRT.EmptyTimer = function()
    return {
        startCondition = PRT.EmptyCondition(),
        stopCondition = PRT.EmptyCondition(),
        name = "TODO",
        timings = {
            PRT.EmptyTiming()
        }
    }
end


-------------------------------------------------------------------------------
-- Rotation

PRT.EmptyRotation = function()
    return {
        triggerCondition = PRT.EmptyCondition(),
        name = "TODO",
        rotation = {

        },
        shouldRestart = true,
        ignoreAfterActivation = false,
        ignoreDuration = 0
    }
end

-------------------------------------------------------------------------------
-- Percentage

-------------------------------------------------------------------------------
-- Encounter

PRT.EmptyEncounter = function()
    return {
        id = "TODO",
        name = "TODO", 
        Timers = {
            PRT.EmptyTimer()
        },

        Rotations = {

        },

        Percentages = {

        }
    }
end