local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local classColors = {
    [0] = nil,
    [1] = "FFC79C6E",
    [2] = "FFF58CBA",
    [3] = "FFABD473",
    [4] = "FFFFF569",
    [5] = "FFFFFFFF",
    [6] = "FFC41F3B",
    [7] = "FF0070DE",
    [8] = "FF69CCF0",
    [9] = "FF9482C9",
    [10] = "FF00FF96",
    [11] = "FFFF7D0A",
    [12] = "FFA330C9"
}

-------------------------------------------------------------------------------
-- Public API

PRT.MaybeAddStartCondition = function(container, trigger)
    if trigger.hasStartCondition then
        local startConditionGroup = PRT.ConditionWidget(trigger.startCondition, "conditionStartHeading")
        startConditionGroup:SetLayout("Flow")

        local removeStartConditionButton = PRT.Button("conditionRemoveStartCondition")
        removeStartConditionButton:SetCallback("OnClick",
            function()
                trigger.hasStartCondition = false
                trigger.startCondition = nil
                PRT.Core.ReselectCurrentValue()
            end)
            startConditionGroup:AddChild(removeStartConditionButton)
        container:AddChild(startConditionGroup)
    else
        local addStartConditionButton = PRT.Button("conditionAddStartCondition")  
        addStartConditionButton:SetCallback("OnClick",
            function()
                trigger.hasStartCondition = true
                trigger.startCondition = PRT.EmptyCondition()      
                PRT.Core.ReselectCurrentValue()
            end)
        container:AddChild(addStartConditionButton)        
    end
end

PRT.MaybeAddStopCondition = function(container, trigger)
    if trigger.hasStopCondition then
        local stopConditionGroup = PRT.ConditionWidget(trigger.stopCondition, "conditionStopHeading")
        stopConditionGroup:SetLayout("Flow")

        local removeStopConditionButton = PRT.Button("conditionRemoveStopCondition")
        removeStopConditionButton:SetCallback("OnClick",
            function()
                trigger.hasStopCondition = false
                trigger.stopCondition = nil
                PRT.Core.ReselectCurrentValue()
            end)
        stopConditionGroup:AddChild(removeStopConditionButton)
        container:AddChild(stopConditionGroup)
    else
        local addStopConditionButton = PRT.Button("conditionAddStopCondition")
        addStopConditionButton:SetCallback("OnClick",
            function()
                trigger.hasStopCondition = true
                trigger.stopCondition = PRT.EmptyCondition()      
                PRT.Core.ReselectCurrentValue()
            end)
        container:AddChild(addStopConditionButton)        
    end
end

PRT.NewTriggerDeleteButton = function(container, t, idx, textID, entityName)
    local deleteButton = PRT.Button(textID)
    deleteButton:SetHeight(40)
    deleteButton:SetRelativeWidth(1)
    deleteButton:SetCallback("OnClick", 
        function() 
            local text = L["deleteConfirmationText"]
            if entityName then
                text = text.." "..PRT.HighlightString(entityName)
            end
            PRT.ConfirmationDialog(text, 
                function()
                    tremove(t, idx) 
                    PRT.Core.UpdateTree()
                    PRT.mainWindowContent:DoLayout()
                    container:ReleaseChildren()
                end)            
        end)

    return deleteButton
end

PRT.NewCloneButton = function(container, t, idx, textID, entityName)
    local cloneButton = PRT.Button(textID)
    cloneButton:SetHeight(40)
    cloneButton:SetRelativeWidth(1)
    cloneButton:SetCallback("OnClick", 
        function() 
            local text = L["cloneConfirmationText"]
            if entityName then
                text = text.." "..PRT.HighlightString(entityName)
            end
            PRT.ConfirmationDialog(text, 
                function()
                    local clone = PRT.CopyTable(t[idx])
                    clone.name = clone.name.."- Clone"..random(0,100000)
                    tinsert(t, clone) 
                    PRT.Core.UpdateTree()
                    PRT.mainWindowContent:DoLayout()
                    container:ReleaseChildren()
                end)            
        end)

    return cloneButton
end

PRT.ConfirmationDialog = function(text, successFn, ...)
    if not PRT.Core.FrameExists(text) then
        local args = {...}
        local confirmationFrame = PRT.Window("confirmationWindow")
        confirmationFrame:SetLayout("Flow")
        confirmationFrame:SetHeight(130)
        




        confirmationFrame:EnableResize(false)
        confirmationFrame.frame:SetFrameStrata("DIALOG")   
        confirmationFrame:SetCallback("OnClose",
            function()
                confirmationFrame:Hide()
                PRT.Core.UnregisterFrame(text)
            end)

        local textLabel = PRT.Label(text)

        confirmationFrame:SetWidth(max(430, textLabel.label:GetStringWidth() + 50))           

        local okButton = PRT.Button("confirmationDialogOk")
        okButton:SetCallback("OnClick", 
            function(_)
                if successFn then
                    successFn(unpack(args))
                    confirmationFrame:Hide()
                    PRT.Core.UnregisterFrame(text)
                end
            end)
        
        local cancelButton = PRT.Button("confirmationDialogCancel")
        cancelButton:SetCallback("OnClick",
            function(_)
                confirmationFrame:Hide()
                PRT.Core.UnregisterFrame(text)
            end)

        local heading = PRT.Heading(nil)
        confirmationFrame:AddChild(textLabel)
        confirmationFrame:AddChild(heading)
        confirmationFrame:AddChild(okButton)
        confirmationFrame:AddChild(cancelButton)

        confirmationFrame:Show()
        PRT.Core.RegisterFrame(text, confirmationFrame)
    end
end

PRT.ClassColoredName = function(name)
    if name then
        local _, _, classIndex = UnitClass(string.gsub(name, "-.*", ""))
        local color = classColors[classIndex]
        local coloredName = name

        if color then
            coloredName = PRT.ColoredString(name, color)
        else
            coloredName = name
        end        
        return coloredName
    else
        return name
    end
end

PRT.UnitFullName = function(unitID)
    return GetUnitName(unitID, true)
end

PRT.PartyNames = function(withServer)
    local names = {}
    local unitString = ""
    local myName = UnitName("player")

    if withServer then
        myName = PRT.UnitFullName("player")
    end
    
    if UnitInRaid("player") then
        unitString = "raid%d"
    elseif UnitInParty("player") then
        unitString = "party%d"
    end

    for i = 1, GetNumGroupMembers() do
        local index = unitString:format(i)
        local playerName = UnitName(index)
        
        if withServer then
            playerName = PRT.UnitFullName(index)
        end

        if not (playerName == myName) then
            tinsert(names, playerName)
        end
    end

    -- Always add the own character into the list
    tinsert(names, myName)

    return names
end

PRT.UnitInParty = function(unit)
    if unit then
        return UnitInParty(unit) or UnitInRaid(unit)
    end
end

PRT.PlayerInParty = function()
    return PRT.UnitInParty("player")
end