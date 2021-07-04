# Release 2.20.0
## Bugfixes
None
## Features
 - Add raid targets as quick access icons
 - Disable invalid target selections
 - Be able to select `None` as target and raid target


# Release 2.19.3
## Bugfixes
 - Be able to use spec specific profiles again
## Features
 - Rename ExRT to MethodRaidTools
 - More conditons presets for Sanctum of Domination
 - Only add spells to spell database if there is a description for it


# Release 2.19.1
## Bugfixes
 - Make sure backdrops for simple groups are not rendered after elvui update
## Features
 - Update for patch 9.1


# Release 2.18.6
## Bugfixes
 - Make sure Migrations are executed in the right order
## Features
None


# Release 2.18.3
## Bugfixes
None
## Features
 - Update Ace3-0


# Release 2.18.1
## Bugfixes
None
## Features
 - Make sure that a unit has to be in the same zone to be eligible as placeholder replacement


# Release 2.17.15
## Bugfixes
 - Fixed placeholder migration for upgrade fron 2.16.0
   - (!) For everyone not seeing any placeholder names anymore... I fucked it up and you most likely have to redo those placeholders. I am very sorry!
   - Also make sure that old imports of encounters and global placeholders still work
## Features
None

# Release 2.17.14
## Bugfixes
 - Fixed placeholder migration for upgrade fron 2.16.0
   - (!) For everyone not seeing any placeholder names anymore... I fucked it up and you most likely have to redo those placeholders. I am very sorry!
## Features
None

# Release 2.17.5
## Bugfixes
None
## Features
 - Performance optimizations
 - Fully add profiles page into PRT instead of blizzard ui
 - Restructure custom placeholders so it is more consistent and does not
   allow multiple placeholders with the same name.
 - Added first approach to a custom API which can be used by other addons or e.g. WeakAuras. Currently you only can create placeholders. Plan is to add a lot more in the future.
 - (!) Add The Bruning Crusade Classic Build to CurseForce and Wago-Addons

# Release 2.16.1
## Bugfixes
 - Make sure encounter can be viewed even if there is no more version
## Features
None


# Release 2.16.0
## Bugfixes
None
## Features
 - Enhance custom placeholder performance



# Release 2.15.4
## Bugfixes
 - Make sure PRT does not crash when current encounter is not set
## Features
None


# Release 2.15.3
## Bugfixes
None
## Features
 - [#31] Show messages when the player is dead but still in encounter


# Release 2.15.2
## Bugfixes
 - Make some log statements debug instead of info statements
## Features
None


# Release 2.15.1
## Bugfixes
 - Make sure encounter overview is rendered when any trigger has unknown spell id
 - Do not sort message target dropdown multiple times
## Features
None


# Release 2.15.0
## Bugfixes
None
## Features
 - Add `Spell Database` in top level of the main tree
 - Add ExRT export for encounter times
   - Export timers with cooldown type messages
   - Export note personalized
   - Directly update ExRT note
   - Be able to export note into placeholder of an existing note
 - Restructure tree view and option tabs
 - Add `Profiles` in top level of the main tree
 - Add Specialization specific profiles
 - Clamp main window to screen
 - New color scheme for ui components
 - Add changelog to landing view
 - Update rendering of modal views
 - Better version check output (includes enabled status)
 - Add 9.1 condition presets


# Release 2.14.1-BETA
## Bugfixes
 - Make sure building of spell database resumes after combat
## Features
None


# Release 2.14.0-BETA
## Bugfixes
None
## Features
 - Update rendering of confirmation dialog
 - Better version check output (includes enabled status)
 - Add more 9.1 condition presets
 - Add option to replace prt tag within a exrt note instead of overwriting it completely


# Release 2.13.1-BETA
## Bugfixes
 - Make sure $target also works for raidtarget action
 - Make sure placeholders are not shown on every pull
## Features
 None


# Release 2.13.0-BETA
## Bugfixes
None
## Features
 - Cleanup note from unnecessary characters


# Release 2.12.0-BETA
## Bugfixes
None
## Features
 - Disable force exrt note update checkbox when exrt is not loaded


# Release 2.11.0-BETA
## Bugfixes
None
## Features
 - Move none option view to tree view as own top level entries


# Release 2.10.0-BETA
## Bugfixes
None
## Features
 - Move profiles page into the addon itself as own options tab


# Release 2.9.0-BETA
## Bugfixes
None
## Features
 - Specialization specific profiles
   - You now can enable and select spec specific profiles which will
     change automatically once you change your specialization


# Release 2.8.6-BETA
## Bugfixes
None
## Features
 - Be able to export the ExRT note personalized
   - So each player only gets shown entries which are for him/her
 - Be able to directly push export into ExRT without having to open it


# Release 2.8.5-BETA
## Bugfixes
None
## Features
 - Updated locals


# Release 2.8.4-BETA
## Bugfixes
None
## Features
 - Clamp main window to screen
 - Add new color scheme for most ui components
 - Be able to configure ExRT note export for your needs
   - Enable/Disable encounter name as title
   - Enable/Disable timer name as section titles
   - Enable/Disable timing name as line prefix for each exrt line
   - Enable/Disable empty lines so empty lines can be omitted


# Release 2.8.3-BETA
## Bugfixes
None
## Features
 - Add basic changelog to general option tab

# Release 2.8.2-BETA
## Bugfixes
None
## Features
 - ExRT note export now also takes `Occurence` into account so the ExRT note
   timers start correctly

# Release 2.8.1-BETA
## Bugfixes
None
## Features
 - Add encounter name to ExRT exported note
 - Make sure all colored names are escaped so the colors will be displayed properly
   in ExRT note

# Release 2.8.0-ALPHA
## Bugfixes
None
## Features
 - Add new option tab `Spell Database`
   - This is a tab where you can search all spells in the game. The database
     will be generated in the background. This process takes around 2-3 hours
     and will be globally available for all characters. Once it's finished you'll be able
     to search for any given spell in the database. The database will be
     updated once the wow patch version changes.
  - Add new function to export timers as ExRT Note.
    - This will only work for timers including messages of type `cooldown`.
      Also the timer start condition will be used as ExRT start condition for the timers
      aswell. So it should only start counting the timer when the configured
      event/spell combination was found.

# Release 2.7.4
## Bugfixes
 - Make sure encounter versions do not disable the execution
 - Make sure encounter disabled status is the only disabled status
 - Migrate all encounter versions to be "enabled"
## Features
None

# Release 2.7.3
## Bugfixes
None
## Features
 - Highlight event name in condition dropdown
 - Add created at on first version of an encounter aswell

# Release 2.7.2
## Bugfixes
None
## Features
 - Add missing locals

# Release 2.7.1
## Bugfixes
 - Make sure encounter id is set for new version aswell
## Features
 - Add description for condition events

# Release 2.7.0-BETA
## Bugfixes
None
## Features
 - Add new action type raid target
   - With this you can set raid targets to specific players in your group

# Release 2.6.0

# Release 2.5.6-BETA
## Bugfixes
None
## Features
 - Make sure character name with realm name is also a valid target

# Release 2.5.5-BETA
## Bugfixes
 - Encounter versions are now always enabled
## Features
 - Move encounter start debug logging to better position
 - Add created at for encounter versions
 - Add more specific phase 2 condition preset for sire denathrius
 - Rename old phase 2 condition preset of sire denathrius to intermission start

# Release 2.5.4-BETA
## Bugfixes
None
## Features
 - Cleanup

# Release 2.5.3-BETA
## Bugfixes
None
## Features
 - Cleanup

# Release 2.5.2-BETA
## Bugfixes
 - Do not throw an exception when you don't have a routine for a boss you pulled
## Features
None

# Release 2.5.1-BETA
## Bugfixes
 - Actually add example encounter to encounter list on new profile
## Features
None

# Release 2.5.0-BETA
## Bugfixes
None
## Features
 - Be able to create versions of encounters and switch between them
   - You now can create, clone and delete versions of encounters. This can
     be used to easily test stuff or just import an existing version of
     another user without pumping up your current versions. The import and
     export of whole encounters is no more supported due to this change. You now
     only can import/export encounter versions.

# Release 2.4.12
## Bugfixes
None
## Features
 - Wording changes

# Release 2.4.11
## Bugfixes
None
## Features
 - Cleanup and little layout changes

# Release 2.4.10
## Bugfixes
None
## Features
 - Be able to clone messages

# Release 2.4.9
## Bugfixes
None
## Features
 - Refactoring and performance enhancements
 - Update guide link
 - Select tab when creating a new template

# Release 2.4.8-BETA
## Bugfixes
 - Make sure sender backdrop ist shown when options are open
 - Fix typo
## Features
 - Refactoring and performance enhancements
 - Ability to migrate data on addon load (for future developments)
 - Add guide link into discord on inforamtion panel
 - Changed some rendering for the option tabs
 - Completly expand encounter when clicked
   - You now don't have to expand every trigger type by itself

# Release 2.4.7
## Bugfixes
 - Make sure events are only tracked if you are in sender mode
## Features
None

# Release 2.4.6
## Bugfixes
 - Remove LibDeflate from external lib list because of broken build
## Features
None

# Release 2.4.5
## Bugfixes
 - Fix overlay options to sometimes break the game
## Features
None

# Release 2.4.4
## Bugfixes
 - Fix curseforge build
## Features
None

# Release 2.4.0
## Bugfixes
None
## Features
 - [#28] Add more locals
 - Be able to choose grow direction for receiver overlays
   - This also will fixate the position. In the past the message were centered vertically

# Release 2.3.16
## Bugfixes
 - Fix sire phase 2 condition preset
## Features
None

# Release 2.3.15
## Bugfixes
 - Fix typo
## Features
None

# Release 2.3.14
## Bugfixes
None
## Features
 - Update unit tracking for boss units
 - Added condition presets for each encounter (except inerva :))

# Release 2.3.13
## Bugfixes
None
## Features
 - Make sure receiver overlay and options are rendered correctly even if the font does not exist

# Release 2.3.12
## Bugfixes
- Make sure timers are checking even if sender overlay is not shown
## Features
 - Be able to import/export overlay options
 - Added missing deDE locals

# Release 2.3.11
## Bugfixes
 - Make sure timers are checked and execute even if you have the sender overlay deactivated
## Features
None

# Release 2.3.10

# Release 2.3.10-BETA
## Bugfixes
 - Check timings once at the start of combat so triggers with < 0.5 will trigger aswell
## Features
None

# Release 2.3.9-ALPHA
## Bugfixes
None
## Features
 - Add new DE translations

# Release 2.3.8-ALPHA
## Bugfixes
 - Add missing locals
## Features
None

# Release 2.3.7-ALPHA
## Bugfixes
 - Fix sender overlay when offset is empty
 - Some small fixes
## Features
None

# Release 2.3.6-ALPHA
## Bugfixes
None
## Features
 - Minor cleanup

# Release 2.3.5
## Bugfixes
None
## Features
 - Change version concept to semantic versioning
 - Add credits tab to options
 - Always query all units with the given unit-id/name until one is found
 - Change to AceLocale instead of own system

# Release 2.3.4.0
## Bugfixes
None
## Features
 - Fix some debug strings
 - Show next timing in sender overlay with offset
 - Add all new action types to default options
 - (!) Be able to use spell name and spell id for conditions
 - Fix locals for some castle nathria bosses
 - Update version for patch 9.0.5

# Release 2.3.3.1
## Bugfixes
 - Make sure raid warnings are also sent if you're the group leader
## Features
None

# Release 2.3.3.0

# Release 2.3.3.0-BETA
## Bugfixes
None
## Features
 - Added some more sounds
  - Phase 1
  - Phase 2
  - Phase 3
  - Phase 4
  - Phase 5
  - Heal Cooldown
  - Soak
- Only render template options when in sender mode
- Only render sender overlay options when in sender mode
- Disable test encounter select when not in test mode and add test mode description
- Add action type `raidwarning`
  - You now can send raid warnings to the group.
    This can be used to send raid warnings to a group which does not use prt yet or a pug.
    What i had in mind is stuff like `Kill Shade of Bargast` when they reach 60% power or something.

# Release 2.3.2.0-BETA
## Bugfixes
None
## Features
 - Make sure units not affected in combat (maybe instant cc) are still being tracked
   - E.g. Shade of Bargast

# Release 2.3.1.1-BETA
## Bugfixes
 - Be able to delete condition spell id again
## Features
None

# Release 2.3.1.0-BETA
## Bugfixes
 - Fixed a bug that occured when you deleted the last message of an entry
## Features
 - Added logging when a message should be send to make it easier to see when a placeholder wasn't found
 - Track units by their guid
 - Instead of N/A return the placeholder colored in red

# Release 2.3.0.0-BETA
## Bugfixes
None
## Features
 - Refactor event handling
   - Health and power percentages will now be checked by tracking wow events
     "UNIT_HEALTH" and "UNIT_POWER_UPDATE" which should lead to a far more accurate
     result
   - Timers now will only be checked only twice a second instead of on every combat event
   - Message queue will only processed twice a second now instead of on every
     combat event

# Release 2.2.10.0
## Bugfixes
None
## Features
 - Add message duration to defaults

# Release 2.2.9.0
## Bugfixes
None
## Features
 - Add Ashen Hallow to quick access cooldowns

# Release 2.2.8.0
## Bugfixes
 - Remove unused world events from tracked events
## Features
 - Add debug logging for tracked units and events

# Release 2.2.7.9
## Bugfixes
 - Make sure world events are added to the list of tracked events aswell
## Features
None

# Release 2.2.7.8
## Bugfixes
 - Make sure units are also tracked by numeric unit id (e.g. from wowhead)
## Features
None

# Release 2.2.7.7
## Bugfixes
 - Remove debug logging
## Features
None

# Release 2.2.7.6
## Bugfixes
 - Only check units which are present in the current encounter
   - Compile a list of all events and units which are in the triggers in the
     current encounter and only check events if it is necessary
## Features
None

# Release 2.2.7.5
## Bugfixes
 - Do not import non existing files
## Features
None

# Release 2.2.7.4
## Bugfixes
 - Make sure template name input does not disappear
## Features
None

# Release 2.2.7.3
## Bugfixes
 - Make sure template names can be changed again
## Features
None

# Release 2.2.7.2
## Bugfixes
 - Update logic for templates
## Features
None

# Release 2.2.7.1
## Bugfixes
 - Update check if trigger is active or not
## Features
None

# Release 2.2.7.0
## Bugfixes
None
## Features
 - Add option to set the default message type

# Release 2.2.6.3
## Bugfixes
 - [#24] Make sure the default message type is advanced
   - This should fix an issue where a mesage gets the message type cooldown if
     it was create prior to the templates release
 - Make sure number is not compared to string
## Features
None

# Release 2.2.6.1
## Bugfixes
 - Make sure all tab groups are sorted correctly
## Features
 - Add target overlay to message default options

# Release 2.2.5.0
## Bugfixes
None
## Features
 - Sort tabs by name if possible

# Release 2.2.4.1
## Bugfixes
 - Make sure saved templates *always* have a type
  - This fixes an issue if you saved a message that was created prior to 2.2.2.2
## Features
None

# Release 2.2.4.0
## Bugfixes
None
## Features
 - Add custom option for cooldown action

# Release 2.2.3.1
## Bugfixes
 - Fix trigger active check
   - Start and stop conditions of trigger were not checked correctly
## Features
None

# Release 2.2.3.0
## Bugfixes
None
## Features
 - Updated a lot of locals
 - Add option to activate countdown for cooldown messages

# Release 2.2.2.2
## Bugfixes
 - Make sure raid roster import/clear does not break
 - Fix copy&paste conditions
 - Fix typo
 - Correctly check **every** percentage entry for match and don't stop if one matched
 - Don't access table field for custom placeholders which are not present
 - Set the default targets to only the player
   - So if you fuck up it won't spam everyone in the raid but you
 - Update tracked units if they reappear and do not use outdated unit-ids to query
 - Reinitialize overlays after profile change
 - Typo fixes
 - Only log into protocol when encounter is ongoing
 - Clear debug log on init
## Features
 - Revert health/power check for better performance
 - Refactoring
 - Add button to add new template
 - Track health and power values by UNIT_HEALTH and UNIT_POWER_UPDATE wow events
 - Update highlight debug strings
 - Warn if entered spell id for condition is non existing
 - Be able to rename templates
 - Be able to save and load message templates
 - Set default font for labels to 14
 - Better tooltip rendering
 - Be able to use `mob-id` for percentage unit to check
 - Generalize general trigger options rendering
 - Update sound names to reflect correct spell names
 - Add messages types
   - Advanced ( current state )
   - Cooldown
   - From template
 - Add debug log
 - Update some debug prints
 - Add remove all global placeholder button

# Release 2.2.2.2-BETA
## Bugfixes
 - Make sure raid roster import/clear does not break
## Features
None

# Release 2.2.2.1-BETA
## Bugfixes
None
## Features
 - Revert health/power check for better performance

# Release 2.2.2.0-BETA
## Bugfixes
None
## Features
 - Refactoring
 - Track health and power values by UNIT_HEALTH and UNIT_POWER_UPDATE wow events
 - Update highlight debug strings
 - Warn if entered spell id for condition is non existing

# Release 2.2.1.2-BETA
## Bugfixes
 - Update unit querying for health and power percentages ... again
 - Clear debug log on init
## Features
 - Update some debug prints
 - Add remove all global placeholder button

# Release 2.2.1.1-BETA
## Bugfixes
 - Reinitialize overlays after profile change
 - Typo fixes
 - Only log into protocol when encounter is ongoing
## Features
None

# Release 2.2.1.0-BETA
## Bugfixes
 - Update tracked units if they reappear and do not use outdated unit-ids to query
## Features
 - Add debug log

# Release 2.2.0.4-BETA
## Bugfixes
 - Set the default targets to only the player
   - So if you fuck up it won't spam everyone in the raid but you
## Features
None

# Release 2.2.0.3-BETA
## Bugfixes
 - Don't access table field for custom placeholders which are not present
## Features
None

# Release 2.2.0.2-BETA
## Bugfixes
None
## Features
 - Add button to add new template
 - Be able to rename templates

# Release 2.2.0.1-BETA
## Bugfixes
 - Fix typo
 - Correctly check **every** percentage entry for match and don't stop if one matched
## Features
 - Better tooltip rendering
 - Be able to use `mob-id` for percentage unit to check

# Release 2.2.0.0-BETA
## Bugfixes
 - Fix copy&paste conditions
## Features
 - Be able to save and load message templates
 - Set default font for labels to 14
 - Generalize general trigger options rendering
 - Update sound names to reflect correct spell names
 - Add messages types
   - Advanced ( current state )
   - Cooldown
   - From template

# Release 2.1.0.1
## Bugfixes
 - Prepend exception when swapping loadscreens to fast
## Features
 - Refactoring
   - Use luacheck for unused vars etc.
   - Use lua-format for better indentation

# Release 2.0.21.2
## Bugfixes
 - Make sure test mode events are only checked in test mode
## Features
None

# Release 2.0.21.1
## Bugfixes
 - Make sure backdrop removal for styling does not break for non elvui users
 - Simplify trigger active check for faster execution
## Features
 - Automatically replace `ENCOUNTER_START` events with `PLAYER_REGEN_DISABLED` in test mode
   - You do not have to change this everytime you want to test simple timers for an encounter

# Release 2.0.20.1
## Bugfixes
 - Fix start/stop condition for rotations
   - If you only used start condition it wouldn't work at all...
 - Remove backdrop for simple groups
## Features
None

# Release 2.0.20.0
## Bugfixes
 - Do not throw exception when enabling or disabling an encounter
## Features
 - Add `always include myself` checkbox for message filter
  - This can be used instead of `$me` as name so you will be able to include yourself even if
    you choose to filter messages by a higher guild rank than yourself. Note `$me` as name will still work.

# Release 2.0.19.1
## Bugfixes
 - Make sure required names for message filter is empty initially
## Features
None

# Release 2.0.19.0
## Bugfixes
 - Show index for timings if no name is set
## Features
 - Added ability to copy&paste timers, rotations, and percentages
   - Go into a trigger and click "Copy to clipboard"
   - Afterwards go to the overview of the corresponding trigger type in another encounter and
     click "Paste from clipboard"
 - A whole lot of local fixes
 - Show custom placeholder explanation for encounter placeholders aswell

# Release 2.0.18.0-BETA
## Bugfixes
None
## Features
 - A lot of refactoring
 - Add ability to filter messages by guild rank
 - Removed legacy weakaura support
## Notes
 - Make sure to add a message filter again. Due to some data changes this will be empty

# Release 2.0.17.3
## Bugfixes
 - Set default width for all selects
 - Make sure encounter merge on import works in every case
 - Create local copies of wow api functions to make sure no other addons overwrite them
## Features
None

# Release 2.0.17.2
## Bugfixes
 - Make sure timing entries with the same timings all trigger not just one of them
## Features
None

# Release 2.0.17.1
## Bugfixes
 - Make sure targets of a new trigger are not cleared after a reload if you haven't changed them
 - Make sure PRT is loaded correctly for every language in the world (use IDs instead of localized names...)
 - Display current version in the PRT header
 - Be able to use exact unit names within `source` and `target` values for conditions
   - With this you will be able to do stuff like
     - Examples of what should now be able to do:
       - `send a message when unit X dies` e.g. for cabalists on sire denathrius
       - `send a messge when unit Xy starts casting a spell` e.g. for interupts on a specific unit
## Features
None

# Release 2.0.17.0
## Bugfixes
None
## Features
 - Check if a player of custom placeholders is dead before sending a message

# Release 2.0.16.1
## Bugfixes
 - Only add units to tracked units if not already exists
 - Change event to track units
## Features
None

# Release 2.0.16.0
## Bugfixes
 -
## Features
 - Add description field for triggers to make it easier to understand the purpose
 - Add Flourish and Tree of Life as cooldown quick access

# Release 2.0.15.1
## Bugfixes
 - Make sure multiple imports do not create equaly named triggers
## Features
None

# Release 2.0.15.0
## Bugfixes
None
## Features
 - Be able to merge encounters on import if encounter is already existing

# Release 2.0.14.1
## Bugfixes
 - Upload correct file format for newly added sounds
## Features
None

# Release 2.0.14.0
## Bugfixes
None
## Features
 - Added sounds for heal cds

# Release 2.0.13.0
## Bugfixes
 - Make sure unit name percentage trigger work as intended
 - Close main window when profile page is opened
## Features
 - Show current active profile on minimap icon hover

# Release 2.0.12.0
## Bugfixes
 - Fix some locals
 - Make sure placeholder TANK, HEALER, and DAMAGER work properly again
 - Make sure sender overlay is initialized correctly
## Features
 - Show indicator for each trigger for enabled difficulties (N, H, M)
 - Add /prt profile slash command to open profile window

# Release 2.0.11.0
## Bugfixes
 - Fix percentage recognition for unit names
 - Add newly used library to support non "elvui" users
## Features
None

# Release 2.0.10.0
## Bugfixes
None
## Features
 - Add profiles within interface/addons frame

# Release 2.0.9.0
## Bugfixes
None
## Features
 - Add difficulty switches for every trigger so you can have mythic only triggers
 - Add immunities to quick access message icons
 - Add some more sounds for disc priests
 - Some little ui improvements

# Release 2.0.8.4
## Bugfixes
 - Fix some typos / missleading labels
## Features
 - Add option the explicitly restart counter on timer stop condition
 - QoL stuff

# Release 2.0.8.3
## Bugfixes
 - Fix scrollbar jumping when changing selection of tab groups
## Features
 - Add Darkness as quick access on messages

# Release 2.0.8.2
## Bugfixes
 - Make sure you can restart multiple timers with the same event
## Features
None

# Release 2.0.8.1
## Bugfixes
 - Fix some tooltips
## Features
None

# Release 2.0.8.0
## Bugfixes
None
## Features
 - Be able to use usdifferent format for timings like `mm:ss`, `m:s`, `m:ss`, or just seconds like usual
 - Add `Rallying Cry` as fast access cooldown in messages

# Release 2.0.7.0
## Bugfixes
None
## Features
 - Be able to adjust default message targets
 - Be able to adjust default message for messages
 - Add icons for easy cooldown access in messages

# Release 2.0.6.1
## Bugfixes
 - Fix typo
## Features
None

# Release 2.0.6.0
## Bugfixes
None
## Features
 - First Iteration: Be able to use unit names for percentage trigger

# Release 2.0.5.9
## Bugfixes
 - Make sure custom encounter placeholders do not disappear on first navigation
 - Debug message changes
## Features
None

# Release 2.0.5.8
## Bugfixes
 - Clear executions on reactivation of timers
 - Be able to reactivate timers with the same spell (check stop and then start)
## Features
None

# Release 2.0.5.7
## Bugfixes
 - Fix typo
## Features
None

# Release 2.0.5.5
## Bugfixes
 - Be able to use $target in message targets again
## Features
None

# Release 2.0.5.4
## Bugfixes
 - Prevent users from using spaces within placeholder names
## Features
None

# Release 2.0.5.3
## Bugfixes
None
## Features
 - The addon now will save and restore the position of the main window
 - The addon now will save and restore the size of the main window
 - The addon now will save and restore the size of the tree group

# Release 2.0.5.2
## Bugfixes
 - Only iterate custom placeholders if present
## Features
None

# Release 2.0.5.1
## Bugfixes
None
## Features
- Added name editbox for timings so you have the ability to overwrite the default

# Release 2.0.5.0
## Bugfixes
None
## Features
 - Add custom placeholders for each encounter
  - Those will be exported / imported along with the given encounter
 - Add offset slider for timings which will be substracted from the timings
  - Can be used to offset all timings of a timer

# Release 2.0.4.1
This release supports the upcoming shadowlands beta / pre-patch.

# Release 2.0.4.1-SL-ALPHA
## Bugfixes
 - Added label to overlay name input
 - Changed media file names to reflect origin
## Features
None

# Release 2.0.4.0-SL-ALPHA
## Bugfixes
None
## Features
 - Be able to clone rotation entries
 - Be able to clone timings
 - Be able to clone percentages

# Release 2.0.3.0-SL-ALPHA
## Bugfixes
None
## Features
 - Be able to export custom placeholders
 - Be able to import custom placeholders
   - Newly imported placeholders will be *added* to the existing ones. They
     won't overwrite the existing ones

# Release 2.0.2.6-SL-ALPHA
## Bugfixes
None
## Features
 - Added shadowlands encounter ids for encounter select

# Release 2.0.2.5-SL-ALPHA
## Bugfixes
 - Be able to create new triggers again
   - You're no longer able to mute single messages. This change is due to the
     facts that each player can mute certain reicever overlays
## Features
None

# Release 2.0.2.4-SL-ALPHA
## Bugfixes
 - Make sure receiver overlay is positioned correctly after drag with mouse
## Features
None

# Release 2.0.2.3-SL-ALPHA
## Bugfixes
 - Make sure receiver overlay colors are set correctly on first start
## Features
None

# Release 2.0.2.2-SL-ALPHA
## Bugfixes
 - Make sure default colors are set correctly
 - Use correct receiver colors to display messages
## Features
None

# Release 2.0.2.1-SL-ALPHA
## Bugfixes
 - Be able to set sender overlay font again
 - Be able to set sender overlay backdrop color again
## Features
None

# Release 2.0.2.0-SL-ALPHA
## Bugfixes
None
## Features
 - Be able to configure multiple receiver overlays
   - You can change the target overlay on each message (defaults to "1")

# Release 2.0.0.0-SL-ALPHA
## Bugfixes
 - Make sure overlays will render from the beginning without opening options once
 - Make sure everything renders correctly for Shadowlands
## Features
 - Updated Libs

# Release 1.6.8.0-BETA
## Bugfixes
None
## Features
 - Add sliders to adjust positon of overlays

# Release 1.6.7.0-BETA
## Bugfixes
None
## Features
 - Send each message just once to every player configured (distinct targets)

# Release 1.6.6.0-BETA
## Bugfixes
 - Make sure every target in target preview is class colored
 - Make sure default sound is loaded correctly
 - Use the correct `ENCOUNTER_END` event to determine if combat stopped
## Features
None

# Release 1.6.5.1
## Bugfixes
 - Make sure custom placeholder groups work like intended
## Features
None

# Release 1.6.5.0

# Release 1.6.5.0-ALPHA
## Bugfixes
 - Make sure delete button is not removed when re rendering tab item
## Features
 - Custom placeholders are now rendered as tab group for more overview and easier
   usage

# Release 1.6.4.0-ALPHA
## Bugfixes
 - Make sure spell names on encounter overview are queried when needed and
   not ahead of time
## Features
None

# Release 1.6.3.1

# Release 1.6.3.0-ALPHA
## Bugfixes
 - Make sure rotations without start/stop condition don't show up as inactive
## Features
 - Add default sound select to receiver overlay options

# Release 1.6.2.0-ALPHA
## Bugfixes
 - Make sure sender overlay uses correct field to determine of trigger is inactive
## Features
 - Some UI improvements

# Release 1.6.1.0-ALPHA
## Bugfixes
 - Do not scroll to top if not needed
   - Will still happen on some pages due to needed rerendering
 - Fixed some locals
## Features
 - Show health/power percentage start/stop condition on encounter overview
 - No longer print spell name next to spell icon on condition, because we now have a spell tooltip


# Release 1.6.0.0-ALPHA
## Bugfixes
None
## Features
 - Add possibility to add start condition for health and power triggers
 - Add possibility to add stop condition for health and power triggers

# Release 1.5.3.0-ALPHA
## Bugfixes
None
## Features
 - Show spell tooltip for spell icons in conditions

# Release 1.5.2.0-ALPHA
## Bugfixes
None
## Features
 - Reorderd options tab group
 - Added custom placeholder locals

# Release 1.5.1.0-ALPHA
## Bugfixes
None
## Features
 - You now can differentiate between custom placeholder types `player` and `group`
   - `player` will only message one player which is configured (ment for alts)
   - `group` will message every player configured (ment for custom groups assigned to a specific task)
## CAUTION
 - `customNames` was completly removed from the state
   - You might have to redo your placeholders. Sorry.

# Release 1.5.0.0-ALPHA
## Bugfixes
 - Do not show empty triggers on encounter overview
 - Better handling of messages not ment for the player
## Features
 - Be able to use $group1-8 as placeholder in message targets (will be exchanged with the player names dynamically)
 - Add more options to target select for messages
 - Support `space` as delimiter in message targets for more stability
 - Renamed `customNames` to `customPlaceholders`
   - This change was made in preparation to add more placeholder types like `group` (all players will be messaged instead of one)

# Release 1.4.2.3-ALPHA
## Bugfixes
 - Do not jump to general settings after version check
## Features
None

# Release 1.4.2.2-ALPHA
## Bugfixes
 - Fixed some Shadowlands locals
 - Fixed an issue with the encounter overview and overhaul
## Features
None

# Release 1.4.2.0-ALPHA
## Bugfixes
None
## Features
 - Add chat command `/prtm $message` to send messages on the fly
 - You now can add a `Start condition` for rotations on which the rotation should start counting
 - You now can add a `Stop condition` for rotations on which the rotation should stop counting
   - Those can be defined without the need to define a `Start condition`. So it will "start" counting from `ENCOUNTER_START` and stop on `Stop condition`

# Release 1.4.1.0-ALPHA
## Bugfixes
None
## Features
 - Add custom placeholders for message targets

# Release 1.4.0.0-ALPHA
## Bugfixes
 - Fix some locals
## Features
 - Remove 180 character limit for messages (shouldn't really matter)
 - Added shared media files with more to come for the new expansion
 - Prepare encounter select for Shadowlands

# Release 1.3.23.0

# Release 1.3.23.0-BETA
## Bugfixes
None
## Features
 - Add encounter select box to encounter options to easily select the encounter of the current raid tier

# Release 1.3.22.0-BETA
## Bugfixes
None
## Features
 - Tiny change for condition layout

# Release 1.3.21.0-BETA
## Bugfixes
None
## Features
 - Be able to clone any trigger

# Release 1.3.20.0

# Release 1.3.20.0-BETA
## Bugfixes
 - Do not zoom raid markers in messages
## Features
 - Add some more default options

# Release 1.3.19.0-BETA
## Bugfixes
 - Be able to open confirmation dialogs again after closing them with `x`
## Features
 - Add button to clear raid roster

# Release 1.3.18.2
## Bugfixes
 - Send message to whisper channel regardless of test mode
 - Make sure every popup frame can only be open once
## Features
None

# Release 1.3.18.1

# Changelog 1.3.18.1-BETA
## Bugfixes
 - Show all party members on version check not only the ones with the addon
 - Send messages through whipser channel if alone and in test mode
## Features
None

# Changelog 1.3.18.0-BETA
## Bugfixes
 - Make sure receiver overlay is initialized even if you're not in sender mode
 - Make sure receiver overlay is reset after combat if not in sender mode
 - Make sure addon can run standalone
 - Make sure version check correctly works crossrealm
## Features
 - If PRT is disabled it now won't display any debug or info messages

# Changelog 1.3.17.3-BETA
## Bugfixes
 - Fix version check for crossrealm
## Features
None

# Release 1.3.17.1

# Changelog 1.3.17.1-BETA
## Bugfixes
 - Correctly check for `$me` in message filter
## Features
None

# Changelog 1.3.17.0-BETA
## Bugfixes
None
## Features
 - Be able to use `$me` as message filter

# Changelog 1.3.16.3-BETA
## Bugfixes
 - Make sure to show weakaura receiver button only in sender mode
 - Make sure to show message filter in receiver mode aswell
## Features
None

# Changelog 1.3.16.2-BETA
## Bugfixes
 - Make sure raid roster tab is refreshed after import of current group
## Features
None

# Changelog 1.3.16.1-BETA
## Bugfixes
 - All open frames will now be closed when PRT is closed
## Features
 - Added raid roster import by current group
 - Added confirmation dialog for raid roster import
 - Added confirmation dialog for encounter deletion
 - Added confirmation dialog for timer deletion
 - Added confirmation dialog for rotation deletion
 - Added confirmation dialog for percentage deletion

# Changelog 1.3.15.2-BETA
## Bugfixes
 - Make version check work again
## Features
None

# Changelog 1.3.15.1-BETA
## Bugfixes
None
## Features
 - Be able to filter messages by player name (select the player who you want to display messages from)

# Changelog 1.3.14.1-BETA
## Bugfixes
 - Make sure version check works for raids and not only for groups
## Features
None

# Changelog 1.3.14.0-BETA
## Bugfixes
None
## Features
 - Added version check /prt version

# Changelog 1.3.13.0-BETA
## Bugfixes
 - Make sure receiver overlay stays visible after locking it
## Features
 - The WeakAura and the addon now have different addon message prefixes so the WeakAura won't receiver messages if legacy mode is disabled
 - First attempt of adding version check (only prints the versions of people who have the addon installed!)

# Release 1.3.12.2

# Changelog 1.3.12.2-BETA
## Bugfixes
 - Make sure weakaura legacy mode actually sends messages to the weakaura
## Features
None

# Changelog 1.3.12.1-BETA
## Bugfixes
 - Only update receiver overlay if it is already initialized
 - Only start encounter if it is enabled even in test mode
## Features
None

# Changelog 1.3.11.0-BETA
## Bugfixes
 - Disabled rotations will now display correctly on the sender overlay
 - Remove duplicate files
## Features
 - Disable or hide all sender related inputs if only receiver mode is selected

# Changelog 1.3.10.0-BETA
## Bugfixes
None
## Features
 - When a custom sound is selected the sound will now play once
 - Show disabled trigger in red within the tree view

# Changelog 1.3.9.0-BETA
## Bugfixes
None
## Features
 - Receiver overlay will now be displayed while in options
 - Receiver font color will now be updated directly if changed

# Changelog 1.3.8.1
## Bugfixes
 - Make sure newly created percentages are enabled by default
 - Make sure example encounter triggers are enabled by default
## Features
None

# Changelog 1.3.8.0
## Bugfixes
None
## Features
 - Update default values for example encounter
 - Update default values for trigger settings
 - Update example encounter to show raid markers and spell icons

# Changelog 1.3.7.3
## Bugfixes
None
## Features
 - Release version 1.3.7.3

# Changelog 1.3.7.3-BETA
## Bugfixes
 - Make sure you can deactivate sounds on each message
## Features
None

# Changelog 1.3.7.1-BETA
## Bugfixes
 - Make sure message.duration is used correctly to remove message from receiver display
## Features
None