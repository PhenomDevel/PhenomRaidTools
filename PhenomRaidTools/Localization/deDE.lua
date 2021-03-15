local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("PhenomRaidTools", "deDE")
if not L then return end

L = L or {}
L["--- Castle Nathria ---"] = "--- Schloss Nathria ---"
L["--- De Other Side ---"] = "--- Die Andere Seite ---"
L["--- Halls of Atonement ---"] = "--- Hallen der Sühne ---"
L["--- Mists of Tirna Scithe ---"] = "--- Die Nebel von Tirna Scithe ---"
L["--- Necrotic Wake ---"] = "--- Die Nekrotische Schneise ---"
L["--- Plaguefall ---"] = "--- Seuchensturz ---"
L["--- Sanguine Depths ---"] = "--- Die Blutigen Tiefen ---"
L["--- Spires of Ascension ---"] = "--- Spitzen des Aufstiegs ---"
L["--- Theater of Pain ---"] = "--- Theater der Schmerzen ---"
L["\"PhenomRaidTools will only load for the configured difficulties."] = "PhenomRaidTools wird nur für die konfigurierten Schwierigkeitsgrade geladen."
L["%s (%s) health match (%s%% %s %s%%)"] = true
L["* Custom *"] = "* Benutzerdefiniert *"
L["Activates the debug mode."] = "Aktiviert den Debug Modus."
L["Activates the receiver mode."] = "Aktiviert den Empfänger Modus."
L["Activates the sender mode."] = "Aktiviert den Sender Modus."
L["Activates the test mode."] = "Aktiviert den Test Modus"
L["Add Name"] = "Name hinzufügen"
L["Add Start Condition"] = "Start Bedingung hinzufügen"
L["Add Stop Condition"] = "Stop Bedingung hinzufügen"
L["Add Target"] = "Ziel hinzufügen"
L["Additional Events"] = "Zusätzliche Events"
L["Advanced"] = "Erweitert"
L["After how many occurrences of\\nstart condition the timer should start."] = "Nach wie vielen Vorkommnissen der Start Bedingung soll der Timer starten."
L[ [=[After how many seconds the
message should be displayed.]=] ] = [=[Nach wie vielen Sekunden
soll die Nachricht angezeigt werden.]=]
L[ [=[After how many seconds the
message should be displayed.]=] ] = [=[Nach wie vielen Sekunden die
Nachricht angezeigt werden soll.]=]
L["Always includes yourself as valid sender."] = "Akzeptiert dich immer als validen Absender."
L["Are you sure you want to clear the current raid roster?"] = "Bist Du dir sicher, dass du den Raidkader leeren willst?"
L["Are you sure you want to clone %s?"] = "Bist Du dir sicher, dass Du %s klonen willst?"
L["Are you sure you want to delete %s?"] = "Bist Du dir sicher, dass Du %s löschen willst?"
L["Are you sure you want to delete template %s?"] = "Bist Du dir sicher, dass Du die Vorlage %s löschen willst?"
L["Are you sure you want to import your current group?\""] = "Bist Du dir sicher, dass Du die aktuelle Gruppe importieren willst?"
L["Are you sure you want to merge encounters?"] = "Bist Du dir sicher, dass Du die Bosse zusammenführen willst?"
L["Are you sure you want to remove all custom placeholders?"] = "Bist Du dir sicher, dass Du alle benutzerdefinierten Platzhalter löschen willst?"
L["Are you sure you want to save this message as template?"] = "Bist Du dir sicher, dass Du diese Nachricht als Vorlage speichern willst?"
L["Backdrop Color"] = "Hintergrundfarbe"
L[ [=[Can be either of
- Player name
- Custom Placeholder (e.g. $tank1)
- $target (event target)]=] ] = [=[Kann eins der folgenden sein
- Spielername
- Benutzerdefinierter Platzhalter
- $target (Event-Ziel)]=]
L[ [=[Can be either of
- Unit-Name
- Unit-ID (boss1, player ...)
- Numeric Unit-ID]=] ] = [=[Kann eins der folgenden sein
- Name einer Einheit
- ID einer Einheit (boss1, player...)
- Numerische ID einer Einheit]=]
L[ [=[Can be either of
- valid unique spell ID
- spell name known to the player character]=] ] = [=[Kann eins der folgenden sein
- valide eindeutige Zauber-ID
- Zauber-Name eines vom Charakter bekannten Zaubers]=]
L[ [=[Can be either of
- Player name
- Custom Placeholder (e.g. $tank1)
- $target (event target)]=] ] = [=[Kann eins der folgenden sein
- Spielername
- Benutzerdefinierter Platzhalter (z.B. $tank1)
- $target (Ereignis-Ziel)]=]
L[ [=[Can be either of
- Unit-Name
- Unit-ID (boss1, player ...)
- Numeric Unit-ID]=] ] = [=[Kann eins der folgenden sein
- Einheitenname
- Einheiten-ID (boss1, player, ...)
- Numerische Einheiten-ID]=]
L[ [=[Can be either of
- valid unique spell ID
- spell name known to the player character]=] ] = [=[Kann eins der folgenden sein
- valide eindeutige Zauber-ID
- Zaubername, welcher dem Charakter bekannt ist]=]
L["Cancel"] = "Abbrechen"
L["Check after"] = "Prüfen nach"
L["Check again"] = "Erneut prüfen"
L["Clear"] = "Leeren"
L["Clone"] = "Klonen"
L["CN - Altimor the Huntsman"] = "SN - Jäger Altimor"
L["CN - Artificer Xy'Mox"] = "SN - Konstrukteur Xy'mox"
L["CN - Hungering Destroyer"] = "SN - Hungernder Zerstörer"
L["CN - Lady Inerva Darkvein"] = "SN - Lady Inerva Dunkelader"
L["CN - Shriekwing"] = "SN - Schrillschwinge"
L["CN - Sire Denathrius"] = "SN - Graf Denathrius"
L["CN - Sludgefist"] = "SN - Schlickfaust"
L["CN - Stone Legion Generals"] = "SN - Generäle der Steinlegion"
L["CN - Sun King's Salvation"] = "SN - Rettung des Sonnenkönigs"
L["CN - The Council of Blood"] = "SN - Der Rat des Blutes"
L["Coming soon"] = "Kommt bald"
L["Comma separated list of player names."] = "Komma separierte Liste von Spielernamen."
L["Comma separated list of timings\\supports different formats\\n- 69\\n- 1:09\\n- 00:09"] = [=[Komma separierte Liste von Zeit Einträgen
Unterstützt verschiedene Formate
- 69
- 1:09
- 00:09]=]
L["Condition"] = "Bedingung"
L["Confirmation"] = "Bestätigung"
L["Cooldown"] = "Zauber"
L["Copy"] = "Kopieren"
L["Countdown"] = true
L["Custom Placeholder"] = "Benutzerdefinierter Platzhalter"
L["Custom Placeholders"] = "Benutzerdefinierte Platzhalter"
L["Custom Sound"] = "Benutzerdefinierter Sound"
L["Damage"] = "Schaden"
L["Debug Log"] = "Debug Protokoll"
L["Debug Mode"] = "Debug Modus"
L["Default Sound"] = "Standard Sound"
L["Delay"] = "Verzögerung"
L["Delete"] = "Löschen"
L["Description"] = "Beschreibung"
L["Developer"] = "Entwickler"
L["Difficulties"] = "Schwierigkeitsgrade"
L["Disabled"] = "Deaktiviert"
L["Dungeon"] = true
L["Duration"] = "Dauer"
L["Enable on"] = "Aktivieren für"
L["Enabled"] = "Aktiviert"
L["Encounter"] = "Boss"
L["Encounter-ID"] = "Boss-ID"
L["Entries %s"] = "Einträge %s"
L["Event"] = "Ereignis"
L["Export"] = "Exportieren"
L["Export String"] = "Export Daten"
L["Filter by"] = "Einschränken nach"
L[ [=[Filter out all messages
below selected guild rank.]=] ] = "Alle Nachrichten unter dem ausgewählten Gildenrank filtern."
L[ [=[Filter out all messages
below selected guild rank.]=] ] = [=[Alle Nachrichten unter
einem bestimmten Gildenrank filtern.]=]
L["Font"] = "Schrift"
L["Font Color"] = "Schriftfarbe"
L["General"] = "Allgemein"
L["Group"] = "Gruppe"
L["Guild Rank"] = "Gildenrank"
L["guild rank"] = "Gildenrank"
L["Healer"] = "Heiler"
L["Health"] = "Leben"
L["Health Percentage"] = "Lebensprozent"
L["Health Percentages"] = "Lebensprozente"
L["Heroic"] = "Heroisch"
L["Hide after combat"] = "Nach dem Kampf ausblenden"
L["Hide disabled triggers"] = "Deaktivierte Auslöser verstecken"
L["How long the message should be displayed."] = "Wie lange die Nachricht dargestellt werden soll."
L["Ignore after activation"] = "Nach der Aktivierung ignorieren"
L["Ignore all events for X seconds."] = "Ignoriere alle Ereignisse für X Sekunden."
L["Ignore for"] = "Ignorieren für"
L["Import"] = "Importieren"
L["Import raid"] = "Raidkader importieren"
L["Import String"] = "Import Daten"
L["In addition you always include %s as valid sender."] = "Zusätzlich bist %s immer als valider Absender ausgewählt."
L["Include myself"] = "Inkludiere mich selbst "
L["Information"] = true
L["Interesting Links"] = "Interessante Links"
L["Load Template"] = "Vorlage Laden"
L["Locked"] = "Gesperrt"
L["Message"] = "Nachricht"
L["Message Filter"] = "Nachrichtenfilter"
L["Messages"] = "Nachrichten"
L["Modes"] = "Modi"
L["Mythic"] = "Mythisch"
L["Name"] = true
L["Names"] = "Namen"
L["New"] = "Neu"
L["Normal"] = true
L["Note: Not every element can be displayed in a raid warning e.g. icons."] = "Anmerkung: Nicht jedes Element kann in einer Schlachtzugswarnung dargestellt werden. "
L["Occurence"] = "Vorkommnis"
L["Occurrence"] = "Vorkommnisse"
L["of"] = "von"
L["Offset"] = "Versatz"
L["Offset will be applied to all timings."] = "Der Versatz wird auf alle Zeit Einträge angewendet."
L["OK"] = "Ok"
L["Operator"] = true
L["Options"] = "Optionen"
L["Overlay"] = true
L["Overlay on which the message should show up"] = "Auf welchem Overlay die Nachricht angezeigt werden soll."
L["Overlays"] = true
L["Overview"] = "Übersicht"
L["Paste"] = "Einfügen"
L["Percentage"] = "Prozent"
L["Placeholder"] = "Platzhalter"
L["Player"] = "Spieler"
L["player names"] = "Spielernamen"
L["Player who should receive the message"] = "Spieler, welcher die Nachricht erhalten soll"
L["Position"] = true
L["Power"] = "Energie"
L["Power Percentage"] = "Energie-Prozent"
L["Power Percentages"] = "Energie-Prozente"
L["Preview: "] = "Vorschau: "
L["Profiles"] = "Profile"
L["PRT: Default"] = true
L["Raid"] = "Schlachtzug"
L["Raid mark"] = "Schlachtzugsmarkierung"
L["Raid roster"] = "Schlachtzugskader"
L["Raid warning"] = "Schlachtzugsmarkierung"
L["Receiver Mode"] = "Empfänger Modus"
L["Receivers"] = "Empfänger"
L["Remove"] = "Entfernen"
L["Remove all"] = "Alle entfernen"
L["Remove empty names"] = "Leere Namen entfernen"
L["Reset counter on stop"] = "Zähler nach Stop zurücksetzen"
L["Resets the counter of start conditions\\nwhen the timer is stopped."] = "Setzt den Zähler zurück wenn der Timer gestoppt wird."
L["Restart"] = "Neustarten"
L[ [=[Restarts the rotation when
no more entries are found.]=] ] = [=[Startet die Rotation neu,
wenn keine Einträge mehr gefunden werden.]=]
L[ [=[Restarts the rotation when
no more entries are found.]=] ] = [=[Startet die Rotation neu,
wenn keine Einträge mehr gefunden werden.]=]
L["Rotation"] = true
L["Rotation Entry"] = "Rotationseintrag"
L["Rotations"] = "Rotationen"
L["Save as template"] = "Als Vorlage speichern"
L["Select Encounter"] = "Boss auswählen"
L[ [=[Selected player/placeholder will be
added to the list of targets.]=] ] = [=[Ausgewählter Spieler/Platzhalter
wird der Liste der Empfänger hinzugefügt.]=]
L[ [=[Selected player/placeholder will be
added to the list of targets.]=] ] = [=[Ausgewählter Spieler/Platzhalter wird
der Liste der Ziele hinzugefügt.]=]
L["Sender"] = "Absender"
L["Sender Mode"] = "Absender Modus"
L["Size"] = "Größe"
L["Sound"] = true
L["Source"] = "Quelle"
L["Special Thanks"] = "Besonderen Dank"
L["Spell"] = "Zauber"
L["Start Condition"] = "Start Bedingung"
L["Start on"] = "Startet wenn"
L["Stop Condition"] = "Stop Bedingung"
L["Stop on"] = "Stoppt wenn"
L[ [=[Supports following special symbols
- $target (event target)
- Custom placeholders (e.g. $tank1)
- Spell icons (e.g. {spell:17}
- Raid marks (e.g. {rt1})]=] ] = [=[Unterstützt folgende speziellen Symbole
- $target (Ereignis-Ziel)
- Benutzerdefinierte Platzhalter (z.B. $tank1)
- Zauber-Icon (z.B. {spell:17})
- Schlatzugsmarkierungen (z.B. {rt1})]=]
L["Tanks"] = true
L["Target"] = "Ziel"
L["Target Overlay"] = "Ziel Overlay"
L["Targets"] = "Ziele"
L["Template Name"] = "Vorlagenname"
L["Templates"] = "Vorlagen"
L["Test Mode"] = "Test Modus"
L["The defined default values will be used when creating new messages."] = "Die definierten Standardwerte werden benutzt, wenn neue Nachrichten erstellt werden."
L["There are currently no templates."] = "Aktuell gibt es keine Vorlagen."
L["Timer"] = true
L["Timers"] = "Timer"
L["Timings"] = "Zeit Einträge"
L["Timings %s"] = "Zeit Einträge %s"
L["Trigger Defaults"] = "Auslöser Standards"
L["Trigger on"] = "Auslösen wenn"
L["Trigger On %s %s %s"] = "Auslösen wenn %s %s %s"
L["Type"] = "Typ"
L["Types\\n%s - Only the first player found within the group will be messaged\\n%s - All players will be messaged"] = [=[Types
%s - Nur der erste erfolgreich gefundene Spieler wird benachrichtigt
%s - Alle gefundenen Spieler werden benachrichtigt]=]
L["Unit"] = "Einheit"
L["Version Check"] = "Versionsüberprüfung"
L["Will show a countdown of 5 seconds"] = "Zeigt einen Countdown von 5 Sekunden an."
L["X Offset"] = "X Versatz"
L["Y Offset"] = "Y Versatz"
L["You are currently in receiver only mode. Therefore some features are disabled because they only relate to the sender mode."] = "Du befindest dich gerade ausschließlich im Empfänger Modus. Daher werden manche Features nicht zur Verfügung stehen oder deaktiviert sein."
L["You are currently in test mode. Some triggers behave slightly different in test mode."] = "Du befindest dich aktuell im Test Modus. Manche Auslöser verhalten sich im Test Modus anders."
L["You can define custom placeholder which can be used as message targets."] = "Du kannst benutzerdefinierte Platzhalter definieren, welche in Nachrichten als Ziele genutzt werden können."
L["You can import or define your raid roster and use the placeholder within your triggers."] = "Du kannst deine aktuelle Gruppe importieren oder definieren, um diese als Platzhalter zu verwenden."
L["You currently filter messages by %s, but haven't configured any name yet. Therefore all messages from all players will be displayed."] = "Du filterst aktuell alle Nachrichten nach %s aber hast noch keinen Namen spezifiziert. Daher werden alle Nachrichten empfangen und nicht gefiltert."
L["You currently filter messages by %s. Therefore only message from players with the configured guild rank or higher will be displayed."] = "Du filterst aktuell alle Nachrichten nach %s. Daher werden nur Nachrichten von Spielern mit dem angegebenen Gildenrank oder höher angezeigt."
L["You currently filter messages by %s. Therefore only messages from those players will be displayed."] = "Du filterst aktuell alle Nachrichten nach %s. Daher werden Dir nur Nachrichten von den spezifizierten Spielern angezeigt."
L["yourself"] = "Du"
