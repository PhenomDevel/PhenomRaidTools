if GetLocale() == "deDE" then
  L["sender"] = "Absender"
  L["receiver"] = "Empfänger"
  L["sender+receiver"] = "Absender & Empfänger"

  L["mainWindowTitle"] = "PhenomRaidTools"

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
    "Wenn du das Aussehen des für das Empfänger-Overlay ändern möchtest bitte navigiere auf `|cFF69CCF0Overlays|r`."
  L["optionsEnabled"] = "Aktiviert"
  L["optionsDebugMode"] = "Debugmodus"
  L["optionsDebugLog"] = "Protokoll des letzten Bosses"
  L["optionsShowOverlay"] = "Overlay anzeigen"
  L["optionsHideOverlayAfterCombat"] = "Overlay nach dem Kampf ausblenden"
  L["optionsDifficultyExplanation"] = "Hier können die Schwierigkeiten ausgewählt werden, auf denen das Add-on aktiv sein soll."
  L["optionsDefaultsExplanation"] = "Hier können Standardwerte für die Auslöser ausgewählt werden."
  L["optionsRaidRosterExplanation"] = "Hier können Spielernamen des Raidkaders eingetragen werden, um diese später zu referenzieren mit z.B. |cFF69CCF0$tank2|r |cFF69CCF0$heal1|r etc."
  L["optionsHideDisabledTriggers"] = "Deaktivierte Auslöser verstecken"
  L["optionsRaidRosterImportByGroup"] = "Aktuellen Schlachtzug importieren"
  L["optionsRaidRosterClear"] = "Raidroster leeren"
  L["optionsVersionCheck"] = "Versionscheck ausführen"
  L["optionsOpenProfiles"] = "Profilseite öffnen"

  L["debugModeGroup"] = "Debugmodus"
  L["debugModeEnabled"] = "Aktiviert"
  L["debugModeEnabledTooltip"] = "Wenn dieser Modus aktiviert ist, werden einige zusätzliche Informationen in den Chat ausgegeben, die bei einer Fehleranalyse helfen können."

  L["runModeGroup"] = "Ausführungsmodus"
  L["runModeDropdown"] = "Select mode"

  L["testModeGroup"] = "Testmodus"
  L["testModeEnabled"] = "Aktiviert"
  L["testModeEncounterID"] = "Zu testender Boss"

  L["messageFilterGroup"] = "Nachrichtenfilter"
  L["messageFilterByDropdown"] = "Filter nach"
  L["messageFilterGuildRankDropdown"] = "Mindestens benötigter Gilden Rang"
  L["messageFilterNamesEditBox"] = "Spielernamen"
  L["messageFilterNamesEditBoxTooltip"] = "Komma separierte Liste von Spielernamen.\n"..
    "Wenn die Liste leer ist, werden keine Nachrichten gefiltert.\n"..
    "(!) das kann zu sehr vielen Nachrichten führen, wenn einige Spieler in der Raidgruppe Nachrichten konfiguriert haben."
  L["messageFilterAlwaysIncludeMyself"] = "Nachrichten von mir selbst immer erhalten"
  L["messageFilterExplanationNames"] = "Du filters Nachrichten aktuell nach |cFF69CCF0Spielernamen|r, dadurch werden nur Nachrichten von diesen Spielern angezeigt."
  L["messageFilterExplanationNoNames"] = "Du filters Nachrichten aktuell nach |cFF69CCF0Spielernamen|r, aber hast keine Namen konfiguriert. Dadurch werden alle Nachrichten von anderen Spielern angezeigt."
  L["messageFilterExplanationGuildRank"] = "Du filters Nachrichten aktuell nach |cFF69CCF0Gildenrang|r, dadurch werden alle Nachrichten von Spielern mit diesem Gildenrang oder höher angezeigt."
  L["messageFilterExplanationAlwaysIncludeMyself"] = "\nZusätzlich lässt du dir immer deine eigenen Nachrichten anzeigen."

  L["optionsCustomPlaceholdersHeading"] = "Benutzerdefinierte Platzhalter"
  L["optionsCustomPlaceholderDeleteButton"] = "|cFFed3939Löschen|r"
  L["optionsCustomPlaceholderTypePlayer"] = "Spieler"
  L["optionsCustomPlaceholderTypeGroup"] = "Gruppe"
  L["optionsCustomPlaceholderType"] = "Typ"
  L["optionsCustomPlaceholderName"] = "Name"
  L["optionsCustomPlaceholderNameTooltip"] = "Platzhalter dürfen keine Leerzeichen enthalten"
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
  L["treeTemplates"] = "Vorlagen"
  L["treeEncounters"] = "Bosse"
  L["treeTimer"] = "Timer"
  L["treeRotation"] = "Rotationen"
  L["treeHealthPercentage"] = "Lebens-Prozente"
  L["treePowerPercentage"] = "Energie-Prozente"
  L["treeCustomPlaceholder"] = "Platzhalter"

  -- Defaults
  L["rotationDefaults"] = "Rotation"
  L["percentageDefaults"] = "Prozente"
  L["messageDefaults"] = "Nachricht"
  L["defaultShouldRestart"] = "Soll neu starten"
  L["defaultIgnoreDuration"] = "Ignorieren für"
  L["defaultIgnoreAfterActivation"] = "Nach der Aktivierung ignorieren"
  L["defaultEvent"] = "Event"
  L["defaultMessage"] = "Nachricht"
  L["defaultDuration"] = "Dauer (s)"
  L["defaultTargets"] = "Empfänger"
  L["defaultTargetsTooltip"] =
    "Kommaseparierte Liste von Empfängern\n"..
    "Beispiele:\n"..
    "- |cFF69CCF0$me|r → wird mit dem Namen des aktuellen Charakters ausgetauscht\n"..
    "- |cFF69CCF0$target|r → wird mit dem Ziel des Kampfevents ausgetauscht\n"..
    "- |cFF69CCF0$healN|r or |cFF69CCF0$tankN|r or |cFF69CCF0$ddN|r → N ist eine Zahl zwischen 1 und 21. Wird mit dem konfigurierten Namen im Raidkader ausgetauscht.\n"..
    "- |cFF69CCF0$groupN|r → N ist eine Zahl zwischen 1 und 8. Wird mit *allen* Spielern der entsprechenden Gruppe ausgetauscht.\n"..
    "- |cFF69CCF0ALL|r |cFF69CCF0HEALER|r |cFF69CCF0TANK|r |cFF69CCF0DAMAGER|r\n"
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
  L["messageTargetOverlay"] = "Ziel Overlay"
  L["messageWithCountdown"] = "Countdown anzeigen"
  L["messageCustomSpellID"] = "Benutzerdefinierte Zauber-ID"
  L["messageDeleteButton"] = "|cFFed3939Nachricht entfernen|r"
  L["messageTargets"] = "Empfänger"
  L["messageTargetsTooltip"] =
    "Kommaseparierte Liste von Empfängern\n"..
    "Beispiele:\n"..
    "- |cFF69CCF0$me|r → wird mit dem Namen des aktuellen Charakters ausgetauscht\n"..
    "- |cFF69CCF0$target|r → wird mit dem Ziel des Kampfevents ausgetauscht\n"..
    "- |cFF69CCF0$healN|r or |cFF69CCF0$tankN|r or |cFF69CCF0$ddN|r → N ist eine Zahl zwischen 1 und 21. Wird mit dem konfigurierten Namen im Raidkader ausgetauscht.\n"..
    "- |cFF69CCF0$groupN|r → N ist eine Zahl zwischen 1 und 8. Wird mit *allen* Spielern der entsprechenden Gruppe ausgetauscht.\n"..
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
  L["rotationShouldRestart"] = "Soll der Auslöser neu starten?"
  L["rotationIgnoreAfterActivation"] = "Nach der Aktivierung ignorieren"
  L["rotationIgnoreDuration"] = "Ignorieren für (s)"
  L["rotationTriggerConditionHeading"] = "Auslöser"
  L["rotationOptionsHeading"] = "Optionen"

  -- RotationEntries
  L["rotationEntryHeading"] = "Rotationseinträge"
  L["rotationEntryDeleteButton"] = "|cFFed3939Eintrag entfernen|r"
  L["cloneRotationEntry"] = "Rotationseintrag duplizieren"

  -- Percentages
  L["percentageEnabled"] = "Aktiviert"
  L["percentageDeleteButton"] = "|cFFed3939Prozent entfernen|r"
  L["percentageName"] = "Name"
  L["percentageUnitID"] = "Unit"
  L["percentageUnitIDTooltip"] = {
    "Die Einheit, welche geprüft werden soll.",
    "Wenn mehrere Einheiten mit dem gleichen Namen oder ID gefunden werden, wird nur die erste geprüft.",
    "Einheiten-Namen und IDs können auf z.B. wowhead.com gefunden werden.",
    "Beispiele:",
    "- |cFF69CCF0boss1|r",
    "- |cFF69CCF0"..UnitName("player").."|r",
    "- |cFF69CCF038046|r"
  }
  L["percentageCheckAgain"] = "Mehrfach prüfen?"
  L["percentageOptionsHeading"] = "Optionen"
  L["percentageCheckAgainAfter"] = "Nochmal prüfen nach (s)"
  L["clonePercentageEntry"] = "Prozenteintrag duplizieren"

  -- Percentage Entries
  L["percentageEntryDeleteButton"] = "|cFFed3939Prozenteintrag entfernen|r"
  L["percentageEntryPercent"] = "Prozent"
  L["percentageEntryOperatorDropdown"] = "Operator"
  L["percentageEntryOptionsHeading"] = "Optionen"

  -- Encounters
  L["encounterHeading"] = "Optionen"
  L["encounterTriggerHeading"] = "Auslöser"
  L["encounterImport"] = "Importieren"
  L["encounterExport"] = "Exportieren"
  L["encounterID"] = "Boss-ID"
  L["encounterName"] = "Name"
  L["encounterSelectDropdown"] = "Boss auswählen"
  L["encounterDeleteButton"] = "|cFFed3939Boss entfernen|r"
  L["encounterEnabled"] = "Aktiviert?"
  L["encounterOverview"] = "Übersicht der Auslöser"
  L["timerOverview"] = "Timer"
  L["rotationOverview"] = "Rotationen"
  L["healthPercentageOverview"] = "Lebens-Prozente"
  L["powerPercentageOverview"] = "Energie-Prozente"

  L["encounterOverviewDisabled"] = "deaktiviert"
  L["encounterOverviewOf"] = "von"
  L["encounterOverviewStartTimerOn"] = "Starte Timer, wenn"
  L["encounterOverviewStopTimerOn"] = "Stoppe Timer, wenn"
  L["encounterOverviewTimings"] = "Auslösungszeiten"
  L["encounterOverviewStartTriggerOn"] = "Starte Auslöser, wenn"
  L["encounterOverviewStopTriggerOn"] = "Starte Auslöser, wenn"
  L["encounterOverviewTriggerOn"] = "Löse aus, wenn"
  L["encounterOverviewEntries"] = "Rotationseinträge"

  -- Conditions
  L["conditionEvent"] = "Event"
  L["conditionEventTooltip"] = "Das Kampfevent bei dem der Auslöser ausgelöst werden soll"
  L["conditionSpellID"] = "Zauber-ID"
  L["conditionSpellIDTooltip"] = "Die Zauber-ID bei dem der Auslöser ausgelöst werden soll (kann leer sein)"
  L["conditionTarget"] = "Ziel"
  L["conditionTargetTooltip"] = "Das Event-Ziel, bei dem der Auslöser ausgelöst werden soll (z.B. der exakte Name eines Gegners, |cFF69CCF0"..UnitName("player").."|r)"
  L["conditionSource"] = "Quelle"
  L["conditionSourceTooltip"] = "Die Event-Quelle bei dem der Auslöser ausgelöst werden soll (z.B. |cFF69CCF0boss1|r, der exakte Name eines Gegners)"
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
  L["timerOptionsResetCounterOnStop"] = "Zähler bei Stop neu starten"

  -- Timings
  L["timingOptions"] = "Zeiteinträge"
  L["timingSeconds"] = "Auslösungszeiten"
  L["timingOffset"] = "Versatz"
  L["timingName"] = "Name"
  L["timingSecondsTooltip"] = "Die Zeiten bei denen die Nachrichten an die Empfänger geschickt werden. (Kommaseparierte Liste)"..
    "Es werden verschiedene Formate unterstützt\n"..
    "Beispiele:\n"..
    " - |cFF69CCF055|r\n"..
    " - |cFF69CCF001:55|r\n"..
    " - |cFF69CCF01:5|r"
  L["timingDeleteButton"] = "|cFFed3939Auslösungszeit entfernen|r"
  L["timingOptionsHeading"] = "Optionen"
  L["cloneTiming"] = "Timing duplizieren"

  -- Trigger
  L["descriptionMultiLineEditBox"] = "Beschreibung"

  -- Overlay
  L["senderGroup"] = "Absender"
  L["receiversGroup"] = "Empfänger"
  L["overlayLabel"] = "Name"
  L["overlaySoundGroup"] = "Sound"
  L["overlayFontGroup"] = "Schrift"
  L["overlayPositionGroup"] = "Position"
  L["overlayFontColor"] = "Schriftfarbe"
  L["overlayFontSize"] = "Schriftgröße"
  L["overlayBackdropColor"] = "Hintergrundfarbe"
  L["overlayLocked"] = "Gesperrt"
  L["overlayEnableSound"] = "Aktiviert"
  L["overlayDefaultSoundFile"] = "Standard Sound"

  L["deleteTimer"] = "|cFFed3939Timer entfernen|r"
  L["deleteRotation"] = "|cFFed3939Rotation entfernen|r"
  L["deletePercentage"] = "|cFFed3939Prozent entfernen|r"
  L["deleteEncounter"] = "|cFFed3939Boss entfernen|r"
  L["exportEncounter"] = "Exportieren"
  L["importEncounter"] = "Importieren"
  L["newEncounter"] = "|cFF76ff68Neu|r"
  L["newTimer"] = "|cFF76ff68Neuer Timer|r"
  L["newRotation"] = "|cFF76ff68Neue Rotation|r"
  L["newHealthPercentage"] = "|cFF76ff68Neues Lebens-Prozent|r"
  L["newPowerPercentage"] = "|cFF76ff68Neues Energie-Prozent|r"

  -- Confirmation
  L["confirmationWindow"] = "Bestätigung"
  L["confirmationDialogOk"] = "Ok"
  L["confirmationDialogCancel"] = "Abbrechen"
  L["importConfirmationMergeEncounter"] = "Der Boss ist bereits vorhanden. Sollen die Auslöser zusammengeführt worden?"
  L["importByGroupConfirmationText"] =
    "Bist Du sicher, dass Du das Raid-Roster anhand der aktuellen Gruppe importieren willst?|n"..
    "|cFF69CCF0Notiz: |rDieser Vorgang wird alle aktuell eingetragenen Namen überschreiben."
  L["deleteConfirmationText"] = "Bist Du sicher, dass Du folgenden Eintrag entfernen willst:"
  L["clearRaidRosterConfirmationText"] = "Bist Du sicher, dass Du alle Raidroster Einträge entfernen willst?"
  L["cloneConfirmationText"] = "Bist Du sicher, dass Du diesen Auslöser duplizieren möchtest?"
  L["optionsCustomNameDeleteButtonConfirmation"] = "Bist Du sicher, dass Du den benutzerdefinierten Platzhalter entfernen willst?"

  -- Import/Export
  L["exportFrame"] = "Export"
  L["importFrame"] = "Import"
  L["exportButton"] = "Export"
  L["importButton"] = "Import"
  L["removeAllButton"] = "|cFFed3939Delete all|r"

  -- Custom Placeholders
  L["removeAllCustomPlaceholderConfirmation"] = "Bist Du sicher, dass Du *ALLE* benutzerdefinierten Platzhalter entfernen willst?"

  -- Clone
  L["cloneTimer"] = "Timer duplizieren"
  L["cloneRotation"] = "Rotation duplizieren"
  L["clonePercentage"] = "Prozent duplizieren"

  L["deleteTabEntryConfirmationText"] = "Bist Du sicher, dass Du diesen Eintrag löschen willst?"

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

  L["copyTimer"] = "In Zwischenablage kopieren"
  L["copyRotation"] = "In Zwischenablage kopieren"
  L["copyPercentage"] = "In Zwischenablage kopieren"
  L["pasteTimer"] = "Einfügen aus Zwischenablage"
  L["pasteRotation"] = "Einfügen aus Zwischenablage"
  L["pastePercentage"] = "Einfügen aus Zwischenablage"

  -- Trigger
  L["triggerEnabled"] = "Aktiviert"
  L["triggerName"] = "Name"
  L["triggerDescription"] = "Beschreibung"
  L["triggerCloneButton"] = "Klonen"
  L["triggerDeleteButton"] = "|cFFed3939Löschen|r"

  -- Action
  L["actionType"] = "Typ"
  L["actionTypeCooldown"] = "Fähigkeit"
  L["actionTypeAdvanced"] = "Erweitert"
  L["actionTypeLoadTemplate"] = "Template laden"
  L["cooldownActionTargetDropdown"] = "Ziel"
  L["cooldownActionSpellDropdown"] = "Fähigkeit"
  L["cooldownActionCustomDropdownItem"] = "*Benutzerdefiniert*"

  -- Template
  L["saveAsTemplate"] = "Als Vorlage speichern"
  L["saveAsTemplateDescription"] = "Vorlage speichern\n"..
    "Bitte sicherstellen, dass alles korrekt eingestellt ist. Eine Vorlage ist nur eine Momentaufnahme.\n"..
    "Wenn Du Einstellungen veränderst, wird die Vorlage nicht automatisch mit angepasst."
  L["saveAsTemplateName"] = "Vorlagenname"
  L["templatesTabGroup"] = "Vorlagen"
  L["templatesTabGroupMessages"] = "Nachrichten"
  L["templatesTabGroupTimers"] = "Timer"
  L["templatesTabGroupRotations"] = "Rotationen"
  L["templatesTabGroupHealthPercentages"] = "Lebens-Prozente"
  L["templatesTabGroupPowerPercentages"] = "Energie-Prozente"
  L["messageTemplateName"] = "Name"
  L["templateMessageNewButton"] = "|cFF76ff68Neu|r"
  L["templateMessagesEmptyDescription"] = "Aktuell sind keine Vorlagen vorhanden."
  L["templateMessagesDeleteDropdown"] = "Vorlage löschen"
  L["templateMessagesDeleteConfirmation"] = "Bist Du Dir sicher, dass Du die Vorlage löschen willst?"
  L["loadTemplateActionTemplateDropdown"] = "Vorlage wählen"

else
  return
end
