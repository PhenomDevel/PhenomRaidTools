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