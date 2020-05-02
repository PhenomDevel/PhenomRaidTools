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
        delay = 0,
        withSound = true
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
PRT.EmptyPercentageValue = function()
    return {
        value = 50,
        messages = {
            PRT.EmptyMessage()
        }
    }
end

PRT.EmptyPercentage = function()
    return {
        name = "Percentage Name",
        unitID = "player",
        values = {
            PRT.EmptyPercentageValue()
        },
        ignoreAfterActivation = true,
        ignoreDuration = 10
    }
end


-------------------------------------------------------------------------------
-- Encounter

PRT.EmptyEncounter = function()
    return {
        id = "Encounter ID",
        name = "Encounter Name", 
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
        id = 9999,
        name = "Example", 
        Timers = {
            {
                startCondition = {
                    event = "ENCOUNTER_START",
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
                        seconds = 1,
                        messages = {
                            {
                                message = "Message 1 second into the Encounter - %s",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0
                            }
                        }
                    },
                    {
                        seconds = 5,
                        messages = {
                            {
                                message = "Message 5 seconds into the Encounter",
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
                triggerCondition = {
                    event = "SPELL_CAST_START",
                    spellID = 123456,
                    source = nil,
                    target = nil,
                },
                name = "Heal CDs for Ability X",
                entries = {
                    {
                        messages = {
                            {
                                message = "Please use your Heal cooldown",
                                duration = 5,
                                targets = {
                                    "PlayerA"
                                },
                                delay = 0
                            }
                        }
                    },
                    {
                        messages = {
                            {
                                message = "Please use your Heal cooldown",
                                duration = 5,
                                targets = {
                                    "PlayerB"
                                },
                                delay = 0
                            }
                        }
                    },
                    {
                        messages = {
                            {
                                message = "Please use your Heal cooldown",
                                duration = 5,
                                targets = {
                                    "PlayerC"
                                },
                                delay = 0
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
                name = "Phase 2",
                unitID = "boss1",
                values = {
                    {
                        value = 60,
                        messages = {
                            {
                                message = "Phase 2 starting soon",
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
                name = "Players power reaches 90",
                unitID = "player",
                values = {
                    {
                        value = 90,
                        messages = {
                            {
                                message = "Evil Ability is coming soon",
                                duration = 5,
                                targets = {
                                    "ALL"
                                },
                                delay = 0
                            }
                        }
                    }
                },
                ignoreAfterActivation = true,
                ignoreDuration = 10
            }
        }
    }
end