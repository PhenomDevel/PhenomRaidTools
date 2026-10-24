local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-- Notes for the "What's new" window (WhatsNew.lua), newest first. Add an
-- entry for every release users should hear about; small fixes need none.
-- Lines starting with "# " are section headings; a function computes its
-- line when the window opens (nil: no line).

local function UnsupportedTriggers()
  local count = 0
  for _, encounter in ipairs(PRT.GetProfileDB().encounters or {}) do
    for _, version in ipairs(encounter.versions or {}) do
      count = count + #PRT.GetUnsupportedTriggers(version)
    end
  end
  if count > 0 then
    return L["%d of your triggers can't fire anymore (combat log, boss health or power). They are kept and listed per encounter under {Can't fire anymore}."]:format(count)
  end
end

PRT.whatsNew = {
  {
    version = "3.0.0",
    notes = {
      "# " .. L["Midnight and WoW: Forever"],
      L["Since Midnight addons get no combat log, no boss health or power and can't message the group during encounters. Plans now go to the group before the pull and run on every player."],
      L["The lead sends the plans on every ready check (or with `/prt sync`); the overview shows who has them."],
      UnsupportedTriggers,
      "# " .. L["New window"],
      L["Everything in one window with search: overview, encounters with a timeline, players & groups, templates, overlays, settings and profiles."],
      L["Assignments are edited as one sentence with a live preview and can be tried on your overlay."],
      "# " .. L["Overlays"],
      L["Each overlay shows text, icons or bars, grows in any direction and starts at its anchor or centered on it."],
      L["New: your next assignments during an encounter, with a countdown."],
      L["`/prt news` opens this window again."]
    }
  }
}
