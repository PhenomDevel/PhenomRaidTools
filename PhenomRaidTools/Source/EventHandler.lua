local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local EventHandler = {
	essentialEvents = {
		"PLAYER_REGEN_DISABLED", 
		"PLAYER_REGEN_ENABLED",
		"ENCOUNTER_START",
		"ENCOUNTER_END",
		"PLAYER_ENTERING_WORLD",
		"CHAT_MSG_ADDON"
	}
}


-------------------------------------------------------------------------------
-- Local Helper

EventHandler.StartEncounter = function(event, encounterID, encounterName)
	if PRT.db.profile.enabled then
		PRT.SenderOverlay.Initialize(PRT.db.profile.overlay.sender)
		PRT.ReceiverOverlay.Initialize(PRT.db.profile.overlay.receiver)

		if PRT.db.profile.senderMode then
			PRT.Debug("Starting new encounter|cFF69CCF0", encounterID, encounterName, "|r")
			local _, encounter = PRT.FilterEncounterTable(PRT.db.profile.encounters, encounterID)

			-- Ensure that encounter has all trigger tables!
			PRT.EnsureEncounterTrigger(encounter)
			if encounter then			
				if encounter.enabled then
					PRT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
					PRT.currentEncounter = {}
					PRT.currentEncounter.inFight = true
							
					PRT.currentEncounter.encounter = PRT.CopyTable(encounter)				
					PRT.currentEncounter.encounter.startedAt = GetTime()

				else
					PRT.Debug("Found encounter but it is disabled. Skipping encounter.")
				end

				if PRT.db.profile.overlay.sender.enabled then
					PRT.SenderOverlay.Show()
					PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, false)
					AceTimer:ScheduleRepeatingTimer(PRT.SenderOverlay.UpdateFrame, 1, PRT.currentEncounter.encounter)
				end
		
				if PRT.db.profile.receiverMode then
					PRT.ReceiverOverlay.Show()
					AceTimer:ScheduleRepeatingTimer(PRT.ReceiverOverlay.UpdateFrame, 0.01)
				end
			end



			PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
		end
	else
		PRT.Debug("PRT is disabled. Not starting encounter.")
	end
end

EventHandler.StopEncounter = function(event)
	if PRT.db.profile.senderMode then
		PRT.Debug("Combat stopped. Resetting PRT.")

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

		-- Stop all timers
		AceTimer:CancelAllTimers()	
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

function PRT:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	if PRT.db.profile.receiverMode then
		if prefix == PRT.db.profile.addonMessagePrefix then
			PRT.ReceiverOverlay.AddMessage(message)
		end
	end
end

function PRT:ENCOUNTER_END(event)	
	if PRT.enabled and not self.db.profile.testMode then
		EventHandler.StopEncounter(event)
	end
end

function PRT:PLAYER_REGEN_DISABLED(event)		
	if self.db.profile.testMode then
		if PRT.db.profile.senderMode then
			PRT.Debug("You are currently in test mode.")

			local _, encounter = PRT.FilterEncounterTable(self.db.profile.encounters, self.db.profile.testEncounterID)

			if encounter then
				EventHandler.StartEncounter(event, encounter.id, encounter.name)
			else
				PRT.Error("You are in test mode and have no encounter selected.")
			end
		else
			PRT.Error("You are in test mode and have sender mode disabled. Enable it if you want to test an encounter.")
		end
	end
end

function PRT:PLAYER_REGEN_ENABLED(event)
	if self.db.profile.testMode then
		EventHandler.StopEncounter(event)
	end
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
				PRT.Debug("Current difficulty is |cFF9482C9", difficulty, "|r")
				
				if self.db.profile.enabledDifficulties["dungeon"][difficulty] then
					PRT.Debug("Enabling PhenomRaidTools for|cFF9482C9", name, "|ron difficulty|cFF9482C9", difficulty, "|r")
					PRT.enabled = true
				else
					PRT.Debug("Difficulty not configured. PhenomRaidTools disabled.")
					PRT.enabled = false
				end
			elseif type == "raid" then
				PRT.Debug("Player entered raid - checking difficulty")
				PRT.Debug("Current difficulty is|cFF9482C9"..difficulty, "|r")
				
				if self.db.profile.enabledDifficulties["raid"][difficulty] then
					PRT.Debug("Enabling PhenomRaidTools for|cFF9482C9", name, "|ron difficulty|cFF9482C9", difficulty, "|r")
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