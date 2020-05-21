if GetLocale() == "deDE" then
    L["mainWindowTitle"] = "PhenomRaidTools"
    L["runModeDropdown"] = "Ausführungsmodus"

    -- Options
    L["optionsTabGeneral"] = "Generell"
    L["optionsTabDifficulties"] = "Schwierigkeiten"
    L["optionsTabDefaults"] = "Auslöser Standards"
    L["optionsTabRaidRoster"] = "Raidkader"
    L["optionsTabOverlays"] = "Overlays"

    L["optionsTestMode"] = "Testmodus"
    L["optionsDebugMode"] = "Debugmodus"
    L["optionsDebugModeTooltip"] = "Wenn dieser Modus aktiviert ist werden einige allgemeine Informationen in das Chatfenster ausgegeben"
    L["optionsTestEncounterID"] = "Boss-ID zum Testen"
    L["optionsTestEncounterIDTooltip"] = "Wähle den Boss der getestet werden soll"
    L["optionsShowOverlay"] = "Overlay anzeigen"
    L["optionsHideOverlayAfterCombat"] = "Overlay nach dem Kampf ausblenden"
    L["optionsDifficultyExplanation"] = "Hier können die Schwierigkeiten ausgewählt werden auf denen das Addon aktiv sein soll."
    L["optionsDefaultsExplanation"] = "Hier können Standardwerte für die Auslöser ausgewählt werden."
    L["optionsRaidRosterExplanation"] = "Hier können Spielernamen des Raidkaders eingetragen werden, um diese später zu referenzieren mit z.B. |cFF69CCF0$tank2|r |cFF69CCF0$heal1|r etc."
    L["dungeonHeading"] = "Dungeon"
    L["dungeonDifficultyNormal"] = "Normal"
    L["dungeonDifficultyHeroic"] = "Heroisch"   
    L["dungeonDifficultyMythic"] = "Mythisch"
    L["raidHeading"] = "Schlachtzug"
    L["raidDifficultyNormal"] = "Normal"
    L["raidDifficultyHeroic"] = "Heroisch"
    L["raidDifficultyMythic"] = "Mythisch"

    -- Tree
    L["treeOptions"] = "Optionen"
    L["treeEncounters"] = "Bosse"
    L["treeTimer"] = "Timer"
    L["treeRotation"] = "Rotationen"
    L["treeHealthPercentage"] = "Lebens-Prozente"
    L["treePowerPercentage"] = "Energie-Prozente"

    -- Defaults
    L["rotationDefaults"] = "Rotation"
    L["percentageDefaults"] = "Prozente"
    L["messageDefaults"] = "Nachricht"
    L["defaultShouldRestart"] = "Soll neustarten"
    L["defaultIgnoreDuration"] = "Ignorieren für"
    L["defaultIgnoreAfterActivation"] = "Nach der Aktivierung ignorieren"
    L["defaultWithSound"] = "Sound für Empfänger aktivieren"
    L["defaultEvent"] = "Event"
    L["defaultCheckAgain"] = "Mehrfach prüfen"
    L["defaultCheckAgainAfter"] = "Erneut prüfen nach (s)"
    L["additionalEvents"] = "Zusätzliche Events"
    L["additionalEventsTooltip"] = "Kommaseparierte Liste von Events welche in Auslösern genutzt werden können (z.B. SPELL_CAST_FAILED)"
    L["conditionDefaults"] = "Auslöser"

    -- Raid Roster
    L["raidRosterTanksHeading"] = "Tanks"
    L["raidRosterHealerHeading"] = "Heiler"
    L["raidRosterDDHeading"] = "DDs"
    
    -- Messages
    L["messagePreview"] = "Vorschau: "
    L["messageHeading"] = "Nachrichten"
    L["messageDeleteButton"] = "Nachricht löschen"
    L["messageWithSound"] = "Sound für Empfänger aktivieren"
    L["messageTargets"] = "Empfänger"
    L["messageTargetsTooltip"] =
        "Kommaseparierte Liste von Empfängern\n"..
        "Beispiele:\n"..
        "- |cFF69CCF0$me|r -> Wird mit dem Namen der aktuellen Charakters ausgetauscht\n"..
        "- |cFF69CCF0$target|r -> Wird mit dem Ziel des Kampfevents ausgetauscht\n"..
        "- |cFF69CCF0$healN|r or |cFF69CCF0$tankN|r or |cFF69CCF0$ddN|r -> N ist eine Zahl zwischen 1-21. Wird mit dem konfigurierten Namen im Raidkader ausgetauscht.\n"..
        "- |cFF69CCF0ALL|r |cFF69CCF0HEALER|r |cFF69CCF0TANK|r |cFF69CCF0DAMAGER|r\n"
    L["messageMessage"] = "Nachricht"
    L["messageMessageTooltip"] =          
        "- Benutze |cFF69CCF0%s|r um einen Countdown anzuzeigen\n"..
        "- Es können Platzhalter benutzt werden, welche später mit den entsprechenden Namen ausgetauscht werden z.B. |cFF69CCF0$source|r |cFF69CCF0$target|r |cFF69CCF0$heal1|r |cFF69CCF0$me|r\n"..
        "- Bitte benutze keine reservierten Zeichen in den Nachrichten (|cFF69CCF0#|r |cFF69CCF0?|r |cFF69CCF0~|r |cFF69CCF0%|r)"
    L["messageDelay"] = "Verzögerung (s)"
    L["messageDelayTooltip"] = "Nach wie vielen Sekunden soll die Nachricht erst zum Empfänger geschickt werden?"
    L["messageDuration"] = "Dauer (s)"
    L["messageDurationTooltip"] = "Wie lange soll die Nachricht angezeigt werden?"
    L["messageRaidRosterAddDropdown"] = "Zusätzliche Empfänger auswählen"

    -- Rotations
    L["rotationHeading"] = "Rotationen"
    L["rotationName"] = "Name"
    L["rotationDeleteButton"] = "Rotation löschen"
    L["rotationShouldRestart"] = "Soll der Auslöser neustarten?"
    L["rotationIgnoreAfterActivation"] = "Nach der Aktivierung ignorieren"
    L["rotationIgnoreDuration"] = "Ignorieren für (s)"
    L["rotationTriggerConditionHeading"] = "Auslöser"
    L["rotationOptionsHeading"] = "Optionen"

    -- RotationEntries
    L["rotationEntryHeading"] = "Rotationseinträge"
    L["rotationEntryDeleteButton"] = "Eintrag löschen"

    -- Percentages
    L["percentageDeleteButton"] = "Prozent löschen"
    L["percentageName"] = "Name"
    L["percentageUnitID"] = "Unit-ID"
    L["percentageUnitIDTooltip"] = "Unit-ID welche geprüft werden soll (|cFF69CCF0boss1|r |cFF69CCF0player|r |cFF69CCF0PlayerName|r etc.)"
    L["percentageCheckAgain"] = "Mehrfach prüfen?"
    L["percentageOptionsHeading"] = "Optionen"
    L["percentageCheckAgainAfter"] = "Nochmal prüfen nach (s)"

    -- Percentage Entries
    L["percentageEntryDeleteButton"] = "Prozenteintrag löschen"
    L["percentageEntryPercent"] = "Prozent"
    L["percentageEntryOperatorDropdown"] = "Operator"
    L["percentageEntryOptionsHeading"] = "Optionen"

    -- Encounters
    L["encounterHeading"] = "Boss Optionen"
    L["encounterTriggerHeading"] = "Auslöser"
    L["encounterImport"] = "Boss importieren"
    L["encounterExport"] = "Boss exportieren"
    L["encounterID"] = "Boss-ID"
    L["encounterIDTooltip"] = 
        "Ny'alotha, die Erwachte Stadt\n"..
        "2329 - Furorion\n"..
        "2327 - Ma'ut\n"..
        "2334 - Der Prophet Skitra\n"..
        "2328 - Dunkle Inquisitorin Xanseh\n"..
        "2333 - Das Schwarmbewusstsein\n"..
        "2335 - Shad'har der Unersättliche\n"..
        "2343 - Drest'agath\n"..
        "2345 - Il'gynoth die Wiedergeborene Verderbnis\n"..
        "2336 - Vexiona\n"..
        "2331 - Ra-den der Entweihte\n"..
        "2337 - Panzer von N'Zoth\n"..
        "2344 - N'Zoth der Verderber"
    L["encounterName"] = "Name"
    L["encounterDeleteButton"] = "Boss löschen"
    L["encounterOptionsHeading"] = "Boss Optionen"
    L["encounterEnabled"] = "Aktiviert?"
    L["encounterOverview"] = "Übersicht der Auslöser"
    L["timerOverview"] = "Timer"
    L["rotationOverview"] = "Rotationen"
    L["healthPercentageOverview"] = "Lebens-Prozente"
    L["powerPercentageOverview"] = "Energie-Prozente"

    -- Conditions
    L["conditionEvent"] = "Event"
    L["conditionEventTooltip"] = "Das Kampfevent bei dem der Auslöser ausgelöst werden soll"
    L["conditionSpellID"] = "Zauber-ID"
    L["conditionSpellIDTooltip"] = "Die Zauber-ID bei dem der Auslöser ausgelöst werden soll (kann leer sein)"
    L["conditionTarget"] = "Ziel"
    L["conditionTargetTooltip"] = "Das Event-Ziel bei dem der Auslöser ausgelöst werden soll (kann leer sein)"
    L["conditionSource"] = "Quelle"
    L["conditionSourceTooltip"] = "Die Event-Quelle bei dem der Auslöser ausgelöst werden soll (kann leer sein)"
    L["conditionHeading"] = "Auslöser"
    L["conditionStartHeading"] = "Start Auslöser"
    L["conditionStopHeading"] = "Stop Auslöser"
    L["conditionRemoveStopCondition"] = "Stop Auslöser hinzufügen"
   
    -- Timers
    L["timerName"] = "Name"
    L["timerDeleteButton"] = "Timer löschen"
    L["timerOptionsHeading"] = "Timer Optionen"

    -- Timings
    L["timingOptions"] = "Zeiteinträge"
    L["timingSeconds"] = "Auslösungszeiten"
    L["timingSecondsTooltip"] = "Die Zeiten bei denen die Nachrichten an die Empfänger geschickt werden. (Gezählt ab der Aktivierung des Timers; Kommaseparierte Liste z.B. 1, 3, 10)"
    L["timingDeleteButton"] = "Auslösungszeit löschen"
    L["timingOptionsHeading"] = "Optionen"


    -- Overlay
    L["senderGroup"] = "Absender"
    L["receiverGroup"] = "Empfänger"
    L["overlayFontColor"] = "Schriftfarbe"
    L["overlayFontSize"] = "Schriftgröße"
    L["overlayBackdropColor"] = "Hintergrundfarbe"
    L["overlayLocked"] = "Gesperrt"
    L["overlayEnableSound"] = "Töne aktivieren"

    L["deleteTimer"] = "Timer löschen"
    L["deleteRotation"] = "Rotation löschen"
    L["deletePercentage"] = "Prozent löschen"
    L["deleteEncounter"] = "Boss löschen"
    L["exportEncounter"] = "Boss exportieren"
    L["importEncounter"] = "Boss importieren"
    L["newEncounter"] = "Neuer Boss"
    L["newTimer"] = "Neuer Timer"
    L["newRotation"] = "Neue Rotation"
    L["newHealthPercentage"] = "Neues Lebens-Prozent"
    L["newPowerPercentage"] = "Neues Energie-Prozent"
else 
    return 
end