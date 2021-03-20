local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Debug Helper

function PRT.PrintTable(t, maxRecursionDepth, recursionDepth)
  local recursionDepth = recursionDepth or 0
  local maxRecursionDepth = maxRecursionDepth or 3
  recursionDepth = recursionDepth + 1

  local prefix = ""
  if recursionDepth > 1 then
    for _ = 1, recursionDepth do
      prefix = prefix.." "
    end
    prefix = prefix.."- "
  end

  if recursionDepth == 1 then
    print("-----------------")
    print("PrintTable: "..PRT.HighlightString(tostring(t)))
  end

  if t and (recursionDepth <= maxRecursionDepth) then
    for k, v in pairs(t) do
      if type(v) == "table" then
        print(prefix.."["..k.."]")
        PRT.PrintTable(v, maxRecursionDepth, recursionDepth)
      else
        print(prefix.."["..k.."]"..": "..PRT.HighlightString(tostring(v)))
      end
    end
  end
end

function PRT.Info(...)
  if PRT.db.profile.enabled then
    PRT:Print(PRT.ColoredString("[Info]", PRT.db.profile.colors.info), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Info]", PRT.db.profile.colors.info), ...})
    end
  end
end

function PRT.Warn(...)
  if PRT.db.profile.enabled then
    PRT:Print(PRT.ColoredString("[Warn]", PRT.db.profile.colors.warn), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Warn]", PRT.db.profile.colors.warn), ...})
    end
  end
end

function PRT.Error(...)
  if PRT.db.profile.enabled then
    PRT:Print(PRT.ColoredString("[Error]", PRT.db.profile.colors.error), ...)

    if PRT.currentEncounter and PRT.currentEncounter.inFight then
      tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Error]", PRT.db.profile.colors.error), ...})
    end
  end
end

function PRT.Debug(...)
  if PRT.db.profile.enabled then
    if PRT.db.profile.debugMode then
      PRT:Print(PRT.ColoredString("[Debug]", PRT.db.profile.colors.debug), ...)

      if PRT.currentEncounter and PRT.currentEncounter.inFight then
        tinsert(PRT.db.profile.debugLog, {PRT.ColoredString("[Debug]", PRT.db.profile.colors.debug), ...})
      end
    end
  end
end
