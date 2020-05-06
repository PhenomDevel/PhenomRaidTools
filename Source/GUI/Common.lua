local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Public API

PRT.ConditionWidget = function(condition, textID)
	local widget = PRT.InlineGroup(textID)
	local eventEditBox = PRT.EditBox("conditionEvent", condition.event, true)
	eventEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = widget:GetText()
			if text == "" then
				condition.event = nil
			else
				condition.event = text
			end	
			widget:ClearFocus()
		end)
	
	local spellIDEditBox = PRT.EditBox("conditionSpellID", condition.spellID, true)
	spellIDEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = tonumber(widget:GetText()) 
			if text == "" then
				condition.spellID = nil
			else
				condition.spellID = text
			end				
			widget:ClearFocus()
		end)

	local targetEditBox = PRT.EditBox("conditionTarget", condition.target, true)
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

	local sourceEditBox = PRT.EditBox("conditionSource", condition.source, true)
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

	widget:AddChild(eventEditBox)	
	widget:AddChild(spellIDEditBox)
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