local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


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
    container:AddChild(optionsGroup)
end