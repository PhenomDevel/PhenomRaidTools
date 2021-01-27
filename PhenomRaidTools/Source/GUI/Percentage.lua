local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Percentage = {
    operatorValues = {
        { 
            id = "greater", 
            name = "> (greater)" 
        },
        { 
            id = "less",    
            name = "< (less)" 
        },
        { 
            id = "equals",  
            name = "= (equals)" 
        }
    }
}


-------------------------------------------------------------------------------
-- Local Helper

Percentage.PercentageEntryWidget = function(entry, container, key, entries)
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
    local messagesTabGroup = PRT.TabGroup("messageHeading", messagesTabs)
    messagesTabGroup:SetLayout("List")
    messagesTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, entry.messages, key, PRT.MessageWidget, PRT.EmptyMessage, true, "messageDeleteButton") 
        end)

    PRT.SelectFirstTab(messagesTabGroup, entry.messages)    	

    percentageEntryOptionsGroup:SetLayout("Flow")
    percentageEntryOptionsGroup:AddChild(operatorDropdown)
    percentageEntryOptionsGroup:AddChild(valueSlider)

    container:AddChild(percentageEntryOptionsGroup)
    container:AddChild(messagesTabGroup)

    local cloneButton = PRT.Button("clonePercentageEntry")
    cloneButton:SetCallback("OnClick",
        function()
            local clone = PRT.CopyTable(entry)
            tinsert(entries, clone)
            PRT.Core.ReselectCurrentValue()
        end)
    container:AddChild(cloneButton)  
end

Percentage.PercentageWidget = function(percentage, container, deleteButton, cloneButton)
    local percentageOptionsGroup = PRT.InlineGroup("percentageOptionsHeading")

    local enabledCheckbox = PRT.CheckBox("percentageEnabled", percentage.enabled)
    local nameEditBox = PRT.EditBox("percentageName", percentage.name)
    local unitIDEditBox = PRT.EditBox("percentageUnitID", percentage.unitID, true)
    local checkAgainCheckBox = PRT.CheckBox("percentageCheckAgain", percentage.checkAgain)
    local checkAgainAfterSlider = PRT.Slider("percentageCheckAgainAfter", percentage.checkAgainAfter)

    local copyButton = PRT.Button("copyPercentage")
    copyButton:SetCallback("OnClick", 
        function(widget)
            local copy = PRT.CopyTable(percentage)
            copy.name = copy.name.." Copy"..random(0,100000)
            PRT.db.profile.clipboard.percentage = copy
            PRT.Debug("Copied percentage", PRT.HighlightString(percentage.name), "to clipboard")
        end)

    checkAgainAfterSlider:SetDisabled(not percentage.checkAgain)
    enabledCheckbox:SetRelativeWidth(1)
    enabledCheckbox:SetCallback("OnValueChanged", 
        function(widget) 
            percentage.enabled = widget:GetValue()         
            PRT.Core.UpdateTree()  
        end)

    nameEditBox:SetRelativeWidth(1)
    nameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            percentage.name = widget:GetText() 
            PRT.Core.UpdateTree()
            PRT.Core.ReselectExchangeLast(percentage.name)
            widget:ClearFocus()
        end)
    
    unitIDEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            percentage.unitID = widget:GetText() 
			widget:ClearFocus()
        end)
    
    checkAgainCheckBox:SetCallback("OnValueChanged", 
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
            PRT.TabGroupSelected(widget, percentage.values, key, Percentage.PercentageEntryWidget, PRT.EmptyPercentageEntry, true, "percentageEntryDeleteButton") 
        end)    

    PRT.SelectFirstTab(valuesTabGroupWidget, percentage.values)

    percentageOptionsGroup:SetLayout("Flow")

    percentageOptionsGroup:AddChild(enabledCheckbox)
    PRT.AddEnabledDifficultiesGroup(percentageOptionsGroup, percentage) 
    percentageOptionsGroup:AddChild(nameEditBox)    
    PRT.AddDescription(percentageOptionsGroup, percentage) 
    percentageOptionsGroup:AddChild(unitIDEditBox)    
    percentageOptionsGroup:AddChild(checkAgainCheckBox)
    percentageOptionsGroup:AddChild(checkAgainAfterSlider)    
    percentageOptionsGroup:AddChild(cloneButton)
    percentageOptionsGroup:AddChild(deleteButton)
    percentageOptionsGroup:AddChild(copyButton)

    container:AddChild(percentageOptionsGroup)
    PRT.MaybeAddStartCondition(container, percentage)
    PRT.MaybeAddStopCondition(container, percentage) 
    container:AddChild(valuesTabGroupWidget)
end


-------------------------------------------------------------------------------
-- Public API Power Percentage

PRT.AddPowerPercentageOptions = function(container, profile, encounterID)
    local idx, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local percentages = encounter.PowerPercentages

    local percentageOptionsGroup = PRT.InlineGroup("Options")
    percentageOptionsGroup:SetLayout("Flow")

    local hasClipboardPercentage = not PRT.TableUtils.IsEmpty(PRT.db.profile.clipboard.percentage)
    local pasteButton = PRT.Button("pastePercentage")
    pasteButton:SetDisabled(hasClipboardPercentage)
    pasteButton:SetCallback("OnClick",
        function(widget)
            tinsert(percentages, PRT.db.profile.clipboard.percentage)            
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "percentages", PRT.db.profile.clipboard.percentage.name)
            PRT.Debug("Pasted percentage", PRT.HighlightString(PRT.db.profile.clipboard.percentage.name), "to", PRT.HighlightString(encounter.name))
            PRT.db.profile.clipboard.percentage = nil            
        end)

    local addButton = PRT.Button("newPowerPercentage")
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            tinsert(percentages, newPercentage)
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "powerPercentages", newPercentage.name)
        end)

    percentageOptionsGroup:AddChild(addButton)
    percentageOptionsGroup:AddChild(pasteButton)
    container:AddChild(percentageOptionsGroup)
end

PRT.AddPowerPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.PowerPercentages
    local percentageIndex, percentage = PRT.FilterTableByName(percentages, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, percentages, percentageIndex, "deletePercentage", percentage.name)
    local cloneButton = PRT.NewCloneButton(container, percentages, percentageIndex, "clonePercentage", percentage.name)

    Percentage.PercentageWidget(percentage, container, deleteButton, cloneButton)
end


-------------------------------------------------------------------------------
-- Public API Health Percentage

PRT.AddHealthPercentageOptions = function(container, profile, encounterID)
    local idx, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local percentages = encounter.HealthPercentages
    
    local percentageOptionsGroup = PRT.InlineGroup("Options")
    percentageOptionsGroup:SetLayout("Flow")

    local hasClipboardPercentage = not PRT.TableUtils.IsEmpty(PRT.db.profile.clipboard.percentage)
    local pasteButton = PRT.Button("pastePercentage")
    pasteButton:SetDisabled(hasClipboardPercentage)
    pasteButton:SetCallback("OnClick",
        function(widget)
            tinsert(percentages, PRT.db.profile.clipboard.percentage)            
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "percentages", PRT.db.profile.clipboard.percentage.name)
            PRT.Debug("Pasted percentage", PRT.HighlightString(PRT.db.profile.clipboard.percentage.name), "to", PRT.HighlightString(encounter.name))
            PRT.db.profile.clipboard.percentage = nil            
        end)

    local addButton = PRT.Button("newHealthPercentage")
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            tinsert(percentages, newPercentage)
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            PRT.mainWindowContent:SelectByPath("encounters", encounterID, "healthPercentages", newPercentage.name)
        end)

    percentageOptionsGroup:AddChild(addButton)
    percentageOptionsGroup:AddChild(pasteButton)
    container:AddChild(percentageOptionsGroup)
end

PRT.AddHealthPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = PRT.FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.HealthPercentages
    local percentageIndex, percentage = PRT.FilterTableByName(percentages, triggerName)
    local deleteButton = PRT.NewTriggerDeleteButton(container, percentages, percentageIndex, "deletePercentage", percentage.name)
    local cloneButton = PRT.NewCloneButton(container, percentages, percentageIndex, "clonePercentage", percentage.name)

    Percentage.PercentageWidget(percentage, container, deleteButton, cloneButton)
end