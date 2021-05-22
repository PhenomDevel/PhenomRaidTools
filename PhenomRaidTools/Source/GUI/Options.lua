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
      text = L["Raidroster"] ,
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
      text = L["Trigger Defaults"] ,
      disabled = not PRT.IsSender()
    },
    {
      value = "information",
      text = L["Information"]
    }
  }

  local optionsTabsGroup = PRT.TabGroup(nil, optionsTabs)
  optionsTabsGroup:SetLayout("Flow")
  optionsTabsGroup:SetCallback("OnGroupSelected",
    function(container, _, key)
      container:ReleaseChildren()

      if key ==  "general" then
        PRT.AddGeneralWidgets(container, PRT.GetProfileDB())
      elseif key == "difficulties" then
        PRT.AddDifficultyWidgets(container, PRT.GetProfileDB().enabledDifficulties)
      elseif key == "defaults" then
        PRT.AddDefaultsGroups(container, PRT.GetProfileDB().triggerDefaults)
      elseif key == "raidRoster" then
        PRT.AddRaidRosterWidget(container, PRT.GetProfileDB().raidRoster)
      elseif key == "overlay" then
        PRT.AddOverlayWidget(container, PRT.GetProfileDB().overlay)
      elseif key == "information" then
        PRT.AddInformationWidgets(container)
      end

      if PRT.mainWindowContent.scrollFrame then
        PRT.Core.UpdateScrollFrame()
      end
    end)

  container:AddChild(optionsTabsGroup)
  optionsTabsGroup:SelectTab("general")
end
