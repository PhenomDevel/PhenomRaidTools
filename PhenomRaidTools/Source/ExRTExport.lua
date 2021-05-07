local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Local Helper

local ExRTCombatEventTranslations = {
  ["SPELL_CAST_SUCCESS"] = "SCC",
  ["SPELL_CAST_START"] = "SCS",
  ["SPELL_AURA_APPLIED"] = "SAA",
  ["SPELL_AURA_REMOVED"] = "SAR"
}

local function IsValidMessage(message)
  return (message.type == "cooldown")
end

local function SecondsToTimePrefix(seconds, startCondition)
  local timePrefixString

  timePrefixString = string.format("{time:%s", PRT.SecondsToClock(seconds))

  if startCondition then
    local translatedEvent = ExRTCombatEventTranslations[startCondition.event]

    if translatedEvent and startCondition.spellID then
      timePrefixString = timePrefixString..string.format(",%s:%s:0", translatedEvent, startCondition.spellID)
    else
      PRT.Debug(string.format("Could not translate start condition event %s to ExRT event. ExRT note timers might not work correctly.",
        PRT.HighlightString(startCondition.event)))
    end
  end

  timePrefixString = timePrefixString.."}>"

  return timePrefixString
end

local function CollectMessagesPerTiming(timer)
  local messagesPerTiming = {}

  for _, timing in ipairs(timer.timings) do
    for _, timeInSeconds in ipairs(timing.seconds) do
      if not messagesPerTiming[timeInSeconds] then
        messagesPerTiming[timeInSeconds] = {
          startCondition = timer.startCondition,
          messages = {}
        }
      end

      for _, message in ipairs(timing.messages) do
        if IsValidMessage(message) then
          tinsert(messagesPerTiming[timeInSeconds].messages, message)
        end
      end
    end
  end

  local sortedEntries = {}
  for timeInSeconds, entry in pairs(messagesPerTiming) do
    entry.time = timeInSeconds

    tinsert(sortedEntries, entry)
  end

  PRT.TableUtils.SortByKey(sortedEntries, "time")

  return sortedEntries
end

local function GenerateTimingContent(messages)
  local contents = {}

  for _, message in ipairs(messages) do
    local targetString = PRT.ReplacePlayerNameTokens(message.targets[1])
    local content = string.format("{spell:%s} %s", message.spellID, PRT.ClassColoredName(targetString))
    tinsert(contents, content)
  end

  return contents
end

local function GenerateTimingString(entry, includeEmptyLines)
  local timeInSeconds, startCondition, messages = entry.time, entry.startCondition, entry.messages
  local timingString
  local contents = GenerateTimingContent(messages)

  timingString = SecondsToTimePrefix(timeInSeconds, startCondition)

  local contentsString = strjoin(" ", unpack(contents))

  if not includeEmptyLines and PRT.TableUtils.Count(contents) == 0 then
    return nil
  end

  return timingString.." "..contentsString
end

local function MessagePerStringToExRTNote(messagesPerTiming, includeEmptyLines)
  local timingStrings = {}

  for _, entry in ipairs(messagesPerTiming) do
    local timingString = GenerateTimingString(entry, includeEmptyLines)
    if timingString then
      tinsert(timingStrings, timingString)
    end
  end

  return timingStrings
end


-------------------------------------------------------------------------------
-- Public API

function PRT.ExRTExportFromTimer(timer, includeEmptyLines)
  local localTimer = PRT.TableUtils.Clone(timer)
  local collectedMessagePerTiming = CollectMessagesPerTiming(localTimer)
  local timingStrings = MessagePerStringToExRTNote(collectedMessagePerTiming, includeEmptyLines)

  local title = PRT.ColoredString(timer.name, "FFffc526")
  local content = strjoin("\n", unpack(timingStrings))
  local finalString = string.gsub(string.format("%s\n%s", title, content), "|", "||")

  return finalString
end

function PRT.ExRTExportFromTimers(timers, includeEmptyLines)
  local strings = {}

  for _, timer in ipairs(timers) do
    tinsert(strings, PRT.ExRTExportFromTimer(timer, includeEmptyLines))
  end

  return strjoin("\n\n", unpack(strings))
end
