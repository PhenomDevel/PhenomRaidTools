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

local Cooldowns = {
	externals = {
		33206, -- Pain Suppression
		47788, -- Guardian Spirit

		102342, -- Iron Bark

		6940, -- Blessing of Sacrifice
		1022, -- Blessing of Protection
		204018, -- Blessing of Spellwarding

		116849, -- Life Cocoon
	},
	raidHeal = {
		64843, -- Divine Hymn
		265202, -- Holy Word: Salvation

		740, -- Tranquility

		108280, -- Healing Tide Totem

		115310, -- Revival
	},
	raidDamageReduction = {
		62618, -- Power Word: Barrier

		98008, -- Spirit Link Totem

		31821, -- Aura Mastery

		320420, -- Darkness
	},
	utility = {
		106898, -- Stampeding Roar

		97462, -- Rallying Cry
	},
	immunities = {
		31224, -- Cloak of Shadows
		204018, -- Blessing of Spellwarding
		642, -- Divine Shield
		45438, -- Iceblock
		186265, -- Turtle
		196555, -- Netherwalk
	}
}

local cooldownIconSize = 20


-------------------------------------------------------------------------------
-- Local Helper

Message.TargetsPreviewString = function(targets)
	if targets then
		local previewNames = {}

		  for i, target in ipairs(targets) do
			local name = PRT.ReplacePlayerNameTokens(target)
			local names = {strsplit(",", name)}
			
			for i, name in ipairs(names) do
				local trimmedName = strtrim(name, " ")
				local coloredName = PRT.ClassColoredName(trimmedName)

				tinsert(previewNames, coloredName)
			end
		end

		return strjoin(", ", unpack(previewNames))
	else
		return ""
	end
end

Message.ColoredRaidPlayerNames = function()
	local playerNames = {}

	for i, name in ipairs(PRT.PartyNames(false)) do
		tinsert(playerNames, { id = name, name = PRT.ClassColoredName(name)})
	end

	return playerNames
end

Message.GenerateRaidRosterDropdownItems = function()
	local raidRosterItems = {}
	
	-- Add Raid Roster entries
	for k, v in pairs(PRT.db.profile.raidRoster) do
		local name = PRT.ClassColoredName(v)
		
		name = "$"..k.." ("..name..")"

		tinsert(raidRosterItems, { id = "$"..k , name = name})
	end

	-- Add Custom Encounter Placeholder
	-- Hacky because we do not have the encounter here...
	if PRT.currentEncounter.encounter then
		if PRT.currentEncounter.encounter.CustomPlaceholders then
			for i, customEncounterPlaceholder in ipairs(PRT.currentEncounter.encounter.CustomPlaceholders) do
				local coloredNames = {}

				for nameIdx, name in ipairs(customEncounterPlaceholder.names) do 
					tinsert(coloredNames, PRT.ClassColoredName(name))
				end
		
				local name = strjoin(", ", unpack(coloredNames))
				name = "$"..customEncounterPlaceholder.name.." ("..name..")"
				tinsert(raidRosterItems, { id = "$"..customEncounterPlaceholder.name , name = name})
			end
		end
	end

	-- Add Custom Placeholder
	for i, customPlaceholder in ipairs(PRT.db.profile.customPlaceholders) do
		local coloredNames = {}

		for nameIdx, name in ipairs(customPlaceholder.names) do 
			tinsert(coloredNames, PRT.ClassColoredName(name))
		end

		local name = strjoin(", ", unpack(coloredNames))
		name = "$"..customPlaceholder.name.." ("..name..")"
		tinsert(raidRosterItems, { id = "$"..customPlaceholder.name , name = name})
	end

	-- Add groups
	local groupItems = {}
	for i = 1, 8, 1 do  
		local identifier = "$group"..i
		if not tContains(groupItems, identifier) then
			tinsert(groupItems, identifier)
		end
	end
	
	for i, v in ipairs(groupItems) do
		tinsert(raidRosterItems, { id = v, name = v})
	end

	-- Add default targets (HEALER, TANK etc.)
	for i, name in ipairs(Message.defaultTargets) do
		tinsert(raidRosterItems, { id = name, name = name})
	end

	tinsert(raidRosterItems, { id = "$target", name = "$conditionTarget"})
	
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
	targetsEditBox:SetWidth(500)

	local targetsPreviewLabel = PRT.Label(L["messagePreview"]..PRT.PrepareMessageForDisplay(targetsPreviewString))
	targetsPreviewLabel:SetWidth(500)

	local raidRosterDropdown = PRT.Dropdown("messageRaidRosterAddDropdown", raidRosterItems)
	raidRosterDropdown:SetWidth(500)

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
			PRT.ReSelectTab(container)
		end)

	targetsEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = widget:GetText()
			if text ~= "" then
				-- Support space and comma
				local split1 = {strsplit(" ", text)}
				local split2 = {strsplit(",", strjoin(",", unpack(split1)))}

				message.targets = PRT.TableRemove(split2, PRT.EmptyString)			
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
		
	local messagePreviewLabel = PRT.Label(L["messagePreview"]..PRT.PrepareMessageForDisplay(message.message), 16)	
	messagePreviewLabel:SetWidth(500)
	local messageEditBox = PRT.EditBox("messageMessage", message.message, true)		
	messageEditBox:SetWidth(500)
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
	durationEditBox:SetSliderValues(0, 60, 0.5)
	durationEditBox:SetCallback("OnValueChanged", 
		function(widget)
			message.duration = tonumber(widget:GetValue()) 
		end)

	local targetOverlayDropdownItems = {}
	for i, overlay in ipairs(PRT.db.profile.overlay.receivers) do
		tinsert(targetOverlayDropdownItems, { id = overlay.id, name = overlay.id..": "..overlay.label})
	end
	
	local targetOverlayDropdown = PRT.Dropdown("messageTargetOverlay", targetOverlayDropdownItems, (message.targetOverlay or 1))
	targetOverlayDropdown:SetCallback("OnValueChanged", 
	function(widget) 	
		message.targetOverlay = widget:GetValue()
	end)  


	container:AddChild(targetsEditBox)
	container:AddChild(targetsPreviewLabel)	
	container:AddChild(raidRosterDropdown)		

	container:AddChild(messageEditBox)
	container:AddChild(messagePreviewLabel)

	for k, cooldownGroup in pairs(Cooldowns) do
		local cooldownIconsGroup = PRT.SimpleGroup()
		cooldownIconsGroup:SetLayout("Flow")

		for i, spellID in ipairs(cooldownGroup) do 
			local name, _, icon = GetSpellInfo(spellID)
			local spellIcon = PRT.Icon(icon, spellID)
			spellIcon:SetHeight(cooldownIconSize + 4)	
			spellIcon:SetWidth(cooldownIconSize + 4)	
			spellIcon:SetImageSize(cooldownIconSize, cooldownIconSize)
	
			spellIcon:SetCallback("OnClick", 
				function(widget)
					message.message = message.message.."{spell:"..spellID.."}"
					messageEditBox:SetText(message.message)
					messagePreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(message.message))
				end)	
			cooldownIconsGroup:AddChild(spellIcon)
		end
		
		container:AddChild(cooldownIconsGroup)
	end

	container:AddChild(delayEditBox)
	container:AddChild(durationEditBox)	
	container:AddChild(targetOverlayDropdown)
	container:AddChild(useCustomSoundCheckbox)	

	if message.useCustomSound then
		container:AddChild(soundSelect)
	end	
end