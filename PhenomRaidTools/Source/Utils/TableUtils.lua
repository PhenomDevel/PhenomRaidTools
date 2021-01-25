local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local TableUtils = {}
PRT.TableUtils = TableUtils


-------------------------------------------------------------------------------
-- String Utils

TableUtils.Tableify = function(x)
   if type(x) == "string" then
      return {x}
   elseif type(x) == "table" then
      return x
   end
end

TableUtils.Remove = function(t, pred)
   for i = #t, 1, -1 do
       if pred(t[i], i) then
           table.remove(t, i)
       end
   end
   
   return t
end

TableUtils.IsEmpty = function(t)
   if t then
       if table.getn(t) == 0 then
           return true
       end
   end

   return false
end