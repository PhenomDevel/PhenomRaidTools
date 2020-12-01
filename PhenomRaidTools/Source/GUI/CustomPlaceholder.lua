local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

PRT.AddCustomPlaceholderOptions = function(container, profile, encounterID)
   local idx, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
   local CustomPlaceholders = encounter.CustomPlaceholders

   if not CustomPlaceholders then
      encounter.CustomPlaceholders = {}
      CustomPlaceholders = {}
   end

   PRT.AddCustomPlaceholdersTabGroup(container, CustomPlaceholders)
end