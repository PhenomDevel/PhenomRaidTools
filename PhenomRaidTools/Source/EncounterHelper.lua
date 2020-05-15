local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Condition

PRT.EmptyCondition = function()
    return {
        event = "PLAYER_REGEN_DISABLED",
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
        delay = 0,
        withSound = PRT.db.profile.triggerDefaults.messageDefaults.defaultWithSound
    }
end


-------------------------------------------------------------------------------
-- Timer

PRT.EmptyTiming = function()
    return {
        seconds = {1},
        messages = {
            PRT.EmptyMessage()
        }
    }
end

PRT.EmptyTimer = function()
    return {
        startCondition = PRT.EmptyCondition(),
        stopCondition = PRT.EmptyCondition(),
        name = "Timer Name"..random(0,100000),
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
        name = "Rotation Name"..random(0,100000),
        entries = {
            PRT.EmptyRotationEntry()
        },
        shouldRestart = PRT.db.profile.triggerDefaults.rotationDefaults.defaultShouldRestart,
        ignoreAfterActivation = PRT.db.profile.triggerDefaults.rotationDefaults.defaultIgnoreAfterActivation,
        ignoreDuration = PRT.db.profile.triggerDefaults.rotationDefaults.defaultIgnoreDuration
    }
end


-------------------------------------------------------------------------------
-- Percentage

PRT.EmptyPercentageEntry = function()
    return {
        value = 50,
        operator = "equals",
        messages = {
            PRT.EmptyMessage()
        }
    }
end

PRT.EmptyPercentage = function()
    return {
        name = "Percentage Name"..random(0,100000),
        unitID = "boss1",
        values = {
            PRT.EmptyPercentageEntry()
        },
        ignoreAfterActivation = PRT.db.profile.triggerDefaults.percentageDefaults.defaultIgnoreAfterActivation,
        ignoreDuration = PRT.db.profile.triggerDefaults.percentageDefaults.defaultIgnoreDuration
    }
end


-------------------------------------------------------------------------------
-- Encounter

PRT.EmptyEncounter = function()
    return {
        enabled = true,
        id = random(0,100000),
        name = "Encounter Name"..random(0,100000), 
        Timers = {
        },

        Rotations = {
        },

        HealthPercentages = {
        },

        PowerPercentages = {
        }
    }
end

PRT.ExampleEncounter = function()
    return {
        enabled = true,
        id = 9999,
        name = "Example", 
        Timers = {
            {
                startCondition = {
                    event = "PLAYER_REGEN_DISABLED",
                    spellID = nil,
                    source = nil,
                    target = nil,
                },
                stopCondition = {
                    event = nil,
                    spellID = nil,
                    source = nil,
                    target = nil,
                },
                name = "Timer Name",
                timings = {
                    {
                        seconds = {1, 7},
                        messages = {
                            {
                                message = "Message 1 and 7 seconds into Encounter",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0,
                                withSound = true
                            }
                        }
                    },
                    {
                        seconds = {5},
                        messages = {
                            {
                                message = "Message 5 seconds into the Encounter",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0,
                                withSound = true
                            }
                        }
                    }
                }
            }
        },

        Rotations = {
            {
                triggerCondition = {
                    event = "SPELL_CAST_START",
                    spellID = 188196,
                    spellIcon = 136048,
                    spellName = "Lightning Bolt",
                    source = nil,
                    target = nil,
                },
                name = "Lightning Bolt Cast started",
                entries = {
                    {
                        messages = {
                            {
                                message = "You started casting Lightning Bolt",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0,
                                withSound = true
                            }
                        }
                    }
                },
                shouldRestart = true,
                ignoreAfterActivation = false,
                ignoreDuration = 0
            }
        },

        HealthPercentages = {
            {
                name = "Above 60 %",
                unitID = "player",
                values = {
                    {
                        value = 60,
                        operator = "greater",
                        messages = {
                            {
                                message = "You are above 60%% HP",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0,
                                withSound = true
                            }
                        }
                    }
                },
                ignoreAfterActivation = false,
                ignoreDuration = nil
            }
        },

        PowerPercentages = {
            {
                name = "Above 90% Power",
                unitID = "player",
                values = {
                    {
                        value = 90,
                        operator = "greater",
                        messages = {
                            {
                                message = "You are above 90%% Power",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0,
                                withSound = true
                            }
                        }
                    }
                },
                ignoreAfterActivation = false,
                ignoreDuration = nil
            }
        }
    }
end