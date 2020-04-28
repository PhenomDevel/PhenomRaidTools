local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


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