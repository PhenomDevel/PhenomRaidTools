local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Public API

function PRT.AddOptionWidgets(container)
  local optionsTabs = {
    {
      value = "general",
      text = L["General"]
    },
    {
      value = "raidRoster",
      text = L["Raidroster"],
      disabled = not PRT.IsSender()
    },
    {
      value = "difficulties",
      text = L["Difficulties"]
    },
    {
      value = "overlay",
      text = L["Overlays"]
    },
    {
      value = "defaults",
      text = L["Trigger Defaults"],
      disabled = not PRT.IsSender()
    },
    {
      value = "information",
      text = L["Information"]
    }
  }

  local optionsTabsGroup = PRT.TabGroup(nil, optionsTabs)
  optionsTabsGroup:SetLayout("Flow")
  optionsTabsGroup:SetCallback(
    "OnGroupSelected",
    function(tabGroup, _, key)
      tabGroup:ReleaseChildren()

      if key == "general" then
        PRT.AddGeneralWidgets(tabGroup, PRT.GetProfileDB())
      elseif key == "difficulties" then
        PRT.AddDifficultyWidgets(tabGroup, PRT.GetProfileDB().enabledDifficulties)
      elseif key == "defaults" then
        PRT.AddDefaultsGroups(tabGroup, PRT.GetProfileDB().triggerDefaults)
      elseif key == "raidRoster" then
        PRT.AddRaidRosterWidget(tabGroup, PRT.GetProfileDB().raidRoster)
      elseif key == "overlay" then
        PRT.AddOverlayWidget(tabGroup, PRT.GetProfileDB().overlay)
      elseif key == "information" then
        PRT.AddInformationWidgets(tabGroup)
      end
    end
  )

  container:AddChild(optionsTabsGroup)
  optionsTabsGroup:SelectTab("general")
end
