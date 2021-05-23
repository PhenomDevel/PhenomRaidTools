local _, PRT = ...

local StringUtils = {}
PRT.StringUtils = StringUtils

-------------------------------------------------------------------------------
-- String Utils

function StringUtils.IsEmpty(s)
  return (s == "" or s == nil)
end

function StringUtils.SplitToTable(s)
  local entries = {}
  if s ~= "" then
    local split1 = {strsplit(" ", s)}
    local split2 = {strsplit(",", strjoin(",", unpack(split1)))}

    entries = PRT.TableUtils.Remove(split2, StringUtils.IsEmpty)
  end

  return entries
end

function StringUtils.WrapColorByBoolean(s, boolean, inactiveColor, activeColor)
  if boolean then
    if activeColor then
      return "|c" .. activeColor .. s .. "|r"
    else
      return s
    end
  else
    if inactiveColor then
      return "|c" .. inactiveColor .. s .. "|r"
    else
      return s
    end
  end
end
