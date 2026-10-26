# Changelog

## Unreleased

### Added
- Warn earlier: a cooldown shows 5 seconds before its time by default and counts down to the moment you press it, then shows *Now*. Change the default on the *New messages* page or per assignment; text messages can warn earlier too.
- **The encounter page is one desk:** the bosses of the instance as tiles on top, a toolbar, the timeline across the whole width and the selected assignment below it as a form with one line per setting: template, when (once, repeating or several times), what, for whom, overlay, duration and warning, sound and difficulties. A new assignment can start from a template right there. *Advanced* opens every setting in a window of its own. There is no separate encounter list or assignment page anymore.
- **Demo playback:** plays the plan from the playhead on your overlays, in real time or four times as fast. Click on the time axis to move the playhead.
- **View as** a role or player: the timeline and the demo playback show only what they get. Normal, Heroic and Mythic switch on and off one by one; the timeline dims the assignments that run on none of them.
- In the timeline, drag a marker to move the assignment, with Alt to copy it, and middle-click it to delete it (asks first). The mouse wheel zooms (out to 20 minutes, to plan after the last assignment), Shift + mouse wheel scrolls the time, and repeating assignments show as a bar. The timeline and its markers list these controls.
- *New encounter* lists the dungeons of the current expansion besides the raids.
- On Retail it also lists the Mythic+ dungeons of the current season. A dungeon's page lets you add a boss the journal doesn't list, by its encounter ID.
- Each encounter has a *Share with the group* switch. Encounters you don't share aren't sent to your group and run only for you.
- Demo: *Overlays → Demo* or `/prt demo` plays a sample fight of about 40 seconds with every kind of message for you (text with countdown, marker, own sound, read aloud, healing and utility cooldowns, a repeating assignment) on your overlays, plus your next assignments and the raid plan in combat. It runs anywhere, out of combat and in every role.

### Changed
- In a dungeon group every member can send plans; in a raid it stays the leader and assistants.
- Simpler window: the overview and the settings are one page (with *About* at the end), and importing an encounter moved to *New encounter*.
- The overview picks your role (lead, player or both) the same way as the first start guide.
- A message's sound is one choice: the overlay's sound, its own sound or TTS (text to speech).
- An assignment's targets are picked with ticks in one list (roles, your group, raid groups, classes), so several targets need no extra step.
- *Save as template* is one click; the template is named after the message and can be renamed on the templates page.
- The message editor has no *Tools* card and no *Undo* anymore; loading and saving templates and deleting the assignment are at the end of *Display*.
- Overlays have one *Unlock* switch instead of lock and unlock buttons, *Raid plan in combat* (formerly *Lead status*) one switch to place it, and the layout options are labeled.
- *New messages* is its own page with the same options as an assignment (type, text, targets, overlay, duration, sound) plus the difficulties of new assignments. Every new assignment and template starts as this message.
- Overlays lock again when you close the options window.
- A new profile is created by pressing Enter in its name field.
- The debug log shows one line per entry.
- Every overlay (messages, your next assignments, lead status) has the same text settings: font, size, outline (off, thin, thick) and shadow.
- *Your next assignments* shows every line in the same size; the next one is no longer larger.

### Fixed
- The *Every* slider of a repeating assignment can be dragged again.
- Overlays in icon or bar style and the upcoming list show a message's icon once instead of twice (cooldowns showed their spell icon beside and in the text).
- *Countdown* now has an effect on overlays in icon or bar style (and in the preview): without it, no remaining seconds show beside the text.
- The button that writes the cooldown assignments into your MethodRaidTools note is back. It is now always shown on the encounter page and grayed out only when MethodRaidTools isn't loaded.

## v3.1.0 (2026-10-25)

PhenomRaidTools 3.1 for Midnight (12.x) and WoW: Forever. Since Midnight, addons get no combat log and no boss health or power, and they can't message the group during encounters. PRT therefore sends the plans to the group before the pull, and every player runs them locally.

**Back up your SavedVariables first** (`WTF/Account/<account>/SavedVariables/PhenomRaidTools.lua`). The update removes everything that can't run anymore, and this can't be undone.

### New
- Everything is in one window with search: overview, encounters, templates, overlays, settings and profiles (`/prt`).
- The lead sends the enabled plans on every ready check or with `/prt sync`, and the overview shows who has them.
- **Assignments:** click into an encounter's timeline to add one at that time. An assignment shows once, repeating (every *n* seconds from–to) or at several times, and runs only on the difficulties you pick.
- The timeline shows spell icons. Hover a marker to see the text and who gets it.
- Cooldowns show the spell's name or your own text. Text to speech can read any message aloud.
- A preview beside the window shows the assignment or overlay you are editing.
- *New encounter* offers the bosses of the current raids. The encounter list is grouped by instance and shows boss portraits.
- New profiles start with three overlays: messages at the top, healing cooldowns on the left and utility cooldowns on the right. A cooldown chosen from the list goes on the matching overlay.
- Each overlay shows text, icons or bars and can grow in any direction.
- *Your next assignments* shows what is next for you during an encounter.
- The *What's new* window opens after updates, and `/prt news` opens it again.

### Removed
- Rotations, health and power percentages, timers on combat log events, stop conditions, raid warnings, raid markers, placeholders (raid roster, custom and encounter placeholders), `/prtm` and the message filter.
- Encounter versions (the active version is kept) and timer groups. Each assignment takes over its group's difficulties.
- The old AceGUI options and Classic Era / Wrath Classic support.
- The unfinished global `PRT` API for other addons; its functions did nothing.
