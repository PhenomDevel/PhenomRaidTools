local PRT = LibStub("AceAddon-3.0"):NewAddon("PhenomRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");

local AceGUI = LibStub("AceGUI-3.0")

local PhenomRaidToolsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("PhenomRaidTools", {
	type = "data source",
	text = "PhenomRaidTools",
	icon = "615103",
	OnClick = function() 
		PRT:OpenPRT()
	end,

	OnEnter = function()
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:AddLine("PhenomRaidTools") 
		GameTooltip:Show() 
	end,

	OnLeave = function()
		GameTooltip:Hide()
	end})

local LibDBIcon = LibStub("LibDBIcon-1.0")

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

		overlay = {
			bottom = nil,
			left = nil
		},

		minimap = {
			hide = false
		},

		enabledDifficulties = {
			dungeon = {
				Normal = true,
				Heroic = true,
				Mythic = true
			},
			raid = {
				Normal = true,
				Heroic = true,
				Mythic = true
			}
		},

		triggerDefaults = {
			messageDefaults = {
				defaultWithSound = true
			},
			rotationDefaults = {
				defaultShouldRestart = true,
				defaultIgnoreAfterActivation = true,
				defaultIgnoreDuration = 10
			},
			percentageDefaults = {
				defaultIgnoreAfterActivation = true,
				defaultIgnoreDuration = 5
			},
			conditionDefaults = {
				additionalEvents = {}
			}
		}, 

		encounters = {		
			-- encounters go in here				
		},
		currentEncounter = {
			inFight = false
		},
		colors = {
			general = "FFB5FFEB",
			timers = "FFFFF569",
			rotations = "FF9482C9",
			percentages = "FFABD473",
			error = "FFFF0000"
		}
	}
}

function PRT:OnInitialize()	
	table.insert(defaults.profile.encounters, PRT.ExampleEncounter())
	self.db = LibStub("AceDB-3.0"):New("PhenomRaidToolsDB", defaults, true)
	
	LibDBIcon:Register("PhenomRaidTools", PhenomRaidToolsLDB, self.db.profile.minimap)

	-- We hold the main frame within the global addon variable 
	-- because we sometimes have to do a re-layout of the complete content
	PRT.mainFrame = nil
	PRT.mainFrameContent = nil
end

function PRT:OnEnable()
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
		-- <PRT.Overlay.Open()
	end
end


-------------------------------------------------------------------------------
-- Chat Commands

PRT:RegisterChatCommand("prt", "OpenPRT")