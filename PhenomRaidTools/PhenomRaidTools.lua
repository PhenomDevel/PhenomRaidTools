local PRT = LibStub("AceAddon-3.0"):NewAddon("PhenomRaidTools", "AceConsole-3.0", "AceEvent-3.0");

local AceGUI = LibStub("AceGUI-3.0")
local AceComm = LibStub("AceComm-3.0")

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

local defaults =  {
	profile = {
		enabled = true,
		addonMessagePrefix = "PRT_MSG",
		testMode = false,
		testEncounterID = 9999,
		testEncounterName = "Example Encounter",
		debugMode = false,
		showOverlay = false,
		hideOverlayAfterCombat = false,
		weakAuraMode = false,

		runMode = "receiver",
		senderMode = false,
		receiverMode = true,

		overlay = {
			receiver = {
				locked = true,
				top = 450,
				left = 615,
				fontSize = 14,
				fontColor = {
					hex = "FFFFFF",
					r = 0,
					g = 0,
					b = 0,
					a = 0
				},
				enableSound = true,
				backdropColor = {
					r = 0,
					g = 0,
					b = 0,
					a = 0
				}
			},

			sender = {
				top = 50,
				left = 615,
				fontSize = 14,
				backdropColor = {
					r = 0,
					g = 0,
					b = 0,
					a = 0.7
				},
				enabled = true,
				hideAfterCombat = false
			}
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
				defaultCheckAgain = true,
				defaultCheckAgainAfter = 5
			},
			conditionDefaults = {
				additionalEvents = {}
			}
		}, 

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
			error = "FFFF0000",
			highlight = "FF69CCF0",
			classes = {
				[0] = nil,
				[1] = "C79C6E",
				[2] = "F58CBA",
				[3] = "ABD473",
				[4] = "FFF569",
				[5] = "FFFFFF",
				[6] = "C41F3B",
				[7] = "0070DE",
				[8] = "69CCF0",
				[9] = "9482C9",
				[10] = "00FF96",
				[11] = "FF7D0A",
				[12] = "A330C9",
			}
		},

		raidRoster = {
			tank1 = "Tank1",
			heal1 = "Heal1",
			dd1 = "Damager1"
		}
	}
}

function PRT:OnInitialize()		
	self.db = LibStub("AceDB-3.0"):New("PhenomRaidToolsDB", defaults, true)
	LibDBIcon:Register("PhenomRaidTools", PhenomRaidToolsLDB, self.db.profile.minimap)

	local encounterIdx, encounter = PRT.FilterEncounterTable(self.db.profile.encounters, 9999)

	if not encounterIdx and table.empty(self.db.profile.encounters) then
		table.insert(self.db.profile.encounters, PRT.ExampleEncounter())
	end	

	-- We hold the main frame within the global addon variable 
	-- because we sometimes have to do a re-layout of the complete content
	PRT.mainWindow = nil
	PRT.mainWindowContent = nil
end

function PRT:OnEnable()
	PRT.RegisterEssentialEvents()

	-- AceComm:RegisterComm(PRT.db.profile.addonMessagePrefix, PRT.OnCommReceive)
	-- AceComm:SendCommMessage(PRT.db.profile.addonMessagePrefix, PRT.TableToString({a = 5}), "WHISPER", UnitName("player"))
	C_ChatInfo.RegisterAddonMessagePrefix(PRT.db.profile.addonMessagePrefix)
end

function PRT:OnDisable()
	PRT.UnregisterEssentialEvents()
end

function PRT:Open()
	if (PRT.mainWindow and not PRT.mainWindow:IsShown()) or not PRT.mainWindow then
		PRT.SenderOverlay.Initialize(PRT.db.profile.overlay.sender)
		PRT.ReceiverOverlay.Initialize(PRT.db.profile.overlay.receiver)
		PRT.CreateMainWindow(self.db.profile)		
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