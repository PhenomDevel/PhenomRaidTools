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

  local removeAllButton = PRT.Button("removeAllButton")
  removeAllButton:SetCallback("OnClick",
    function()
      PRT.ConfirmationDialog("removeAllCustomPlaceholderConfirmation",
        function()
          wipe(CustomPlaceholders)
          container:ReleaseChildren()
          PRT.AddCustomPlaceholderOptions(container, profile, encounterID)
        end)
    end)

  PRT.AddCustomPlaceholderDescription(container)
  container:AddChild(removeAllButton)
  PRT.AddCustomPlaceholdersTabGroup(container, CustomPlaceholders)
end
