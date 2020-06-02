local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

-------------------------------------------------------------------------------
-- Public API

-------------------------------------------------------------------------------
-- Misc

PRT.Round = function (num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
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
    if s ~= nil and s ~= "" then
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

PRT.Error = function(...)
    PRT:Print("[Error]|c"..PRT.db.profile.colors.error, ...)
end

PRT.Debug = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("[Debug]|c"..PRT.db.profile.colors.general, ...)
    end
end

PRT.DebugTimer = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("[Debug]|c"..PRT.db.profile.colors.timers, "[Timer] - ", ...)
    end
end

PRT.DebugRotation = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("[Debug]|c"..PRT.db.profile.colors.rotations, "[Rotation] - ", ...)
    end
end

PRT.DebugPercentage = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("[Debug]|c"..PRT.db.profile.colors.percentages, "[Percentage] - ", ...)
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

PRT.ExchangeRaidMarker = function(s)
    return string.gsub(s, "{rt([^}])}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%1:16:16:0:0:64:64:6:58:6:58|t")
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
    local playerName = token
    
    if token == "me" then
        playerName = UnitName("player")
    elseif PRT.db.profile.raidRoster[token] then
        playerName = PRT.db.profile.raidRoster[token]
    else
        playerName = "N/A"
    end

    return playerName
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