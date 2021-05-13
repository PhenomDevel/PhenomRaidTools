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

local function GetLineTargets(entry)
  local targets = {}

  for _, message in ipairs(entry.messages) do
    local target = PRT.ReplacePlayerNameTokens(message.targets[1])
    tinsert(targets, target)
  end

  return PRT.TableUtils.Distinct(targets)
end

local function WrapPersonalization(contentString, targetString, options)
  local personalizedString = ""

  if options.withPersonalization then
    personalizedString = string.format("{p:%s}", targetString)
  end

  personalizedString = personalizedString..contentString

  if options.withPersonalization then
    personalizedString = personalizedString.."{/p}"
  end

  return personalizedString
end

local function SecondsToTimePrefix(entry, options)
  local timePrefixString

  timePrefixString = string.format("{time:%s", PRT.SecondsToClock(entry.time))

  if entry.startCondition then
    local translatedEvent = ExRTCombatEventTranslations[entry.startCondition.event]

    if translatedEvent and entry.startCondition.spellID then
      timePrefixString = timePrefixString..string.format(",%s:%s:%s", translatedEvent, entry.startCondition.spellID, entry.triggerAtOccurence or 0)
    else
      PRT.Debug(string.format("Could not translate start condition event %s to ExRT event. ExRT note timers might not work correctly.",
        PRT.HighlightString(entry.startCondition.event)))
    end
  end

  timePrefixString = timePrefixString.."}"

  if options.withTimingNames then
    timePrefixString = timePrefixString..string.format(" %s -> ", PRT.ColoredString(entry.name, PRT.Static.Colors.Tertiary))
  end

  return timePrefixString
end

local function GenerateTimingContent(messages, options)
  local contents = {}

  for _, message in ipairs(messages) do
    local targetString = PRT.ReplacePlayerNameTokens(message.targets[1])
    local content = string.format("{spell:%s} %s", message.spellID, PRT.ClassColoredName(targetString))

    local finalString = WrapPersonalization(content, targetString, options)

    tinsert(contents, finalString)
  end

  return contents
end

local function CollectMessagesPerTiming(timer)
  local messagesPerTiming = {}

  for _, timing in ipairs(timer.timings) do
    for _, timeInSeconds in ipairs(timing.seconds) do
      if not messagesPerTiming[timeInSeconds] then
        local newEntry = {
          name = timing.name,
          triggerAtOccurence = timer.triggerAtOccurence,
          startCondition = timer.startCondition,
          messages = {}
        }

        for _, message in ipairs(timing.messages) do
          if IsValidMessage(message) then
            tinsert(newEntry.messages, message)
          end
        end

        if PRT.TableUtils.Count(newEntry.messages) > 0 then
          messagesPerTiming[timeInSeconds] = newEntry
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

local function GenerateTimingString(entry, options)
  local contents = GenerateTimingContent(entry.messages, options)
  local timingString = SecondsToTimePrefix(entry, options)

  local contentsString = strjoin(" ", unpack(contents))

  if not options.withEmptyLines and PRT.TableUtils.Count(contents) == 0 then
    return nil
  end

  local finalString = "\n"..timingString.." "..contentsString
  local targetsString = strjoin(",", unpack(GetLineTargets(entry)))
  return WrapPersonalization(finalString, targetsString, options)
end

local function MessagePerStringToExRTNote(messagesPerTiming, options)
  local timingStrings = {}

  for _, entry in ipairs(messagesPerTiming) do
    local timingString = GenerateTimingString(entry, options)
    if timingString then
      tinsert(timingStrings, timingString)
    end
  end

  return timingStrings
end


-------------------------------------------------------------------------------
-- Public API

function PRT.ExRTExportFromTimer(options, timer)
  local localTimer = PRT.TableUtils.Clone(timer)
  local collectedMessagePerTiming = CollectMessagesPerTiming(localTimer)
  local timingStrings = MessagePerStringToExRTNote(collectedMessagePerTiming, options)

  PRT.TableUtils.Remove(timingStrings, PRT.StringUtils.IsEmpty)

  local title

  if options.withTimerNames then
    title = PRT.ColoredString(string.format("== %s ==", timer.name), PRT.Static.Colors.Secondary)
  end

  local content = strjoin("", unpack(timingStrings))
  local finalString = ""

  if not PRT.TableUtils.IsEmpty(timingStrings) then
    if title then
      if options.withPersonalization then
        finalString = string.format("%s\n\n%s", title or "", content)
      else
        finalString = string.format("%s\n%s", title or "", content)
      end
    else
      finalString = content
    end
  end

  return finalString
end

function PRT.ExRTExportFromTimers(options, timers, encounterName)
  local strings = {}
  local finalString
  local contentString

  for _, timer in ipairs(timers) do
    tinsert(strings, PRT.ExRTExportFromTimer(options, timer))
  end

  PRT.TableUtils.Remove(strings, PRT.StringUtils.IsEmpty)

  contentString = strjoin("\n\n", unpack(strings))

  if encounterName and options.withEncounterName then
    finalString = string.format("%s\n\n%s", encounterName, contentString)

  else
    finalString = contentString
  end

  return finalString
end
