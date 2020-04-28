local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local FilterEncounterTable = function(encounters, id)
    local value
    if encounters then
        for i, v in ipairs(encounters) do
            if v.id == id then
                if not value then
                    value = v
                end
            end
        end
    end
    return value
end

function PRT:ENCOUNTER_START(event, encounterID)
	PRT:Debug("ENCOUNTER_START - ", encounterID)
	if not self.db.profile.testMode then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		PRT.currentEncounter = {}
		PRT.currentEncounter.inFight = true
		PRT.currentEncounter.lastCheck = GetTime()	

		local encounter = FilterEncounterTable(self.db.profile.encounters, encounterID)
		PRT.currentEncounter.encounter = PRT.CopyTable(encounter)
	end

	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
end

function PRT:ENCOUNTER_END(event)
	PRT:Debug("ENCOUNTER_END")
	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if PRT.currentEncounter then
		PRT.currentEncounter.inFight = false
	end	
end

function PRT:PLAYER_REGEN_DISABLED(event)
	PRT:Debug("PLAYER_REGEN_DISABLED")
	if self.db.profile.testMode then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		PRT.currentEncounter = {}
		PRT.currentEncounter.inFight = true
		PRT.currentEncounter.lastCheck = GetTime()	

		local encounter = FilterEncounterTable(self.db.profile.encounters, self.db.profile.testEncounterID)
		PRT.currentEncounter.encounter = PRT.CopyTable(encounter)		
	end	
	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
end

function PRT:PLAYER_REGEN_ENABLED(event)
	PRT:Debug("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if PRT.currentEncounter then
		PRT.currentEncounter.inFight = false
	end

	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
end

function PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
	if PRT.currentEncounter then
		local timestamp, combatEvent, _, sourceGUID, sourceName, _, _, targetGUID, targetName, _, _, eventSpellID,_,_, eventExtraSpellID = CombatLogGetCurrentEventInfo()
		if PRT.currentEncounter.inFight then
			if PRT.currentEncounter.encounter then
				-- Check for activations 10 times a second
				--if GetTime() > PRT.currentEncounter.lastCheck + 0.1 then
				--	PRT.currentEncounter.lastCheck = GetTime()
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
						PRT.CheckRotationTriggerCondition(rotations, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
					end

					-- Checking Percentage activation
					if percentages then
						--PRT.CheckUnitHealthTrackers(percentages)
					end

					-- Process Message Queue after activations
					if timers or rotations or percentages then
						PRT.ProcessMessageQueue()
					end
				--end
			end
		end
	end
end