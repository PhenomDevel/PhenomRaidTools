local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Public API

PRT.ConditionWidget = function(condition)
	local conditionGroupWidget = AceGUI:Create("SimpleGroup")
	conditionGroupWidget:SetLayout("Flow")
	conditionGroupWidget:SetFullWidth(true)

	local eventEditBox = PRT.EditBox("EditBox")
	eventEditBox:SetLabel("Event")
	eventEditBox:SetCallback("OnTextChanged", function(widget) condition.event = widget:GetText() end)
	
	local spellIDEditBox = PRT.EditBox("EditBox")
	spellIDEditBox:SetLabel("Spell-ID")	
	spellIDEditBox:SetCallback("OnTextChanged", function(widget) condition.spellID = tonumber(widget:GetText()) end)

	local targetEditBox = PRT.EditBox("EditBox")
	targetEditBox:SetLabel("Target")
	targetEditBox:SetCallback("OnTextChanged", function(widget) condition.target = widget:GetText() end)

	local sourceEditBox = PRT.EditBox("EditBox")
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
	local messageWidget = PRT.SimpleGroup()

	local targetsEditBox = PRT.EditBox("EditBox", PRT:TargetsToString(message.targets))
	targetsEditBox:SetLabel("Targets")   
	targetsEditBox:SetCallback("OnTextChanged", function(widget) message.targets = PRT.StringToTargets(widget:GetText()) end) 

	local targetsLabel = PRT.Label("Use commas to separate targets")
	targetsLabel:SetFullWidth(true)

	local messageEditBox = PRT.EditBox("EditBox")	
    messageEditBox:SetLabel("Message")
    messageEditBox:SetCallback("OnTextChanged", function(widget) message.message = widget:GetText() end)

	local messageLabel = PRT.Label("Use `%s` if you want to display the countdown")
	messageLabel:SetFullWidth(true)

	local delayEditBox = PRT.EditBox("EditBox")	
	delayEditBox:SetLabel("Delay (s)")
	delayEditBox:SetCallback("OnTextChanged", function(widget) message.delay = tonumber(widget:GetText()) end)

	local durationEditBox = PRT.EditBox("EditBox")	
	durationEditBox:SetLabel("Duration (s)")
	durationEditBox:SetCallback("OnTextChanged", function(widget) message.duration = tonumber(widget:GetText()) end)

	local withSoundCheckbox = PRT.CheckBox("With Sound?", message.withSound)
    withSoundCheckbox:SetCallback("OnValueChanged", function(widget) message.withSound = widget:GetValue() end)
    withSoundCheckbox:SetFullWidth(true)

	if message then
		if message.targets then
			targetsEditBox:SetText(PRT.TargetsToString(message.targets))
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
	messageWidget:AddChild(targetsLabel)
	messageWidget:AddChild(messageEditBox)
	messageWidget:AddChild(messageLabel)
	messageWidget:AddChild(delayEditBox)
	messageWidget:AddChild(durationEditBox)
	messageWidget:AddChild(withSoundCheckbox)

	return messageWidget
end