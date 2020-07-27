if GetLocale() == "deDE" then
    L["sender"] = "Absender"
    L["receiver"] = "Empfänger"
    L["sender+receiver"] = "Absender & Empfänger"

    L["mainWindowTitle"] = "PhenomRaidTools"
    L["runModeDropdown"] = "Ausführungsmodus"

    -- Options
    L["optionsFontSelect"] = "Schriftart"
    L["optionsTabGeneral"] = "Generell"
    L["optionsTabDifficulties"] = "Schwierigkeiten"
    L["optionsTabDefaults"] = "Auslöser Standards"
    L["optionsTabRaidRoster"] = "Raidkader"
    L["optionsTabOverlays"] = "Overlays"

    L["optionsReceiverModeHelp"] = 
        "|cFF69CCF0Notiz|r: Alle Optionen, welche mit dem Sender-Modus zusammenhängen sind entweder ausgeblendet oder deaktiviert.\n"..
        "Wenn du das Aussehen des für das Empfänger-Overlay ändern möchtest bitte navgiere auf `|cFF69CCF0Overlays|r`."
    L["optionsWeakAuraMode"] = "WeakAura Empfänger benutzen"
    L["optionsWeakAuraModeTooltip"] = 
        "Aktiviere diese Option, um den WeakAura Empfänger zu benutzen.\n"..
        "Wenn Du das Addon als Empfänger benutzen möchstest stelle sicher, dass die WeakAura |cFF69CCF0Phenom Raid Tools: Receiver|r deaktiviert ist.\n"..
        "https://wago.io/HyieicnAz\n"..
        "|cFFcc7000WARNUNG|r: Nicht alle Funktionalitäten des Addons funktionieren mit der WeakAura!"
    L["optionsEnabled"] = "Aktiviert"
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
    L["optionsReceiveMessagesFrom"] = "Akzeptiere nur Nachrichten von:"
    L["optionsReceiveMessagesFromTooltip"] = 
        "Wähle einen Spielernamen von dem du Nachrichten erhalten möchtest.|n"..
        "Alle Nachrichten von anderen Absendern werden ignoriert.|n"..
        "Du kannst auch |cFF69CCF0$me|r benutzen damit du Nachrichten von dir selbst immer erhälst.|n"
    L["optionsReceiveMessagesFromDropdown"] = "Namensauswahl"
    L["optionsHideDisabledTriggers"] = "Deaktivierte Auslöser verstecken"
    L["optionsRaidRosterImportByGroup"] = "Importiere Raidroster anhand der aktuellen Gruppe"
    L["optionsRaidRosterClear"] = "Raidroster leeren"
    L["optionsVersionCheck"] = "Versionscheck ausführen"

    -- Dungeon Difficulty
    L["dungeonHeading"] = "Dungeon"
    L["dungeonDifficultyNormal"] = "Normal"
    L["dungeonDifficultyHeroic"] = "Heroisch"   
    L["dungeonDifficultyMythic"] = "Mythisch"

    -- Raid Difficulty
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
    L["defaultUnitID"] = "Unit-ID"
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
        "- Benutze |cFF69CCF0%.0f|r oder |cFF69CCF0%s|r um einen Countdown anzuzeigen (1 kann ebenso 1-2 sein, um Dezimalstellen anzuzeigen)\n"..
        "- Es können Platzhalter benutzt werden, welche später mit den entsprechenden Namen ausgetauscht werden z.B. |cFF69CCF0$source|r |cFF69CCF0$target|r |cFF69CCF0$heal1|r |cFF69CCF0$me|r\n"..
        "- Benutzer den Platzhalter |cFF69CCF0{rt1-8}|r um Raidmarkierungen im Text zu benutzen ({rt1} = |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t, {rt2} = |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t, ...)\n"..
        "- Benutzer den Platzhalter |cFF69CCF0{spell:$ID}|r, um die Textur eines Zaubers anzuzeigen. Dabei ist $ID die Zauber-ID dessen Textur angezeigt werden soll. Z.b. {spell:17} = |T135940:16|t"
    L["messageDelay"] = "Verzögerung (s)"
    L["messageDelayTooltip"] = "Nach wie vielen Sekunden soll die Nachricht erst zum Empfänger geschickt werden?"
    L["messageDuration"] = "Dauer (s)"
    L["messageDurationTooltip"] = "Wie lange soll die Nachricht angezeigt werden?"
    L["messageRaidRosterAddDropdown"] = "Zusätzliche Empfänger auswählen"
    L["messageStandardSound"] = "Standard"
    L["messageUseCustomSound"] = "Benutzerdefinierter Sound"
    L["messageSound"] = "Sound"

    -- Rotations
    L["rotationEnabled"] = "Enabled"
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
    L["percentageEnabled"] = "Enabled"
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
    L["encounterSelectDropdown"] = "Boss auswählen"
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
    L["conditionTargetTooltip"] = "Das Event-Ziel bei dem der Auslöser ausgelöst werden soll (z.B. |cFF69CCF0"..UnitName("player").."|r)"
    L["conditionSource"] = "Quelle"
    L["conditionSourceTooltip"] = "Die Event-Quelle bei dem der Auslöser ausgelöst werden soll (z.B. |cFF69CCF0boss1|r)"
    L["conditionHeading"] = "Auslöser"
    L["conditionStartHeading"] = "Start Auslöser"
    L["conditionStopHeading"] = "Stop Auslöser"
    L["conditionRemoveStopCondition"] = "Stop Auslöser löschen"
    L["conditionAddStopCondition"] = "Stop Auslöser hinzufügen"
   
    -- Timers
    L["timerEnabled"] = "Enabled"
    L["timerName"] = "Name"
    L["timerDeleteButton"] = "Timer löschen"
    L["timerOptionsHeading"] = "Timer Optionen"
    L["timerOptionsTriggerAtOccurence"] = "Nach n Start Auslösern starten"

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

    -- Confirmation
    L["confirmationWindow"] = "Bestätigung"
    L["confirmationDialogOk"] = "Ok"
    L["confirmationDialogCancel"] = "Abbrechen"
    L["importByGroupConfirmationText"] = 
        "Bist Du sicher, dass Du das Raid-Roster anhand der aktuellen Gruppe importieren willst?|n"..
        "|cFF69CCF0Notiz: |rDieser Vorgang wird alle aktuell eingetragenen Namen überschreiben."
    L["deleteConfirmationText"] = "Bist Du sicher, dass Du folgenden Eintrag löschen willst:"
    L["clearRaidRosterConfirmationText"] = "Bist Du sicher, dass Du alle Raidroster Einträge löschen willst?"
    L["cloneConfirmationText"] = "Bist Du sicher, dass Du diesen Auslöser duplizieren möchtest?"

    -- Clone
    L["cloneTimer"] = "Timer duplizieren"
    L["cloneRotation"] = "Rotation duplizieren"
    L["clonePercentage"] = "Prozent duplizieren"


    -- Encounters
    L["--- Castle Nathria"] = "--- Castle Nathria ---"
    L["CN - Shriekwing" ] = "CN - Shriekwing"
    L["CN - Altimor the Huntsman" ] = "CN - Altimor the Huntsman"
    L["CN - Hungering Destroyer" ] = "CN - Hungering Destroyer"
    L["CN - Artificer Xy'Mox" ] = "CN - Artificer Xy'Mox"
    L["CN - Sun King's Salvation" ] = "CN - Sun King's Salvation"
    L["CN - Lady Inerva Darkvein" ] = "CN - Lady Inerva Darkvein"
    L["CN - The Council of Blood" ] = "CN - The Council of Blood"
    L["CN - Il'gynoth Corruption Reborn" ] = "CN - Il'gynoth Corruption Reborn" 
    L["CN - Sludgefist" ] = "CN - Sludgefist"
    L["CN - Stoneborne Generals" ] = "CN - Stoneborne Generals"
    L["CN - Sire Denathrius" ] = "CN - Sire Denathrius"

    -- De Other Side
    L["--- De Other Side"] = "--- De Other Side ---"
    L["DOS - Hakkar the Soulflayer" ] = "DOS - Hakkar the Soulflayer"
    L["DOS - The Manastorms" ] = "DOS - The Manastorms"
    L["DOS - Dealer Xy'exa" ] = "DOS - Dealer Xy'exa"
    L["DOS - Mueh'zala" ] = "DOS - Mueh'zala"

    -- Halls of Atonement
    L["--- Halls of Atonement"] = "--- Halls of Atonement ---"
    L["HOA - Halkias the Sin-Stained Goliath" ] = "HOA - Halkias the Sin-Stained Goliath"
    L["HOA - Echelon" ] = "HOA - Echelon"
    L["HOA - High Adjudicator Aleez" ] = "HOA - High Adjudicator Aleez"
    L["HOA - Lord Chamberlain" ] = "HOA - Lord Chamberlain"

    -- Mists of Tirna Scithe
    L["--- Mists of Tirna Scithe"] = "--- Mists of Tirna Scithe ---"
    L["MOTS - Ingra Maloch" ] = "MOTS - Ingra Maloch"
    L["MOTS - Mistcaller" ] = "MOTS - Mistcaller"
    L["MOTS - Tred'ova" ] = "MOTS - Tred'ova"

    -- Necrotic Wake
    L["--- Necrotic Wake"] = "--- Necrotic Wake ---"
    L["NW - Blightbone" ] = "NW - Blightbone" 
    L["NW - Amarth The Reanimator" ] = "NW - Amarth The Reanimator"
    L["NW - Surgeon Stitchflesh" ] = "NW - Surgeon Stitchflesh" 
    L["NW - Nalthor the Rimebinder" ] = "NW - Nalthor the Rimebinder" 

    -- Plaguefall
    L["--- Plaguefall"] = "--- Plaguefall ---"
    L["NW - Globgrog" ] = "NW - Globgrog"
    L["NW - Doctor Ickus" ] = "NW - Doctor Ickus"
    L["NW - Domina Venomblade" ] = "NW - Domina Venomblade"
    L["NW - Margrave Stradama" ] = "NW - Margrave Stradama"

    -- Sanguine Depths
    L["--- Sanguine Depths"] = "--- Sanguine Depths ---"
    L["SD - Kryxis the Voracious" ] = "SD - Kryxis the Voracious"
    L["SD - Executor Tarvold" ] = "SD - Executor Tarvold" 
    L["SD - Grand Proctor Beryllia" ] = "SD - Grand Proctor Beryllia"
    L["SD - General Kaal" ] = "SD - General Kaal"

    -- Spires of Ascension
    L["--- Spires of Ascension"] = "--- Spires of Ascension ---"
    L["SOA - Kin-Tara" ] = "SOA - Kin-Tara"
    L["SOA - Ventunax" ] = "SOA - Ventunax"
    L["SOA - Oryphrion" ] = "SOA - Oryphrion"
    L["SOA - Devo Paragon of Doubt" ] = "SOA - Devo Paragon of Doubt"

    -- Theater of Pain
    L["--- Theater of Pain"] = "--- Theater of Pain ---"
    L["TOP - An Affront of Challengers" ] = "TOP - An Affront of Challengers"
    L["TOP - Gorechop" ] = "TOP - Gorechop"
    L["TOP - Xav the Unfallen" ] = "TOP - Xav the Unfallen"
    L["TOP - Kul'tharok" ] = "TOP - Kul'tharok"
    L["TOP - Mordretha the Endless Empress"] = "TOP - Mordretha the Endless Empress"

else 
    return 
end