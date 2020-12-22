===============================================================================
# Release 2.0.8.4
## Bugfixes
 - Fix some typos / missleading labels

## Features
 - Add option the explicitly restart counter on timer stop condition
 - QoL stuff


===============================================================================
# Release 2.0.8.3
## Bugfixes
 - Fix scrollbar jumping when changing selection of tab groups

## Features
 - Add Darkness as quick access on messages


===============================================================================
# Release 2.0.8.2
## Bugfixes
 - Make sure you can restart multiple timers with the same event

## Features
None


===============================================================================
# Release 2.0.8.1
## Bugfixes
 - Fix some tooltips

## Features
None


===============================================================================
# Release 2.0.8.0
## Bugfixes
None

## Features
 - Be able to use usdifferent format for timings like `mm:ss`, `m:s`, `m:ss`, or just seconds like usual
 - Add `Rallying Cry` as fast access cooldown in messages


===============================================================================
# Release 2.0.7.0
## Bugfixes
None

## Features
 - Be able to adjust default message targets
 - Be able to adjust default message for messages
 - Add icons for easy cooldown access in messages


===============================================================================
# Release 2.0.6.1
## Bugfixes
 - Fix typo

## Features
None


===============================================================================
# Release 2.0.6.0
## Bugfixes
None

## Features
 - First Iteration: Be able to use unit names for percentage trigger


===============================================================================
# Release 2.0.5.9
## Bugfixes
 - Make sure custom encounter placeholders do not disappear on first navigation
 - Debug message changes

## Features
None


===============================================================================
# Release 2.0.5.8
## Bugfixes
 - Clear executions on reactivation of timers
 - Be able to reactivate timers with the same spell (check stop and then start)

## Features
None


===============================================================================
# Release 2.0.5.7
## Bugfixes
 - Fix typo

## Features
None


===============================================================================
# Release 2.0.5.5
## Bugfixes
 - Be able to use $target in message targets again

## Features
None


===============================================================================
# Release 2.0.5.4
## Bugfixes
 - Prevent users from using spaces within placeholder names

## Features
None


===============================================================================
# Release 2.0.5.3
## Bugfixes
None

## Features
 - The addon now will save and restore the position of the main window
 - The addon now will save and restore the size of the main window
 - The addon now will save and restore the size of the tree group


===============================================================================
# Release 2.0.5.2
## Bugfixes
 - Only iterate custom placeholders if present

## Features
None


===============================================================================
# Release 2.0.5.1
## Bugfixes
None

## Features
- Added name editbox for timings so you have the ability to overwrite the default


===============================================================================
# Release 2.0.5.0
## Bugfixes
None

## Features
 - Add custom placeholders for each encounter
  - Those will be exported / imported along with the given encounter
 - Add offset slider for timings which will be substracted from the timings
  - Can be used to offset all timings of a timer  


===============================================================================
# Release 2.0.4.1
This release supports the upcoming shadowlands beta / pre-patch.


===============================================================================
# Release 2.0.4.1-SL-ALPHA
## Bugfixes
 - Added label to overlay name input
 - Changed media file names to reflect origin

## Features
None


===============================================================================
# Release 2.0.4.0-SL-ALPHA
## Bugfixes
None

## Features
 - Be able to clone rotation entries
 - Be able to clone timings
 - Be able to clone percentages


===============================================================================
# Release 2.0.3.0-SL-ALPHA
## Bugfixes
None

## Features
 - Be able to export custom placeholders
 - Be able to import custom placeholders
   - Newly imported placeholders will be *added* to the existing ones. They
     won't overwrite the existing ones


===============================================================================
# Release 2.0.2.6-SL-ALPHA
## Bugfixes
None

## Features
 - Added shadowlands encounter ids for encounter select


===============================================================================
# Release 2.0.2.5-SL-ALPHA
## Bugfixes
 - Be able to create new triggers again
   - You're no longer able to mute single messages. This change is due to the 
     facts that each player can mute certain reicever overlays

## Features
None


===============================================================================
# Release 2.0.2.4-SL-ALPHA
## Bugfixes
 - Make sure receiver overlay is positioned correctly after drag with mouse

## Features
None


===============================================================================
# Release 2.0.2.3-SL-ALPHA
## Bugfixes
 - Make sure receiver overlay colors are set correctly on first start

## Features
None


===============================================================================
# Release 2.0.2.2-SL-ALPHA
## Bugfixes
 - Make sure default colors are set correctly
 - Use correct receiver colors to display messages

## Features
None


===============================================================================
# Release 2.0.2.1-SL-ALPHA
## Bugfixes
 - Be able to set sender overlay font again
 - Be able to set sender overlay backdrop color again

## Features
None


===============================================================================
# Release 2.0.2.0-SL-ALPHA
## Bugfixes
None

## Features
 - Be able to configure multiple receiver overlays
   - You can change the target overlay on each message (defaults to "1")


===============================================================================
# Release 2.0.0.0-SL-ALPHA
## Bugfixes
 - Make sure overlays will render from the beginning without opening options once
 - Make sure everything renders correctly for Shadowlands

## Features
 - Updated Libs


===============================================================================
# Release 1.6.8.0-BETA
## Bugfixes
None

## Features
 - Add sliders to adjust positon of overlays


===============================================================================
# Release 1.6.7.0-BETA
## Bugfixes
None

## Features
 - Send each message just once to every player configured (distinct targets)


===============================================================================
# Release 1.6.6.0-BETA
## Bugfixes
 - Make sure every target in target preview is class colored
 - Make sure default sound is loaded correctly
 - Use the correct `ENCOUNTER_END` event to determine if combat stopped

## Features
None


===============================================================================
# Release 1.6.5.1
## Bugfixes
 - Make sure custom placeholder groups work like intended

## Features
None

===============================================================================
# Release 1.6.5.0


===============================================================================
# Release 1.6.5.0-ALPHA
## Bugfixes
 - Make sure delete button is not removed when re rendering tab item

## Features
 - Custom placeholders are now rendered as tab group for more overview and easier
   usage


===============================================================================
# Release 1.6.4.0-ALPHA
## Bugfixes
 - Make sure spell names on encounter overview are queried when needed and 
   not ahead of time

## Features
None


===============================================================================
# Release 1.6.3.1


===============================================================================
# Release 1.6.3.0-ALPHA
## Bugfixes
 - Make sure rotations without start/stop condition don't show up as inactive

## Features
 - Add default sound select to receiver overlay options


===============================================================================
# Release 1.6.2.0-ALPHA
## Bugfixes
 - Make sure sender overlay uses correct field to determine of trigger is inactive

## Features
 - Some UI improvements


===============================================================================
# Release 1.6.1.0-ALPHA
## Bugfixes
 - Do not scroll to top if not needed
   - Will still happen on some pages due to needed rerendering
 - Fixed some locals

## Features
 - Show health/power percentage start/stop condition on encounter overview
 - No longer print spell name next to spell icon on condition, because we now have a spell tooltip



===============================================================================
# Release 1.6.0.0-ALPHA
## Bugfixes
None

## Features
 - Add possibility to add start condition for health and power triggers
 - Add possibility to add stop condition for health and power triggers


===============================================================================
# Release 1.5.3.0-ALPHA
## Bugfixes
None

## Features
 - Show spell tooltip for spell icons in conditions


===============================================================================
# Release 1.5.2.0-ALPHA
## Bugfixes
None

## Features
 - Reorderd options tab group
 - Added custom placeholder locals


===============================================================================
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


===============================================================================
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


===============================================================================
# Release 1.4.2.3-ALPHA
## Bugfixes
 - Do not jump to general settings after version check

## Features
None


===============================================================================
# Release 1.4.2.2-ALPHA
## Bugfixes
 - Fixed some Shadowlands locals
 - Fixed an issue with the encounter overview and overhaul

## Features
None


===============================================================================
# Release 1.4.2.0-ALPHA
## Bugfixes
None

## Features
 - Add chat command `/prtm $message` to send messages on the fly
 - You now can add a `Start condition` for rotations on which the rotation should start counting
 - You now can add a `Stop condition` for rotations on which the rotation should stop counting
   - Those can be defined without the need to define a `Start condition`. So it will "start" counting from `ENCOUNTER_START` and stop on `Stop condition`


===============================================================================
# Release 1.4.1.0-ALPHA
## Bugfixes
None

## Features
 - Add custom placeholders for message targets


===============================================================================
# Release 1.4.0.0-ALPHA
## Bugfixes
 - Fix some locals

## Features
 - Remove 180 character limit for messages (shouldn't really matter)
 - Added shared media files with more to come for the new expansion
 - Prepare encounter select for Shadowlands
 

===============================================================================
# Release 1.3.23.0


===============================================================================
# Release 1.3.23.0-BETA
## Bugfixes
None

## Features
 - Add encounter select box to encounter options to easily select the encounter of the current raid tier


===============================================================================
# Release 1.3.22.0-BETA
## Bugfixes
None

## Features
 - Tiny change for condition layout


===============================================================================
# Release 1.3.21.0-BETA
## Bugfixes
None

## Features
 - Be able to clone any trigger


===============================================================================
# Release 1.3.20.0


===============================================================================
# Release 1.3.20.0-BETA
## Bugfixes
 - Do not zoom raid markers in messages

## Features
 - Add some more default options


===============================================================================
# Release 1.3.19.0-BETA
## Bugfixes
 - Be able to open confirmation dialogs again after closing them with `x`

## Features
 - Add button to clear raid roster


===============================================================================
# Release 1.3.18.2
## Bugfixes
 - Send message to whisper channel regardless of test mode
 - Make sure every popup frame can only be open once

## Features
None


===============================================================================
# Release 1.3.18.1

===============================================================================
# Changelog 1.3.18.1-BETA
## Bugfixes
 - Show all party members on version check not only the ones with the addon
 - Send messages through whipser channel if alone and in test mode

## Features
None


===============================================================================
# Changelog 1.3.18.0-BETA
## Bugfixes
 - Make sure receiver overlay is initialized even if you're not in sender mode
 - Make sure receiver overlay is reset after combat if not in sender mode
 - Make sure addon can run standalone
 - Make sure version check correctly works crossrealm

## Features
 - If PRT is disabled it now won't display any debug or info messages


===============================================================================
# Changelog 1.3.17.3-BETA
## Bugfixes
 - Fix version check for crossrealm

## Features
None


===============================================================================
# Release 1.3.17.1


===============================================================================
# Changelog 1.3.17.1-BETA
## Bugfixes
 - Correctly check for `$me` in message filter

## Features
None


===============================================================================
# Changelog 1.3.17.0-BETA
## Bugfixes
None

## Features
 - Be able to use `$me` as message filter


===============================================================================
# Changelog 1.3.16.3-BETA
## Bugfixes
 - Make sure to show weakaura receiver button only in sender mode
 - Make sure to show message filter in receiver mode aswell

## Features
None


===============================================================================
# Changelog 1.3.16.2-BETA
## Bugfixes
 - Make sure raid roster tab is refreshed after import of current group

## Features
None


===============================================================================
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


===============================================================================
# Changelog 1.3.15.2-BETA
## Bugfixes
 - Make version check work again

## Features
None


===============================================================================
# Changelog 1.3.15.1-BETA
## Bugfixes
None

## Features
 - Be able to filter messages by player name (select the player who you want to display messages from)


===============================================================================
# Changelog 1.3.14.1-BETA
## Bugfixes
 - Make sure version check works for raids and not only for groups

## Features
None


===============================================================================
# Changelog 1.3.14.0-BETA
## Bugfixes
None

## Features
 - Added version check /prt version


===============================================================================
# Changelog 1.3.13.0-BETA
## Bugfixes
 - Make sure receiver overlay stays visible after locking it

## Features
 - The WeakAura and the addon now have different addon message prefixes so the WeakAura won't receiver messages if legacy mode is disabled
 - First attempt of adding version check (only prints the versions of people who have the addon installed!)


===============================================================================
# Release 1.3.12.2


===============================================================================
# Changelog 1.3.12.2-BETA
## Bugfixes
 - Make sure weakaura legacy mode actually sends messages to the weakaura

## Features
None


===============================================================================
# Changelog 1.3.12.1-BETA
## Bugfixes
 - Only update receiver overlay if it is already initialized
 - Only start encounter if it is enabled even in test mode

## Features
None


===============================================================================
# Changelog 1.3.11.0-BETA
## Bugfixes
 - Disabled rotations will now display correctly on the sender overlay
 - Remove duplicate files

## Features
 - Disable or hide all sender related inputs if only receiver mode is selected


===============================================================================
# Changelog 1.3.10.0-BETA
## Bugfixes
None

## Features
 - When a custom sound is selected the sound will now play once
 - Show disabled trigger in red within the tree view


===============================================================================
# Changelog 1.3.9.0-BETA
## Bugfixes
None

## Features
 - Receiver overlay will now be displayed while in options
 - Receiver font color will now be updated directly if changed


===============================================================================
# Changelog 1.3.8.1
## Bugfixes
 - Make sure newly created percentages are enabled by default
 - Make sure example encounter triggers are enabled by default

## Features
None


===============================================================================
# Changelog 1.3.8.0
## Bugfixes
None

## Features
 - Update default values for example encounter
 - Update default values for trigger settings
 - Update example encounter to show raid markers and spell icons


===============================================================================
# Changelog 1.3.7.3
## Bugfixes
None

## Features
 - Release version 1.3.7.3


===============================================================================
# Changelog 1.3.7.3-BETA
## Bugfixes
 - Make sure you can deactivate sounds on each message

## Features
None


===============================================================================
# Changelog 1.3.7.1-BETA
## Bugfixes
 - Make sure message.duration is used correctly to remove message from receiver display

## Features
None