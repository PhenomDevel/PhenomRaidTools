local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Percentage = {}

-------------------------------------------------------------------------------
-- Local Helper

Percentage.PercentageEntryWidget = function(entry, container)
    local percentageEntryOptionsGroup = PRT.InlineGroup("percentageEntryOptionsHeading")

    local operatorValues = {
        {
            id = "greater",
            name = "greater than"
        },
        {
            id = "less",
            name = "less than"
        },
        {
            id = "equals",
            name = "equals"
        },
    }
    local operatorDropdown = PRT.Dropdown("percentageEntryOperatorDropdown", operatorValues, entry.operator)
    operatorDropdown:SetCallback("OnValueChanged", 
        function(widget, event, key) 
            entry.operator = key 
        end)

    local valueEditBox = PRT.EditBox("percentageEntryPercent", entry.value)
    valueEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            entry.value = tonumber(widget:GetText()) 
            entry.name = widget:GetText().." %" 
        end)

    local messagesHeading = PRT.Heading("messageHeading")
    local messagesTabs = PRT.TableToTabs(entry.messages, true)
    local messagesTabGroup = PRT.TabGroup(nil, messagesTabs)
    messagesTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "messageDeleteButton") 
        end)

    PRT.SelectFirstTab(messagesTabGroup, entry.messages)    	

    percentageEntryOptionsGroup:AddChild(operatorDropdown)
    percentageEntryOptionsGroup:AddChild(valueEditBox)

    container:AddChild(percentageEntryOptionsGroup)
    container:AddChild(messagesTabGroup)
end

Percentage.PercentageWidget = function(percentage, container)
    local percentageOptionsGroup = PRT.InlineGroup("percentageOptionsHeading")

    local nameEditBox = PRT.EditBox("percentageName", percentage.name)
    nameEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            percentage.unitID = widget:GetText() 
        end)

    local unitIDEditBox = PRT.EditBox("percentageUnitID", percentage.unitID)
    unitIDEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            percentage.unitID = widget:GetText() 
        end)
    
    local ignoreAfterActivationCheckBox = PRT.CheckBox("percentageCheckAgain", percentage.ignoreAfterActivation)
    ignoreAfterActivationCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            percentage.ignoreAfterActivation = widget:GetValue() 
        end)

    local ignoreDurationEditBox = PRT.EditBox("percentageCheckDelay", percentage.ignoreDuration)
    ignoreDurationEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            percentage.ignoreDuration = tonumber(widget:GetText()) 
        end)

    local tabs = PRT.TableToTabs(percentage.values, true)
	local valuesTabGroupWidget = PRT.TabGroup(nil, tabs)
    valuesTabGroupWidget:SetCallback("OnGroupSelected", 
        function(widget, event,key) 
            PRT.TabGroupSelected(widget, percentage.values, key, Percentage.PercentageEntryWidget, PRT.EmptyPercentageEntry, "percentageEntryDeleteButton") 
        end)    

    PRT.SelectFirstTab(valuesTabGroupWidget, percentage.values)

    percentageOptionsGroup:AddChild(nameEditBox)
    percentageOptionsGroup:AddChild(unitIDEditBox)
    percentageOptionsGroup:AddChild(ignoreAfterActivationCheckBox)
    percentageOptionsGroup:AddChild(ignoreDurationEditBox)

    container:AddChild(percentageOptionsGroup)
    container:AddChild(valuesTabGroupWidget)
end


-------------------------------------------------------------------------------
-- Public API

PRT.HealthPercentageTabGroup = function(percentages)
	local tabs = PRT.TableToTabs(percentages, true)
	local percentagesTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    percentagesTabGroupWidget:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, percentages, key, Percentage.PercentageWidget, PRT.EmptyPercentage, "percentageDeleteButton") 
        end)

    PRT.SelectFirstTab(percentagesTabGroupWidget, percentages)  

    return percentagesTabGroupWidget
end

PRT.PowerPercentageTabGroup = function(percentages)
	local tabs = PRT.TableToTabs(percentages, true)
	local powersTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    powersTabGroupWidget:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, percentages, key, Percentage.PercentageWidget, PRT.EmptyPercentage, "percentageDeleteButton") 
        end)

    PRT.SelectFirstTab(powersTabGroupWidget, percentages)  

    return powersTabGroupWidget
end