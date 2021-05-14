local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("PhenomRaidTools", "enUS", true, true)
if not L then return end

L = L or {}
L["- %s This only works for messages with type %s"] = true
L["--- Castle Nathria ---"] = true
L["--- De Other Side ---"] = true
L["- Export any timer as ExRT note"] = true
L["--- Halls of Atonement ---"] = true
L["--- Mists of Tirna Scithe ---"] = true
L["--- Necrotic Wake ---"] = true
L["--- Plaguefall ---"] = true
L["--- Sanguine Depths ---"] = true
L["--- Spires of Ascension ---"] = true
L["- The profiles will change automatically once you change your specialization"] = true
L["- The spell database will be updated each patch automatically"] = true
L["--- Theater of Pain ---"] = true
L["- To do so you have to navigate to %s within any encounter and click %s"] = true
L["- Within the spell database you can search any spell the game has to over"] = true
L["- You can now enable and select specialization specific profiles"] = true
L["\"PhenomRaidTools will only load for the configured difficulties."] = true
L["%s (%s) health match (%s%% %s %s%%)"] = true
L["* Custom *"] = true
L["Ability to export timers as ExRT note"] = true
L["Activates the debug mode."] = true
L["Activates the receiver mode."] = true
L["Activates the sender mode."] = true
L["Activates the test mode."] = true
L["Add Name"] = true
L["Add Start Condition"] = true
L["Add Stop Condition"] = true
L["Add Target"] = true
L["Additional Events"] = true
L["Advanced"] = true
L["After how many occurrences of\\nstart condition the timer should start."] = true
L[ [=[After how many seconds the
message should be displayed.]=] ] = true
L[ [=[After how many seconds the
message should be displayed.]=] ] = true
L["Always includes yourself as valid sender."] = true
L["Are you sure you want to clear the current raid roster?"] = true
L["Are you sure you want to clone %s?"] = true
L["Are you sure you want to clone this item?"] = true
L["Are you sure you want to delete %s?"] = true
L["Are you sure you want to delete profile %s?"] = true
L["Are you sure you want to delete template %s?"] = true
L["Are you sure you want to delete this item?"] = true
L["Are you sure you want to import your current group?\""] = true
L["Are you sure you want to merge encounters?"] = true
L["Are you sure you want to remove all custom placeholders?"] = true
L["Are you sure you want to reset profile %s?"] = true
L["Are you sure you want to save this message as template?"] = true
L["Backdrop Color"] = true
L["Buff/Debuff applied"] = true
L["Buff/Debuff refreshed"] = true
L["Buff/Debuff removed"] = true
L[ [=[Can be either of
- Player name
- Custom Placeholder (e.g. $tank1)
- $target (event target)]=] ] = true
L[ [=[Can be either of
- Unit-Name
- Unit-ID (boss1, player ...)
- NPC-ID]=] ] = [=[Can be either of
- Unit-Name
- Unit-ID (boss1, player ...)
- Numeric Unit-ID]=]
L[ [=[Can be either of
- valid unique spell ID
- spell name known to the player character]=] ] = true
L[ [=[Can be either of
- Player name
- Custom Placeholder (e.g. $tank1)
- $target (event target)]=] ] = true
L[ [=[Can be either of
- valid unique spell ID
- spell name known to the player character]=] ] = true
L["Can be either of\\n- Player name\\n- Custom Placeholder (e.g. $tank1)\\n- $target (event target)\\n- TANK, HEALER, DAMAGER"] = true
L["Cancel"] = true
L["Changelog"] = true
L["Check after"] = true
L["Check again"] = true
L["Circle"] = true
L["Clear"] = true
L["Clone"] = true
L["CN - Altimor the Huntsman"] = true
L["CN - Artificer Xy'Mox"] = true
L["CN - Hungering Destroyer"] = true
L["CN - Lady Inerva Darkvein"] = true
L["CN - Shriekwing"] = true
L["CN - Sire Denathrius"] = true
L["CN - Sludgefist"] = true
L["CN - Stone Legion Generals"] = true
L["CN - Sun King's Salvation"] = true
L["CN - The Council of Blood"] = true
L["Coming soon"] = true
L["Comma separated list of player names."] = true
L["Comma separated list of timings\\supports different formats\\n- 69\\n- 1:09\\n- 00:09"] = true
L["Completed at"] = true
L["Condition"] = true
L["Confirmation"] = true
L["Cooldown"] = true
L["cooldown"] = true
L["Copy"] = true
L["Countdown"] = true
L["Created at:"] = true
L["Cross"] = true
L["Current Profile"] = true
L["Custom Placeholder"] = true
L["Custom Placeholders"] = true
L["Custom Sound"] = true
L["Damage"] = true
L["Debug Log"] = true
L["Debug Mode"] = true
L["Default Sound"] = true
L["Delay"] = true
L["Delete"] = true
L["Delete Profile"] = true
L["Description"] = true
L["Developer"] = true
L["Diamond"] = true
L["Difficulties"] = true
L["Disabled"] = true
L["Dungeon"] = true
L["Duration"] = true
L["Enable on"] = true
L["Enabled"] = true
L["Encounter"] = true
L["Encounter end"] = true
L["Encounter found. Do you want to import the new version?"] = true
L["Encounter start"] = true
L["Encounter-ID"] = true
L["Entries %s"] = true
L["Event"] = true
L["Export"] = true
L["Export String"] = true
L["ExRT Note"] = true
L["ExRT Note Generator"] = true
L["Filter by"] = true
L[ [=[Filter out all messages
below selected guild rank.]=] ] = true
L[ [=[Filter out all messages
below selected guild rank.]=] ] = true
L["Font"] = true
L["Font Color"] = true
L["Force ExRT note update"] = true
L["General"] = true
L["Generate ExRT Note"] = true
L["Group"] = true
L["Grow Direction"] = true
L["guild rank"] = true
L["Guild Rank"] = true
L["Healer"] = true
L["Health"] = true
L["Health Percentage"] = true
L["Health Percentages"] = true
L["Here you can search the spell database. The database is build up in the background and may not contain all known spells just yet. If you can't find a spell please check back later when status is `completed`."] = true
L["Heroic"] = true
L["Hide after combat"] = true
L["Hide disabled triggers"] = true
L["How long the message should be displayed."] = true
L["Ignore after activation"] = true
L["Ignore all events for X seconds."] = true
L["Ignore for"] = true
L["Import"] = true
L["Import raid"] = true
L["Import String"] = true
L["In addition you always include %s as valid sender."] = true
L["Include empty lines"] = true
L["Include line prefix"] = true
L["Include myself"] = true
L["Include section names"] = true
L["Include title"] = true
L["Includes lines even if there are no entries within the prt timer."] = true
L["Information"] = true
L["Interesting Links"] = true
L["Last checked id"] = true
L["Latest Features"] = true
L["Load Template"] = true
L["Locked"] = true
L["Message"] = true
L["Message Filter"] = true
L["Messages"] = true
L["Modes"] = true
L["Moon"] = true
L["Mythic"] = true
L["Name"] = true
L["Names"] = true
L["New"] = true
L["New Profile"] = true
L["Normal"] = true
L["Note: Not every element can be displayed in a raid warning e.g. icons."] = true
L["Occurence"] = true
L["Occurrence"] = true
L["of"] = true
L["Offset"] = true
L["Offset will be applied to all timings."] = true
L["OK"] = true
L["Once you change your current specialization the profile will change automatically."] = true
L["Operator"] = true
L["Options"] = true
L["Overlay"] = true
L["Overlay on which the message should show up"] = true
L["Overlays"] = true
L["Overview"] = true
L["Paste"] = true
L["Percentage"] = true
L["Personalize note"] = true
L["Placeholder"] = true
L["Player"] = true
L["Player entered combat"] = true
L["Player left combat"] = true
L["player names"] = true
L["Player who should receive the message"] = true
L["Position"] = true
L["Power"] = true
L["Power Percentage"] = true
L["Power Percentages"] = true
L["Preview: "] = true
L["Profiles"] = true
L["Profiles options tab"] = true
L["PRT: Default"] = true
L["Raid"] = true
L["Raid mark"] = true
L["Raid roster"] = true
L["Raid warning"] = true
L["Rebuild spell database"] = true
L["Rebuilding the spell cache can take a while.|nAre you sure you want to rebuild it?"] = true
L["Receiver Mode"] = true
L["Receivers"] = true
L["Remove"] = true
L["Remove all"] = true
L["Remove empty names"] = true
L["Replace PRT tag content"] = true
L["Reset counter on stop"] = true
L["Reset Profile"] = true
L["Resets the counter of start conditions\\nwhen the timer is stopped."] = true
L["Restart"] = true
L[ [=[Restarts the rotation when
no more entries are found.]=] ] = true
L[ [=[Restarts the rotation when
no more entries are found.]=] ] = true
L["Rotation"] = true
L["Rotation Entry"] = true
L["Rotations"] = true
L["Save as template"] = true
L["Search"] = true
L["Select a profile you want to delete. You can't delete the currently active profile."] = true
L["Select Encounter"] = true
L["Select Profile"] = true
L["Select the profile you want to change to."] = true
L["Select Timers"] = true
L["Select version"] = true
L[ [=[Selected player/placeholder will be
added to the list of targets.]=] ] = true
L[ [=[Selected player/placeholder will be
added to the list of targets.]=] ] = true
L["Sender"] = true
L["Sender Mode"] = true
L["Shows the encounter name on top of the note."] = true
L["Shows the prt timer names on top of each group of note timers."] = true
L["Shows the timing names before each line of a given prt timer."] = true
L["Size"] = true
L["Skull"] = true
L["Sound"] = true
L["Source"] = true
L["Special Thanks"] = true
L["Specialization Profiles"] = true
L["Specialization specific profiles are global. If you enable it, it will be active for all profiles."] = true
L["Spell"] = true
L["Spell cast canceled"] = true
L["Spell cast started"] = true
L["Spell cast successfully"] = true
L["Spell count"] = true
L["Spell Database"] = true
L["Spell database options tab"] = true
L["Spell interrupted"] = true
L["Square"] = true
L["Star"] = true
L["Start Condition"] = true
L["Start on"] = true
L["Started at"] = true
L["Status"] = true
L["Stop Condition"] = true
L["Stop on"] = true
L[ [=[Supports following special symbols
- $target (event target)
- Custom placeholders (e.g. $tank1)
- Spell icons (e.g. {spell:17}
- Raid marks (e.g. {rt1})]=] ] = true
L["Tanks"] = true
L["Target"] = true
L["Target Overlay"] = true
L["Targets"] = true
L["Template Name"] = true
L["Templates"] = true
L["Test Mode"] = true
L["The defined default values will be used when creating new messages."] = true
L["The spell database is globally available for all of your characters and will be build up regardless of which character you are playing."] = true
L["The spell database will rebuild once the patch version changes. This is done so you always have the newest spells in the database."] = true
L["There are currently no templates."] = true
L["This feature will export your selected timers to a ExRT note. This will only work for message of type %s."] = true
L["This feature will export your selected timers to a ExRT note. This will only work for message of type %s.\\n\\nIf you want to keep your current note you can use %s and %s. The prt generated note will be put inbetween those tags."] = true
L["This will hide all entries which are not interesting for the given player."] = true
L["This will try and force ExRT to directly update the note."] = true
L["This will update the existing ExRT note and just replace the content between %s and %s tag with the generated content."] = true
L["Timer"] = true
L["Timers"] = true
L["Timings"] = true
L["Timings %s"] = true
L["Triangle"] = true
L["Trigger Defaults"] = true
L["Trigger on"] = true
L["Trigger On %s %s %s"] = true
L["Type"] = true
L["Type any name for the new profile you want to create. If the name is already taken profile will instead switch to the already existing one."] = true
L["Types\\n%s - Only the first player found within the group will be messaged\\n%s - All players will be messaged"] = true
L["Unit"] = true
L["Unit died"] = true
L["Unit killed"] = true
L["Unselect all"] = true
L["Update"] = true
L["Version Check"] = true
L["Version name"] = true
L["Versions"] = true
L["Will show a countdown of 5 seconds"] = true
L["X Offset"] = true
L["Y Offset"] = true
L["You are currently in receiver only mode. Therefore some features are disabled because they only relate to the sender mode."] = true
L["You are currently in test mode. Some triggers behave slightly different in test mode."] = true
L["You can define custom placeholder which can be used as message targets."] = true
L["You can import or define your raid roster and use the placeholder within your triggers."] = true
L["You currently filter messages by %s, but haven't configured any name yet. Therefore all messages from all players will be displayed."] = true
L["You currently filter messages by %s. Therefore only message from players with the configured guild rank or higher will be displayed."] = true
L["You currently filter messages by %s. Therefore only messages from those players will be displayed."] = true
L["You want to force update ExRT note without replacing PRT tag content. This will overwrite the whole note. Are you sure about that?"] = true
L["yourself"] = true
