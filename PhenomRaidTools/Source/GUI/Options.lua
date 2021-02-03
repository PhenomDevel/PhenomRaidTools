local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

function PRT.AddOptionWidgets(container, profile)
  local optionsTabs = {
    { value = "general", text = L["optionsTabGeneral"] },
    { value = "raidRoster", text = L["optionsTabRaidRoster"] , disabled = not profile.senderMode},
    { value = "customPlaceholders", text = L["optionsTabCustomPlaceholders"] , disabled = not profile.senderMode},
    { value = "difficulties", text = L["optionsTabDifficulties"] },
    { value = "overlay", text = L["optionsTabOverlays"] },
    { value = "defaults", text = L["optionsTabDefaults"] , disabled = not profile.senderMode}
  }

  local optionsTabsGroup = PRT.TabGroup(nil, optionsTabs)
  optionsTabsGroup:SetLayout("Flow")
  optionsTabsGroup:SetCallback("OnGroupSelected",
    function(container, event, key)
      container:ReleaseChildren()

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
      elseif key =="customPlaceholders" then
        PRT.AddCustomPlaceholdersWidget(container, PRT.db.profile.customPlaceholders)
      end

      if PRT.mainWindowContent.scrollFrame then
        PRT.Core.UpdateScrollFrame()
      end
    end)

  container:AddChild(optionsTabsGroup)
  optionsTabsGroup:SelectTab("general")
end
