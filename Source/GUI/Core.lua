local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Public API

PRT.CreateMainFrame = function(profile)
	PRT.mainFrame = AceGUI:Create("Frame")
	PRT.mainFrame:SetTitle("Phenom Raid Tools")
	PRT.mainFrame:SetLayout("Fill")
	PRT.mainFrame:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
	PRT.mainFrame:SetWidth(1000)
	PRT.mainFrame:SetHeight(600)

	PRT.mainFrameContent = AceGUI:Create("ScrollFrame")
	PRT.mainFrameContent:SetLayout("Flow")	
	PRT.mainFrameContent:SetFullHeight(true)
	PRT.mainFrameContent:SetAutoAdjustHeight(true)

	-- Add options gui elements
	local optionsHeading = PRT.Heading("Options")

	-- Add testmode gui elements
	local testModeCheckbox = PRT.CheckBox("Test mode?", profile.testMode)
	testModeCheckbox:SetCallback("OnValueChanged", function(widget) profile.testMode = widget:GetValue() end)	

	local testEncounterIDEditBox = PRT.EditBox("EditBox", profile.testEncounterID)	
	testEncounterIDEditBox:SetLabel("Test Encounter ID")
	testEncounterIDEditBox:SetCallback("OnTextChanged", function(widget) profile.testEncounterID = tonumber(widget:GetText()) end)
	
	-- Add debugmode gui elements
	local debugModeCheckbox = PRT.CheckBox("Debug mode?", profile.debugMode)
	debugModeCheckbox:SetCallback("OnValueChanged", function(widget) profile.debugMode = widget:GetValue() end)
    debugModeCheckbox:SetFullWidth(true)

	local encounterHeading = PRT.Heading("Encounters")

	PRT.mainFrameContent:AddChild(optionsHeading)
	PRT.mainFrameContent:AddChild(testModeCheckbox)
	PRT.mainFrameContent:AddChild(testEncounterIDEditBox)
	PRT.mainFrameContent:AddChild(debugModeCheckbox)
	PRT.mainFrameContent:AddChild(encounterHeading)
	PRT.mainFrameContent:AddChild(PRT.EncounterTabGroup(profile.encounters))
	
	PRT.mainFrame:AddChild(PRT.mainFrameContent)
end	