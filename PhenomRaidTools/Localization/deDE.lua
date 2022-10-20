local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale("PhenomRaidTools", "deDE")
if not L then
  return
end

L = L or {}
L["- %s This only works for messages with type %s"] = "- %s Das funktioniert nur für Nachrichten vom Typ %s"
L["--- Castle Nathria ---"] = "--- Schloss Nathria ---"
L["--- De Other Side ---"] = "--- Die Andere Seite ---"
L["- Export any timer as ExRT note"] = "- Exportiere jeden Timer als MethodRaidTools Notiz"
L["--- Halls of Atonement ---"] = "--- Hallen der Sühne ---"
L["--- Mists of Tirna Scithe ---"] = "--- Die Nebel von Tirna Scithe ---"
L["--- Necrotic Wake ---"] = "--- Die Nekrotische Schneise ---"
L["--- Plaguefall ---"] = "--- Seuchensturz ---"
L["--- Sanguine Depths ---"] = "--- Die Blutigen Tiefen ---"
L["--- Spires of Ascension ---"] = "--- Spitzen des Aufstiegs ---"
L["- The profiles will change automatically once you change your specialization"] = "- Das Profil wird sich automatisch ändern, wenn du deine Spezialisierung wechselst"
L["- The spell database will be updated each patch automatically"] = "- Die Zauber Datenbank wird nach jedem Patch automatisch aktualisiert"
L["--- Theater of Pain ---"] = "--- Theater der Schmerzen ---"
L["- To do so you have to navigate to %s within any encounter and click %s"] = "- Um die Funktion zu nutzen navigiere zu %s innerhalb eines Bosses und klicke %s"
L["- Within the spell database you can search any spell the game has to over"] = "- In der Zauber Datenbank kannst Du nach jeglichem Zauber im Spiel suchen"
L["- You can now enable and select specialization specific profiles"] = "- Du kannst jetzt Spezialisierungsspezifische Profile aktivieren und auswählen"
L["\"PhenomRaidTools will only load for the configured difficulties."] = "PhenomRaidTools wird nur für die konfigurierten Schwierigkeitsgrade geladen."
L["%s (%s) health match (%s%% %s %s%%)"] = true
L["* Custom *"] = "* Benutzerdefiniert *"
L["Ability to export timers as ExRT note"] = "Möglichkeit Timer als MethodRaidTools Notiz zu exportieren"
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
L["Are you sure you want to clone this item?"] = "Bist Du dir sicher, dass du diesen Eintrag klonen willst?"
L["Are you sure you want to delete %s?"] = "Bist Du dir sicher, dass Du %s löschen willst?"
L["Are you sure you want to delete profile %s?"] = "Bist Du sicher, dass Du das Profil %s löschen willst?"
L["Are you sure you want to delete template %s?"] = "Bist Du dir sicher, dass Du die Vorlage %s löschen willst?"
L["Are you sure you want to delete this item?"] = "Bist Du dir sicher, dass du diesen Eintrag löschen willst?"
L["Are you sure you want to import your current group?\""] = "Bist Du dir sicher, dass Du die aktuelle Gruppe importieren willst?"
L["Are you sure you want to merge encounters?"] = "Bist Du dir sicher, dass Du die Bosse zusammenführen willst?"
L["Are you sure you want to remove all custom placeholders?"] = "Bist Du dir sicher, dass Du alle benutzerdefinierten Platzhalter löschen willst?"
L["Are you sure you want to reset profile %s?"] = "Bist Du sicher, dass Du das Profil %s zurücksetzen willst?"
L["Are you sure you want to save this message as template?"] = "Bist Du dir sicher, dass Du diese Nachricht als Vorlage speichern willst?"
L["Backdrop Color"] = "Hintergrundfarbe"
L["Buff/Debuff applied"] = "Stärkungs-/Schwächungszauber angewendet"
L["Buff/Debuff refreshed"] = "Stärkungs-/Schwächungszauber erneuert"
L["Buff/Debuff removed"] = "Stärkungs-/Schwächungszauber entfernt"
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
- NPC-ID]=] ] = [=[Kann eins der folgenden sein
- Name einer Einheit
- ID einer Einheit (boss1, player...)
- NPC-ID]=]
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
- valid unique spell ID
- spell name known to the player character]=] ] = [=[Kann eins der folgenden sein
- valide eindeutige Zauber-ID
- Zaubername, welcher dem Charakter bekannt ist]=]
L["Can be either of\\n- Player name\\n- Custom Placeholder (e.g. $tank1)\\n- $target (event target)\\n- TANK, HEALER, DAMAGER"] = [=[Kann eins der folgenden sein
- Spielername
- Benutzerdefinierter Platzhalter
- $target (Event-Ziel)
- TANK, HEALER, DAMAGER]=]
L["Cancel"] = "Abbrechen"
L["Changelog"] = "Änderungshistorie"
L["Check after"] = "Prüfen nach"
L["Check again"] = "Erneut prüfen"
L["Circle"] = "Kreis"
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
L["completed"] = "abgeschlossen"
L["Completed at"] = "Abgeschlossen am"
L["Condition"] = "Bedingung"
L["Confirmation"] = "Bestätigung"
L["Cooldown"] = "Zauber"
L["cooldown"] = true
L["Copy"] = "Kopieren"
L["Countdown"] = true
L["Created at:"] = "Erstellt am:"
L["Cross"] = "Kreuz"
L["Current Profile"] = "Aktuelles Profil"
L["Custom Placeholder"] = "Benutzerdefinierter Platzhalter"
L["Custom Placeholders"] = "Benutzerdefinierte Platzhalter"
L["Custom Sound"] = "Benutzerdefinierter Sound"
L["Damage"] = "Schaden"
L["Debug Log"] = "Debug Protokoll"
L["Debug Mode"] = "Debug Modus"
L["Default Sound"] = "Standard Sound"
L["Delay"] = "Verzögerung"
L["Delete"] = "Löschen"
L["Delete Profile"] = "Profil löschen"
L["Description"] = "Beschreibung"
L["Developer"] = "Entwickler"
L["Diamond"] = "Diamant"
L["Difficulties"] = "Schwierigkeitsgrade"
L["Disabled"] = "Deaktiviert"
L["Dungeon"] = true
L["Duration"] = "Dauer"
L["Each event has to be in a seperate line."] = "Jedes Event muss in einer eigenen Zeile stehen."
L["Each unit has to be in a seperate line."] = "Jede Einheit muss in einer eigenen Zeile stehen."
L["Enable on"] = "Aktivieren für"
L["Enabled"] = "Aktiviert"
L["Encounter"] = "Boss"
L["Encounter end"] = "Boss beendet"
L["Encounter found. Do you want to import the new version?"] = "Boss gefunden. Bist Du dir sicher, dass Du die neue Version importieren willst?"
L["Encounter start"] = "Boss gestartet"
L["Encounter-ID"] = "Boss-ID"
L["Entries %s"] = "Einträge %s"
L["Event"] = "Ereignis"
L["Events to track"] = "Zu verfolgende Events"
L["Export"] = "Exportieren"
L["Export String"] = "Export Daten"
L["ExRT  Note"] = "MethodRaidTools Notiz"
L["ExRT Note Generator"] = "MethodRaidTools Notiz Generator"
L["Filter by"] = "Einschränken nach"
L[ [=[Filter out all messages
below selected guild rank.]=] ] = "Alle Nachrichten unter dem ausgewählten Gildenrank filtern."
L[ [=[Filter out all messages
below selected guild rank.]=] ] = [=[Alle Nachrichten unter
einem bestimmten Gildenrank filtern.]=]
L["Font"] = "Schrift"
L["Font Color"] = "Schriftfarbe"
L["Force ExRT note update"] = "MethodRaidTools Notiz update erzwingen"
L["General"] = "Allgemein"
L["Generate ExRT Note"] = "MethodRaidTools Notiz generieren"
L["Group"] = "Gruppe"
L["Grow Direction"] = "Wachstumsrichtung"
L["guild rank"] = "Gildenrank"
L["Guild Rank"] = "Gildenrank"
L["Healer"] = "Heiler"
L["Health"] = "Leben"
L["Health Percentage"] = "Lebensprozent"
L["Health Percentages"] = "Lebensprozente"
L["Here you can search the spell database. The database is build up in the background and may not contain all known spells just yet. If you can't find a spell please check back later when status is `completed`."] = "Hier kannst Du die Zauber Datenbank durchsuchen. Die Zauber Datenbank wird im Hintergrund erzeugt. Wenn Du einen Zauber nicht finden kannst warte einige Zeit und warte bis der Status auf `completed` steht."
L["Heroic"] = "Heroisch"
L["Hide after combat"] = "Nach dem Kampf ausblenden"
L["Hide disabled triggers"] = "Deaktivierte Auslöser verstecken"
L["How long the message should be displayed."] = "Wie lange die Nachricht dargestellt werden soll."
L["If you want to track all events put `ALL` in the editbox."] = "Wenn Du alle Events verfolgen möchtest trage `ALL` ein."
L["If you want to track all units in your raid put `RAID` in the editbox."] = "Wenn Du alle Einheiten in deinem Raid verfolgen möchtest trage `RAID` ein."
L["If you want to track all units put `ALL` in the editbox."] = "Wenn Du alle Einheiten verfolgen möchtest trage `ALL` ein."
L["Ignore after activation"] = "Nach der Aktivierung ignorieren"
L["Ignore all events for X seconds."] = "Ignoriere alle Ereignisse für X Sekunden."
L["Ignore for"] = "Ignorieren für"
L["Import"] = "Importieren"
L["Import raid"] = "Raidkader importieren"
L["Import String"] = "Import Daten"
L["In addition you always include %s as valid sender."] = "Zusätzlich bist %s immer als valider Absender ausgewählt."
L["Include empty lines"] = "Leere Zeilen inkludieren"
L["Include line prefix"] = "Zeilen Präfix hinzufügen"
L["Include myself"] = "Inkludiere mich selbst "
L["Include section names"] = "Sektionsnamen hinzufügen"
L["Include title"] = "Titel hinzufügen"
L["Includes lines even if there are no entries within the prt timer."] = "Zeilen welche keine Nachrichten enthalten bleiben bestehen und werden ausgegeben."
L["Information"] = true
L["Interesting Links"] = "Interessante Links"
L["Last checked id"] = "Zuletzt geprüfte ID"
L["Latest Features"] = "Neuste Funktionen"
L["Load Template"] = "Vorlage Laden"
L["Locked"] = "Gesperrt"
L["Message"] = "Nachricht"
L["Message Filter"] = "Nachrichtenfilter"
L["Messages"] = "Nachrichten"
L["Modes"] = "Modi"
L["Moon"] = "Mond"
L["Mythic"] = "Mythisch"
L["Name"] = true
L["Names"] = "Namen"
L["New"] = "Neu"
L["New Profile"] = "Neues Profil"
L["Normal"] = true
L["Note: Not every element can be displayed in a raid warning e.g. icons."] = "Anmerkung: Nicht jedes Element kann in einer Schlachtzugswarnung dargestellt werden. "
L["Occurence"] = "Vorkommnis"
L["Occurrence"] = "Vorkommnisse"
L["Ocurrences"] = "Vorkommen"
L["of"] = "von"
L["Offset"] = "Versatz"
L["Offset will be applied to all timings."] = "Der Versatz wird auf alle Zeit Einträge angewendet."
L["OK"] = "Ok"
L["Once you change your current specialization the profile will change automatically."] = "Das Profil wird sich automatisch ändern, wenn du deine Spezialisierung wechselst"
L["Operator"] = true
L["Options"] = "Optionen"
L["Overlay"] = true
L["Overlay on which the message should show up"] = "Auf welchem Overlay die Nachricht angezeigt werden soll."
L["Overlays"] = true
L["Overview"] = "Übersicht"
L["Paste"] = "Einfügen"
L["Percentage"] = "Prozent"
L["Personalize note"] = "Notiz personalisieren"
L["Placeholder"] = "Platzhalter"
L["Player"] = "Spieler"
L["Player entered combat"] = "Spieler beginnt Kampf"
L["Player left combat"] = "Spieler verlässt Kampf"
L["player names"] = "Spielernamen"
L["Player who should receive the message"] = "Spieler, welcher die Nachricht erhalten soll"
L["Position"] = true
L["Power"] = "Energie"
L["Power Percentage"] = "Energie-Prozent"
L["Power Percentages"] = "Energie-Prozente"
L["Preview: "] = "Vorschau: "
L["Profiles"] = "Profile"
L["Profiles options tab"] = "Profile"
L["PRT: Default"] = true
L["Raid"] = "Schlachtzug"
L["Raid mark"] = "Schlachtzugsmarkierung"
L["Raid roster"] = "Schlachtzugskader"
L["Raid warning"] = "Schlachtzugsmarkierung"
L["Rebuild spell database"] = "Zurücksetzen"
L["Rebuilding the spell cache can take a while.|nAre you sure you want to rebuild it?"] = "Das Zurücksetzen der Zauber Datenbank kann einige Zeit in Anspruch nehmen.|nBist Du dir sicher, dass Du die Zauber Datenbank zurücksetzen willst?"
L["Receiver Mode"] = "Empfänger Modus"
L["Receivers"] = "Empfänger"
L["Remove"] = "Entfernen"
L["Remove all"] = "Alle entfernen"
L["Remove empty names"] = "Leere Namen entfernen"
L["Replace PRT tag content"] = "PRT Tag Inhalt ersetzen"
L["Reset counter on stop"] = "Zähler nach Stop zurücksetzen"
L["Reset Data"] = "Daten zurücksetzen"
L["Reset on Encounter start"] = "Bei Kampfbeginn zurücksetzen"
L["Reset Profile"] = "Profil zurücksetzen"
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
L["running"] = "läuft"
L["Save as template"] = "Als Vorlage speichern"
L["Search"] = "Suchen"
L["Select a profile you want to delete. You can't delete the currently active profile."] = "Wähle ein Profil aus, das Du löschen willst. Das aktuell aktive Profil kann nicht gelöscht werden."
L["Select Encounter"] = "Boss auswählen"
L["Select Profile"] = "Profil auswählen"
L["Select the profile you want to change to."] = "Wähle das Profil aus, auf das Du wechseln willst."
L["Select Timers"] = "Timer auswählen"
L["Select version"] = "Version auswählen"
L[ [=[Selected player/placeholder will be
added to the list of targets.]=] ] = [=[Ausgewählter Spieler/Platzhalter
wird der Liste der Empfänger hinzugefügt.]=]
L[ [=[Selected player/placeholder will be
added to the list of targets.]=] ] = [=[Ausgewählter Spieler/Platzhalter wird
der Liste der Ziele hinzugefügt.]=]
L["Sender"] = "Absender"
L["Sender Mode"] = "Absender Modus"
L["Shows the encounter name on top of the note."] = "Zeigt den Bossnamen am Anfang der Notiz an."
L["Shows the prt timer names on top of each group of note timers."] = "Zeigt die Timer Namen über jeder Gruppe von Zeilen an."
L["Shows the timing names before each line of a given prt timer."] = "Zeigt die Namen der Timer Einträge vor jeder Zeile an."
L["Size"] = "Größe"
L["Skull"] = "Totenkopf"
L["Sound"] = true
L["Source"] = "Quelle"
L["Special Thanks"] = "Besonderen Dank"
L["Specialization Profiles"] = "Spezialisierungsprofile"
L["Specialization specific profiles are global. If you enable it, it will be active for all profiles."] = "Spezialisierungsspezifische Profile sind global aktiv."
L["Spell"] = "Zauber"
L["Spell cast canceled"] = "Zauber abgebrochen"
L["Spell cast started"] = "Zauber gestartet"
L["Spell cast successfully"] = "Zauber erfolgreich"
L["Spell count"] = "Anzahl Zauber"
L["Spell Database"] = "Zauber Datenbank"
L["Spell database options tab"] = "Zauber Datenbank"
L["Spell interrupted"] = "Zauber unterbrochen"
L["Square"] = "Viereck"
L["Star"] = "Stern"
L["Start Condition"] = "Start Bedingung"
L["Start on"] = "Startet wenn"
L["Started at"] = "Gestartet am"
L["Status"] = true
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
L["The spell database is globally available for all of your characters and will be build up regardless of which character you are playing."] = "Die Zauber Datenbank ist global für jeden Charakter verfügbar. Die Zauber Datenbank wird im Hintergrund aufgebaut solange PRT aktiviert ist. "
L["The spell database will rebuild once the patch version changes. This is done so you always have the newest spells in the database."] = "Die Zauber Datenbank wird zurückgesetzt, wenn ein neuer Patch veröffentlicht wird, um sicherzustellen, dass immer alle Zauber in der Datenbank zur Verfügung stehen."
L["There are currently no templates."] = "Aktuell gibt es keine Vorlagen."
L["This feature will export your selected timers to a ExRT note. This will only work for message of type %s."] = "Diese Funktion exportiert die ausgewählten Timer als MethodRaidTools Notiz. Das funktioniert nur für Nachrichten mit dem Typ %s."
L["This feature will export your selected timers to a ExRT note. This will only work for message of type %s.\\n\\nIf you want to keep your current note you can use %s and %s. The prt generated note will be put inbetween those tags."] = "Diese Funktion exportiert die ausgewählten Timer entsprechend der vorgenommenen Einstellungen. Das funktioniert nur für Nachrichten vom typ %s.\\n\\nWenn Du deine aktuelle Notiz beibehalten willst kannst du die zwei Tags %s und %s benutzen. Die generierte Notiz wird dann zwischen diesen beiden Tags eingefügt."
L["This will hide all entries which are not interesting for the given player."] = "Alle Einträge, welche nicht für einen Spieler relevant sind werden in dessen Notiz nicht mehr dargestellt."
L["This will try and force ExRT to directly update the note."] = "Es wird versucht MethodRaidTools dazu zu zwingen die Notiz zu aktualisieren."
L["This will update the existing ExRT note and just replace the content between %s and %s tag with the generated content."] = "Hiermit wird die erzeugte Notiz nicht die MethodRaidTools Notiz überschreiben sondern den Inhalt zwischen das Tag %s und %s schreiben."
L["Timer"] = true
L["Timers"] = "Timer"
L["Timings"] = "Zeit Einträge"
L["Timings %s"] = "Zeit Einträge %s"
L["Triangle"] = "Dreieck"
L["Trigger Defaults"] = "Auslöser Standards"
L["Trigger on"] = "Auslösen wenn"
L["Trigger On %s %s %s"] = "Auslösen wenn %s %s %s"
L["Type"] = "Typ"
L["Type any name for the new profile you want to create. If the name is already taken profile will instead switch to the already existing one."] = "Um ein neues Profil zu erstellen musst Du einen Namen vergeben. Wenn der Name bereits vergeben ist wird stattdessen auf das vorhandene Profil gewechselt."
L["Types\\n%s - Only the first player found within the group will be messaged\\n%s - All players will be messaged"] = [=[Types
%s - Nur der erste erfolgreich gefundene Spieler wird benachrichtigt
%s - Alle gefundenen Spieler werden benachrichtigt]=]
L["Unit"] = "Einheit"
L["Unit died"] = "NPC gestorben"
L["Unit killed"] = "NPC getötet"
L["Units to track"] = "Zu verfolgende Einheiten"
L["Unselect all"] = "Alle abwählen"
L["Update"] = "Aktualisieren"
L["Version Check"] = "Versionsüberprüfung"
L["Version name"] = "Versionsname"
L["Versions"] = "Versionen"
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
L["You want to force update ExRT note without replacing PRT tag content. This will overwrite the whole note. Are you sure about that?"] = "Du willst gerade MethodRaidTools dazu zwingen die Notiz zu aktualisieren ohne den Inhalt der PRT Tags auszutauschen. Das sorgt dafür, dass die gesamte Notiz überschrieben wird. Willst Du das wirklich?"
L["yourself"] = "Du"
