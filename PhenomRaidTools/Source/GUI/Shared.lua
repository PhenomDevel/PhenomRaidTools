local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

PRT.NewTriggerDeleteButton = function(container, t, idx, textID)
    local deleteButton = PRT.Button(textID)
    deleteButton:SetHeight(40)
    deleteButton:SetRelativeWidth(1)
    deleteButton:SetCallback("OnClick", 
        function() 
            tremove(t, idx) 
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            container:ReleaseChildren()
        end)

    return deleteButton
end

PRT.ClassColoredName = function(name)
    if name then
        local _, _, classIndex = UnitClass(name)
        local color = PRT.db.profile.colors.classes[classIndex]
        local coloredName = name

        if color then
            coloredName = "|cFF"..color..name.."|r"
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
        local playerName = GetUnitName(index)

        if not (playerName == GetUnitName("player")) then
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