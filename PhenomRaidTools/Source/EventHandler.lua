local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local EventHandler = {
	essentialEvents = {
		"PLAYER_REGEN_DISABLED", 
		"PLAYER_REGEN_ENABLED",
		"ENCOUNTER_START",
		"PLAYER_ENTERING_WORLD"
	}
}


-------------------------------------------------------------------------------
-- Local Helper

EventHandler.StartReceiveMessages = function()
	if PRT.db.profile.enabled then
		if PRT.db.profile.receiverMode then
			PRT.ReceiverOverlay.Show()
			AceTimer:ScheduleRepeatingTimer(PRT.ReceiverOverlay.UpdateFrame, 0.01)
		else
			PRT.Debug("You are not in receiver mode. We won't track messages.")
		end
	else
		PRT.Debug("PRT is disabled. We do not start to track messages.")
	end
end

EventHandler.StartEncounter = function(event, encounterID, encounterName)
	if PRT.db.profile.enabled then
		if PRT.db.profile.senderMode then
			PRT.Debug("Starting new encounter", PRT.HighlightString(encounterName),"(", PRT.HighlightString(encounterID), ")" , "|r")
			local _, encounter = PRT.FilterEncounterTable(PRT.db.profile.encounters, encounterID)

			PRT.EnsureEncounterTrigger(encounter)

			if encounter then			
				if encounter.enabled then
					PRT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
					PRT.currentEncounter = {}
					PRT.currentEncounter.inFight = true
							
					PRT.currentEncounter.encounter = PRT.CopyTable(encounter)				
					PRT.currentEncounter.encounter.startedAt = GetTime()

					if PRT.db.profile.overlay.sender.enabled then
						PRT.SenderOverlay.Show()
						PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, false)
						AceTimer:ScheduleRepeatingTimer(PRT.SenderOverlay.UpdateFrame, 1, PRT.currentEncounter.encounter, PRT.db.profile.overlay.sender)
					end								
				else
					PRT.Warn("Found encounter but it is disabled. Skipping encounter.")
				end				
			end
		end

		PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
	else
		PRT.Debug("PRT is disabled. Not starting encounter.")
	end
end

EventHandler.StopEncounter = function(event)	
	PRT.Debug("Combat stopped.")
	if PRT.db.profile.senderMode then
		-- Send the last event before unregistering the event
		PRT:COMBAT_LOG_EVENT_UNFILTERED(event)	
		PRT:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

		if PRT.currentEncounter then
			PRT.currentEncounter = {}
		end	
		
		-- Hide overlay if necessary
		if PRT.db.profile.overlay.sender.hideAfterCombat then
			PRT.SenderOverlay.Hide()
		end
	end

	if PRT.db.profile.overlay.sender.enabled then
		PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, true)
	end

	-- Clear ReceiverFrame
	if PRT.db.profile.receiverMode then
		PRT.ReceiverOverlay.ClearMessageStack()
		PRT.ReceiverOverlay.UpdateFrame()
		PRT.ReceiverOverlay.Hide()
	end

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

function PRT:PLAYER_REGEN_DISABLED(event)	
	-- Initialize overlays
	PRT.SenderOverlay.Initialize(PRT.db.profile.overlay.sender)
	PRT.ReceiverOverlay.Initialize(PRT.db.profile.overlay.receiver)

	if self.db.profile.testMode then
		PRT.Debug("You are currently in test mode.")

		local _, encounter = PRT.FilterEncounterTable(self.db.profile.encounters, self.db.profile.testEncounterID)

		if encounter then
			if encounter.enabled then
				EventHandler.StartEncounter(event, encounter.id, encounter.name)
			else
				PRT.Warn("The selected encounter is disabled. Please enabled it before testing.")
			end
		else
			PRT.Warn("You are in test mode and have no encounter selected.")
		end
	end	
	
	-- Always try to start receiver
	EventHandler.StartReceiveMessages()
end

function PRT:PLAYER_REGEN_ENABLED(event)
	EventHandler.StopEncounter(event)
end

function PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
	if PRT.currentEncounter and PRT.db.profile.senderMode then
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
	PRT.Debug("Zone entered.")
	PRT.Debug("Will check zone/difficulty in 10 seconds to determine if addon should be loaded.")

	AceTimer:ScheduleTimer(
		function()
			local name, type, _, difficulty = GetInstanceInfo()						
			if type == "party" then
				PRT.Debug("Player entered dungeon - checking difficulty")
				PRT.Debug("Current difficulty is", PRT.HighlightString(difficulty))
				
				if self.db.profile.enabledDifficulties["dungeon"][difficulty] then
					PRT.Debug("Enabling PhenomRaidTools for", PRT.HighlightString(name), "on difficulty", PRT.HighlightString(difficulty))
					PRT.enabled = true
				else
					PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
					PRT.enabled = false
				end
			elseif type == "raid" then
				PRT.Debug("Player entered raid - checking difficulty")
				PRT.Debug("Current difficulty is", PRT.HighlightString(difficulty))
				
				if self.db.profile.enabledDifficulties["raid"][difficulty] then
					PRT.Debug("Enabling PhenomRaidTools for", PRT.HighlightString(name), "on difficulty", PRT.HighlightString(difficulty))
					PRT.enabled = true
				else
					PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
					PRT.enabled = false
				end
			elseif type == "none" then
				PRT.Debug("Player is not in a raid nor in a dungeon. PhenomRaidTools disabled.")
			end
		end,
		10
	)
end