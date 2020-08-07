local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

PRT.AddOptionWidgets = function(container, profile)
    local optionsTabs = {
        { value = "general", text = L["optionsTabGeneral"] },
        { value = "difficulties", text = L["optionsTabDifficulties"] },
        { value = "defaults", text = L["optionsTabDefaults"] , disabled = not profile.senderMode},
        { value = "raidRoster", text = L["optionsTabRaidRoster"] , disabled = not profile.senderMode},
        { value = "customPlaceholders", text = L["optionsTabCustomPlaceholders"] , disabled = not profile.senderMode},
        { value = "overlay", text = L["optionsTabOverlays"] }
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
                -- Merge customNames for backwards compatibility
                PRT.AddCustomPlaceholdersWidget(container, table.mergemany(PRT.db.profile.customPlaceholders, PRT.db.profile.customNames))
            end

            if PRT.mainWindowContent.scrollFrame then
                PRT.mainWindowContent.scrollFrame:DoLayout()
            end
        end)

    container:AddChild(optionsTabsGroup) 
    optionsTabsGroup:SelectTab("general")
end