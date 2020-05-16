local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Rotation = {}


-------------------------------------------------------------------------------
-- Local Helper

Rotation.RotationEntryWidget = function(entry, container)
    local messagesTabs = PRT.TableToTabs(entry.messages, true)
    local messagesTabGroup = PRT.TabGroup("Messages", messagesTabs)    
    messagesTabGroup:SetLayout("List")
    messagesTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "messageDeleteButton") 
        end)

    PRT.SelectFirstTab(messagesTabGroup, entry.messages)    	

    container:AddChild(messagesTabGroup)
end

Rotation.RotationWidget = function(rotation, container)
    local rotationOptionsGroup = PRT.InlineGroup("rotationOptionsHeading")
    rotationOptionsGroup:SetLayout("Flow")

    local nameEditBox = PRT.EditBox("rotationName", rotation.name)    
    nameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            rotation.name = widget:GetText() 
            PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.Core.ReselectExchangeLast(rotation.name)
        end)

    local shouldRestartCheckBox =  PRT.CheckBox("rotationShouldRestart", rotation.shouldRestart)
    shouldRestartCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            rotation.shouldRestart = widget:GetValue() 
        end)
    
    local ignoreAfterActivationCheckBox = PRT.CheckBox("rotationIgnoreAfterActivation", rotation.ignoreAfterActivation)
    ignoreAfterActivationCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            rotation.ignoreAfterActivation = widget:GetValue() 
        end)

    local ignoreDurationEditBox = PRT.EditBox("rotationIgnoreDuration", rotation.ignoreDuration)
    ignoreDurationEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            rotation.ignoreDuration = widget:GetText() 
			widget:ClearFocus()
        end)

    local triggerConditionGroup = PRT.ConditionWidget(rotation.triggerCondition, "Trigger Condition")
    triggerConditionGroup:SetLayout("Flow")

    local tabs = PRT.TableToTabs(rotation.entries, true)
	local entriesTabGroupWidget = PRT.TabGroup("Rotation Entries", tabs)
    entriesTabGroupWidget:SetCallback("OnGroupSelected", 
        function(widget, event,key) 
            PRT.TabGroupSelected(widget, rotation.entries, key, Rotation.RotationEntryWidget, PRT.EmptyRotationEntry, "rotationEntryDeleteButton") 
        end)    

    PRT.SelectFirstTab(entriesTabGroupWidget, rotation.entries)

    rotationOptionsGroup:AddChild(nameEditBox)
    rotationOptionsGroup:AddChild(shouldRestartCheckBox)
    rotationOptionsGroup:AddChild(ignoreAfterActivationCheckBox)
    rotationOptionsGroup:AddChild(ignoreDurationEditBox)    
    container:AddChild(rotationOptionsGroup)
    container:AddChild(triggerConditionGroup)    
    container:AddChild(entriesTabGroupWidget) 
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddRotationOptions = function(container, profile, encounterID)
    local idx, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local rotations = encounter.Rotations

    local rotationOptionsGroup = PRT.InlineGroup("Options")
    rotationOptionsGroup:SetLayout("Flow")

    local addButton = PRT.Button("NEW ROTATION")
    addButton:SetHeight(40)
    addButton:SetRelativeWidth(1)
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newRotation = PRT.EmptyRotation()
            tinsert(rotations, newRotation)
            PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "rotations", newRotation.name)
        end)

    rotationOptionsGroup:AddChild(addButton)
    container:AddChild(rotationOptionsGroup)
end

PRT.AddRotationWidget = function(container, profile, encounterID, triggerName)    
    local idx, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local rotations = encounter.Rotations
    local rotationIndex, rotation = PRT.FilterTableByName(rotations, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, rotations, rotationIndex, "deleteRotation")

    Rotation.RotationWidget(rotation, container)
    container:AddChild(deleteButton)
end