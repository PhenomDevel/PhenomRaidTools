local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Public API

function PRT.AddOptionWidgets(container)
  container:SetLayout("Fill")
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

  local contentScrollFrame = PRT.ScrollFrame()
  contentScrollFrame:SetFullHeight(true)
  contentScrollFrame:SetFullWidth(true)

  local optionsTabsGroup = PRT.TabGroup(nil, optionsTabs)
  optionsTabsGroup:SetLayout("Flow")
  optionsTabsGroup:SetCallback(
    "OnGroupSelected",
    function(_, _, key)
      contentScrollFrame:ReleaseChildren()

      if key == "general" then
        PRT.AddGeneralWidgets(contentScrollFrame, PRT.GetProfileDB())
      elseif key == "difficulties" then
        PRT.AddDifficultyWidgets(contentScrollFrame, PRT.GetProfileDB().enabledDifficulties)
      elseif key == "defaults" then
        PRT.AddDefaultsGroups(contentScrollFrame, PRT.GetProfileDB().triggerDefaults)
      elseif key == "raidRoster" then
        PRT.AddRaidRosterWidget(contentScrollFrame, PRT.GetProfileDB().raidRoster)
      elseif key == "overlay" then
        PRT.AddOverlayWidget(contentScrollFrame, PRT.GetProfileDB().overlay)
      elseif key == "information" then
        PRT.AddInformationWidgets(contentScrollFrame)
      end
    end
  )
  optionsTabsGroup:AddChild(contentScrollFrame)
  container:AddChild(optionsTabsGroup)
  optionsTabsGroup:SelectTab("general")
end
