local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Public API

PRT.ConditionWidget = function(condition)
	local conditionGroupWidget = AceGUI:Create("SimpleGroup")
	conditionGroupWidget:SetLayout("Flow")
	conditionGroupWidget:SetFullWidth(true)

	local eventEditBox = PRT.EditBox("conditionEvent", condition.event, true)
	eventEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			condition.event = widget:GetText() 
		end)
	
	local spellIDEditBox = PRT.EditBox("conditionSpellID", condition.spellID, true)
	spellIDEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			condition.spellID = tonumber(widget:GetText()) 
		end)

	local targetEditBox = PRT.EditBox("conditionTarget", condition.target, true)
	targetEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			condition.target = widget:GetText() 
		end)

	local sourceEditBox = PRT.EditBox("conditionSource", condition.source, true)
	sourceEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			condition.source = widget:GetText() 
		end)

	conditionGroupWidget:AddChild(eventEditBox)	
	conditionGroupWidget:AddChild(spellIDEditBox)
	conditionGroupWidget:AddChild(targetEditBox)
	conditionGroupWidget:AddChild(sourceEditBox)
	
	return conditionGroupWidget
end

PRT.MessageWidget = function (message)
	local messageWidget = AceGUI:Create("SimpleGroup")
	messageWidget:SetLayout("Flow")
	messageWidget:SetFullWidth(true)

	local targetsEditBox = PRT.EditBox("messageTargets", PRT.TargetsToString(message.targets), true)
	targetsEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			message.targets = PRT.StringToTargets(widget:GetText()) 
		end) 

	local messageEditBox = PRT.EditBox("messageMessage", message.message, true)	
	messageEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			message.message = widget:GetText() 
		end)
	messageEditBox:SetRelativeWidth(1)

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

	messageWidget:AddChild(targetsEditBox)
	messageWidget:AddChild(delayEditBox)
	messageWidget:AddChild(durationEditBox)	
	messageWidget:AddChild(messageEditBox)
	messageWidget:AddChild(withSoundCheckbox)

	return messageWidget
end