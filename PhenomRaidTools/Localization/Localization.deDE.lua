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
    L["optionsTabCustomPlaceholders"] = "Benutzerdefinierte Platzhalter"
    L["optionsTabRaidRoster"] = "Raidkader"
    L["optionsTabOverlays"] = "Overlays"
    L["optionsPositionX"] = "Position X"
    L["optionsPositionY"] = "Position Y"

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
    L["optionsRaidRosterImportByGroup"] = "Aktuellen Schlachtzug importieren"
    L["optionsRaidRosterClear"] = "Raidroster leeren"
    L["optionsVersionCheck"] = "Versionscheck ausführen"

    L["optionsCustomPlaceholdersHeading"] = "Benutzerdefinierte Platzhalter"
    L["optionsCustomPlaceholderDeleteButton"] = "|cFFed3939Löschen|r"
    L["optionsCustomPlaceholderTypePlayer"] = "Spieler"
    L["optionsCustomPlaceholderTypeGroup"] = "Gruppe"
    L["optionsCustomPlaceholderType"] = "Typ"
    L["optionsCustomPlaceholderName"] = "Name"
    L["optionsCustomPlaceholderRemoveEmptyNames"] = "Leere Namen entfernen"
    L["optionsCustomPlaceholderAddNameButton"] = "Name hinzufügen"
    L["optionsCustomNameDeleteButton"] = "|cFFed3939Entfernen|r"
    L["optionsCustomNamesDescription"] = "Hier können Platzhalter definiert werden die dann als Nachrichten-Empfänger genutzt werden können.\n"
    L["optionsCustomNamesSubDescription"] = "Typen:\n"..
        "|cFF69CCF0Spieler|r - Nur der erste Spieler, der in der Gruppe gefunden wird, wird eine Nachricht erhalten\n"..
        "|cFF69CCF0Gruppe|r - Alle konfigurierten Charaktere werden eine Nachricht erhalten"
        
    L["optionsCustomNamesAddButton"] = "|cFF76ff68Neuer Platzhalter|r"
    L["optionsGeneralVersionHeading"] = "Installierte Versionen"

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
    L["messageTargetOverlay"] "Ziel Overlay"
    L["messageDeleteButton"] = "|cFFed3939Nachricht entfernen|r"
    L["messageTargets"] = "Empfänger"
    L["messageTargetsTooltip"] =
        "Kommaseparierte Liste von Empfängern\n"..
        "Beispiele:\n"..
        "- |cFF69CCF0$me|r -> Wird mit dem Namen der aktuellen Charakters ausgetauscht\n"..
        "- |cFF69CCF0$target|r -> Wird mit dem Ziel des Kampfevents ausgetauscht\n"..
        "- |cFF69CCF0$healN|r or |cFF69CCF0$tankN|r or |cFF69CCF0$ddN|r -> N ist eine Zahl zwischen 1-21. Wird mit dem konfigurierten Namen im Raidkader ausgetauscht.\n"..
        "- |cFF69CCF0$groupN|r -> N ist eine Zahl zwischen 1-8. Wird mit *allen* Spielern der entsprechenden Gruppe ausgetauscht.\n"..
        "- |cFF69CCF0ALL|r |cFF69CCF0HEALER|r |cFF69CCF0TANK|r |cFF69CCF0DAMAGER|r\n"
    L["messageMessage"] = "Nachricht"
    L["messageMessageTooltip"] =          
        "- Benutze |cFF69CCF0%.0f|r oder |cFF69CCF0%s|r um einen Countdown anzuzeigen (1 kann ebenso 1-2 sein, um Dezimalstellen anzuzeigen)\n"..
        "- Es können Platzhalter benutzt werden, welche später mit den entsprechenden Namen ausgetauscht werden z.B. |cFF69CCF0$source|r |cFF69CCF0$target|r |cFF69CCF0$heal1|r |cFF69CCF0$me|r\n"..
        "- Benutzer den Platzhalter |cFF69CCF0{rt1-8}|r um Raidmarkierungen im Text zu benutzen (1=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t, 2=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t, 3=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t, 4=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t, 5=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t, 6=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t, 7=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t, 8=|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t)\n"..
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
    L["rotationEnabled"] = "Aktiviert"
    L["rotationHeading"] = "Rotationen"
    L["rotationName"] = "Name"
    L["rotationDeleteButton"] = "|cFFed3939Rotation entfernen|r"
    L["rotationShouldRestart"] = "Soll der Auslöser neustarten?"
    L["rotationIgnoreAfterActivation"] = "Nach der Aktivierung ignorieren"
    L["rotationIgnoreDuration"] = "Ignorieren für (s)"
    L["rotationTriggerConditionHeading"] = "Auslöser"
    L["rotationOptionsHeading"] = "Optionen"

    -- RotationEntries
    L["rotationEntryHeading"] = "Rotationseinträge"
    L["rotationEntryDeleteButton"] = "|cFFed3939Eintrag entfernen|r"

    -- Percentages
    L["percentageEnabled"] = "Aktiviert"
    L["percentageDeleteButton"] = "|cFFed3939Prozent entfernen|r"
    L["percentageName"] = "Name"
    L["percentageUnitID"] = "Unit-ID"
    L["percentageUnitIDTooltip"] = "Unit-ID welche geprüft werden soll (|cFF69CCF0boss1|r |cFF69CCF0player|r |cFF69CCF0PlayerName|r etc.)"
    L["percentageCheckAgain"] = "Mehrfach prüfen?"
    L["percentageOptionsHeading"] = "Optionen"
    L["percentageCheckAgainAfter"] = "Nochmal prüfen nach (s)"

    -- Percentage Entries
    L["percentageEntryDeleteButton"] = "|cFFed3939Prozenteintrag entfernen|r"
    L["percentageEntryPercent"] = "Prozent"
    L["percentageEntryOperatorDropdown"] = "Operator"
    L["percentageEntryOptionsHeading"] = "Optionen"

    -- Encounters
    L["encounterHeading"] = "Boss Optionen"
    L["encounterTriggerHeading"] = "Auslöser"
    L["encounterImport"] = "Boss importieren"
    L["encounterExport"] = "Boss exportieren"
    L["encounterID"] = "Boss-ID"
    L["encounterName"] = "Name"
    L["encounterSelectDropdown"] = "Boss auswählen"
    L["encounterDeleteButton"] = "|cFFed3939Boss entfernen|r"
    L["encounterOptionsHeading"] = "Boss Optionen"
    L["encounterEnabled"] = "Aktiviert?"
    L["encounterOverview"] = "Übersicht der Auslöser"
    L["timerOverview"] = "Timer"
    L["rotationOverview"] = "Rotationen"
    L["healthPercentageOverview"] = "Lebens-Prozente"
    L["powerPercentageOverview"] = "Energie-Prozente"

    L["encounterOverviewDisabled"] = "deaktiviert"
    L["encounterOverviewOf"] = "von"
    L["encounterOverviewStartTimerOn"] = "Starte Timer wenn"
    L["encounterOverviewStopTimerOn"] = "Stoppe Timer wenn"
    L["encounterOverviewTimings"] = "Auslösungszeiten"
    L["encounterOverviewStartTriggerOn"] = "Starte Auslöser wenn"
    L["encounterOverviewStopTriggerOn"] = "Starte Auslöser wenn"
    L["encounterOverviewTriggerOn"] = "Löse aus wenn"
    L["encounterOverviewEntries"] = "Rotationseinträge"

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
    L["conditionRemoveStopCondition"] = "|cFFed3939Stop Auslöser entfernen|r"
    L["conditionAddStopCondition"] = "Stop Auslöser hinzufügen"
    L["conditionRemoveStartCondition"] = "|cFFed3939Start Auslöser entfernen|r"
    L["conditionAddStartCondition"] = "Start Auslöser hinzufügen"
    L["encounterOverviewPercentagePrefixHealth"] = "Leben"
    L["encounterOverviewPercentagePrefixPower"] = "Energie"
    -- Timers
    L["timerEnabled"] = "Aktiviert"
    L["timerName"] = "Name"
    L["timerDeleteButton"] = "|cFFed3939Timer entfernen|r"
    L["timerOptionsHeading"] = "Timer Optionen"
    L["timerOptionsTriggerAtOccurence"] = "Nach n Start Auslösern starten"

    -- Timings
    L["timingOptions"] = "Zeiteinträge"
    L["timingSeconds"] = "Auslösungszeiten"
    L["timingSecondsTooltip"] = "Die Zeiten bei denen die Nachrichten an die Empfänger geschickt werden. (Gezählt ab der Aktivierung des Timers; Kommaseparierte Liste z.B. 1, 3, 10)"
    L["timingDeleteButton"] = "|cFFed3939Auslösungszeit entfernen|r"
    L["timingOptionsHeading"] = "Optionen"


    -- Overlay
    L["senderGroup"] = "Absender"
    L["receiversGroup"] = "Empfänger"
    L["overlaySoundGroup"] = "Sound"
    L["overlayFontGroup"] = "Schrift"
    L["overlayPositionGroup"] = "Position"
    L["overlayFontColor"] = "Schriftfarbe"
    L["overlayFontSize"] = "Schriftgröße"
    L["overlayBackdropColor"] = "Hintergrundfarbe"
    L["overlayLocked"] = "Gesperrt"
    L["overlayEnableSound"] = "Töne aktivieren"
    L["overlayDefaultSoundFile"] = "Standard Sound"

    L["deleteTimer"] = "|cFFed3939Timer entfernen|r"
    L["deleteRotation"] = "|cFFed3939Rotation entfernen|r"
    L["deletePercentage"] = "|cFFed3939Prozent entfernen|r"
    L["deleteEncounter"] = "|cFFed3939Boss entfernen|r"
    L["exportEncounter"] = "Boss exportieren"
    L["importEncounter"] = "Boss importieren"
    L["newEncounter"] = "|cFF76ff68Neuer Boss|r"
    L["newTimer"] = "|cFF76ff68Neuer Timer|r"
    L["newRotation"] = "|cFF76ff68Neue Rotation|r"
    L["newHealthPercentage"] = "|cFF76ff68Neues Lebens-Prozent|r"
    L["newPowerPercentage"] = "|cFF76ff68Neues Energie-Prozent|r"

    -- Confirmation
    L["confirmationWindow"] = "Bestätigung"
    L["confirmationDialogOk"] = "Ok"
    L["confirmationDialogCancel"] = "Abbrechen"
    L["importByGroupConfirmationText"] = 
        "Bist Du sicher, dass Du das Raid-Roster anhand der aktuellen Gruppe importieren willst?|n"..
        "|cFF69CCF0Notiz: |rDieser Vorgang wird alle aktuell eingetragenen Namen überschreiben."
    L["deleteConfirmationText"] = "Bist Du sicher, dass Du folgenden Eintrag entfernen willst:"
    L["clearRaidRosterConfirmationText"] = "Bist Du sicher, dass Du alle Raidroster Einträge entfernen willst?"
    L["cloneConfirmationText"] = "Bist Du sicher, dass Du diesen Auslöser duplizieren möchtest?"
    L["optionsCustomNameDeleteButtonConfirmation"] = "Bist Du sicher, dass du den benutzerdefinierten Platzhalter entfernen willst?"

    -- Clone
    L["cloneTimer"] = "Timer duplizieren"
    L["cloneRotation"] = "Rotation duplizieren"
    L["clonePercentage"] = "Prozent duplizieren"

    L["deleteTabEntryConfirmationText"] = "Bist Du sicher, dass du diesen Eintrag löschen willst?"

    -- Encounters
    L["--- Castle Nathria ---"] = "--- Schloss Nathria ---"
    L["CN - Shriekwing" ] = "SN - Schrillschwinge"
    L["CN - Altimor the Huntsman" ] = "SN - Altimor der Jäger"
    L["CN - Hungering Destroyer" ] = "SN - Hungernder Zerstörer"
    L["CN - Artificer Xy'Mox" ] = "SN - Konstrukteur Xy'Mox"
    L["CN - Sun King's Salvation" ] = "SN - Die Rettung des Sonnenkönig"
    L["CN - Lady Inerva Darkvein" ] = "SN - Lady Inerva Dunkelader"
    L["CN - The Council of Blood" ] = "SN - Der Rat des Blutes"
    L["CN - Sludgefist" ] = "SN - Schlickfaust"
    L["CN - Stoneborne Generals" ] = "SN - Generäle der Steingeborenen"
    L["CN - Sire Denathrius" ] = "SN - Graf Denathrius"

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
    L["PF - Globgrog" ] = "PF - Globgrog"
    L["PF - Doctor Ickus" ] = "PF - Doctor Ickus"
    L["PF - Domina Venomblade" ] = "PF - Domina Venomblade"
    L["PF - Margrave Stradama" ] = "PF - Margrave Stradama"

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