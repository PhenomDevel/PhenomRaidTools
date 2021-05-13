local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")


-------------------------------------------------------------------------------
-- Public API

function PRT.AddOptionWidgets(container, profile)
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

      if container.backgroundTimer then
        AceTimer:CancelTimer(container.backgroundTimer)
      end

      if key ==  "general" then
        PRT.AddGeneralWidgets(container, PRT.db.profile)
      elseif key == "difficulties" then
        PRT.AddDifficultyWidgets(container, PRT.db.profile.enabledDifficulties)
      elseif key == "defaults" then
        PRT.AddDefaultsGroups(container, PRT.db.profile.triggerDefaults)
      elseif key == "raidRoster" then
        PRT.AddRaidRosterWidget(container, PRT.db.profile.raidRoster)
      elseif key == "overlay" then
        PRT.AddOverlayWidget(container, PRT.db.profile.overlay)
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
