local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-- Notes for the "What's new" window (WhatsNew.lua), newest first. Add an
-- entry for every release users should hear about; small fixes need none.
-- Lines starting with "# " are section headings; a function computes its
-- line when the window opens (nil: no line).

PRT.whatsNew = {
  {
    version = "3.0.0",
    notes = {
      "# " .. L["Midnight and WoW: Forever"],
      L["Since Midnight addons get no combat log, no boss health or power and can't message the group during encounters. Plans now go to the group before the pull and run on every player."],
      L["The lead sends the plans on every ready check (or with `/prt sync`); the overview shows who has them."],
      L["What can't run anymore is gone: rotations, health and power percentages, timers on combat log events, raid warnings, raid markers, placeholders and `/prtm`."],
      "# " .. L["New window"],
      L["Everything in one window with search: overview, encounters, templates, overlays, settings and profiles."],
      L["Click into an encounter's timeline to add an assignment there, once or repeating. The preview beside the window shows it as your players see it."],
      L["New encounters start from the bosses of the current raids."],
      "# " .. L["Overlays"],
      L["New profiles start with three overlays: messages at the top, healing cooldowns on the left, utility cooldowns on the right. A cooldown chosen from the list goes on the matching one."],
      L["Each overlay shows text, icons or bars, grows in any direction and starts at its anchor or centered on it."],
      L["New: your next assignments during an encounter, with a countdown."],
      L["`/prt news` opens this window again."]
    }
  }
}
