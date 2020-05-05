local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

-------------------------------------------------------------------------------
-- Local Helper

local RegisterESCHandler = function(name, container)
	_G[name] = container.frame
    -- Register the global variable `MyGlobalFrameName` as a "special frame"
    -- so that it is closed when the escape key is pressed.
    tinsert(UISpecialFrames, name)
end


-------------------------------------------------------------------------------
-- Public API

PRT.CreateMainFrameContent = function(container, profile)
	PRT.mainFrameContent = AceGUI:Create("ScrollFrame")
	PRT.mainFrameContent:SetLayout("Flow")	
	PRT.mainFrameContent:SetFullHeight(true)
	PRT.mainFrameContent:SetAutoAdjustHeight(true)

	local optionsGroup = PRT.InlineGroup("optionsHeading")
	
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

	local encounterGroup = PRT.InlineGroup("encounterHeading")

	local importButton = PRT.Button("encounterImport")
	importButton:SetCallback("OnClick", 
		function(widget) 
			PRT.CreateImportEncounterFrame(profile.encounters)
		end)

	optionsGroup:AddChild(testModeCheckbox)
	optionsGroup:AddChild(testEncounterIDEditBox)
	optionsGroup:AddChild(debugModeCheckbox)

	encounterGroup:AddChild(importButton)
	encounterGroup:AddChild(PRT.EncounterTabGroup(profile.encounters))

	PRT.mainFrameContent:AddChild(optionsGroup)
	PRT.mainFrameContent:AddChild(encounterGroup)

	return PRT.mainFrameContent
end

PRT.CreateMainFrame = function(profile)
	PRT.mainFrame = AceGUI:Create("Window")
	PRT.mainFrame:SetTitle("PhenomRaidTools")
	PRT.mainFrame:SetStatusText("PhenomRaidTools - Raid smarter not harder")
	PRT.mainFrame:SetLayout("Fill")
	PRT.mainFrame:SetCallback("OnClose",
		function(widget) 
			AceGUI:Release(widget) 
		end)
	PRT.mainFrame:SetWidth(1100)
	PRT.mainFrame:SetHeight(800)
	PRT.mainFrame.frame:SetResizable(true)
	PRT.mainFrame.frame:SetMinResize(1100, 800)
	PRT.mainFrame.frame:SetMaxResize(1100, 800)
	RegisterESCHandler("mainFrame", PRT.mainFrame)

	PRT.mainFrame:AddChild(PRT.CreateMainFrameContent(PRT.mainFrame, profile))
end	