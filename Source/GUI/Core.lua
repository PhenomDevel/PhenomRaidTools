local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

-------------------------------------------------------------------------------
-- Local Helper

local RegisterESCHandler = function()
	_G["mainFrameName"] = PRT.mainFrame.frame
    -- Register the global variable `MyGlobalFrameName` as a "special frame"
    -- so that it is closed when the escape key is pressed.
    tinsert(UISpecialFrames, "mainFrameName")
end


-------------------------------------------------------------------------------
-- Public API

PRT.CreateMainFrame = function(profile)
	PRT.mainFrame = AceGUI:Create("Frame")
	PRT.mainFrame:SetTitle("Phenom Raid Tools")
	PRT.mainFrame:SetStatusText("Phenom Raid Tools - Encounter Configuration")
	PRT.mainFrame:SetLayout("Fill")
	PRT.mainFrame:SetCallback("OnClose",
		function(widget) 
			AceGUI:Release(widget) 
		end)
	PRT.mainFrame:SetWidth(1400)
	PRT.mainFrame:SetHeight(800)

	PRT.mainFrameContent = AceGUI:Create("ScrollFrame")
	PRT.mainFrameContent:SetLayout("Flow")	
	PRT.mainFrameContent:SetFullHeight(true)
	PRT.mainFrameContent:SetAutoAdjustHeight(true)

	local optionsHeading = PRT.Heading("optionsHeading")
	
	local testModeCheckbox = PRT.CheckBox("optionsTestMode", profile.testMode)
	testModeCheckbox:SetCallback("OnValueChanged", 
		function(widget) 
			profile.testMode = widget:GetValue() 
		end)	

	local testEncounterIDEditBox = PRT.EditBox("optionsTestEncounterID", profile.testEncounterID, true)	
	testEncounterIDEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			profile.testEncounterID = tonumber(widget:GetText()) 
		end)
	
	local debugModeCheckbox = PRT.CheckBox("optionsDebugMode", profile.debugMode)
	debugModeCheckbox:SetCallback("OnValueChanged", 
		function(widget) 
			profile.debugMode = widget:GetValue() 
		end)

	local encounterHeading = PRT.Heading("encounterHeading")

	PRT.mainFrameContent:AddChild(optionsHeading)
	PRT.mainFrameContent:AddChild(testModeCheckbox)
	PRT.mainFrameContent:AddChild(testEncounterIDEditBox)
	PRT.mainFrameContent:AddChild(debugModeCheckbox)
	PRT.mainFrameContent:AddChild(encounterHeading)
	PRT.mainFrameContent:AddChild(PRT.EncounterTabGroup(profile.encounters))

	RegisterESCHandler()

	PRT.mainFrame:AddChild(PRT.mainFrameContent)
end	