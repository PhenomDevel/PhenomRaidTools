local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


local AceGUI = LibStub("AceGUI-3.0")
-------------------------------------------------------------------------------
-- Local Helper

local conditionEvents = {
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START",
	"SPELL_CAST_FAILED",
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED_DOSE",
	"SPELL_AURA_REFRESH",
	"SPELL_CAST_INTERRUPT",
	"ENCOUNTER_START",
	"ENCOUNTER_END",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"UNIT_DIED",
	"PARTY_KILL"
}

local defaultTargets = {
	"$me",
	"ALL",
	"HEALER",
	"TANKS",
	"DAMAGER"
}

local TargetsPreviewString = function(targets)
	if targets then
		local previewNames = {}

		for i, target in ipairs(targets) do
			local trimmedName = strtrim(target, " ")
			local raidRosterID = string.gsub(trimmedName, "[$]+", "")  
			local raidRosterEntry

			if raidRosterID then
				raidRosterEntry = PRT.db.profile.raidRoster[raidRosterID]
			end

			if raidRosterEntry then
				if UnitExists(raidRosterEntry) then
					local _, _, classIndex = UnitClass(raidRosterEntry)
					color = PRT.db.profile.colors.classes[classIndex]
				end
				
				if color then
					table.insert(previewNames, "|cFF"..(color or "")..raidRosterEntry.."|r")
				end
			else
				table.insert(previewNames, trimmedName)
			end	
		end

		return strjoin(", ", unpack(previewNames))
	else
		return ""
	end
end

PRT.PartyOrRaidNames = function()
	local names = {}

	if UnitInParty("player") then
		for i=1, 5 do

		end
	elseif UnitInRaid("player") then
		-- loop 40
	end
end

PRT.ColoredRaidPlayerNames = function()
	local playerNames = {}

	for i=1, 40 do
		local index = "raid"..i
		if UnitExists(index) then
			local name = GetRaidRosterInfo(i)
			local _, _, classIndex = UnitClass(name)
			local color = PRT.db.profile.colors.classes[classIndex]
			local coloredName = "|cFF"..color..name.."|r"
			table.insert(playerNames, { id = name, name = coloredName})
		end
	end

	return playerNames
end

PRT.GenerateRaidRosterDropdownItems = function()
	local raidRosterItems = {}
	for k, v in pairs(PRT.db.profile.raidRoster) do
		local color = nil

		if UnitExists(v) then
			local _, _, classIndex = UnitClass(v)
			color = PRT.db.profile.colors.classes[classIndex]
		end
		
		local name = ""
		if color then
			name = "$"..k.." (|cFF"..(color or "")..v.."|r)"
		else
			name = "$"..k.." ("..v..")"
		end

		table.insert(raidRosterItems, { id = "$"..k , name = name})
	end

	for i, name in ipairs(defaultTargets) do
		table.insert(raidRosterItems, { id = name, name = name})
	end
	
	raidRosterItems = table.mergecopy(raidRosterItems, PRT.ColoredRaidPlayerNames())

	return raidRosterItems
end

-------------------------------------------------------------------------------
-- Public API

PRT.ConditionWidget = function(condition, textID)
	local widget = PRT.InlineGroup(textID)

	local eventEditBox = PRT.EditBox("conditionEvent", condition.event, true)

	local conditionEventsFull = table.mergecopy(conditionEvents, PRT.db.profile.triggerDefaults.conditionDefaults.additionalEvents)
	
	local eventDropDown = PRT.Dropdown("conditionEvent", conditionEventsFull, condition.event, true)
	local targetEditBox = PRT.EditBox("conditionTarget", condition.target, true)
	local sourceEditBox = PRT.EditBox("conditionSource", condition.source, true)

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
	local targetsString = strjoin(", ", unpack(message.targets))
	local targetsPreviewString = TargetsPreviewString(message.targets)
	local raidRosterItems = PRT.GenerateRaidRosterDropdownItems()	

	local targetsEditBox = PRT.EditBox("messageTargets", targetsString, true)	
	local targetsPreviewLabel = PRT.Label("Preview: "..targetsPreviewString)
	local raidRosterDropdown = PRT.Dropdown("messageRaidRosterAddDropdown", raidRosterItems)

	targetsEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			message.targets = { strsplit(",", widget:GetText()) }
			targetsPreviewLabel:SetText("Preview: "..TargetsPreviewString(message.targets))
			widget:ClearFocus()
		end) 
				
	raidRosterDropdown:SetCallback("OnValueChanged", 
		function(widget) 
			local text = targetsEditBox:GetText()..", "..widget:GetValue()
			targetsEditBox:SetText(text)
			message.targets = { strsplit(",", targetsEditBox:GetText()) }
			targetsPreviewLabel:SetText("Preview: "..TargetsPreviewString(message.targets))
			widget:SetValue(nil)
		end)    

	local messageEditBox = PRT.EditBox("messageMessage", message.message, true)	
	messageEditBox:SetWidth(400)
	messageEditBox:SetMaxLetters(180)
	messageEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			message.message = widget:GetText() 
			widget:ClearFocus()
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
	container:AddChild(delayEditBox)
	container:AddChild(durationEditBox)	
	
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