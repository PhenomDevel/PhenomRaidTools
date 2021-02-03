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
    function(widget, _, key)
      widget:ReleaseChildren()

      if key ==  "general" then
        PRT.AddGeneralWidgets(widget, PRT.db.profile)
      elseif key == "difficulties" then
        PRT.AddDifficultyWidgets(widget, PRT.db.profile.enabledDifficulties)
      elseif key == "defaults" then
        PRT.AddDefaultsGroups(widget, PRT.db.profile.triggerDefaults)
      elseif key == "raidRoster" then
        PRT.AddRaidRosterWidget(widget, PRT.db.profile.raidRoster)
      elseif key == "overlay" then
        PRT.AddOverlayWidget(widget, PRT.db.profile.overlay)
      elseif key =="customPlaceholders" then
        PRT.AddCustomPlaceholdersWidget(widget, PRT.db.profile.customPlaceholders)
      end

      if PRT.mainWindowContent.scrollFrame then
        PRT.Core.UpdateScrollFrame()
      end
    end)

  container:AddChild(optionsTabsGroup)
  optionsTabsGroup:SelectTab("general")
end
