local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Options = {}

local difficulties = {"Normal", "Heroic", "Mythic"}

-------------------------------------------------------------------------------
-- Local Helper

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
                widget:SetCallback("OnEnterPressed", function(widget) t[k] = tonumber(widget:GetText()) end)
            elseif type(v) == "table" then
                print("yay")
                widget = PRT.EditBox(k, strjoin(", ", unpack(v)))
                widget:SetCallback("OnEnterPressed", function(widget) t[k] = { strsplit(",", widget:GetText()) } end)
            end
    
            if widget then
                container:AddChild(widget)
            end
        end
    end
end

Options.AddDefaultsGroups = function(container)
    local defaultsGroup = PRT.InlineGroup("triggerDefaults")

    if PRT.db.profile.triggerDefaults then
        for k, v in pairs(PRT.db.profile.triggerDefaults) do
            local groupWidget = PRT.InlineGroup(k)
            Options.AddDefaultsWidgets(groupWidget, v)
            defaultsGroup:AddChild(groupWidget)
        end

        container:AddChild(defaultsGroup)
    end
end

Options.AddDifficultyWidgets = function(container)
    local difficultiesGroup = PRT.InlineGroup("optionsEnabledDifficulties")
    difficultiesGroup:SetLayout("Flow")
    local dungeonHeading = PRT.Heading("dungeonHeading")
    difficultiesGroup:AddChild(dungeonHeading)
    
    for i, difficulty in ipairs(difficulties) do
        local widget = PRT.CheckBox("dungeonDifficulty"..difficulty, PRT.db.profile.enabledDifficulties["dungeon"][difficulty])
        widget:SetCallback("OnValueChanged", function(widget, event, key) PRT.db.profile.enabledDifficulties["dungeon"][difficulty] = widget:GetValue() end)
        widget:SetWidth(100)                
        difficultiesGroup:AddChild(widget)
    end

    local raidHeading = PRT.Heading("raidHeading")
    difficultiesGroup:AddChild(raidHeading)
    
    for i, difficulty in ipairs(difficulties) do
        local widget = PRT.CheckBox("raidDifficulty"..difficulty, PRT.db.profile.enabledDifficulties["raid"][difficulty])
        widget:SetCallback("OnValueChanged", function(widget, event, key) PRT.db.profile.enabledDifficulties["raid"][difficulty] = widget:GetValue() end)
        widget:SetWidth(100)
        difficultiesGroup:AddChild(widget)
    end

    container:AddChild(difficultiesGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddOptionWidgets = function(container, profile)
    local optionsGroup = PRT.InlineGroup("optionsHeading")   
    optionsGroup:SetLayout("Flow")

    local debugModeCheckbox = PRT.CheckBox("optionsDebugMode", profile.debugMode)
	debugModeCheckbox:SetCallback("OnValueChanged", function(widget) profile.debugMode = widget:GetValue() end)

    local testModeCheckbox = PRT.CheckBox("optionsTestMode", profile.testMode)
	testModeCheckbox:SetCallback("OnValueChanged", function(widget)	profile.testMode = widget:GetValue() end)	

    local textEncounterIDDropdown = PRT.Dropdown("optionsTestEncounterID", profile.encounters, profile.testEncounterID)        
    textEncounterIDDropdown:SetCallback("OnValueChanged", function(widget) profile.testEncounterID = tonumber(widget:GetValue()) end)        

    optionsGroup:AddChild(debugModeCheckbox)
    optionsGroup:AddChild(testModeCheckbox)    
    optionsGroup:AddChild(textEncounterIDDropdown)
    Options.AddDifficultyWidgets(optionsGroup)
    Options.AddDefaultsGroups(optionsGroup)
    container:AddChild(optionsGroup)
end