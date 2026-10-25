local _, PRT = ...

local StringUtils = {}
PRT.StringUtils = StringUtils

-------------------------------------------------------------------------------
-- String Utils

function StringUtils.IsEmpty(s)
  return (s == "" or s == nil)
end
