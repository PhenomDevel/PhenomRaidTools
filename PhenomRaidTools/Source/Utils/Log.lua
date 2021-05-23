local _, PRT = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Debug Helper

function PRT.PrintTable(t, maxRecursionDepth, recursionDepth)
  recursionDepth = recursionDepth or 0
  maxRecursionDepth = maxRecursionDepth or 3
  recursionDepth = recursionDepth + 1

  local prefix = ""
  if recursionDepth > 1 then
    for _ = 1, recursionDepth do
      prefix = prefix .. " "
    end
    prefix = prefix .. "- "
  end

  if recursionDepth == 1 then
    print("-----------------")
    print("PrintTable: " .. PRT.HighlightString(tostring(t)))
  end

  if t and (recursionDepth <= maxRecursionDepth) then
    for k, v in pairs(t) do
      if type(v) == "table" then
        print(prefix .. "[" .. k .. "]")
        PRT.PrintTable(v, maxRecursionDepth, recursionDepth)
      else
        print(prefix .. "[" .. k .. "]" .. ": " .. PRT.HighlightString(tostring(v)))
      end
    end
  end
end

function PRT.Info(...)
  if PRT.GetProfileDB().enabled then
    addon:Print(PRT.ColoredString("[Info]", PRT.Static.Colors.Info), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.GetProfileDB().debugLog, {PRT.ColoredString("[Info]", PRT.Static.Colors.Info), ...})
    end
  end
end

function PRT.Warn(...)
  if PRT.GetProfileDB().enabled then
    addon:Print(PRT.ColoredString("[Warn]", PRT.Static.Colors.Warn), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.GetProfileDB().debugLog, {PRT.ColoredString("[Warn]", PRT.Static.Colors.Warn), ...})
    end
  end
end

function PRT.Error(...)
  if PRT.GetProfileDB().enabled then
    addon:Print(PRT.ColoredString("[Error]", PRT.Static.Colors.Error), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.GetProfileDB().debugLog, {PRT.ColoredString("[Error]", PRT.Static.Colors.Error), ...})
    end
  end
end

function PRT.Debug(...)
  if PRT.GetProfileDB().enabled then
    if PRT.GetProfileDB().debugMode then
      addon:Print(PRT.ColoredString("[Debug]", PRT.Static.Colors.Debug), ...)

      if PRT.currentEncounter and PRT.currentEncounter.inFight then
        tinsert(PRT.GetProfileDB().debugLog, {PRT.ColoredString("[Debug]", PRT.Static.Colors.Debug), ...})
      end
    end
  end
end
