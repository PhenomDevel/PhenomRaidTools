local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

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


-------------------------------------------------------------------------------
-- Public API

PRT.RotationWidget = function(rotation, container)
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