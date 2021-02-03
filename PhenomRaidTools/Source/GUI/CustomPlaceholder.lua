local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

function PRT.AddCustomPlaceholderOptions(container, profile, encounterID)
  local _, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
  local CustomPlaceholders = encounter.CustomPlaceholders

  if not CustomPlaceholders then
    encounter.CustomPlaceholders = {}
    CustomPlaceholders = {}
  end

  PRT.AddCustomPlaceholderDescription(container)
  PRT.AddCustomPlaceholdersTabGroup(container, CustomPlaceholders)
end
