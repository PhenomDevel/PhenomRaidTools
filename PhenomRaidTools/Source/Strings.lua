local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Strings = {}
PRT.Strings = Strings


-------------------------------------------------------------------------------
-- Public API

PRT.InitializeStrings = function()
    Strings = {

        mainWindowTitle = {},

        -- Options
        runModeDropdown = {},
        optionsTestMode = {},
        optionsDebugMode = {
            tooltip = L["optionsDebugModeTooltip"]
        },
        optionsTestEncounterID = {
            text = "Test encounter",
            tooltip = "Choose the encounter you want to test"
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
            text = "Here you can define player names and reference them as "..PRT.HighlightString("targets").." in message with e.g. "..PRT.HighlightString("$tank2")..", "..PRT.HighlightString("$heal1").." etc."
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
        defaultCheckAgain = {
            text = "Check multiple times"
        },
        defaultCheckAgainAfter = {
            text = "Check again after (s)"
        },
        additionalEvents = {
            text = "Additional events",
            tooltip = "Comma separated list of events you want to use within the conditions (e.g. "..PRT.HighlightString("SPELL_CAST_FAILED")..")"
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
                "Examples:",
                "- "..PRT.HighlightString("$me").." -> Will be exchanged with the current characters name",
                "- "..PRT.HighlightString("$target").." -> Will be exchanged with the target of the event",
                "- "..PRT.HighlightString("$healN").." or "..PRT.HighlightString("$tankN").." or "..PRT.HighlightString("$ddN").." -> N is a number between 1-21. Will be exchanged with the configured raid roster name.",
                "- "..PRT.HighlightString("ALL")..", "..PRT.HighlightString("HEALER")..", "..PRT.HighlightString("TANK")..", "..PRT.HighlightString("DAMAGER").."",
            }
        },
        messageMessage = {
            text = "Message",
            tooltip = {              
                "- Use "..PRT.HighlightString("%s").." to display the countdown",
                "- You can use tokens which will be replaced within the message e.g. "..PRT.HighlightString("$source")..", "..PRT.HighlightString("$target")..", "..PRT.HighlightString("$heal1")..", "..PRT.HighlightString("$me"),
                "- Do not use reserved characters ("..PRT.HighlightString("#")..", "..PRT.HighlightString("?")..", "..PRT.HighlightString("~")..", "..PRT.HighlightString("%")..")"
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
        messageRaidRosterAddDropdown = {
            text = "Select additional target entry",
            tooltip = "You can add a reference of your configured raid roster. It will always add the reference *not* the player name in the targets."
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
        percentageCheckAgainAfter = {
            text = "Check again after (s)"
        },
        percentageCheckAgain = {
            text = "Check multiple times"
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
        encounterOverview = {
            text = "Trigger Overview"
        },
        timerOverview = {
            text = "Timers"
        },
        rotationOverview = {
            text = "Rotations"
        },
        healthPercentageOverview = {
            text = "Health Percentages"
        },
        powerPercentageOverview = {
            text = "Power Percentages"
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
        },


        -- Overlay
        senderGroup = {
            text = "Sender"
        },
        receiverGroup = {
            text = "Receiver"
        },
        overlayFontColor = {
            text = "Font color"
        },
        overlayFontSize = {
            text = "Font size"
        },
        overlayBackdropColor = {
            text = "Backdrop color"
        },
        overlayLocked = {
            text = "Locked"
        },
        overlayEnableSound = {
            text = "Enable sounds"
        },

        deleteTimer = {
            text = "Delete Timer"
        },
        deleteRotation = {
            text = "Delete Rotation"
        },
        deletePercentage = {
            text = "Delete Percentage"
        },
        deleteEncounter = {
            text = "Delete Encounter"
        },
        exportEncounter = {
            text = "Export Encounter"
        },
        importEncounter = {
            text = "Import Encounter"
        },
        newEncounter = {
            text = "New Encounter"
        },
        newTimer = {
            text = "New Timer"
        },
        newRotation = {
            text = "New Rotation"
        },
        newHealthPercentage = {
            text = "New Health Percentage"
        },
        newPowerPercentage = {
            text = "New Power Percentage"
        },
    }
end

PRT.Strings.GetText = function(s)
    if s then
        if Strings[s] then
            if Strings[s].text then
                return Strings[s].text
            else
                if L[s] then
                    return L[s]
                else
                    PRT.Error("String entry found but no text specified for:", s)
                    return s
                end
            end
        else
            return s
        end
    end
end

PRT.Strings.GetTooltip = function(s)
    if s then
        if Strings[s] then
            if Strings[s].tooltip then
                return Strings[s].tooltip
            else
                PRT.Error("String entry found but no tooltip specified for:", s)
                return s
            end
        else
            return s
        end
    end
end