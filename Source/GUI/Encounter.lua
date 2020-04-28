local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Encounter = {}


-------------------------------------------------------------------------------
-- Local Helper

Encounter.EncounterTabs = function(encounters)
	local tabs = {}
	
	if encounters then
		for i, v in ipairs(encounters) do
			table.insert(tabs, {value = i, text = v.name})
		end
	end

	table.insert(tabs, {value = "new", text = newTabText or "+"})
 
	return tabs
end

Encounter.TriggerTabGroupSelected = function(container, encounter, key)
	container:ReleaseChildren()
	local widget = nil

	if key == "timers" then
		widget = PRT.TimerTabGroup(encounter.Timers)
	elseif key == "rotations" then
		widget = PRT.RotationTabGroup(encounter.Rotations)
	elseif key == "percentages" then
		widget = PRT.PercentageTabGroup(encounter.Percentages)		
	end

	container:AddChild(widget)	
	PRT.mainFrameContent:DoLayout()
end

Encounter.EncounterWidget = function(encounter)
	local encounterWidget = PRT.SimpleGroup()
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
	triggerTabGroup:SetCallback("OnGroupSelected", function(widget, event, key) Encounter.TriggerTabGroupSelected(widget, encounter, key) end)	

	triggerTabGroup:SelectTab("timers")

	local triggerHeading = PRT.Heading("Trigger")
	
	encounterWidget:AddChild(idEditBox)
	encounterWidget:AddChild(nameEditBox)
	encounterWidget:AddChild(triggerHeading)
	encounterWidget:AddChild(triggerTabGroup)

	return encounterWidget
end


-------------------------------------------------------------------------------
-- Public API

PRT.EncounterTabGroup = function(encounters)
	PRT:PrintTable("", encounters)
	local tabs = PRT.TableToTabs(encounters, true)
	local encountersTabGroupWidget = PRT.TabGroup(nil, tabs)
 
	encountersTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, encounters, key, Encounter.EncounterWidget, PRT.EmptyEncounter, "Delete Encounter") end)

	if encounters then
		if table.getn(encounters) > 0 then
			encountersTabGroupWidget:SelectTab(1)
		end
	end

	return encountersTabGroupWidget
end