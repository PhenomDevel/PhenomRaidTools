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
-- Message

PRT.EmptyMessage = function()
    return {
        message = "TODO",
        duration = 5,
        targets = {
            "ALL"
        },
        delay = 0
    }
end


-------------------------------------------------------------------------------
-- Timer

PRT.EmptyTiming = function()
    return {
        seconds = 1,
        messages = {
            PRT.EmptyMessage()
        }
    }
end

PRT.EmptyTimer = function()
    return {
        startCondition = PRT.EmptyCondition(),
        stopCondition = PRT.EmptyCondition(),
        name = "Timer Name",
        timings = {
            PRT.EmptyTiming()
        }
    }
end


-------------------------------------------------------------------------------
-- Rotation

PRT.EmptyRotationEntry = function()
    return {
        messages = {
            PRT.EmptyMessage()
        }
    }
end

PRT.EmptyRotation = function()
    return {
        triggerCondition = PRT.EmptyCondition(),
        name = "Rotation Name",
        entries = {
            PRT.EmptyRotationEntry()
        },
        shouldRestart = true,
        ignoreAfterActivation = false,
        ignoreDuration = 0
    }
end


-------------------------------------------------------------------------------
-- Percentage

PRT.EmptyPercentage = function()
    return {
        name = "Percentage Name",
        unitID = "player",
        values = {
            {
                value = 50,
                messages = {
                    PRT.EmptyMessage()
                }
            }
        }
    }
end


-------------------------------------------------------------------------------
-- Encounter

PRT.EmptyEncounter = function()
    return {
        id = "Encounter ID",
        name = "Encounter Name", 
        Timers = {
            PRT.EmptyTimer()
        },

        Rotations = {

        },

        Percentages = {

        }
    }
end