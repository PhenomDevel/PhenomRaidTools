local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Condition = {
    defaultEvents = {
        "SPELL_CAST_SUCCESS",
        "SPELL_CAST_START",
        "SPELL_CAST_FAILED",
        "SPELL_AURA_REMOVED",
        "SPELL_AURA_APPLIED",
        "SPELL_AURA_APPLIED_DOSE",
        "SPELL_AURA_REMOVED_DOSE",
        "SPELL_AURA_REFRESH",
        "SPELL_INTERRUPT",
        "ENCOUNTER_START",
        "ENCOUNTER_END",
        "PLAYER_REGEN_DISABLED",
        "PLAYER_REGEN_ENABLED",
        "UNIT_DIED",
        "PARTY_KILL"
    }
}


-------------------------------------------------------------------------------
-- Public API

PRT.ConditionWidget = function(condition, textID)
	local conditionGroup = PRT.InlineGroup(textID)
        
    -- Generate event list
    local additionalEvents = PRT.db.profile.triggerDefaults.conditionDefaults.additionalEvents
	local conditionEventsFull = table.mergecopy(Condition.defaultEvents, additionalEvents)
    
    -- Create default widgets for condition
    local eventEditBox = PRT.EditBox("conditionEvent", condition.event, true)
	local eventDropDown = PRT.Dropdown("conditionEvent", conditionEventsFull, condition.event, true)
	local targetEditBox = PRT.EditBox("conditionTarget", condition.target, true)
	local sourceEditBox = PRT.EditBox("conditionSource", condition.source, true)

    -- Create new group for spell inputs
	local spellGroup = PRT.SimpleGroup()
	spellGroup:SetLayout("Flow")
	spellGroup:SetRelativeWidth(1)

	local spellIDEditBox = PRT.EditBox("conditionSpellID", condition.spellID, true)
	local spellNameLabel = PRT.Label(condition.spellName)
    spellNameLabel:SetWidth(150)
    
	local spellIcon = PRT.Icon(condition.spellIcon)
	spellIcon:SetHeight(20)
	spellIcon:SetWidth(30)
	spellIcon:SetImageSize(20,20)

	eventDropDown:SetCallback("OnValueChanged", 
		function(widget) 
			local text = widget:GetValue()

			if text == "" then
				condition.event = nil
			else
				condition.event = text
			end	

			widget:ClearFocus()
		end)	
	
	spellIDEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = tonumber(widget:GetText()) 

			local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(text)
			
			if name then
				condition.spellName = name								
			end

			if spellId then
				condition.spellID = spellId				
			end

			if icon then
				condition.spellIcon = icon				
			end

			if not (name and spellId and icon) then
				condition.spellName = nil
				condition.spellIcon = nil
				condition.spellID = nil		
			end

			spellIcon:SetImage(condition.spellIcon)
			spellNameLabel:SetText(condition.spellName)
			spellIDEditBox:SetText(condition.spellID)
			PRT.Core.UpdateTree()
			widget:ClearFocus()
		end)
			
	targetEditBox:SetCallback("OnEnterPressed", 
		function(widget)
			local text = widget:GetText()
			if text == "" then
				condition.target = nil
			else
				condition.target = text
			end		
			widget:ClearFocus()	
		end)
	
	sourceEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = widget:GetText()
			if text == "" then
				condition.source = nil
			else
				condition.source = text
			end	
			widget:ClearFocus()
		end)

	spellGroup:AddChild(spellIDEditBox)
	spellGroup:AddChild(spellIcon)
    spellGroup:AddChild(spellNameLabel)
    
	conditionGroup:AddChild(eventDropDown)	
	conditionGroup:AddChild(spellGroup)
	conditionGroup:AddChild(targetEditBox)
	conditionGroup:AddChild(sourceEditBox)

	return conditionGroup
end