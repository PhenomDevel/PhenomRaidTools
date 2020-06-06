local PRT = LibStub("AceAddon-3.0"):NewAddon("PhenomRaidTools", "AceConsole-3.0", "AceEvent-3.0");

local AceGUI = LibStub("AceGUI-3.0")
local AceComm = LibStub("AceComm-3.0")
local AceTimer = LibStub("AceTimer-3.0")

local PhenomRaidToolsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("PhenomRaidTools", {
	type = "data source",
	text = "PhenomRaidTools",
	icon = "Interface\\AddOns\\PhenomRaidTools\\Media\\Icons\\PRT.blp",
	OnClick = function() 
		PRT:Open()
	end,

	OnEnter = function()
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:AddLine("|cFF69CCF0PhenomRaidTools|r") 
		GameTooltip:AddLine("Left click to open config") 
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
		myName = UnitName("player"),
		version = "@project-version@", --"1.3.14.0-BETA", 
		receiveMessagesFrom = "",
		enabled = true,
		testMode = false,
		testEncounterID = 9999,
		testEncounterName = "Example Encounter",
		debugMode = false,
		showOverlay = false,
		hideOverlayAfterCombat = true,
		weakAuraMode = false,

		runMode = "receiver",
		senderMode = false,
		receiverMode = true,

		overlay = {
			receiver = {
				locked = true,
				top = 450,
				left = 615,
				fontSize = 32,
				fontColor = {
					hex = "FFFFFF",
					r = 0,
					g = 0,
					b = 0,
					a = 1
				},
				enableSound = true,
				backdropColor = {
					r = 0,
					g = 0,
					b = 0,
					a = 0
				},
				soundFile = "Interface\\AddOns\\PhenomRaidTools\\Media\\Sounds\\ReceiveMessage.ogg",
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
				defaultIgnoreAfterActivation = false,
				defaultIgnoreDuration = 10
			},
			percentageDefaults = {
				defaultCheckAgain = false,
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
			timers = "FF1aBB00",
			rotations = "FFcc1100",
			percentages = "FFABD473",
			error = "FFff6363",
			debug = "FFdcabff",
			info = "FF6bfdff", 
			warn = "FFffc526",
			highlight = "FF69CCF0",
			disabled = "FFff1100",
			enabled = "FF008a25",
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
		},

		addonPrefixes = { 
			weakAuraMessage = "PRT_MSG",
			addonMessage = "PRT_ADDON_MSG",
			versionRequest = "PRT_VERSION_REQ",
			versionResponse = "PRT_VERSION_RESP"
		},

		versionCheck = {

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

	AceComm:RegisterComm(self.db.profile.addonPrefixes.addonMessage, self.OnAddonMessage)
	AceComm:RegisterComm(self.db.profile.addonPrefixes.versionRequest, self.OnVersionRequest)
	AceComm:RegisterComm(self.db.profile.addonPrefixes.versionResponse, self.OnVersionResponse)
	C_ChatInfo.RegisterAddonMessagePrefix(PRT.db.profile.addonPrefixes.weakAuraMessage)
end

function PRT:OnDisable()
	PRT.UnregisterEssentialEvents()
end

function PRT:Open()
	if UnitAffectingCombat("player") then
		PRT.Info("Can't open during combat")
	else
		if (PRT.mainWindow and not PRT.mainWindow:IsShown()) or not PRT.mainWindow then
			PRT.SenderOverlay.Initialize(PRT.db.profile.overlay.sender)
			PRT.ReceiverOverlay.Initialize(PRT.db.profile.overlay.receiver)
			PRT.CreateMainWindow(self.db.profile)		
		end	
	end	
end

function PRT:PrintHelp()
	PRT.Info("You can use following commands:")
	PRT.Info("/prt - Will open the PRT config")
	PRT.Info("/prt versions - Will check PRT versions for each member of your group")
end

function PRT:PrintPartyOrRaidVersions()	
	local myVersion = string.gsub(PRT.db.profile.version, "[^%d]+", "")
	local myVersionN = tonumber(myVersion)

	for player, version in pairs(PRT.db.profile.versionCheck) do				
		local coloredName = PRT.ClassColoredName(player)

		if version == "" or version == nil then
			PRT.Info(coloredName, ":", PRT.ColoredString("no response", PRT.db.profile.colors.disabled))
		else
			local parsedVersion = string.gsub(version, "[^%d]+", "")
			local parsedVersionN = tonumber(parsedVersion)

			if parsedVersionN and myVersionN then
				if parsedVersionN >= myVersionN then
					PRT.Info(coloredName, ":", PRT.ColoredString(version, PRT.db.profile.colors.highlight))			
				elseif parsedVersionN < myVersionN then
					PRT.Info(coloredName, ":", PRT.ColoredString(version, PRT.db.profile.colors.disabled))
				end
			end
		end
	end
end

function PRT:ExecuteChatCommand(input)
	if input == "" or input == nil then
		PRT:Open()
	elseif input == "help" then
		PRT.PrintHelp()
	elseif input == "version" or input == "versions" then
		local request = {
			type = "request",
			requestor = UnitName("player")
		}

		if PRT.PlayerInParty() then
			AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.versionRequest, PRT.TableToString(request), "RAID")		
			PRT.Info("Started version check")
			PRT.Info("Print results in 5 seconds")

			self.db.profile.versionCheck = {}
			local playerNames = PRT.PartyNames()
			for i, playerName in ipairs(playerNames) do
				self.db.profile.versionCheck[playerName] = ""
			end

			AceTimer:ScheduleTimer(PRT.PrintPartyOrRaidVersions, 5)
		else
			PRT.Info("You are currently running version", PRT.ColoredString(self.db.profile.version, self.db.profile.colors.highlight))
		end
	else		
		PRT.PrintHelp()
	end
end

function PRT:VersionCheck(input)
	print("Version Check")
end


-------------------------------------------------------------------------------
-- Chat Commands

PRT:RegisterChatCommand("prt", "ExecuteChatCommand")