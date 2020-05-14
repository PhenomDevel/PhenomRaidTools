local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Strings

local Strings = {

    -- Options
    optionsHeading = {
        text = "Global Options"
    },
    optionsTestMode = {
        text = "Test mode"
    },
    optionsDebugMode = {
        text = "Debug mode",
        tooltip = {
            "If enabled the addon will print a whole lot of information in the default chat frame."
        }
    },
    optionsTestEncounterID = {
        text = "Test encounter",
        tooltip = "Choose the encounter you want to test"
    },
    optionsEnabledDifficulties = {
        text = "Enabled difficulties"
    },
    optionsShowOverlay = {
        text = "Show overlay"
    },
    optionsHideOverlayAfterCombat = {
        text = "Hide overlay after combat"
    },
    optionsDifficultyExplanation = {
        text = "Set the difficulties on which the addon should start tracking combat events"
    },
    optionsDefaultsExplanation = {
        text = "Set some default values for all new messages, timers, percentages and so on."
    },
    optionsRaidRosterExplanation = {
        text = "Here you can define player names and reference them as `targets` in message with e.g. `$tank1`, `$heal3` etc."
    },

    -- dungeon
    dungeonHeading = {
        text = "Dungeon"
    },
    dungeonDifficultyNormal = {
        text = "Normal"
    },
    dungeonDifficultyHeroic = {
        text = "Heroic"
    },
    dungeonDifficultyMythic = {
        text = "Mythic"
    },
    raidHeading = {
        text = "Raid"
    },
    raidDifficultyNormal = {
        text = "Normal"
    },
    raidDifficultyHeroic = {
        text = "Heroic"
    },
    raidDifficultyMythic = {
        text = "Mythic"
    },

    triggerDefaults = {
        text = "Configuration (Default values)"
    },
    rotationDefaults = {
        text = "Rotation"
    },
    percentageDefaults = {
        text = "Percentages"
    },
    messageDefaults = {
        text = "Message"
    },
    defaultIgnoreAfterActivation = {
        text = "Ignore after activation"
    },
    defaultShouldRestart = {
        text = "Should restart"
    },
    defaultIgnoreDuration = {
        text = "Ignore duration"
    },
    defaultWithSound = {
        text = "Activate sound on receiver"
    },
    defaultEvent = {
        text = "Event"
    },
    additionalEvents = {
        text = "Additional events",
        tooltip = "Comma separated list of events you want to use within the conditions (e.g. SPELL_CAST_FAILED)"
    },
    conditionDefaults = {
        text = "Condition"
    },

    -- Messages
    messageHeading = {
        text = "Messages"
    },
    messageDeleteButton = {
        text = "Delete Message"
    },
    messageWithSound = {
        text = "Activate sound on receiver"
    },    
    messageTargets = {
        text = "Targets",
        tooltip = {
            "Comma separated list of targets",
            "(e.g. ALL, HEALER, TANK, DAMAGER, $playerName)",
            "Use |cFFFFFFFF$target|r to send the message to the spell target (only works for rotations)"
        }
    },
    messageMessage = {
        text = "Message",
        tooltip = {              
            "- Use |cFFFFFFFF%s|r to display the countdown",
            "- Use |cFFFFFFFF$source|r or |cFFFFFFFF$target|r to display the source/target of the event (only works for rotations)",
            "- Do not use reserved characters (#, ?, ~, %)"
        }
    },
    messageDelay = {
        text = "Delay (s)",
        tooltip = "After how many seconds the message should be send to the receiver?"
    },
    messageDuration = {
        text = "Duration (s)",
        tooltip = "For how long should the message be displayed?"
    },

    -- Rotations
    rotationHeading = {
        text = "Rotations"
    },
    rotationName = {
        text = "Name"
    },
    rotationDeleteButton = {
        text = "Delete Rotation"
    },
    rotationShouldRestart = {
        text = "Should trigger restart?"
    },
    rotationIgnoreAfterActivation = {
        text = "Ignore after activation?"
    },
    rotationIgnoreDuration = {
        text = "Ignore trigger for (s)"
    },
    rotationTriggerConditionHeading = {
        text = "Rotation Trigger"
    },
    rotationOptionsHeading = {
        text = "Rotation Options"
    },
    rotationTriggerConditionHeading = {
        text = "Condition"
    },
    

    -- RotationEntries
    rotationEntryHeading = {
        text = "Rotation Entries"
    },
    rotationEntryDeleteButton = {
        text = "Delete Rotation Entry"
    },

    -- Percentages
    percentageDeleteButton = {
        text = "Delete Percentage"
    },
    percentageName = {
        text = "Name"
    },
    percentageUnitID = {
        text = "Unit-ID",
        tooltip = "Unit-ID which percentage should be tracked (boss1, player, PlayerName etc.)"
    },
    percentageCheckAgain = {
        text = "Check multiple times?"
    },
    percentageCheckDelay = {
        text = "Check again after (s)"
    },
    percentageOptionsHeading = {
        text = "Percentage Options"
    },

    -- Percentage Entries
    percentageEntryDeleteButton = {
        text = "Delete Percentage Entry"
    },
    percentageEntryPercent = {
        text = "Percentage (%)"
    },
    percentageEntryOperatorDropdown = {
        text = "Operator"
    },
    percentageEntryOptionsHeading = {
        text = "Percentage Entry Options"
    },
    
    -- Encounters
    encounterHeading = {
        text = "Encounter Options"
    },
    encounterTriggerHeading = {
        text = "Trigger"
    },
    encounterImport = {
        text = "Import Encounter"
    },
    encounterExport = {
        text = "Export Encounter"
    },
    encounterID = {
        text = "Encounter-ID",
        tooltip = {
            "Ny'alotha, the Waking City",
            "2329 - Wrathion",
            "2327 - Maut",
            "2334 - The Prophet Skitra",
            "2328 - Dark Inquisitor Xanesh",
            "2333 - The Hivemind",
            "2335 - Shad'har the Insatiable",
            "2343 - Drest'agath",
            "2345 - Il'gynoth, Corruption Reborn",
            "2336 - Vexiona",
            "2331 - Ra-den the Despoiled",
            "2337 - Carapace of N'Zoth",
            "2344 - N'Zoth the Corruptor"
        }
    },
    encounterName = {
        text = "Name"
    },
    encounterDeleteButton = {
        text = "Delete Encounter"
    },
    encounterOptionsHeading = {
        text = "Encounter Options"
    },
    encounterEnabled = {
        text = "Enabled"
    },

    -- Conditions
    conditionEvent = {
        text = "Event",
        tooltip = "Combat event on which the condition should trigger"
    },
    conditionSpellID = {
        text = "Spell-ID",
        tooltip = "Combat spell-ID on which the condition should trigger (Can be empty)"
    },
    conditionTarget = {
        text = "Target",
        tooltip = "The combat target of the event/spell-id combination on which the condition should trigger (Can be empty)"
    },
    conditionSource = {
        text = "Source",
        tooltip = "The combat source of the event/spell-id combination on which the condition should trigger (Can be empty)"
    },
    conditionHeading = {
        text = "Condition"
    },
    
    -- Timers
    timerName = {
        text = "Name"
    },
    timerDeleteButton = {
        text = "Delete Timer"
    },
    timerOptionsHeading = {
        text = "Timer Options"
    },

    -- Timings
    timingSeconds = {
        text = "Trigger Times",
        tooltip = "Times at which this trigger should be executed (comma separated list of seconds e.g. 1, 5, 20)"
    },
    timingDeleteButton = {
        text = "Delete Timing"
    },
    timingOptionsHeading = {
        text = "Timing Options"
    }
}


-------------------------------------------------------------------------------
-- Public API

Strings.GetText = function(s)
    if Strings[s] then
        if Strings[s].text then
            return Strings[s].text
        else
            PRT.Debug("No String found for:", s)
            return s
        end
    else
        return s
    end
end

Strings.GetTooltip = function(s)
    if Strings[s] then
        if Strings[s].tooltip then
            return Strings[s].tooltip
        else
            PRT.Debug("No Tooltip found for:", s)
            return s
        end
    else
        return s
    end
end

PRT.Strings = Strings