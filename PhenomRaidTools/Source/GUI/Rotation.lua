local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Rotation = {}


-------------------------------------------------------------------------------
-- Local Helper

Rotation.RotationEntryWidget = function(entry, container)
    local messagesTabs = PRT.TableToTabs(entry.messages, true)
    local messagesTabGroup = PRT.TabGroup("messageHeading", messagesTabs)    
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
    local shouldRestartCheckBox =  PRT.CheckBox("rotationShouldRestart", rotation.shouldRestart)
    local ignoreAfterActivationCheckBox = PRT.CheckBox("rotationIgnoreAfterActivation", rotation.ignoreAfterActivation)
    local ignoreDurationSlider = PRT.Slider("rotationIgnoreDuration", rotation.ignoreDuration)

    ignoreDurationSlider:SetDisabled(not rotation.ignoreAfterActivation)

    nameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            rotation.name = widget:GetText() 
            PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.Core.ReselectExchangeLast(rotation.name)
        end)
    
    shouldRestartCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            rotation.shouldRestart = widget:GetValue() 
        end)    
    
    ignoreAfterActivationCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            local value = widget:GetValue()
            rotation.ignoreAfterActivation = value
            ignoreDurationSlider:SetDisabled(not value)
        end)
    
    ignoreDurationSlider:SetCallback("OnValueChanged", 
        function(widget) 
            rotation.ignoreDuration = widget:GetValue() 
        end)

    local triggerConditionGroup = PRT.ConditionWidget(rotation.triggerCondition, "Trigger Condition")
    triggerConditionGroup:SetLayout("Flow")

    local tabs = PRT.TableToTabs(rotation.entries, true)
	local entriesTabGroupWidget = PRT.TabGroup("rotationEntryHeading", tabs)
    entriesTabGroupWidget:SetCallback("OnGroupSelected", 
        function(widget, event,key) 
            PRT.TabGroupSelected(widget, rotation.entries, key, Rotation.RotationEntryWidget, PRT.EmptyRotationEntry, "rotationEntryDeleteButton") 
        end)    

    PRT.SelectFirstTab(entriesTabGroupWidget, rotation.entries)

    rotationOptionsGroup:AddChild(nameEditBox)
    rotationOptionsGroup:AddChild(shouldRestartCheckBox)
    rotationOptionsGroup:AddChild(ignoreAfterActivationCheckBox)
    rotationOptionsGroup:AddChild(ignoreDurationSlider)    
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

    local addButton = PRT.Button("newRotation")
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