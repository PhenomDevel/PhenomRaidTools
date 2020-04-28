local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

PRT.RotationEntryWidget = function(entry)
    local rotationEntryWidget = PRT:SimpleGroup() 

    -- Messages
    local messagesHeading = PRT.Heading("Messages")
    local messagesTabs = PRT.TableToTabs(entry.messages, true)
	local messagesTabGroup = PRT.TabGroup(nil, messagesTabs)
    messagesTabGroup:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "Delete Message") end)
    messagesTabGroup:SelectTab(1)

    rotationEntryWidget:AddChild(messagesHeading)
    rotationEntryWidget:AddChild(messagesTabGroup)

	return rotationEntryWidget
end

PRT.RotationWidget = function(rotation)
    local rotationWidget = PRT:SimpleGroup()

    local nameEditBox = PRT.EditBox("Name", rotation.name)
    
    nameEditBox:SetCallback("OnTextChanged", function(widget) rotation.name = widget:GetText() end)

    local shouldRestartCheckBox =  PRT.CheckBox("Should rotation restart?", rotation.shouldRestart)
    shouldRestartCheckBox:SetCallback("OnValueChanged", function(widget) rotation.shouldRestart = widget:GetValue() end)
    shouldRestartCheckBox:SetFullWidth(true)
    
    local ignoreAfterActivationCheckBox =  PRT.CheckBox("Ignore after activation?", rotation.ignoreAfterActivation)
    ignoreAfterActivationCheckBox:SetCallback("OnValueChanged", function(widget) rotation.ignoreAfterActivation = widget:GetValue() end)

    local ignoreDurationEditBox = PRT.EditBox("Ignore duration", rotation.ignoreDuration)
    ignoreDurationEditBox:SetCallback("OnTextChanged", function(widget) rotation.ignoreDuration = widget:GetText() end)

    local triggerConditionHeading = PRT.Heading("Trigger Condition")
    local triggerCondition = PRT.ConditionWidget(rotation.triggerCondition)

    local rotationsHeading = PRT.Heading("Rotation Entries")

    local tabs = PRT.TableToTabs(rotation.entries, true)
	local entriesTabGroupWidget = PRT.TabGroup(nil, tabs)
    entriesTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event,key) PRT.TabGroupSelected(widget, rotation.entries, key, PRT.RotationEntryWidget, PRT.EmptyRotationEntry, "Delete Rotation Entry") end)    

    entriesTabGroupWidget:SelectTab(nil)
    if rotation.entries then
		if table.getn(rotation.entries) > 0 then
			entriesTabGroupWidget:SelectTab(1)
		end
	end

    -- Setup Widget
    rotationWidget:AddChild(nameEditBox)
    rotationWidget:AddChild(shouldRestartCheckBox)
    rotationWidget:AddChild(ignoreAfterActivationCheckBox)
    rotationWidget:AddChild(ignoreDurationEditBox)
    rotationWidget:AddChild(triggerConditionHeading)
    rotationWidget:AddChild(triggerCondition)
    rotationWidget:AddChild(rotationsHeading)   
    rotationWidget:AddChild(entriesTabGroupWidget) 

	return rotationWidget
end

PRT.RotationTabGroup = function(rotations)
	local tabs = PRT.TableToTabs(rotations, true)
	local rotationsTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    rotationsTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, rotations, key, PRT.RotationWidget, PRT.EmptyRotation, "Delete Rotation") end)
    
    rotationsTabGroupWidget:SelectTab(nil)
    if rotations then
		if table.getn(rotations) > 0 then
			rotationsTabGroupWidget:SelectTab(1)
		end
	end

    return rotationsTabGroupWidget
end