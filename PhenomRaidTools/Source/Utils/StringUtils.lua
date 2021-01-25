local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local StringUtils = {}
PRT.StringUtils = StringUtils


-------------------------------------------------------------------------------
-- String Utils

StringUtils.IsEmpty = function(s)
   return (s == "" or s == nil)
end

StringUtils.SplitToTable = function(s)
   local entries = {}
   if s ~= "" then
      local split1 = {strsplit(" ", s)}
      local split2 = {strsplit(",", strjoin(",", unpack(split1)))}

      entries = PRT.TableUtils.Remove(split2, StringUtils.IsEmpty)		
   end

   return entries
end