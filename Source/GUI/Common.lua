local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Public API

PRT.ConditionWidget = function(condition, textID)
	local widget = PRT.InlineGroup(textID)
	local eventEditBox = PRT.EditBox("conditionEvent", condition.event, true)
	eventEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			local text = widget:GetText()
			if text == "" then
				condition.event = nil
			else
				condition.event = text
			end	
		end)
	
	local spellIDEditBox = PRT.EditBox("conditionSpellID", condition.spellID, true)
	spellIDEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			local text = tonumber(widget:GetText()) 
			if text == "" then
				condition.spellID = nil
			else
				condition.spellID = text
			end	
		end)

	local targetEditBox = PRT.EditBox("conditionTarget", condition.target, true)
	targetEditBox:SetCallback("OnTextChanged", 
		function(widget)
			local text = widget:GetText()
			if text == "" then
				condition.target = nil
			else
				condition.target = text
			end			
		end)

	local sourceEditBox = PRT.EditBox("conditionSource", condition.source, true)
	sourceEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			local text = widget:GetText()
			print(text)
			if text == "" then
				condition.source = nil
			else
				condition.source = text
			end	
		end)

	widget:AddChild(eventEditBox)	
	widget:AddChild(spellIDEditBox)
	widget:AddChild(targetEditBox)
	widget:AddChild(sourceEditBox)

	return widget
end

PRT.MessageWidget = function (message, container)
	local targetsEditBox = PRT.EditBox("messageTargets", strjoin(", ", unpack(message.targets)), true)
	targetsEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			message.targets = PRT.StringToTargets(widget:GetText()) 
		end) 

	local messageEditBox = PRT.EditBox("messageMessage", message.message, true)	
	messageEditBox: SetWidth(450)
	messageEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			message.message = widget:GetText() 
		end)

	local delayEditBox = PRT.EditBox("messageDelay", message.delay, true)	
	delayEditBox:SetCallback("OnTextChanged", 
		function(widget)
			message.delay = tonumber(widget:GetText()) 
		end)

	local durationEditBox = PRT.EditBox("messageDuration", message.duration, true)	
	durationEditBox:SetCallback("OnTextChanged", 
		function(widget)
			message.duration = tonumber(widget:GetText()) 
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