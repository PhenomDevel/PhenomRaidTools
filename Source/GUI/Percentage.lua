local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Percentage = {}

-------------------------------------------------------------------------------
-- Local Helper

Percentage.PercentageValueWidget = function(value)
    local percentageValueWidget = PRT.SimpleGroup() 
    
    local valueEditBox = PRT.EditBox("HP Percentage", value.value)
    valueEditBox:SetCallback("OnTextChanged", function(widget) value.value = tonumber(widget:GetText()) value.name = widget:GetText().." %" end)

    -- Messages
    local messagesHeading = PRT.Heading("Messages")
    local messagesTabs = PRT.TableToTabs(value.messages, true)
	local messagesTabGroup = PRT.TabGroup(nil, messagesTabs)
    messagesTabGroup:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, value.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "Delete Message") end)

    PRT.SelectFirstTab(messagesTabGroup, value.messages)    	

    percentageValueWidget:AddChild(valueEditBox)
    percentageValueWidget:AddChild(messagesHeading)
    percentageValueWidget:AddChild(messagesTabGroup)

	return percentageValueWidget
end

Percentage.PercentageWidget = function(percentage)
    local percentageWidget = PRT:SimpleGroup()

    local nameEditBox = PRT.EditBox("Name", percentage.name)
    nameEditBox:SetCallback("OnTextChanged", function(widget) percentage.unitID = widget:GetText() end)

    local unitIDEditBox = PRT.EditBox("Unit-ID", percentage.unitID)
    unitIDEditBox:SetCallback("OnTextChanged", function(widget) percentage.unitID = widget:GetText() end)

    local tabs = PRT.TableToTabs(percentage.values, true)
	local valuesTabGroupWidget = PRT.TabGroup(nil, tabs)
    valuesTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event,key) PRT.TabGroupSelected(widget, percentage.values, key, Percentage.PercentageValueWidget, PRT.EmptyPercentageValue, "Delete Rotation Entry") end)    

    PRT.SelectFirstTab(valuesTabGroupWidget, percentage.values)

    -- Setup Widget
    percentageWidget:AddChild(nameEditBox)
    percentageWidget:AddChild(unitIDEditBox)
    percentageWidget:AddChild(valuesTabGroupWidget)

	return percentageWidget
end


-------------------------------------------------------------------------------
-- Public API

PRT.HealthPercentageTabGroup = function(percentages)
	local tabs = PRT.TableToTabs(percentages, true)
	local percentagesTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    percentagesTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, percentages, key, Percentage.PercentageWidget, PRT.EmptyPercentage, "Delete Percentage") end)

    PRT.SelectFirstTab(percentagesTabGroupWidget, percentages)  

    return percentagesTabGroupWidget
end

PRT.PowerPercentageTabGroup = function(percentages)
	local tabs = PRT.TableToTabs(percentages, true)
	local powersTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    powersTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, percentages, key, Percentage.PercentageWidget, PRT.EmptyPercentage, "Delete Percentage") end)

    PRT.SelectFirstTab(powersTabGroupWidget, percentages)  

    return powersTabGroupWidget
end