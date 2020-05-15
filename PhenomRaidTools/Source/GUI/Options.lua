local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Options = {}

local difficulties = {"Normal", "Heroic", "Mythic"}


-------------------------------------------------------------------------------
-- Local Helper

Options.AddRaidRosterWidget = function(container)
    local explanationLabel = PRT.Label("optionsRaidRosterExplanation")
    explanationLabel:SetRelativeWidth(1)

    local tankGroup = PRT.InlineGroup("Tanks")
    tankGroup:SetLayout("Flow")

    for i=1,3 do 
        local id = "tank"..i
        local value = PRT.db.profile.raidRoster[id]
        local tankEditBox = PRT.EditBox(id, value)
        tankEditBox:SetCallback("OnEnterPressed", 
            function(widget) 
                local text = widget:GetText()
                if not text == "" then
                    PRT.db.profile.raidRoster[id] = widget:GetText() 
                else
                    PRT.db.profile.raidRoster[id] = nil
                end
                widget:ClearFocus()
            end)
        tankGroup:AddChild(tankEditBox)
    end 

    local healGroup = PRT.InlineGroup("Healer")
    healGroup:SetLayout("Flow")

    for i=1,6 do 
        local id = "heal"..i
        local value = PRT.db.profile.raidRoster[id]
        local healEditBox = PRT.EditBox(id, value)
        healEditBox:SetCallback("OnEnterPressed", function(widget) 
            local text = widget:GetText()
            if not text == "" then
                PRT.db.profile.raidRoster[id] = widget:GetText() 
            else
                PRT.db.profile.raidRoster[id] = nil
            end
            widget:ClearFocus()
        end)
        
        healGroup:AddChild(healEditBox)
    end 

    local ddGroup = PRT.InlineGroup("Damage Dealer")
    ddGroup:SetLayout("Flow")

    for i=1,21 do 
        local id = "dd"..i
        local value = PRT.db.profile.raidRoster[id]
        local healEditBox = PRT.EditBox(id, value)
        healEditBox:SetCallback("OnEnterPressed", function(widget) 
            local text = widget:GetText()
            if not text == "" then
                PRT.db.profile.raidRoster[id] = widget:GetText() 
            else
                PRT.db.profile.raidRoster[id] = nil
            end
            widget:ClearFocus()
        end)
        ddGroup:AddChild(healEditBox)
    end 

    container:AddChild(explanationLabel)
    container:AddChild(tankGroup)
    container:AddChild(healGroup)
    container:AddChild(ddGroup)
end

Options.AddDefaultsWidgets = function(container, t)
    if t then
        for k, v in pairs(t) do
            local widget = nil

            if type(v) == "boolean" then
                widget = PRT.CheckBox(k, v)
                widget:SetCallback("OnValueChanged", function(widget) t[k] = widget:GetValue() end)
            elseif type(v) == "string" then
                widget = PRT.EditBox(k, v)
                widget:SetCallback("OnEnterPressed", function(widget) t[k] = widget:GetText() end)
            elseif type(v) == "number" then
                widget = PRT.EditBox(k, v)
                widget:SetWidth(100)
                widget:SetCallback("OnEnterPressed", function(widget) t[k] = tonumber(widget:GetText()) end)
            elseif type(v) == "table" then
                widget = PRT.EditBox(k, strjoin(", ", unpack(v)), true)
                widget:SetWidth(300)
                widget:SetCallback("OnEnterPressed", 
                    function(widget) 
                        if widget:GetText() == "" then
                            t[k] = {}
                        else
                            t[k] = { strsplit(",", widget:GetText()) }                         
                        end
                    end)
            end
    
            if widget then
                container:AddChild(widget)
            end
        end
    end
end

Options.AddDefaultsGroups = function(container)
    local explanationLabel = PRT.Label("optionsDefaultsExplanation")
    explanationLabel:SetRelativeWidth(1)
    container:AddChild(explanationLabel)
    
    if PRT.db.profile.triggerDefaults then
        for k, v in pairs(PRT.db.profile.triggerDefaults) do
            local groupWidget = PRT.InlineGroup(k)
            groupWidget:SetLayout("Flow")
            Options.AddDefaultsWidgets(groupWidget, v)
            container:AddChild(groupWidget)
        end
    end
    
end

Options.AddDifficultyWidgets = function(container)
    local explanationLabel = PRT.Label("optionsDifficultyExplanation")
    explanationLabel:SetRelativeWidth(1)

    local dungeonGroup = PRT.InlineGroup("dungeonHeading")
    dungeonGroup:SetLayout("Flow")
    
    for i, difficulty in ipairs(difficulties) do
        local widget = PRT.CheckBox("dungeonDifficulty"..difficulty, PRT.db.profile.enabledDifficulties["dungeon"][difficulty])
        widget:SetCallback("OnValueChanged", function(widget, event, key) PRT.db.profile.enabledDifficulties["dungeon"][difficulty] = widget:GetValue() end)
        widget:SetWidth(100)                
        dungeonGroup:AddChild(widget)
    end

    local raidGroup = PRT.InlineGroup("raidHeading")
    raidGroup:SetLayout("Flow")

    for i, difficulty in ipairs(difficulties) do
        local widget = PRT.CheckBox("raidDifficulty"..difficulty, PRT.db.profile.enabledDifficulties["raid"][difficulty])
        widget:SetCallback("OnValueChanged", function(widget, event, key) PRT.db.profile.enabledDifficulties["raid"][difficulty] = widget:GetValue() end)
        widget:SetWidth(100)
        raidGroup:AddChild(widget)
    end

    container:AddChild(explanationLabel)
    container:AddChild(dungeonGroup)
    container:AddChild(raidGroup)
end

Options.AddVariousWidgets = function(container)
    local debugModeCheckbox = PRT.CheckBox("optionsDebugMode", PRT.db.profile.debugMode, true)
	debugModeCheckbox:SetCallback("OnValueChanged", function(widget) PRT.db.profile.debugMode = widget:GetValue() end)

    local testModeCheckbox = PRT.CheckBox("optionsTestMode", PRT.db.profile.testMode)
	testModeCheckbox:SetCallback("OnValueChanged", function(widget)	PRT.db.profile.testMode = widget:GetValue() end)	

    local textEncounterIDDropdown = PRT.Dropdown("optionsTestEncounterID", PRT.db.profile.encounters, PRT.db.profile.testEncounterID)        
    textEncounterIDDropdown:SetCallback("OnValueChanged", function(widget) PRT.db.profile.testEncounterID = tonumber(widget:GetValue()) end)    
    
    local showOverlayCheckbox = PRT.CheckBox("optionsShowOverlay", PRT.db.profile.showOverlay)
    showOverlayCheckbox:SetRelativeWidth(1)
    showOverlayCheckbox:SetCallback("OnValueChanged", 
        function(widget) 
            local value = widget:GetValue() 
            PRT.db.profile.showOverlay = value
            if value then
                PRT.Overlay.Initialize()
            else
                PRT.Overlay.Hide()
            end
        end)
    
    local hideOverlayAfterCombatCheckbox = PRT.CheckBox("optionsHideOverlayAfterCombat", PRT.db.profile.hideOverlayAfterCombat)
    hideOverlayAfterCombatCheckbox:SetRelativeWidth(1)
    hideOverlayAfterCombatCheckbox:SetCallback("OnValueChanged", function(widget) PRT.db.profile.hideOverlayAfterCombat = widget:GetValue() end)
    
    container:AddChild(debugModeCheckbox)
    container:AddChild(testModeCheckbox)    
    container:AddChild(textEncounterIDDropdown)
    container:AddChild(showOverlayCheckbox) 
    container:AddChild(hideOverlayAfterCombatCheckbox) 
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddOptionWidgets = function(container, profile)
    local optionsTabs = {
        { value = "various", text = "Various Settings" },
        { value = "difficulties", text = "Difficulty Settings" },
        { value = "defaults", text = "Trigger Defaults" },
        { value = "raidRoster", text = "Raid Roster" }
    }

    local optionsTabsGroup = PRT.TabGroup(nil, optionsTabs)
    optionsTabsGroup:SetLayout("Flow")
    optionsTabsGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key)             
            widget:ReleaseChildren()
                         
            if key ==  "various" then
                Options.AddVariousWidgets(widget)
            elseif key == "difficulties" then
                Options.AddDifficultyWidgets(widget)
            elseif key == "defaults" then
                Options.AddDefaultsGroups(widget) 
            elseif key == "raidRoster" then
                Options.AddRaidRosterWidget(widget) 
            end

            PRT.mainFrameContent.scrollFrame:DoLayout()
        end)

    container:AddChild(optionsTabsGroup) 
    optionsTabsGroup:SelectTab("various")
end