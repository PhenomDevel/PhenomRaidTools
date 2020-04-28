local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Percentage

PRT.PercentageTabGroup = function(percentages)
    PRT:Print("PercentageTabGroup", percentages)
    
    local percentagesTabGroupWidget = PRT.SimpleGroup()

    local todo = PRT.Heading("TODO")

    --local tabs = TableToTabs(percentages, true)
	--local percentagesTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    --percentagesTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, percentages, key, PRT.RotationWidget, PRT.EmptyRotation) end)
    
    --percentagesTabGroupWidget:SelectTab(nil)
    --if percentages then
	--	if table.getn(percentages) > 0 then
	--		percentagesTabGroupWidget:SelectTab(1)
	--	end
	--end

    percentagesTabGroupWidget:AddChild(todo)

    return percentagesTabGroupWidget
end