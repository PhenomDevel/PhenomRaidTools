local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

function PRT.AddCustomPlaceholderOptions(container, profile, encounterID)
  local _, encounter = PRT.TableUtils.GetBy(profile.encounters, "id", tonumber(encounterID))
  local CustomPlaceholders = encounter.CustomPlaceholders

  if not CustomPlaceholders then
    encounter.CustomPlaceholders = {}
    CustomPlaceholders = {}
  end

  local removeAllButton = PRT.Button(L["Remove all"])
  removeAllButton:SetCallback("OnClick",
    function()
      PRT.ConfirmationDialog(L["Are you sure you want to remove all custom placeholders?"],
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
