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
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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
	PRT.mainFrameContent:SetLayout("List")	
	PRT.mainFrameContent:SetFullHeight(true)
	PRT.mainFrameContent:SetAutoAdjustHeight(true)

	PRT.mainFrameContent:AddChild(PRT:EncounterTabGroup(self.db.profile.encounters))

	PRT.mainFrame:AddChild(PRT.mainFrameContent)
end	
	
function PRT:OpenPRT(input)
	PRT:Open()	
end

function PRT:TabGroupTest()
	local tabGroup = AceGUI:Create("TabGroup")
	
end	


-------------------------------------------------------------------------------
-- Events

function PRT:PLAYER_ENTERING_WORLD()
	print("PLAYER_ENTERING_WORLD")
	PRT.currentEncounter = {}
end

function PRT:ENCOUNTER_START()
	print("ENCOUNTER_START - TODO Initialize")
end

function PRT:ENCOUNTER_END()
	print("ENCOUNTER_END - TODO Initialize")
end

function PRT:PLAYER_REGEN_DISABLED()
	print("PLAYER_REGEN_DISABLED")
	PRT.currentEncounter.inFight = true
	PRT.currentEncounter.lastCheck = GetTime()	
	PRT.currentEncounter.encounter = PRT.CopyTable(self.db.profile.encounters[1])
end

PRT.ResetTimers = function()
	local timers = PRT.currentEncounter.encounter.Timers

	if timers then
		for i, timer in ipairs(timers) do
			timer.started = false
			timer.startedAt = nil
		end
	end

end

function PRT:PLAYER_REGEN_ENABLED()
	print("PLAYER_REGEN_ENABLED")
	PRT.currentEncounter.inFight = false

	PRT.ResetTimers()
	--PRT.ResetRotations()
	--PRT.ResetPercentages()
end

function PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
	local timestamp, combatEvent, _, sourceGUID, sourceName, _, _, targetGUID, targetName, _, _, eventSpellID,_,_, eventExtraSpellID = CombatLogGetCurrentEventInfo()

	if sourceName == UnitName("player") then
		print(sourceName..": "..combatEvent)
	end

	if PRT.currentEncounter.inFight then
		if PRT.currentEncounter.encounter then
			-- Check for activations 10 times a second
			if GetTime() > PRT.currentEncounter.lastCheck + 0.1 then
				PRT.currentEncounter.lastCheck = GetTime()
				local timers = PRT.currentEncounter.encounter.Timers
				local rotations = PRT.currentEncounter.encounter.Rotations
				local percentages = PRT.currentEncounter.encounter.Percentages

				-- Checking Timer activation
				if timers then
					PRT.CheckTimerStartConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
					PRT.CheckTimerStopConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
					PRT.CheckTimerTimings(timers)
				end

				-- Checking Rotation activation
				if rotations then
					--PRT.CheckSpellRotationTriggerCondition(spellRotations, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
				end

				-- Checking Percentage activation
				if percentages then
					--PRT.CheckUnitHealthTrackers(unitHealthTrackers)
				end

				-- Process Message Queue after activations
				if timers or rotations or percentages then
					--PRT.ProcessMessageQueue()
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Chat Commands

PRT:RegisterChatCommand("prt", "OpenPRT")