local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Rotation = {}


-------------------------------------------------------------------------------
-- Local Helper

Rotation.RotationEntryWidget = function(entry, container)
    local messagesTabs = PRT.TableToTabs(entry.messages, true)
    local messagesTabGroup = PRT.TabGroup(nil, messagesTabs)
    messagesTabGroup:SetLayout("Flow")
    messagesTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "messageDeleteButton") 
        end)

    PRT.SelectFirstTab(messagesTabGroup, entry.messages)    	

    container:AddChild(messagesTabGroup)
end

Rotation.RotationWidget = function(rotation, container)
    local rotationOptionsGroup = PRT.InlineGroup("rotationOptionsHeading")

    local nameEditBox = PRT.EditBox("rotationName", rotation.name)    
    nameEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            rotation.name = widget:GetText() 
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
    ignoreDurationEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            rotation.ignoreDuration = widget:GetText() 
        end)

    local triggerConditionGroup = PRT.InlineGroup("rotationTriggerConditionHeading")
    PRT.ConditionWidget(rotation.triggerCondition, triggerConditionGroup)

    local tabs = PRT.TableToTabs(rotation.entries, true)
	local entriesTabGroupWidget = PRT.TabGroup(nil, tabs)
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

PRT.RotationTabGroup = function(rotations)
	local tabs = PRT.TableToTabs(rotations, true)
	local rotationsTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    rotationsTabGroupWidget:SetCallback("OnGroupSelected", 
    function(widget, event, key) 
        PRT.TabGroupSelected(widget, rotations, key, Rotation.RotationWidget, PRT.EmptyRotation, "rotationDeleteButton") 
    end)
    
    PRT.SelectFirstTab(rotationsTabGroupWidget, rotations)

    return rotationsTabGroupWidget
end