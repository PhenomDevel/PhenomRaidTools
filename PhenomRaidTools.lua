local PRT = LibStub("AceAddon-3.0"):NewAddon("PhenomRaidTools", "AceConsole-3.0", "AceEvent-3.0");

local AceGUI = LibStub("AceGUI-3.0")

local testEncounter = {
	name = "Test",
	id = 42,
	Timers = {
	},
}

local defaults = {
	profile = {
		testMode = false,
		testEncounterID = 9999,
		debugMode = false,
		showOverlay = true,
		hideOverlayAfterCombat = false,
		encounters = {						
		},
		currentEncounter = {
			inFight = false
		}
	}
}

function PRT:OnInitialize()	
	-- Initialize Database
	-- Defaults will be merged
	self.db = LibStub("AceDB-3.0"):New("PhenomRaidToolsDB", defaults, true)

	-- C_ChatInfo.SendAddonMessage("PRT_MSG", "ALL?#5&HI Vexnlock", "WHISPER", UnitName("player")) 
end

function PRT:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END")
end

function PRT:OnDisable()
end

function PRT:Open()
	if (PRT.mainFrame and not PRT.mainFrame:IsShown()) or not PRT.mainFrame then
		PRT:CreateMainFrame()
	end
end


-------------------------------------------------------------------------------
-- Main Frame

PRT.mainFrame = nil
PRT.mainFrameContent = nil

function PRT:CreateMainFrame()
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

	-- Options
	local optionsHeading = PRT.Heading("Options")

	-- testmode
	local testModeCheckbox = PRT.CheckBox("Test mode?", self.db.profile.testMode)
	testModeCheckbox:SetCallback("OnValueChanged", function(widget) self.db.profile.testMode = widget:GetValue() end)

	local testEncounterIDEditBox = PRT.EditBox("EditBox", self.db.profile.testEncounterID)	
	testEncounterIDEditBox:SetLabel("Test Encounter ID")
	testEncounterIDEditBox:SetCallback("OnTextChanged", function(widget) self.db.profile.testEncounterID = tonumber(widget:GetText()) end)

	-- debug?
	local debugModeCheckbox = PRT.CheckBox("Debug mode?", self.db.profile.debugMode)
	debugModeCheckbox:SetCallback("OnValueChanged", function(widget) self.db.profile.debugMode = widget:GetValue() end)

	local encounterHeading = PRT.Heading("Encounters")

	PRT.mainFrameContent:AddChild(optionsHeading)
	PRT.mainFrameContent:AddChild(testModeCheckbox)
	PRT.mainFrameContent:AddChild(testEncounterIDEditBox)
	PRT.mainFrameContent:AddChild(debugModeCheckbox)
	PRT.mainFrameContent:AddChild(encounterHeading)

	PRT.mainFrameContent:AddChild(PRT:EncounterTabGroup(self.db.profile.encounters))
	
	PRT.mainFrame:AddChild(PRT.mainFrameContent)
end	
	
function PRT:OpenPRT(input)
	if UnitAffectingCombat("player") then
		print("Can't open during combat")
	else
		PRT:Open()	
	end
end


-------------------------------------------------------------------------------
-- Chat Commands

PRT:RegisterChatCommand("prt", "OpenPRT")