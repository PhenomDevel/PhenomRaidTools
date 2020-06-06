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

PRT.ConfirmationDialog = function(text, successFn, ...)
    local args = ...
    local confirmationFrame = PRT.Window("confirmationWindow")
    confirmationFrame:SetLayout("Flow")
    confirmationFrame:SetHeight(130)
    confirmationFrame:SetWidth(430)
    confirmationFrame:EnableResize(false)
    confirmationFrame.frame:SetFrameStrata("DIALOG")   

    local textLabel = PRT.Label(text)

    local okButton = PRT.Button("confirmationDialogOk")
    okButton:SetHeight(30) 
    okButton:SetCallback("OnClick", 
        function(_)
            if successFn then
                successFn(args)
                confirmationFrame:Hide()
            end
        end)
    
    local cancelButton = PRT.Button("confirmationDialogCancel")
    cancelButton:SetHeight(30)  
    cancelButton:SetCallback("OnClick",
        function(_)
            confirmationFrame:Hide()
        end)

    local heading = PRT.Heading(nil)
    confirmationFrame:AddChild(textLabel)
    confirmationFrame:AddChild(heading)
    confirmationFrame:AddChild(okButton)
    confirmationFrame:AddChild(cancelButton)

    confirmationFrame:Show()
    PRT.Core.RegisterFrame(confirmationFrame)
end

PRT.ClassColoredName = function(name)
    if name then
        local _, _, classIndex = UnitClass(name)
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

PRT.PartyNames = function()
    local names = {}
    local unitString = ""

    if UnitInRaid("player") then
        unitString = "raid%d"
    elseif UnitInParty("player") then
        unitString = "party%d"
    end

    for i = 1, GetNumGroupMembers() do
        local index = unitString:format(i)
        local playerName = UnitName(index)

        if not (playerName == UnitName("player")) then
            tinsert(names, playerName)
        end
    end

    -- Always add the own character into the list
    tinsert(names, GetUnitName("player"))

    return names
end

PRT.ColoredPartyNames = function()
    local names = PRT.PartyNames()
    local coloredNames = {}

    for i, name in ipairs(names) do
        local coloredName = PRT.ClassColoredName(name)
        tinsert(coloredNames, coloredName)
    end

    return coloredNames
end

PRT.ColoredPartyOrRaidNames = function()
    local names = PRT.PartyNames()
    local coloredNames = {}
    for i, name in ipairs(names) do
        local coloredName = PRT.ClassColoredName(name)

        tinsert(coloredNames, coloredName)
    end

    return coloredNames
end

PRT.PlayerInParty = function()
    return UnitInParty("player") or UnitInRaid("player")
end