local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Local Helper

local essentialEvents = {
	"PLAYER_REGEN_DISABLED", 
	"PLAYER_REGEN_ENABLED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
}

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


-------------------------------------------------------------------------------
-- Public API

PRT.RegisterEssentialEvents = function()
	for i, event in ipairs(essentialEvents) do
		PRT:RegisterEvent(event)
	end
end

PRT.UnregisterEssentialEvents = function()
	for i, event in ipairs(essentialEvents) do
		PRT:UnregisterEvent(event)
	end
end

function PRT:ENCOUNTER_START(event, encounterID, encounterName)	
	PRT.Debug("Encounter started - ", encounterID, encounterName)
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
	PRT.Debug("Encounter ended.")	
	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if PRT.currentEncounter then
		PRT.currentEncounter.inFight = false
	end	

	PRT.ClearMessageQueue()
end

function PRT:PLAYER_REGEN_DISABLED(event)
	PRT.Debug("Combat started.")
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
	PRT.Debug("Combat stopped. Resetting encounter.")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if PRT.currentEncounter then
		PRT.currentEncounter.inFight = false
	end

	PRT.ClearMessageQueue()
	PRT:COMBAT_LOG_EVENT_UNFILTERED(event)
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
					PRT.CheckRotationTriggerCondition(rotations, event, combatEvent, eventSpellID, targetGUID, sourceGUID)
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