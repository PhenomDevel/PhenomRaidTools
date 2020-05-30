L = {
    ["sender"] = "Sender",
    ["receiver"] = "Receiver",
    ["sender+receiver"] = "Sender & Receiver",

    ["mainWindowTitle"] = "PhenomRaidTools",
    ["runModeDropdown"] = "Run mode",

    -- Options
    ["optionsTabGeneral"] = "General",
    ["optionsTabDifficulties"] = "Difficulties",
    ["optionsTabDefaults"] = "Trigger defaults",
    ["optionsTabRaidRoster"] = "Raid roster",
    ["optionsTabOverlays"] = "Overlays",

    ["optionsTestMode"] = "Test mode",
    ["optionsDebugMode"] = "Debug mode",
    ["optionsDebugModeTooltip"] = "If this mode is active PRT will print debug information to the default chat frame",
    ["optionsTestEncounterID"] = "Test encounter",
    ["optionsTestEncounterIDTooltip"] = "Choose the encounter you want to test",
    ["optionsShowOverlay"] = "Show overlay",
    ["optionsHideOverlayAfterCombat"] = "Hide overlay after combat",
    ["optionsDifficultyExplanation"] = "Set the difficulties on which the addon should start tracking combat events",
    ["optionsDefaultsExplanation"] = "Set some default values for all new messages, timers, percentages and so on.",
    ["optionsRaidRosterExplanation"] = "Here you can define player names and reference them as targets in message with e.g. |cFF69CCF0$tank2|r, |cFF69CCF0$heal1|r etc.",
    ["dungeonHeading"] = "Dungeon",
    ["dungeonDifficultyNormal"] = "Normal",
    ["dungeonDifficultyHeroic"] = "Heroic",   
    ["dungeonDifficultyMythic"] = "Mythic",
    ["raidHeading"] = "Raid",
    ["raidDifficultyNormal"] = "Normal",
    ["raidDifficultyHeroic"] = "Heroic",
    ["raidDifficultyMythic"] = "Mythic",

    -- Tree
    ["treeOptions"] = "Options",
    ["treeEncounters"] = "Encounters",
    ["treeTimer"] = "Timers",
    ["treeRotation"] = "Rotations",
    ["treeHealthPercentage"] = "Health Percentages",
    ["treePowerPercentage"] = "Power Percentages",

    -- Defaults
    ["rotationDefaults"] = "Rotation",
    ["percentageDefaults"] = "Percentages",
    ["messageDefaults"] = "Message",
    ["defaultShouldRestart"] = "Ignore after activation",
    ["defaultIgnoreDuration"] = "Should restart",
    ["defaultIgnoreAfterActivation"] = "Ignore duration",
    ["defaultWithSound"] = "Activate sound on receiver",
    ["defaultEvent"] = "Event",
    ["defaultCheckAgain"] = "Check multiple times",
    ["defaultCheckAgainAfter"] = "Check again after (s)",
    ["additionalEvents"] = "Additional events",
    ["additionalEventsTooltip"] = "Comma separated list of events you want to use within the conditions (e.g. SPELL_CAST_FAILED)",
    ["conditionDefaults"] = "Condition",

    -- Raid Roster
    ["raidRosterTanksHeading"] = "Tanks",
    ["raidRosterHealerHeading"] = "Healer",
    ["raidRosterDDHeading"] = "DDs",
    
    -- Messages
    ["messagePreview"] = "Preview: ",
    ["messageHeading"] = "Messages",
    ["messageDeleteButton"] = "Delete Message",
    ["messageWithSound"] = "Activate sound on receiver",
    ["messageTargets"] = "Targets",
    ["messageTargetsTooltip"] =
        "Comma separated list of targets\n"..
        "Examples:\n"..
        "- |cFF69CCF0$me|r -> Will be exchanged with the current characters name\n"..
        "- |cFF69CCF0$target|r -> Will be exchanged with the target of the event\n"..
        "- |cFF69CCF0$healN|r or |cFF69CCF0$tankN|r or |cFF69CCF0$ddN|r -> N is a number between 1-21. Will be exchanged with the configured raid roster name.\n"..
        "- |cFF69CCF0ALL|r, |cFF69CCF0HEALER|r, |cFF69CCF0TANK|r, |cFF69CCF0DAMAGER|r\n",
    ["messageMessage"] = "Message",
    ["messageMessageTooltip"] =          
        "- Use |cFF69CCF0%.0f|r or |cFF69CCF0%s|r to display the countdown (1 can also change to 0-2 for decimals)\n"..
        "- You can use tokens which will be replaced within the message e.g. |cFF69CCF0$source|r, |cFF69CCF0$target|r, |cFF69CCF0$heal1|r, |cFF69CCF0$me|r\n"..
        "- Do not use reserved characters (|cFF69CCF0#|r, |cFF69CCF0?|r, |cFF69CCF0~|r, |cFF69CCF0%|r)",
    ["messageDelay"] = "Delay (s)",
    ["messageDelayTooltip"] = "After how many seconds the message should be send to the receiver?",
    ["messageDuration"] = "Duration (s)",
    ["messageDurationTooltip"] = "For how long should the message be displayed?",
    ["messageRaidRosterAddDropdown"] = "Select additional target entry",
    ["messageRaidRosterAddDropdownTooltip"] = "You can add a reference of your configured raid roster. It will always add the reference *not* the player name in the targets.",

    -- Rotations
    ["rotationEnabled"] = "Enabled",
    ["rotationHeading"] = "Rotations",
    ["rotationName"] = "Name",
    ["rotationDeleteButton"] = "Delete Rotation",
    ["rotationShouldRestart"] = "Should trigger restart?",
    ["rotationIgnoreAfterActivation"] = "Ignore after activation?",
    ["rotationIgnoreDuration"] = "Ignore trigger for (s)",
    ["rotationTriggerConditionHeading"] = "Rotation Trigger",
    ["rotationOptionsHeading"] = "Rotation Options",
    ["rotationTriggerConditionHeading"] = "Condition",

    -- RotationEntries
    ["rotationEntryHeading"] = "Rotation Entries",
    ["rotationEntryDeleteButton"] = "Delete Rotation Entry",

    -- Percentages
    ["percentageEnabled"] = "Enabled",
    ["percentageDeleteButton"] = "Delete Percentage",
    ["percentageName"] = "Name",
    ["percentageUnitID"] = "Unit-ID",
    ["percentageUnitIDTooltip"] = "Unit-ID which percentage should be tracked (|cFF69CCF0boss1|r, |cFF69CCF0player|r, |cFF69CCF0PlayerName|r etc.)",
    ["percentageCheckAgain"] = "Check multiple times?",
    ["percentageCheckDelay"] = "Check again after (s)",
    ["percentageOptionsHeading"] = "Percentage Options",
    ["percentageCheckAgainAfter"] = "Check again after (s)",
    ["percentageCheckAgain"] = "Check multiple times",

    -- Percentage Entries
    ["percentageEntryDeleteButton"] = "Delete Percentage Entry",
    ["percentageEntryPercent"] = "Percentage (%)",
    ["percentageEntryOperatorDropdown"] = "Operator",
    ["percentageEntryOptionsHeading"] = "Percentage Entry Options",

    -- Encounters
    ["encounterHeading"] = "Encounter Options",
    ["encounterTriggerHeading"] = "Trigger",
    ["encounterImport"] = "Import Encounter",
    ["encounterExport"] = "Export Encounter",
    ["encounterID"] = "Encounter-ID",
    ["encounterIDTooltip"] = 
        "Ny'alotha, the Waking City\n"..
        "2329 - Wrathion\n"..
        "2327 - Maut\n"..
        "2334 - The Prophet Skitra\n"..
        "2328 - Dark Inquisitor Xanesh\n"..
        "2333 - The Hivemind\n"..
        "2335 - Shad'har the Insatiable\n"..
        "2343 - Drest'agath\n"..
        "2345 - Il'gynoth, Corruption Reborn\n"..
        "2336 - Vexiona\n"..
        "2331 - Ra-den the Despoiled\n"..
        "2337 - Carapace of N'Zoth\n"..
        "2344 - N'Zoth the Corruptor",
    ["encounterName"] = "Name",
    ["encounterDeleteButton"] = "Delete Encounter",
    ["encounterOptionsHeading"] = "Encounter Options",
    ["encounterEnabled"] = "Enabled",
    ["encounterOverview"] = "Trigger Overview",
    ["timerOverview"] = "Timers",
    ["rotationOverview"] = "Rotations",
    ["healthPercentageOverview"] = "Health Percentages",
    ["powerPercentageOverview"] = "Power Percentages",

    -- Conditions
    ["conditionEvent"] = "Event",
    ["conditionEventTooltip"] = "Combat event on which the condition should trigger",
    ["conditionSpellID"] = "Spell-ID",
    ["conditionSpellIDTooltip"] = "Combat spell-ID on which the condition should trigger (Can be empty)",
    ["conditionTarget"] = "Target",
    ["conditionTargetTooltip"] = "The combat target of the event/spell-id combination on which the condition should trigger (Can be empty)",
    ["conditionSource"] = "Source",
    ["conditionSourceTooltip"] = "The combat source of the event/spell-id combination on which the condition should trigger (Can be empty)",
    ["conditionHeading"] = "Condition",
    ["conditionStartHeading"] = "Start Condition",
    ["conditionStopHeading"] = "Stop Condition",
    ["conditionRemoveStopCondition"] = "Remove stop condition",
    ["conditionAddStopCondition"] = "Add stop condition",

    -- Timers
    ["timerEnabled"] = "Enabled",
    ["timerName"] = "Name",
    ["timerDeleteButton"] = "Delete Timer",
    ["timerOptionsHeading"] = "Timer Options",
    ["timerOptionsTriggerAtOccurence"] = "Trigger at occurence",

    -- Timings
    ["timingOptions"] = "Timing Options",
    ["timingSeconds"] = "Trigger Times",
    ["timingSecondsTooltip"] = "Times at which this trigger should be executed (comma separated list of seconds e.g. 1, 5, 20)",
    ["timingDeleteButton"] = "Delete Timing",
    ["timingOptionsHeading"] = "Options",


    -- Overlay
    ["senderGroup"] = "Sender",
    ["receiverGroup"] = "Receiver",
    ["overlayFontColor"] = "Font color",
    ["overlayFontSize"] = "Font size",
    ["overlayBackdropColor"] = "Backdrop color",
    ["overlayLocked"] = "Locked",
    ["overlayEnableSound"] = "Enable sounds",

    ["deleteTimer"] = "Delete Timer",
    ["deleteRotation"] = "Delete Rotation",
    ["deletePercentage"] = "Delete Percentage",
    ["deleteEncounter"] = "Delete Encounter",
    ["exportEncounter"] = "Export Encounter",
    ["importEncounter"] = "Import Encounter",
    ["newEncounter"] = "New Encounter",
    ["newTimer"] = "New Timer",
    ["newRotation"] = "New Rotation",
    ["newHealthPercentage"] = "New Health Percentage",
    ["newPowerPercentage"] = "New Power Percentage",

}

local function defaultFunc(L, key)   
    return key
end

setmetatable(L, { __index = defaultFunc })