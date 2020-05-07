local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Percentage = {}


-------------------------------------------------------------------------------
-- Local Helper

Percentage.PercentageEntryWidget = function(entry, container)
    local percentageEntryOptionsGroup = PRT.InlineGroup("percentageEntryOptionsHeading")

    local operatorValues = {
        { id = "greater", name = "greater than" },
        { id = "less",    name = "less than" },
        { id = "equals",  name = "equals" }
    }
    local operatorDropdown = PRT.Dropdown("percentageEntryOperatorDropdown", operatorValues, entry.operator)
    operatorDropdown:SetCallback("OnValueChanged", 
        function(widget, event, key) 
            entry.operator = key 
        end)

    local valueEditBox = PRT.EditBox("percentageEntryPercent", entry.value)
    valueEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            entry.value = tonumber(widget:GetText()) 
            entry.name = widget:GetText().." %" 
			widget:ClearFocus()
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
    percentageEntryOptionsGroup:AddChild(valueEditBox)

    container:AddChild(percentageEntryOptionsGroup)
    container:AddChild(messagesTabGroup)
end

Percentage.PercentageWidget = function(percentage, container)
    local percentageOptionsGroup = PRT.InlineGroup("percentageOptionsHeading")

    local nameEditBox = PRT.EditBox("percentageName", percentage.name)
    nameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            percentage.name = widget:GetText() 
            PRT.mainFrameContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
        end)

    local unitIDEditBox = PRT.EditBox("percentageUnitID", percentage.unitID)
    unitIDEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            percentage.unitID = widget:GetText() 
			widget:ClearFocus()
        end)
    
    local ignoreAfterActivationCheckBox = PRT.CheckBox("percentageCheckAgain", percentage.ignoreAfterActivation)
    ignoreAfterActivationCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            percentage.ignoreAfterActivation = widget:GetValue() 
        end)

    local ignoreDurationEditBox = PRT.EditBox("percentageCheckDelay", percentage.ignoreDuration)
    ignoreDurationEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            percentage.ignoreDuration = tonumber(widget:GetText()) 
			widget:ClearFocus()
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
    percentageOptionsGroup:AddChild(ignoreAfterActivationCheckBox)
    percentageOptionsGroup:AddChild(ignoreDurationEditBox)

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

    local addButton = PRT.Button("NEW POWER-PERCENTAGE")
    addButton:SetHeight(40)
    addButton:SetRelativeWidth(1)
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            tinsert(percentages, newPercentage)
            PRT.mainFrameContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            PRT.mainFrameContent:SelectByPath("encounters", encounterID, "powerPercentages", newPercentage.name)
        end)

    percentageOptionsGroup:AddChild(addButton)
    container:AddChild(percentageOptionsGroup)
end

PRT.AddPowerPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.PowerPercentages
    local percentageIndex, percentage = PRT.FilterTableByName(percentages, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, percentages, percentageIndex, "DELETE POWER-PERCENTAGE")

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

    local addButton = PRT.Button("NEW HEALTH-PERCENTAGE")
    addButton:SetHeight(40)
    addButton:SetRelativeWidth(1)
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            tinsert(percentages, newPercentage)
            PRT.mainFrameContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            PRT.mainFrameContent:SelectByPath("encounters", encounterID, "healthPercentages", newPercentage.name)
        end)

    percentageOptionsGroup:AddChild(addButton)
    container:AddChild(percentageOptionsGroup)
end

PRT.AddHealthPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.HealthPercentages
    local percentageIndex, percentage = PRT.FilterTableByName(percentages, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, percentages, percentageIndex, "DELETE HEALTH-PERCENTAGE")

    Percentage.PercentageWidget(percentage, container)
    container:AddChild(deleteButton)
end