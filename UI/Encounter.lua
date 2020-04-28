local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Encounter

PRT.EncounterTabs = function(encounters)
	local tabs = {}
	
	if encounters then
		for i, v in ipairs(encounters) do
			table.insert(tabs, {value = i, text = v.name})
		end
	end

	table.insert(tabs, {value = "new", text = newTabText or "+"})
 
	return tabs
end

PRT.TriggerTabGroupSelected = function(container, encounter, key)
	container:ReleaseChildren()

	if key == "timers" then
		local widget = PRT.Timer.TimerTabGroup(encounter.Timers)
		container:AddChild(widget)
	elseif key == "rotations" then
		local widget = PRT.RotationTabGroup(encounter.Rotations)
		container:AddChild(widget)		
	elseif key == "percentages" then
		local widget = PRT.PercentageTabGroup(encounter.Percentages)
		container:AddChild(widget)	
	end

	PRT.mainFrameContent:DoLayout()
end

PRT.EncounterWidget = function(encounter)
	PRT:Print("EncounterWidget", encounter)
	local encounterWidget = PRT:SimpleGroup()
	encounterWidget:SetLayout("Flow")

	local idEditBox = PRT.EditBox("ID", encounter.id)	
	idEditBox:SetCallback("OnTextChanged", function(widget) encounter.id = tonumber(widget:GetText()) end)

	local nameEditBox = PRT.EditBox("Name", encounter.name)
	nameEditBox:SetCallback("OnTextChanged", function(widget) encounter.name = widget:GetText() end)

	local tabs = {
		{value = "timers", text = "Timers"},
		{value = "rotations", text = "Rotations"},
		{value = "percentages", text = "Unit HP Values"}
	}
	local triggerTabGroup = PRT.TabGroup(nil, tabs)
	triggerTabGroup:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TriggerTabGroupSelected(widget, encounter, key) end)	

	triggerTabGroup:SelectTab("timers")

	local triggerHeading = PRT.Heading("Trigger")
	
	encounterWidget:AddChild(idEditBox)
	encounterWidget:AddChild(nameEditBox)
	encounterWidget:AddChild(triggerHeading)
	encounterWidget:AddChild(triggerTabGroup)

	return encounterWidget
end

function PRT:EncounterTabGroup(encounters)
	PRT:Print("EncounterTabGroup", encounters)
	local tabs = PRT.TableToTabs(encounters, true)
	local encountersTabGroupWidget = PRT.TabGroup(nil, tabs)
 
	encountersTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, encounters, key, PRT.EncounterWidget, PRT.EmptyEncounter, "Delete Encounter") end)

	if encounters then
		if table.getn(encounters) > 0 then
			encountersTabGroupWidget:SelectTab(1)
		end
	end

	return encountersTabGroupWidget
end