local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Condition

PRT.EmptyCondition = function()
    return {
        event = PRT.db.profile.triggerDefaults.conditionDefaults.defaultEvent,
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
        useCustomSound = false,
        duration = 5,
        targets = {
            "ALL"
        },
        targetOverlay = 1,
        delay = 0
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
        enabled = true,
        startCondition = PRT.EmptyCondition(),
        stopCondition = {},
        hasStopCondition = false,
        counter = 0,        
        triggerAtOccurence = 1,
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
        enabled = true,
        triggerCondition = PRT.EmptyCondition(),
        name = "Rotation Name"..random(0,100000),
        counter = 0,
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
        enabled = true,
        name = "Percentage Name"..random(0,100000),
        unitID = PRT.db.profile.triggerDefaults.percentageDefaults.defaultUnitID,
        values = {
            PRT.EmptyPercentageEntry()
        },
        checkAgain = PRT.db.profile.triggerDefaults.percentageDefaults.defaultCheckAgain,
        checkAgainAfter = PRT.db.profile.triggerDefaults.percentageDefaults.defaultCheckAgainAfter
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
                enabled = true,
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
                name = "Phase 1 Timer",
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
                                delay = 0
                            }
                        }
                    },
                    {
                        seconds = {5},
                        messages = {
                            {
                                message = "Message with raid marker {rt1}",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0
                            }
                        }
                    }
                }
            }
        },

        Rotations = {
            {
                enabled = true,
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
                                message = "You cast {spell:188196}",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0
                            }
                        }
                    }
                },
                shouldRestart = true,
                ignoreAfterActivation = false,
                ignoreDuration = 0
            },
            {
                enabled = false,
                triggerCondition = {
                    event = "SPELL_CAST_SUCCESS",
                    source = nil,
                    target = nil,
                },
                name = "Disabled Rotation",
                entries = {
                    {
                        messages = {
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
                enabled = true,
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
                                delay = 0
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
                enabled = true,
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
                                delay = 0
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