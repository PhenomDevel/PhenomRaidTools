local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

PRT.ConditionWidget = function(condition)
	PRT:Print("ConditionGroupWidget", condition)
	local conditionGroupWidget = AceGUI:Create("SimpleGroup")
	conditionGroupWidget:SetLayout("Flow")
	conditionGroupWidget:SetFullWidth(true)

	local eventEditBox = AceGUI:Create("EditBox")
	eventEditBox:SetLabel("Event")
	eventEditBox:SetCallback("OnTextChanged", function(widget) condition.event = widget:GetText() end)
	
	local spellIDEditBox = AceGUI:Create("EditBox")
	spellIDEditBox:SetLabel("Spell-ID")	
	spellIDEditBox:SetCallback("OnTextChanged", function(widget) condition.spellID = widget:GetText() end)

	local targetEditBox = AceGUI:Create("EditBox")
	targetEditBox:SetLabel("Target")
	targetEditBox:SetCallback("OnTextChanged", function(widget) condition.target = widget:GetText() end)
	
	local sourceEditBox = AceGUI:Create("EditBox")
	sourceEditBox:SetLabel("Source")	
	sourceEditBox:SetCallback("OnTextChanged", function(widget) condition.source = widget:GetText() end)

	if condition then
		if condition.event then
			eventEditBox:SetText(condition.event)
		else
			eventEditBox:SetText("")
		end

		if condition.spellID then
			spellIDEditBox:SetText(condition.spellID)
		else
			spellIDEditBox:SetText("")
		end

		if condition.target then
			targetEditBox:SetText(condition.target)
		else
			targetEditBox:SetText("")
		end

		if condition.source then
			sourceEditBox:SetText(condition.source)
		else
			sourceEditBox:SetText("")
		end
	end	

	conditionGroupWidget:AddChild(eventEditBox)
	conditionGroupWidget:AddChild(spellIDEditBox)
	conditionGroupWidget:AddChild(targetEditBox)
	conditionGroupWidget:AddChild(sourceEditBox)
	
	return conditionGroupWidget
end

PRT.MessageWidget = function (message)
	PRT:Print("MessageWidget", message)
	local messageWidget = PRT.SimpleGroup()

	local targetsEditBox = AceGUI:Create("EditBox")
	targetsEditBox:SetLabel("Targets")   
	targetsEditBox:SetCallback("OnTextChanged", function(widget) message.targets = PRT.StringToTargets(widget:GetText()) end) 

	local messageEditBox = AceGUI:Create("EditBox")	
    messageEditBox:SetLabel("Message")
    messageEditBox:SetCallback("OnTextChanged", function(widget) message.message = widget:GetText() end)

	local delayEditBox = AceGUI:Create("EditBox")	
	delayEditBox:SetLabel("Delay (s)")
	delayEditBox:SetCallback("OnTextChanged", function(widget) message.delay = widget:GetText() end)

	local durationEditBox = AceGUI:Create("EditBox")	
	durationEditBox:SetLabel("Duration (s)")
	durationEditBox:SetCallback("OnTextChanged", function(widget) message.duration = widget:GetText() end)

	if message then
		if message.targets then
			targetsEditBox:SetText(PRT:TargetsToString(message.targets))
		end
		if message.message then
			messageEditBox:SetText(message.message)
		end
		if message.delay then
			delayEditBox:SetText(message.delay)
		end
		if message.duration then
			durationEditBox:SetText(message.duration)
		end
	end

	messageWidget:AddChild(targetsEditBox)
	messageWidget:AddChild(messageEditBox)
	messageWidget:AddChild(delayEditBox)
	messageWidget:AddChild(durationEditBox)

	return messageWidget
end