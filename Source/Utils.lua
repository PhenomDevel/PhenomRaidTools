local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

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

function table.mergecopy(t1, t2)
    local t3 = {}
    for k,v in ipairs(t1) do
        table.insert(t3, v)
     end 
    for k,v in ipairs(t2) do
       table.insert(t3, v)
    end 
  
    return t3
end