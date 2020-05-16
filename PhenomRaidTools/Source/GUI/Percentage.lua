local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Percentage = {
    operatorValues = {
        { 
            id = "greater", 
            name = ">" 
        },
        { 
            id = "less",    
            name = "<" 
        },
        { 
            id = "equals",  
            name = "=" 
        }
    }
}


-------------------------------------------------------------------------------
-- Local Helper

Percentage.PercentageEntryWidget = function(entry, container)
    local percentageEntryOptionsGroup = PRT.InlineGroup("percentageEntryOptionsHeading")

    local operatorDropdown = PRT.Dropdown("percentageEntryOperatorDropdown", Percentage.operatorValues, entry.operator)
    operatorDropdown:SetCallback("OnValueChanged", 
        function(widget, event, key) 
            entry.operator = key 
        end)

    local valueSlider = PRT.Slider("percentageEntryPercent", entry.value)
    valueSlider:SetSliderValues(0, 100, 1)
    valueSlider:SetCallback("OnValueChanged", 
        function(widget) 
            local value = widget:GetValue()
            entry.value = value
            entry.name = value.." %" 
        end)

    local messagesHeading = PRT.Heading("messageHeading")
    local messagesTabs = PRT.TableToTabs(entry.messages, true)
    local messagesTabGroup = PRT.TabGroup("Messages", messagesTabs)
    messagesTabGroup:SetLayout("List")
    messagesTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, "messageDeleteButton") 
        end)

    PRT.SelectFirstTab(messagesTabGroup, entry.messages)    	

    percentageEntryOptionsGroup:SetLayout("Flow")
    percentageEntryOptionsGroup:AddChild(operatorDropdown)
    percentageEntryOptionsGroup:AddChild(valueSlider)

    container:AddChild(percentageEntryOptionsGroup)
    container:AddChild(messagesTabGroup)
end

Percentage.PercentageWidget = function(percentage, container)
    local percentageOptionsGroup = PRT.InlineGroup("percentageOptionsHeading")

    local nameEditBox = PRT.EditBox("percentageName", percentage.name)
    local unitIDEditBox = PRT.EditBox("percentageUnitID", percentage.unitID)
    local percentageCheckAgainCheckBox = PRT.CheckBox("percentageCheckAgain", percentage.checkAgain)
    local checkAgainAfterSlider = PRT.Slider("percentageCheckAgainAfter", percentage.checkAgainAfter)

    checkAgainAfterSlider:SetDisabled(not percentage.checkAgain)

    nameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            percentage.name = widget:GetText() 
            PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.Core.ReselectExchangeLast(percentage.name)
        end)
    
    unitIDEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            percentage.unitID = widget:GetText() 
			widget:ClearFocus()
        end)
        
    percentageCheckAgainCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            local value = widget:GetValue() 
            percentage.checkAgain = value
            checkAgainAfterSlider:SetDisabled(not value)
        end)
    
    checkAgainAfterSlider:SetCallback("OnValueChanged", 
        function(widget) 
            percentage.checkAgainAfter = widget:GetValue()
        end)

    local tabs = PRT.TableToTabs(percentage.values, true)
	local valuesTabGroupWidget = PRT.TabGroup(nil, tabs)
    valuesTabGroupWidget:SetCallback("OnGroupSelected", 
        function(widget, event,key) 
            PRT.TabGroupSelected(widget, percentage.values, key, Percentage.PercentageEntryWidget, PRT.EmptyPercentageEntry, "percentageEntryDeleteButton") 
        end)    

    PRT.SelectFirstTab(valuesTabGroupWidget, percentage.values)

    percentageOptionsGroup:SetLayout("Flow")

    percentageOptionsGroup:AddChild(nameEditBox)
    percentageOptionsGroup:AddChild(unitIDEditBox)
    percentageOptionsGroup:AddChild(percentageCheckAgainCheckBox)
    percentageOptionsGroup:AddChild(checkAgainAfterSlider)

    container:AddChild(percentageOptionsGroup)
    container:AddChild(valuesTabGroupWidget)
end


-------------------------------------------------------------------------------
-- Public API Power Percentage

PRT.AddPowerPercentageOptions = function(container, profile, encounterID)
    local idx, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local percentages = encounter.PowerPercentages

    local percentageOptionsGroup = PRT.InlineGroup("Options")
    percentageOptionsGroup:SetLayout("Flow")

    local addButton = PRT.Button("newPowerPercentage")
    addButton:SetHeight(40)
    addButton:SetRelativeWidth(1)
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            tinsert(percentages, newPercentage)
            PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "powerPercentages", newPercentage.name)
        end)

    percentageOptionsGroup:AddChild(addButton)
    container:AddChild(percentageOptionsGroup)
end

PRT.AddPowerPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.PowerPercentages
    local percentageIndex, percentage = PRT.FilterTableByName(percentages, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, percentages, percentageIndex, "deletePercentage")

    Percentage.PercentageWidget(percentage, container)
    container:AddChild(deleteButton)
end


-------------------------------------------------------------------------------
-- Public API Health Percentage

PRT.AddHealthPercentageOptions = function(container, profile, encounterID)
    local idx, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local percentages = encounter.HealthPercentages
    
    local percentageOptionsGroup = PRT.InlineGroup("Options")
    percentageOptionsGroup:SetLayout("Flow")

    local addButton = PRT.Button("newHealthPercentage")
    addButton:SetHeight(40)
    addButton:SetRelativeWidth(1)
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            tinsert(percentages, newPercentage)
            PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "healthPercentages", newPercentage.name)
        end)

    percentageOptionsGroup:AddChild(addButton)
    container:AddChild(percentageOptionsGroup)
end

PRT.AddHealthPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.HealthPercentages
    local percentageIndex, percentage = PRT.FilterTableByName(percentages, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, percentages, percentageIndex, "deletePercentage")

    Percentage.PercentageWidget(percentage, container)
    container:AddChild(deleteButton)
end