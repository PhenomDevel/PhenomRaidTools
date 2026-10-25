# Changelog

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
