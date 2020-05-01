local PRT = LibStub("AceAddon-3.0"):NewAddon("PhenomRaidTools", "AceConsole-3.0", "AceEvent-3.0");

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Ace standard functions

local defaults = {
	profile = {
		testMode = false,
		testEncounterID = 9999,
		testEncounterName = "Example Encounter",
		debugMode = false,
		showOverlay = true,
		hideOverlayAfterCombat = false,
		encounters = {						
		},
		currentEncounter = {
			inFight = false
		},
		colors = {
			general = "FFB5FFEB",
			timers = "FFFFF569",
			rotations = "FF9482C9",
			percentages = "FFABD473",

		}
	}
}

function PRT:OnInitialize()	
	table.insert(defaults.profile.encounters, PRT.ExampleEncounter())
	self.db = LibStub("AceDB-3.0"):New("PhenomRaidToolsDB", defaults, true)
	
	-- We hold the main frame within the global addon variable 
	-- because we sometimes have to do a re-layout of the complete content
	PRT.mainFrame = nil
	PRT.mainFrameContent = nil
	-- PRT.CreateOverlay()
end

function PRT:OnEnable()
	-- NOTE:
	-- Register all events we need to start or stop the condition checks
	PRT.RegisterEssentialEvents()
end

function PRT:OnDisable()
	PRT.UnregisterEssentialEvents()
end

function PRT:Open()
	if (PRT.mainFrame and not PRT.mainFrame:IsShown()) or not PRT.mainFrame then
		PRT.CreateMainFrame(self.db.profile)
	end
end

function PRT:OpenPRT(input)
	if UnitAffectingCombat("player") then
		PRT:Print("Can't open during combat")
	else
		PRT:Open()	
	end
end


-------------------------------------------------------------------------------
-- Chat Commands

PRT:RegisterChatCommand("prt", "OpenPRT")