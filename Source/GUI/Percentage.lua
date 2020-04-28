local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Percentage = {}

-------------------------------------------------------------------------------
-- Local Helper

Percentage.PercentageWidget = function(percentage)
    local todoHeading = PRT.Heading("NOT IMPLEMENTED YET")

    return todoHeading
end


-------------------------------------------------------------------------------
-- Public API

PRT.PercentageTabGroup = function(percentages)
	local tabs = PRT.TableToTabs(percentages, true)
	local percentagesTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    percentagesTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, percentages, key, Percentage.PercentageWidget, PRT.EmptyPercentage, "Delete Percentage") end)

    PRT.SelectFirstTab(percentagesTabGroupWidget, percentages)  

    return percentagesTabGroupWidget
end