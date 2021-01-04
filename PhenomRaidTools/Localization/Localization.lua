L = {
    ["sender"] = "Sender",
    ["receiver"] = "Receiver",
    ["sender+receiver"] = "Sender & Receiver",

    ["mainWindowTitle"] = "PhenomRaidTools",
    ["runModeDropdown"] = "Run mode",

    -- Options
    ["optionsFontSelect"] = "Font",
    ["optionsTabGeneral"] = "General",
    ["optionsTabDifficulties"] = "Difficulties",
    ["optionsTabDefaults"] = "Trigger defaults",
    ["optionsTabRaidRoster"] = "Raid roster",
    ["optionsTabCustomPlaceholders"] = "Custom Placeholders",
    ["optionsTabOverlays"] = "Overlays",
    ["optionsPositionX"] = "Position X",
    ["optionsPositionY"] = "Position Y",

    ["optionsReceiverModeHelp"] = 
        "|cFF69CCF0Note|r: All options regarding the sender mode are hidden or disabled.\n"..
        "If you want to change the appereance of the receiver overlay please go to `|cFF69CCF0Overlays|r`.",
    ["optionsWeakAuraMode"] = "Use legacy WeakAura receiver",
    ["optionsWeakAuraModeTooltip"] = 
        "Activate this option if you want to use the WeakAura as receiver.\n"..
        "If you want to use the addon as receiver make sure you deactivate the WeakAura |cFF69CCF0Phenom Raid Tools: Receiver|r\n"..
        "https://wago.io/HyieicnAz\n"..
        "|cFFcc7000WARNING|r: Not every feature of the addon is supported with the WeakAura!",
    ["optionsEnabled"] = "Enabled",
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
    ["optionsReceiveMessagesFrom"] = "Accept messages only from", 
    ["optionsReceiveMessagesFromTooltip"] = 
        "Put the name of the player you want to receive messages from in here.|n"..
        "All other messages will be filtered out so you won't get spammed.|n"..
        "You also can use |cFF69CCF0$me|r to always receive messages from yourself.", 
    ["optionsReceiveMessagesFromDropdown"] = "Choose player", 
    ["optionsHideDisabledTriggers"] = "Hide disabled triggers",
    ["optionsRaidRosterImportByGroup"] = "Import current raid",
    ["optionsRaidRosterClear"] = "Clear raid roster",
    ["optionsVersionCheck"] = "Perform version check",
    ["optionsOpenProfiles"] = "Open profiles page",

    ["optionsCustomPlaceholdersHeading"] = "Custom Placeholders",
    ["optionsCustomPlaceholderDeleteButton"] = "|cFFed3939Delete Custom Placeholder|r",
    ["optionsCustomPlaceholderTypePlayer"] = "Player",
    ["optionsCustomPlaceholderTypeGroup"] = "Group",
    ["optionsCustomPlaceholderType"] = "Type",
    ["optionsCustomPlaceholderName"] = "Name",
    ["optionsCustomPlaceholderNameTooltip"] = "Placeholders can't contain spaces",
    ["optionsCustomPlaceholderRemoveEmptyNames"] = "Remove empty names",
    ["optionsCustomPlaceholderAddNameButton"] = "|cFF76ff68Add name|r",
    ["optionsCustomPlaceholderDeleteButton"] = "|cFFed3939Delete|r",    
    ["optionsCustomPlaceholdersDescription"] = "Here you can define custom placeholders which can be used as message targets.",
    ["optionsCustomPlaceholdersSubDescription"] = "Types:\n"..
        "|cFF69CCF0Player|r - Only the first player found within the group will be messaged.\n"..
        "|cFF69CCF0Group|r - All configured players will be messaged.",
    ["optionsCustomPlaceholdersAddButton"] = "|cFF76ff68Add Placeholder|r",
    ["optionsGeneralVersionHeading"] = "Installed versions",

    ["deleteTabEntryConfirmationText"] = "Are you sure you want to delete this item?",

    -- Dungeon Difficulty
    ["dungeonHeading"] = "Dungeon",
    ["dungeonDifficultyNormal"] = "Normal",
    ["dungeonDifficultyHeroic"] = "Heroic",   
    ["dungeonDifficultyMythic"] = "Mythic",

    -- Raid Difficulty
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
    ["treeCustomPlaceholder"] = "Placeholder",

    -- Defaults
    ["rotationDefaults"] = "Rotation",
    ["percentageDefaults"] = "Percentages",
    ["messageDefaults"] = "Message",
    ["defaultShouldRestart"] = "Ignore after activation",
    ["defaultIgnoreDuration"] = "Ignore duration",
    ["defaultIgnoreAfterActivation"] = "Should restart",
    ["defaultEvent"] = "Event",
    ["defaultMessage"] = "Message",
    ["defaultTargets"] = "Targets",
    ["defaultUnitID"] = "Unit-ID",
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
    ["messageDeleteButton"] = "|cFFed3939Delete Message|r",
    ["messageTargets"] = "Targets",
    ["messageTargetOverlay"] = "Target Overlay",
    ["messageTargetsTooltip"] =
        "Comma separated list of targets\n"..
        "Examples:\n"..
        "- |cFF69CCF0$me|r -> Will be exchanged with the current characters name\n"..
        "- |cFF69CCF0$target|r -> Will be exchanged with the target of the event\n"..
        "- |cFF69CCF0$healN|r or |cFF69CCF0$tankN|r or |cFF69CCF0$ddN|r -> N is a number between 1-21. Will be exchanged with the configured raid roster name.\n"..
        "- |cFF69CCF0$groupN|r -> N is a number between 1-8. Will be exchanged with *all* members of the group.\n"..
        "- |cFF69CCF0ALL|r, |cFF69CCF0HEALER|r, |cFF69CCF0TANK|r, |cFF69CCF0DAMAGER|r\n",
    ["messageMessage"] = "Message",
    ["messageMessageTooltip"] =          
        "- Use |cFF69CCF0%.0f|r or |cFF69CCF0%s|r to display the countdown (the 1 can also changed to 0-2 for decimals)\n"..
        "- You can use tokens which will be replaced within the message e.g. |cFF69CCF0$source|r, |cFF69CCF0$target|r, |cFF69CCF0$heal1|r, |cFF69CCF0$me|r\n"..
        "- Use placeholder |cFF69CCF0{rt1-8}|r for raid markers (1=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t, 2=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t, 3=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t, 4=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t, 5=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t, 6=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t, 7=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t, 8=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t)\n"..
        "- Use placeholder |cFF69CCF0{spell:$ID}|r where $ID is any spellID of the spell you want to display the texture of e.g. {spell:17} = |T135940:16|t",
    ["messageDelay"] = "Delay (s)",
    ["messageDelayTooltip"] = "After how many seconds the message should be send to the receiver?",
    ["messageDuration"] = "Duration (s)",
    ["messageDurationTooltip"] = "For how long should the message be displayed?",
    ["messageRaidRosterAddDropdown"] = "Select additional target entry",
    ["messageRaidRosterAddDropdownTooltip"] = "You can add a reference of your configured raid roster. It will always add the reference *not* the player name in the targets.",
    ["messageStandardSound"] = "Default",
    ["messageUseCustomSound"] = "Use custom sound",
    ["messageSound"] = "Select sound",

    -- Rotations
    ["rotationEnabled"] = "Enabled",
    ["rotationHeading"] = "Rotations",
    ["rotationName"] = "Name",
    ["rotationDeleteButton"] = "|cFFed3939Delete Rotation|r",
    ["rotationShouldRestart"] = "Should trigger restart?",
    ["rotationIgnoreAfterActivation"] = "Ignore after activation?",
    ["rotationIgnoreDuration"] = "Ignore trigger for (s)",
    ["rotationTriggerConditionHeading"] = "Rotation Trigger",
    ["rotationOptionsHeading"] = "Rotation Options",
    ["rotationTriggerConditionHeading"] = "Condition",

    -- RotationEntries
    ["rotationEntryHeading"] = "Rotation Entries",
    ["rotationEntryDeleteButton"] = "|cFFed3939Delete Rotation Entry|r",
    ["cloneRotationEntry"] = "Clone Rotation Entry",       

    -- Percentages
    ["percentageEnabled"] = "Enabled",
    ["percentageDeleteButton"] = "|cFFed3939Delete Percentage|r",
    ["percentageName"] = "Name",
    ["percentageUnitID"] = "Unit-ID / Unit-Name",
    ["percentageUnitIDTooltip"] = "Unit-ID which percentage should be tracked (|cFF69CCF0boss1|r, |cFF69CCF0player|r, |cFF69CCF0PlayerName|r etc.)\n"..
        "You also can use the units name. It will only work if there is only one unit in combat which will be used.",
    ["percentageCheckAgain"] = "Check multiple times?",
    ["percentageCheckDelay"] = "Check again after (s)",
    ["percentageOptionsHeading"] = "Percentage Options",
    ["percentageCheckAgainAfter"] = "Check again after (s)",
    ["percentageCheckAgain"] = "Check multiple times",
    ["clonePercentageEntry"] = "Clone Percentage Entry",

    -- Percentage Entries
    ["percentageEntryDeleteButton"] = "|cFFed3939Delete Percentage Entry|r",
    ["percentageEntryPercent"] = "Percentage (%)",
    ["percentageEntryOperatorDropdown"] = "Operator",
    ["percentageEntryOptionsHeading"] = "Percentage Entry Options",

    -- Encounters
    ["encounterHeading"] = "Encounter Options",
    ["encounterTriggerHeading"] = "Trigger",
    ["encounterImport"] = "Import Encounter",
    ["encounterExport"] = "Export Encounter",
    ["encounterID"] = "Encounter-ID",
    ["encounterName"] = "Name",
    ["encounterSelectDropdown"] = "Select Encounter",
    ["encounterDeleteButton"] = "|cFFed3939Delete Encounter|r",
    ["encounterOptionsHeading"] = "Encounter Options",
    ["encounterEnabled"] = "Enabled",
    ["encounterOverview"] = "Trigger Overview",
    ["timerOverview"] = "Timers",
    ["rotationOverview"] = "Rotations",
    ["healthPercentageOverview"] = "Health Percentages",
    ["powerPercentageOverview"] = "Power Percentages",

    
    ["encounterOverviewDisabled"] = "disabled",
    ["encounterOverviewOf"] = "of",
    ["encounterOverviewStartTimerOn"] = "Start timer on",
    ["encounterOverviewStopTimerOn"] = "Stop timer on",
    ["encounterOverviewTimings"] = "Timings", 
    ["encounterOverviewStartTriggerOn"] = "Start trigger on",
    ["encounterOverviewStopTriggerOn"] = "Stop trigger on",
    ["encounterOverviewTriggerOn"] = "Trigger on",
    ["encounterOverviewEntries"] = "Entries",
    ["encounterOverviewPercentagePrefixHealth"] = "Health",
    ["encounterOverviewPercentagePrefixPower"] = "Power",


    -- Conditions
    ["conditionEvent"] = "Event",
    ["conditionEventTooltip"] = "Combat event on which the condition should trigger",
    ["conditionSpellID"] = "Spell-ID",
    ["conditionSpellIDTooltip"] = "Combat spell-ID on which the condition should trigger (Can be empty)",
    ["conditionTarget"] = "Target",
    ["conditionTargetTooltip"] = "The combat target of the event/spell-id combination on which the condition should trigger (e.g. |cFF69CCF0"..UnitName("player").."|r)",
    ["conditionSource"] = "Source",
    ["conditionSourceTooltip"] = "The combat source of the event/spell-id combination on which the condition should trigger (e.g. |cFF69CCF0boss1|r)",
    ["conditionHeading"] = "Condition",
    ["conditionStartHeading"] = "Start Condition",
    ["conditionStopHeading"] = "Stop Condition",
    ["conditionRemoveStopCondition"] = "Remove stop condition",
    ["conditionRemoveStartCondition"] = "Remove start condition",
    ["conditionAddStopCondition"] = "Add stop condition",
    ["conditionAddStartCondition"] = "Add start condition",

    -- Timers
    ["timerEnabled"] = "Enabled",
    ["timerName"] = "Name",
    ["timerDeleteButton"] = "|cFFed3939Delete Timer|r",
    ["timerOptionsHeading"] = "Timer Options",
    ["timerOptionsTriggerAtOccurence"] = "Trigger at occurence",
    ["timerOptionsResetCounterOnStop"] = "Restart Counter on Stop",

    -- Timings
    ["timingOptions"] = "Timing Options",
    ["timingSeconds"] = "Trigger Times",
    ["timingOffset"] = "Offset",
    ["timingName"] = "Name",
    ["timingSecondsTooltip"] = "Times at which this trigger should be executed (comma separated list)\n"..
        "Supports different formatting styles\n"..
        "Examples:\n"..
        " - |cFF69CCF055|r\n"..
        " - |cFF69CCF001:55|r\n"..
        " - |cFF69CCF01:5|r",
    ["timingDeleteButton"] = "|cFFed3939Delete Timing|r",
    ["timingOptionsHeading"] = "Options",
    ["cloneTiming"] = "Clone Timing",

    -- Overlay
    ["senderGroup"] = "Sender",
    ["receiversGroup"] = "Receiver",
    ["overlayLabel"] = "Label",
    ["overlaySoundGroup"] = "Sound",
    ["overlayFontGroup"] = "Font",
    ["overlayPositionGroup"] = "Position",
    ["overlayFontColor"] = "Font color",
    ["overlayFontSize"] = "Font size",
    ["overlayBackdropColor"] = "Backdrop color",
    ["overlayLocked"] = "Locked",
    ["overlayEnableSound"] = "Enable sounds",
    ["overlayDefaultSoundFile"] = "Default Sound",

    ["deleteTimer"] = "|cFFed3939Delete Timer|r",
    ["deleteRotation"] = "|cFFed3939Delete Rotation|r",
    ["deletePercentage"] = "|cFFed3939Delete Percentage|r",
    ["deleteEncounter"] = "|cFFed3939Delete Encounter|r",
    ["exportEncounter"] = "Export Encounter",
    ["importEncounter"] = "Import Encounter",
    ["newEncounter"] = "|cFF76ff68New Encounter|r",
    ["newTimer"] = "|cFF76ff68New Timer|r",
    ["newRotation"] = "|cFF76ff68New Rotation|r",
    ["newHealthPercentage"] = "|cFF76ff68New Health Percentage|r",
    ["newPowerPercentage"] = "|cFF76ff68New Power Percentage|r",

    -- Confirmation
    ["confirmationWindow"] = "Confirmation",
    ["confirmationDialogOk"] = "Ok",
    ["confirmationDialogCancel"] = "Cancel",
    ["importConfirmationMergeEncounter"] = "Encounter already exists. Should the triggers be merged?",
    ["importByGroupConfirmationText"] = 
        "Are you sure you want to import raid roster by your current group?|n"..
        "|cFF69CCF0Note: |rThis will overwrite all of your current raid roster entries.",
    ["deleteConfirmationText"] = "Are you sure you want to delete:",
    ["clearRaidRosterConfirmationText"] = "Are you sure you want to clear the raid roster settings?",
    ["cloneConfirmationText"] = "Are you sure you want to clone the trigger:",
    ["optionsCustomPlaceholderDeleteButtonConfirmation"] = "Are you sure you want to delete custom placeholder?",

    -- Import/Export
    ["exportFrame"] = "Export",
    ["importFrame"] = "Import",
    ["exportButton"] = "Export",
    ["importButton"] = "Import",

    -- Clone
    ["cloneTimer"] = "Clone Timer",
    ["cloneRotation"] = "Clone Rotation",
    ["clonePercentage"] = "Clone Percentage",

    -- Encounters
    ["--- Castle Nathria ---"] = "--- Castle Nathria ---",
    ["CN - Shriekwing" ] = "CN - Shriekwing",
    ["CN - Altimor the Huntsman" ] = "CN - Altimor the Huntsman",
    ["CN - Hungering Destroyer" ] = "CN - Hungering Destroyer",
    ["CN - Artificer Xy'Mox" ] = "CN - Artificer Xy'Mox",
    ["CN - Sun King's Salvation" ] = "CN - Sun King's Salvation",
    ["CN - Lady Inerva Darkvein" ] = "CN - Lady Inerva Darkvein",
    ["CN - The Council of Blood" ] = "CN - The Council of Blood",
    ["CN - Sludgefist" ] = "CN - Sludgefist",
    ["CN - Stoneborne Generals" ] = "CN - Stoneborne Generals",
    ["CN - Sire Denathrius" ] = "CN - Sire Denathrius",

    -- De Other Side
    ["--- De Other Side ---"] = "--- De Other Side ---",
    ["DOS - Hakkar the Soulflayer" ] = "DOS - Hakkar the Soulflayer",
    ["DOS - The Manastorms" ] = "DOS - The Manastorms",
    ["DOS - Dealer Xy'exa" ] = "DOS - Dealer Xy'exa",
    ["DOS - Mueh'zala" ] = "DOS - Mueh'zala",

    -- Halls of Atonement
    ["--- Halls of Atonement ---"] = "--- Halls of Atonement ---",
    ["HOA - Halkias, the Sin-Stained Goliath" ] = "HOA - Halkias, the Sin-Stained Goliath",
    ["HOA - Echelon" ] = "HOA - Echelon",
    ["HOA - High Adjudicator Aleez" ] = "HOA - High Adjudicator Aleez",
    ["HOA - Lord Chamberlain" ] = "HOA - Lord Chamberlain",

    -- Mists of Tirna Scithe
    ["--- Mists of Tirna Scithe ---"] = "--- Mists of Tirna Scithe ---",
    ["MOTS - Ingra Maloch" ] = "MOTS - Ingra Maloch",
    ["MOTS - Mistcaller" ] = "MOTS - Mistcaller",
    ["MOTS - Tred'ova" ] = "MOTS - Tred'ova",

    -- Necrotic Wake
    ["--- Necrotic Wake ---"] = "--- Necrotic Wake ---",
    ["NW - Blightbone" ] = "NW - Blightbone" ,
    ["NW - Amarth, The Reanimator" ] = "NW - Amarth, The Reanimator",
    ["NW - Surgeon Stitchflesh" ] = "NW - Surgeon Stitchflesh" ,
    ["NW - Nalthor the Rimebinder" ] = "NW - Nalthor the Rimebinder" ,

    -- Plaguefall
    ["--- Plaguefall ---"] = "--- Plaguefall ---",
    ["PF - Globgrog" ] = "PF - Globgrog",
    ["PF - Doctor Ickus" ] = "PF - Doctor Ickus",
    ["PF - Domina Venomblade" ] = "PF - Domina Venomblade",
    ["PF - Margrave Stradama" ] = "PF - Margrave Stradama",

    -- Sanguine Depths
    ["--- Sanguine Depths ---"] = "--- Sanguine Depths ---",
    ["SD - Kryxis the Voracious" ] = "SD - Kryxis the Voracious",
    ["SD - Executor Tarvold" ] = "SD - Executor Tarvold" ,
    ["SD - Grand Proctor Beryllia" ] = "SD - Grand Proctor Beryllia",
    ["SD - General Kaal" ] = "SD - General Kaal",

    -- Spires of Ascension
    ["--- Spires of Ascension ---"] = "--- Spires of Ascension ---",
    ["SOA - Kin-Tara" ] = "SOA - Kin-Tara",
    ["SOA - Ventunax" ] = "SOA - Ventunax",
    ["SOA - Oryphrion" ] = "SOA - Oryphrion",
    ["SOA - Devo, Paragon of Doubt" ] = "SOA - Devo, Paragon of Doubt",

    -- Theater of Pain
    ["--- Theater of Pain ---"] = "--- Theater of Pain ---",
    ["TOP - An Affront of Challengers" ] = "TOP - An Affront of Challengers",
    ["TOP - Gorechop" ] = "TOP - Gorechop",
    ["TOP - Xav the Unfallen" ] = "TOP - Xav the Unfallen",
    ["TOP - Kul'tharok" ] = "TOP - Kul'tharok",
    ["TOP - Mordretha, the Endless Empress"] = "TOP - Mordretha, the Endless Empress",    
}


local function defaultFunc(L, key)
    return key
end

setmetatable(L, { __index = defaultFunc })