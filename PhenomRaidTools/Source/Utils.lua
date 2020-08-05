local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

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

-------------------------------------------------------------------------------
-- Misc

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

PRT.Round = function (num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

PRT.CopyTable = function(orig, copies)    
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[PRT.CopyTable(orig_key, copies)] = PRT.CopyTable(orig_value, copies)
            end
            setmetatable(copy, PRT.CopyTable(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    return copy
end

PRT.SecondsToClock = function(seconds)
    local seconds = tonumber(seconds)
  
    if seconds <= 0 then
      return "00:00:00";
    else
      mins = string.format("%02.f", math.floor(seconds / 60));
      secs = string.format("%02.f", math.floor(seconds - mins * 60));
      return mins..":"..secs
    end
end


-------------------------------------------------------------------------------
-- Table Helper

PRT.TableToString = function(t)
    local serialized = AceSerializer:Serialize(t)
    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})

    return LibDeflate:EncodeForPrint(compressed)
end

PRT.StringToTable = function(s)
    if s and s ~= "" then
        local decoded = LibDeflate:DecodeForPrint(s)
        if decoded then
            local decompressed = LibDeflate:DecompressDeflate(decoded)

            if decompressed then
                local worked, t = AceSerializer:Deserialize(decompressed)
                
                return worked, t    
            else
                PRT.Error("String could not be decompressed. Aborting import.")
            end
        else
            PRT.Error("String could not be decoded. Aborting import.")
        end
    end

    return nil
end

table.mergemany = function(...)
    local tNew = {}

    for i, t in ipairs({...}) do
        for i, v in ipairs(t) do
            tinsert(tNew, v)
        end
    end

    return tNew
end

table.mergecopy = function(t1, t2)
    local t3 = {}

    for k,v in ipairs(t1) do
        tinsert(t3, v)
    end 

    for k,v in ipairs(t2) do
       tinsert(t3, v)
    end 
  
    return t3
end

table.empty = function(t)
    if t then
        if table.getn(t) == 0 then
            return true
        end
    end

    return false
end

PRT.FilterEncounterTable = function(encounters, id)
    local value
    if encounters then
        for i, v in ipairs(encounters) do
            if v.id == id then
                if not value then
                    return i, v
                end
            end
        end
    end
end

PRT.FilterTableByName = function(t, name)
    local value
    if t then
        for i, v in ipairs(t) do
            if v.name == name then
                if not value then                    
                    return i, v
                end
            end
        end
    end
end

PRT.FilterTableByID = function(t, id)
    local value
    if t then
        for i, v in ipairs(t) do
            if v.id == id then
                if not value then                    
                    return i, v
                end
            end
        end
    end
end

PRT.CompareByName = function(a, b)
    return a.name < b.name
end

PRT.SortTableByName = function(t)
    table.sort(t, PRT.CompareByName)
end


-------------------------------------------------------------------------------
-- Debug Helper

PRT.PrintTable = function(prefix, t)
    if t ~= nil then
        for k, v in pairs(t) do
            if type(v) == "table" then
                print(prefix.." ".."["..k.."]")
                PRT.PrintTable(prefix.."  ", v)
            else
                if v == true then
                    print(prefix.." ".."["..k.."]".." - ".."true")
                elseif v == false then
                    print(prefix.." ".."["..k.."]".." - ".."false")
                else
                    print(prefix.." ".."["..k.."]".." - "..v)
                end
            end
        end
    end
end

PRT.Info = function(...)
    if PRT.db.profile.enabled then
        PRT:Print(PRT.ColoredString("[Info]", PRT.db.profile.colors.info), ...)
    end
end

PRT.Warn = function(...)
    if PRT.db.profile.enabled then
        PRT:Print(PRT.ColoredString("[Warn]", PRT.db.profile.colors.warn), ...)
    end
end

PRT.Error = function(...)
    if PRT.db.profile.enabled then
        PRT:Print(PRT.ColoredString("[Error]", PRT.db.profile.colors.error), ...)
    end
end

PRT.Debug = function(...)
    if PRT.db.profile.enabled then
        if PRT.db.profile.debugMode then
            PRT:Print(PRT.ColoredString("[Debug]", PRT.db.profile.colors.debug), ...)
        end
    end
end


-------------------------------------------------------------------------------
-- Encounter Helper

PRT.EnsureEncounterTrigger = function(encounter)
	if encounter then
		if not encounter.Rotations then
			encounter.Rotations = {}
		end

		if not encounter.Timers then
			encounter.Timers = {}
		end

		if not encounter.HealthPercentages then
			encounter.HealthPercentages = {}
		end

		if not encounter.PowerPercentages then
			encounter.PowerPercentages = {}
		end
	end
end


-------------------------------------------------------------------------------
-- String Helper

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

PRT.ColoredString = function(s, color)
    return "|c"..(color or "FFFFFFFF")..s.."|r"
end

PRT.HighlightString = function(s)
    return PRT.ColoredString(s, PRT.db.profile.colors.highlight)
end

PRT.TextureString = function(id, size)
    if id then
        return "|T"..id..":"..(size or 16)..":"..(size or 16)..":0:0:64:64:6:58:6:58|t"
    end
end

PRT.ExchangeRaidMarker = function(s)
    return string.gsub(s, "{rt([^}])}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:16|t")
end

PRT.ExchangeSpellIcons = function(s)
    return string.gsub(s, "{spell:([^}]+)}", 
        function(match)
            local _, _, texture = GetSpellInfo(tonumber(match))
            return "|T"..(texture or "Interface\\Icons\\INV_MISC_QUESTIONMARK")..":16:16:0:0:64:64:6:58:6:58|t"
        end)
end

PRT.ReplaceToken = function(token)
    token = strtrim(token, " ")
    local playerName = "N/A"

    if token == "me" then
        playerName = UnitName("player")
    elseif PRT.db.profile.raidRoster[token] then
        playerName = PRT.db.profile.raidRoster[token]
    elseif PRT.db.profile.customNames then
        for i, customName in ipairs(PRT.db.profile.customNames) do
            if customName.placeholder == token then
                for nameIdx, name in ipairs(customName.names) do
                    if PRT.UnitInParty(name) or UnitExists(name) then
                        playerName = name
                        break
                    end
                end
            end
        end
    else
        playerName = "N/A"
    end

    return strtrim(playerName, " ")
end

PRT.ReplacePlayerNameTokens = function(s)
    return string.gsub(s, "[$]+([^$, ]*)", PRT.ReplaceToken)
end

PRT.PrepareMessageForDisplay = function(s)
    if s then
        return PRT.ReplacePlayerNameTokens(PRT.ExchangeSpellIcons(PRT.ExchangeRaidMarker(s:gsub("||", "|"))))
    else
        return ""
    end
end


-------------------------------------------------------------------------------
-- Unit Helper

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