local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-- Notes for the "What's new" window (WhatsNew.lua), newest first. Add an
-- entry for every release users should hear about; small fixes need none.
-- Lines starting with "# " are section headings; a function computes its
-- line when the window opens (nil: no line).

PRT.whatsNew = {
  {
    version = "3.2.0",
    notes = {
      "# " .. L["Encounter page"],
      L["The encounter page is one desk: bosses as tiles, the timeline across the full width and the selected assignment below as a form. *Advanced* opens all settings in their own window."],
      L["In the timeline, drag a marker to move the assignment (with Alt to copy it, middle-click deletes it). The mouse wheel zooms; Shift + mouse wheel or dragging an empty spot scrolls."],
      L["*Demo playback* plays the plan from the playhead on your overlays. *View as* shows only what a role or player gets."],
      "# " .. L["Dungeons"],
      L["*New encounter* also lists the dungeons of the current expansion and, on Retail, the Mythic+ dungeons of the season. In a dungeon group every member can send plans."],
      L["Encounters you don't share with the group (*Share with the group*) run only for you."],
      "# " .. L["Overlays"],
      L["Cooldowns show 5 seconds early and count down to the moment you press them. Change it on *New messages* or per assignment."],
      L["Every overlay has its own font, size, outline and shadow."],
      L["*Overlays → Demo* or `/prt demo` plays a short sample fight with every kind of message on your overlays."]
    }
  },
  {
    version = "3.1.0",
    notes = {
      "# " .. L["Midnight and WoW: Forever"],
      L["Since Midnight addons get no combat log, no boss health or power and can't message the group during encounters. Plans now go to the group before the pull and run on every player."],
      L["The lead sends the plans on every ready check (or with `/prt sync`); the overview shows who has them."],
      L["What can't run anymore is gone: rotations, health and power percentages, timers on combat log events, raid warnings, raid markers, placeholders and `/prtm`."],
      "# " .. L["New window"],
      L["Everything in one window with search: overview, encounters, templates, overlays, settings and profiles."],
      L["Click into an encounter's timeline to add an assignment there, once or repeating. The preview beside the window shows it as your players see it."],
      L["New encounters start from the bosses of the current raids; the list is grouped by instance."],
      L["Every assignment has its own difficulties. Groups and encounter versions are gone: an encounter keeps the version that was active."],
      L["Cooldowns show the spell's name or your own text, and any message can be read aloud with text to speech."],
      "# " .. L["Overlays"],
      L["New profiles start with three overlays: messages at the top, healing cooldowns on the left, utility cooldowns on the right. A cooldown chosen from the list goes on the matching one."],
      L["Each overlay shows text, icons or bars, grows in any direction and starts at its anchor or centered on it."],
      L["New: your next assignments during an encounter, with a countdown."],
      L["`/prt news` opens this window again."]
    }
  }
}
