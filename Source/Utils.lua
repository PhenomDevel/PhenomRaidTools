local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

PRT.StringSplit = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        local trimmed, n = string.gsub(match, " ", "")
        table.insert(result, trimmed);
    end
    return result;
end

PRT.Texture = function(spellID, size)
    if spellID ~= nil then
        local _, _, spellTexture = GetSpellInfo(spellID)
        return "|T"..(spellTexture or "Interface\\Icons\\INV_MISC_QUESTIONMARK")..":"..(size or "18").."|t"
    end
end

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

PRT.TargetsToString = function(targets)
    if targets then
        local s = ""    
        for i, target in ipairs(targets) do
            s = s..target..","
        end	
        return s
    end    
end

PRT.StringToTargets = function(s)
    local targets = PRT.StringSplit(s, ",")

    return targets
end

PRT.TableToTabs = function(t, withNewTab, newTabText)
	local tabs = {}
	
	if t then
        for i, v in ipairs(t) do
            if v.name then
                table.insert(tabs, {value = i, text = v.name})
            else
                table.insert(tabs, {value = i, text = i})
            end
		end
	end
    if withNewTab then
		table.insert(tabs, {value = "new", text = (newTabText or "+")})
	end
 
	return tabs
 end

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
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

PRT.Error = function(...)
    PRT:Print("|c"..PRT.db.profile.colors.error, ...)
end

PRT.Debug = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("|c"..PRT.db.profile.colors.general, ...)
    end
end

PRT.DebugTimer = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("|c"..PRT.db.profile.colors.timers, "[Timer] - ", ...)
    end
end

PRT.DebugRotation = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("|c"..PRT.db.profile.colors.rotations, "[Rotation] - ", ...)
    end
end

PRT.DebugPercentage = function(...)
    if PRT.db.profile.debugMode then
        PRT:Print("|c"..PRT.db.profile.colors.percentages, "[Percentage] - ", ...)
    end
end

PRT.TableContains = function(table, value)
    for i, tableValue in pairs(table) do
        if tableValue == value then
            return true
        end
    end
    
    return false
end