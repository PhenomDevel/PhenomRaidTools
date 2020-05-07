local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Local Helper

local conditionEvents = {
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START",
	"SPELL_CAST_FAILED",
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_INTERRUPT",
	"ENCOUNTER_START",
	"ENCOUNTER_END",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"UNIT_DIED",
	"PARTY_KILL"
}

-------------------------------------------------------------------------------
-- Public API

PRT.ConditionWidget = function(condition, textID)
	local widget = PRT.InlineGroup(textID)

	local eventEditBox = PRT.EditBox("conditionEvent", condition.event, true)

	local conditionEventsFull = table.merge(conditionEvents, PRT.db.profile.triggerDefaults.conditionDefaults.additionalEvents)

	local eventDropDown = PRT.Dropdown("conditionEvent", conditionEvents, condition.event)
	local targetEditBox = PRT.EditBox("conditionTarget", condition.target, true)
	local sourceEditBox = PRT.EditBox("conditionSource", condition.source, true)

	local spellGroup = PRT.SimpleGroup()
	spellGroup:SetLayout("Flow")
	spellGroup:SetRelativeWidth(1)

	local spellIDEditBox = PRT.EditBox("conditionSpellID", condition.spellID, true)
	local spellNameLabel = PRT.Label(condition.spellName)

	local spellIcon = PRT.Icon(condition.spellIcon)
	spellIcon:SetWidth(40)
	spellIcon:SetHeight(20)
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

	widget:AddChild(eventDropDown)	
	widget:AddChild(spellGroup)
	widget:AddChild(targetEditBox)
	widget:AddChild(sourceEditBox)

	return widget
end

PRT.MessageWidget = function (message, container)
	local targetsEditBox = PRT.EditBox("messageTargets", strjoin(", ", unpack(message.targets)), true)
	targetsEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			message.targets = { strsplit(",", widget:GetText()) }
			widget:ClearFocus()
		end) 

	local messageEditBox = PRT.EditBox("messageMessage", message.message, true)	
	messageEditBox: SetWidth(450)
	messageEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			message.message = widget:GetText() 
			widget:ClearFocus()
		end)

	local delayEditBox = PRT.EditBox("messageDelay", message.delay, true)	
	delayEditBox:SetCallback("OnEnterPressed", 
		function(widget)
			message.delay = tonumber(widget:GetText()) 
			widget:ClearFocus()
		end)

	local durationEditBox = PRT.EditBox("messageDuration", message.duration, true)	
	durationEditBox:SetCallback("OnEnterPressed", 
		function(widget)
			message.duration = tonumber(widget:GetText()) 
			widget:ClearFocus()
		end)

	local withSoundCheckbox = PRT.CheckBox("messageWithSound", message.withSound)
	withSoundCheckbox:SetCallback("OnValueChanged", 
		function(widget) 
			message.withSound = widget:GetValue() 
		end)

	container:AddChild(targetsEditBox)
	container:AddChild(delayEditBox)
	container:AddChild(durationEditBox)	
	container:AddChild(messageEditBox)
	container:AddChild(withSoundCheckbox)
end

PRT.NewTriggerDeleteButton = function(container, t, idx, textID)
    local deleteButton = PRT.Button(textID)
    deleteButton:SetHeight(40)
    deleteButton:SetRelativeWidth(1)
    deleteButton:SetCallback("OnClick", 
        function() 
            tremove(t, idx) 
            PRT.mainFrameContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            container:ReleaseChildren()
        end)

    return deleteButton
end