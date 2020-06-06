local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Message = {
    defaultTargets = {
        "$me",
        "ALL",
        "HEALER",
        "TANKS",
        "DAMAGER"
    }
}


-------------------------------------------------------------------------------
-- Local Helper

Message.TargetsPreviewString = function(targets)
	if targets then
		local previewNames = {}

        for i, target in ipairs(targets) do
			local trimmedName = strtrim(target, " ")
			local raidRosterID = string.gsub(trimmedName, "[$]+", "")  
			local raidRosterEntry
			local coloredName

			if raidRosterID then
				raidRosterEntry = PRT.db.profile.raidRoster[raidRosterID]
			end

			if raidRosterEntry then
				coloredName = PRT.ClassColoredName(raidRosterEntry)
			else
				coloredName = PRT.ClassColoredName(trimmedName)
			end
			
			tinsert(previewNames, coloredName)
		end

		return strjoin(", ", unpack(previewNames))
	else
		return ""
	end
end

Message.ColoredRaidPlayerNames = function()
	local playerNames = {}

	for i, name in ipairs(PRT.PartyNames()) do
		tinsert(playerNames, { id = name, name = PRT.ClassColoredName(name)})
	end

	return playerNames
end

Message.GenerateRaidRosterDropdownItems = function()
	local raidRosterItems = {}
	for k, v in pairs(PRT.db.profile.raidRoster) do
		local name = PRT.ClassColoredName(v)
		
		name = "$"..k.." ("..name..")"

		tinsert(raidRosterItems, { id = "$"..k , name = name})
	end

	for i, name in ipairs(Message.defaultTargets) do
		tinsert(raidRosterItems, { id = name, name = name})
	end
	
	raidRosterItems = table.mergecopy(raidRosterItems, Message.ColoredRaidPlayerNames())

	return raidRosterItems
end


-------------------------------------------------------------------------------
-- Public API

PRT.MessageWidget = function (message, container)
	local targetsString = strjoin(", ", unpack(message.targets))
	local targetsPreviewString = Message.TargetsPreviewString(message.targets)
	local raidRosterItems = Message.GenerateRaidRosterDropdownItems()	
	
	local targetsEditBox = PRT.EditBox("messageTargets", targetsString, true)	
   local targetsPreviewLabel = PRT.Label(L["messagePreview"]..PRT.PrepareMessageForDisplay(targetsPreviewString))
	local raidRosterDropdown = PRT.Dropdown("messageRaidRosterAddDropdown", raidRosterItems)

	local soundSelect = PRT.SoundSelect("messageSound", (message.soundFileName or L["messageStandardSound"]))	
	soundSelect:SetCallback("OnValueChanged", 
		function(widget, event, value)
			local path = AceGUIWidgetLSMlists.sound[value]
			message.soundFile = path
			message.soundFileName = value
			widget:SetText(value)

			if path then
				PlaySoundFile(path, "Master")
			end
		end)

	local useCustomSoundCheckbox = PRT.CheckBox("messageUseCustomSound", message.useCustomSound)
	useCustomSoundCheckbox:SetCallback("OnValueChanged", 
		function(widget)
			local value = widget:GetValue()
			message.useCustomSound = value
			container:ReleaseChildren()
			PRT.MessageWidget(message, container)
			PRT.mainWindowContent.scrollFrame:DoLayout()
		end)

	targetsEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = widget:GetText()
			if text ~= "" then
				message.targets = { strsplit(",", text) }				
			else
				message.targets = {}
			end
			targetsPreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(Message.TargetsPreviewString(message.targets)))
			widget:ClearFocus()
		end) 
				
	raidRosterDropdown:SetCallback("OnValueChanged", 
		function(widget) 	
			tinsert(message.targets, widget:GetValue())	
			targetsEditBox:SetText(strjoin(", ", unpack(message.targets)))
			targetsPreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(Message.TargetsPreviewString(message.targets)))
			widget:SetValue(nil)
		end)    
		
	local messagePreviewLabel = PRT.Label(L["messagePreview"]..PRT.PrepareMessageForDisplay(message.message))	
	local messageEditBox = PRT.EditBox("messageMessage", message.message, true)		
	messageEditBox:SetWidth(400)
	messageEditBox:SetMaxLetters(180)
	messageEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = widget:GetText() 
			message.message = text
			widget:ClearFocus()
			messagePreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(message.message))
		end)


	local delayEditBox = PRT.Slider("messageDelay", message.delay, true)	
	delayEditBox:SetCallback("OnValueChanged", 
		function(widget)
			message.delay = tonumber(widget:GetValue()) 
		end)

	local durationEditBox = PRT.Slider("messageDuration", message.duration, true)	
	durationEditBox:SetCallback("OnValueChanged", 
		function(widget)
			message.duration = tonumber(widget:GetValue()) 
		end)

	local withSoundCheckbox = PRT.CheckBox("messageWithSound", message.withSound)
	withSoundCheckbox:SetCallback("OnValueChanged", 
		function(widget) 
			message.withSound = widget:GetValue() 
		end)

	container:AddChild(targetsEditBox)
	container:AddChild(targetsPreviewLabel)	
	container:AddChild(raidRosterDropdown)		

	container:AddChild(messageEditBox)
	container:AddChild(messagePreviewLabel)
	container:AddChild(delayEditBox)
	container:AddChild(durationEditBox)	
	container:AddChild(withSoundCheckbox)
	container:AddChild(useCustomSoundCheckbox)	

	if message.useCustomSound then
		container:AddChild(soundSelect)
	end	
end