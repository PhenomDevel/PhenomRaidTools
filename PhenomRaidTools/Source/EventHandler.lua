local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local EventHandler = {
	essentialEvents = {
		"PLAYER_REGEN_DISABLED", 
		"PLAYER_REGEN_ENABLED",
		"ENCOUNTER_START",
		"ENCOUNTER_END",
		"PLAYER_ENTERING_WORLD"
	}
}


-------------------------------------------------------------------------------
-- Local Helper

EventHandler.StartEncounter = function(event, encounterID, encounterName)
	PRT.Debug("Starting new encounter", encounterID, encounterName)
	local _, encounter = PRT.FilterEncounterTable(PRT.db.profile.encounters, encounterID)

	if encounter then
		if encounter.enabled then
			PRT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			PRT.currentEncounter = {}
			PRT.currentEncounter.inFight = true
					
			PRT.currentEncounter.encounter = PRT.CopyTable(encounter)
		else
			PRT.Debug("Found encounter but it is disabled. Skipping encounter.")
		end
	end

	if PRT.db.profile.showOverlay then
		PRT.Overlay.Show()
		AceTimer:ScheduleRepeatingTimer(PRT.Overlay.UpdateFrame, 1)
	end

	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
end

EventHandler.StopEncounter = function(event)
	PRT.Debug("Combat stopped. Resetting PRT.")

	-- Send the last event before unregistering the event
	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)	
	PRT:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	if PRT.currentEncounter then
		PRT.currentEncounter.inFight = false
	end	
	
	-- Hide overlay if necessary
	if PRT.db.profile.hideOverlayAfterCombat then
		PRT.Overlay.Hide()
	end

	-- Stop all timers
	AceTimer:CancelAllTimers()	
end


-------------------------------------------------------------------------------
-- Public API

PRT.RegisterEssentialEvents = function()
	for i, event in ipairs(EventHandler.essentialEvents) do
		PRT:RegisterEvent(event)
	end
end

PRT.UnregisterEssentialEvents = function()
	for i, event in ipairs(EventHandler.essentialEvents) do
		PRT:UnregisterEvent(event)
	end
end

function PRT:ENCOUNTER_START(event, encounterID, encounterName)	
	-- We only start a real encounter if PRT is enabled (correct dungeon/raid difficulty) and we're not in test mode
	if PRT.enabled and not self.db.profile.testMode then
		EventHandler.StartEncounter(event, encounterID, encounterName)
	end
end

function PRT:ENCOUNTER_END(event)	
	if PRT.enabled and not self.db.profile.testMode then
		EventHandler.StopEncounter(event)
	end
end

function PRT:PLAYER_REGEN_DISABLED(event)	
	if self.db.profile.testMode then
		PRT.Debug("You are currently in test mode.")

		local _, encounter = PRT.FilterEncounterTable(self.db.profile.encounters, self.db.profile.testEncounterID)

		EventHandler.StartEncounter(event, encounter.id, encounter.name)
	end
end

function PRT:PLAYER_REGEN_ENABLED(event)
	if self.db.profile.testMode then
		EventHandler.StopEncounter(event)
	end
end

function PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
	if PRT.currentEncounter then
		local timestamp, combatEvent, _, sourceGUID, sourceName, _, _, targetGUID, targetName, _, _, eventSpellID,_,_, eventExtraSpellID = CombatLogGetCurrentEventInfo()
		
		if PRT.currentEncounter.inFight then
			if PRT.currentEncounter.encounter then
				local timers = PRT.currentEncounter.encounter.Timers
				local rotations = PRT.currentEncounter.encounter.Rotations
				local healthPercentages = PRT.currentEncounter.encounter.HealthPercentages
				local powerPercentages = PRT.currentEncounter.encounter.PowerPercentages

				-- Checking Timer activation
				if timers then
					PRT.CheckTimerStartConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
					PRT.CheckTimerStopConditions(timers, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
					PRT.CheckTimerTimings(timers)
				end

				-- Checking Rotation activation
				if rotations then
					PRT.CheckRotationTriggerCondition(rotations, event, combatEvent, eventSpellID, targetGUID, targetName, sourceGUID, sourceName)
				end

				-- Checking Health Percentage activation
				if healthPercentages then
					PRT.CheckUnitHealthPercentages(healthPercentages)
				end

				-- Checking Resource Percentage activation
				if powerPercentages then
					PRT.CheckUnitPowerPercentages(powerPercentages)
				end

				-- Process Message Queue after activations
				if timers or rotations or healthPercentages or powerPercentages then
					PRT.ProcessMessageQueue()
				end
			end
		end
	end
end

function PRT:PLAYER_ENTERING_WORLD(event)
	AceTimer:ScheduleTimer(
		function()
			local name, type, _, difficulty = GetInstanceInfo()

			PRT.Debug("Zone entered.")
			
			if type == "party" then
				PRT.Debug("Player entered dungeon - checking difficulty")
				PRT.Debug("Current difficulty is", difficulty)
				
				if self.db.profile.enabledDifficulties["dungeon"][difficulty] then
					PRT.Debug("Enabling PhenomRaidTools for", name, "on difficulty", difficulty)
					PRT.enabled = true
				else
					PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
					PRT.enabled = false
				end
			elseif type == "raid" then
				PRT.Debug("Player entered raid - checking difficulty")
				PRT.Debug("Current difficulty is"..difficulty)
				
				if self.db.profile.enabledDifficulties["dungeon"][difficulty] then
					PRT.Debug("Enabling PhenomRaidTools for", name, "on difficulty", difficulty)
					PRT.enabled = true
				else
					PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
					PRT.enabled = false
				end
			elseif type == "none" then
				PRT.Debug("Player is not in a raid nor in a dungeon. PhenomRaidTools disabled.")
			end
		end,
		3
	)	
end