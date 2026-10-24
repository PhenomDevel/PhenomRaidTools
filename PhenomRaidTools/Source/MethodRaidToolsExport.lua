local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Local Helper

local MethodRaidToolsCombatEventTranslations = {
  ["SPELL_CAST_SUCCESS"] = "SCC",
  ["SPELL_CAST_START"] = "SCS",
  ["SPELL_AURA_APPLIED"] = "SAA",
  ["SPELL_AURA_REMOVED"] = "SAR"
}

-- MRT was called ExRT before; support both addon and SavedVariables names.
local function GetMethodRaidToolsNote()
  local db

  if C_AddOns.IsAddOnLoaded("MRT") then
    db = _G.VMRT
  elseif C_AddOns.IsAddOnLoaded("ExRT") then
    db = _G.VExRT
  end

  return db and db.Note
end

local function IsValidMessage(message)
  return (message.type == "cooldown")
end

local function GetDistinctTargets(inputTargets)
  local targets = {}

  for _, target in pairs(inputTargets) do
    local updatedTarget = PRT.ReplacePlayerNameTokens(target)

    if (target ~= PRT.Static.TargetNone) and (target ~= PRT.Static.TargetNoneNumber) then
      tinsert(targets, updatedTarget)
    end
  end

  return PRT.TableUtils.Distinct(targets)
end

local function getTriggerEntryTargets(entry)
  local targets = {}

  for _, message in ipairs(entry.messages) do
    for _, target in pairs(message.targets) do
      local updatedTarget = PRT.ReplacePlayerNameTokens(target)

      if (target ~= PRT.Static.TargetNone) and (target ~= PRT.Static.TargetNoneNumber) then
        tinsert(targets, updatedTarget)
      end
    end
  end

  return PRT.TableUtils.Distinct(targets)
end

local function WrapPersonalization(contentString, targetString, options)
  local personalizedString = ""

  if options.withPersonalization then
    if PRT.StringUtils.IsEmpty(targetString) then
      targetString = "N/A"
    end
    personalizedString = string.format("{p:%s}", targetString)
  end

  personalizedString = personalizedString .. contentString

  if options.withPersonalization then
    personalizedString = personalizedString .. "{/p}"
  end

  return personalizedString
end

local function SecondsToTimePrefix(entry, options)
  local timePrefixString

  timePrefixString = string.format("{time:%s", PRT.SecondsToClock(entry.time))

  if entry.startCondition then
    local translatedEvent = MethodRaidToolsCombatEventTranslations[entry.startCondition.event]

    if translatedEvent and entry.startCondition.spellID then
      timePrefixString = timePrefixString .. string.format(",%s:%s:%s", translatedEvent, entry.startCondition.spellID, entry.triggerAtOccurence or 0)
    else
      PRT.Debug(
        string.format(
          "Could not translate start condition event %s to MethodRaidTools event. MethodRaidTools note timers might not work correctly.",
          PRT.HighlightString(entry.startCondition.event)
        )
      )
    end
  end

  timePrefixString = timePrefixString .. "}"

  if options.withLinePrefix then
    timePrefixString = timePrefixString .. string.format(" %s -> ", PRT.ColoredString((entry.name or "N/A"), PRT.Static.Colors.Tertiary))
  end

  return timePrefixString
end

local function GenerateTimingContent(messages, options)
  local contents = {}

  for _, message in ipairs(messages) do
    local distinctTargets = GetDistinctTargets(message.targets)
    local coloredTargets = {}

    for k, target in pairs(distinctTargets) do
      coloredTargets[k] = PRT.ClassColoredName(target)
    end

    local targetStringColored = strjoin(", ", unpack(coloredTargets))
    local targetString = strjoin(",", unpack(distinctTargets))

    if targetStringColored and message.spellID then
      local content = string.format("{spell:%s} %s", message.spellID, targetStringColored)
      local finalString = WrapPersonalization(content, targetString, options)

      if not PRT.TableUtils.IsEmpty(distinctTargets) then
        tinsert(contents, finalString)
      end
    end
  end

  return contents
end

local function CollectMessagesPerTiming(timer)
  local messagesPerTiming = {}

  for _, timing in pairs(timer.timings) do
    for _, timeInSeconds in pairs(timing.seconds) do
      if not messagesPerTiming[timeInSeconds] then
        messagesPerTiming[timeInSeconds] = {
          name = timing.name,
          triggerAtOccurence = timer.triggerAtOccurence,
          startCondition = timer.startCondition,
          messages = {}
        }
      end

      for _, message in ipairs(timing.messages) do
        if IsValidMessage(message) then
          tinsert(messagesPerTiming[timeInSeconds].messages, message)
        end
      end

      if PRT.TableUtils.Count(messagesPerTiming[timeInSeconds].messages) > 0 then
        messagesPerTiming[timeInSeconds] = messagesPerTiming[timeInSeconds]
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

  local finalString = "\n" .. timingString .. " " .. contentsString
  local targetsString = strjoin(",", unpack(getTriggerEntryTargets(entry)))
  return WrapPersonalization(finalString, targetsString, options)
end

local function MessagePerStringToMethodRaidToolsNote(messagesPerTiming, options)
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

local function noteFromTimer(options, timer)
  local localTimer = PRT.TableUtils.Clone(timer)
  local collectedMessagePerTiming = CollectMessagesPerTiming(localTimer)
  local timingStrings = MessagePerStringToMethodRaidToolsNote(collectedMessagePerTiming, options)

  PRT.TableUtils.Remove(timingStrings, PRT.StringUtils.IsEmpty)

  local title

  if options.withTriggerNames then
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

local function noteFromTimers(options, timers)
  local strings = {}
  local contentString

  for _, timer in ipairs(timers) do
    if timer.enabled and options.selectedTimers[timer.name] then
      tinsert(strings, noteFromTimer(options, timer))
    end
  end

  PRT.TableUtils.Remove(strings, PRT.StringUtils.IsEmpty)

  contentString = strjoin("\n\n", unpack(strings))

  return string.gsub(contentString, "\n\n\n", "\n\n")
end

local function noteFromRotation(options, rotation)
  local rotationNote
  local rotationNoteEntries = {}

  if not PRT.TableUtils.IsEmpty(rotation.entries) then
    if options.withTriggerNames then
      local rotationTitle = PRT.ColoredString(string.format("== %s ==", rotation.name), PRT.Static.Colors.Secondary)
      rotationNote = rotationTitle .. "\n"
    end

    for entryIndex, entry in ipairs(rotation.entries) do
      local validMessages = {}

      for _, message in ipairs(entry.messages) do
        if IsValidMessage(message) then
          tinsert(validMessages, message)
        end
      end

      if (options.withEmptyLines and PRT.TableUtils.IsEmpty(validMessages)) or (not PRT.TableUtils.IsEmpty(validMessages)) then
        local entryNote = ""

        for _, message in ipairs(validMessages) do
          local distinctTargets = GetDistinctTargets(message.targets)
          entryNote = string.format("%s {spell:%s} %s", entryNote, message.spellID, strjoin(" ", unpack(distinctTargets)))
        end

        if options.withPersonalization then
          local entryTargets = getTriggerEntryTargets(entry)
          local targetString = strjoin(",", unpack(entryTargets))
          entryNote = WrapPersonalization(entryNote, targetString, options)
        end

        if not PRT.StringUtils.IsEmpty(entryNote) then
          rotationNoteEntries[entryIndex] = entryNote
        end
      end
    end
  else
    return nil
  end

  if not PRT.TableUtils.IsEmpty(rotationNoteEntries) then
    for idx, entryNote in pairs(rotationNoteEntries) do
      rotationNote = rotationNote .. string.format("<%s> %s\n", idx, entryNote)
    end

    if rotation.shouldRestart then
      rotationNote = rotationNote .. "Repeat\n"
    end
  else
    return nil
  end

  return rotationNote
end

local function noteFromRotations(options, rotations)
  local noteParts = {}

  if rotations then
    for _, rotation in ipairs(rotations) do
      if rotation.enabled and options.selectedRotations[rotation.name] then
        local part = noteFromRotation(options, rotation)

        if not PRT.StringUtils.IsEmpty(part) then
          tinsert(noteParts, part)
        end
      end
    end
  end
  return strjoin("\n", unpack(noteParts))
end

local function noteFromEncounter(options, encounter)
  local encounterVersion = encounter.versions[encounter.selectedVersion]

  local note = ""

  -- Maybe add encounter name
  if options.withEncounterName and encounter.name then
    note = PRT.ColoredString(encounter.name, PRT.Static.Colors.Primary)
  end

  -- Maybe add rotations
  if options.includeRotations then
    local rotationsNote = noteFromRotations(options, encounterVersion.Rotations)

    if not PRT.StringUtils.IsEmpty(rotationsNote) then
      note = note .. "\n" .. rotationsNote
    end
  end

  -- Maybe add timers
  if options.includeTimers then
    local timersNote = noteFromTimers(options, encounterVersion.Timers)

    if not PRT.StringUtils.IsEmpty(timersNote) then
      note = note .. "\n" .. timersNote
    end
  end

  return note
end

-- MRT reads the note from its saved variables; refresh its note frame if
-- the running version offers it. No slash command through the chat box: that
-- runs addon code as the player's chat input and taints the chat frame.
local function RefreshMethodRaidToolsNote()
  local mrt = _G.GMRT
  local note = mrt and mrt.A and mrt.A.Note
  if note and note.frame and type(note.frame.UpdateText) == "function" then
    pcall(note.frame.UpdateText, note.frame)
  end
end

local function InjectIntoTags(currentNote, export)
  local prtStart = currentNote and currentNote:find("{prtstart}", 1, true)
  local prtEnd = currentNote and currentNote:find("{prtend}", 1, true)
  if not (prtStart and prtEnd and prtStart < prtEnd) then
    return nil
  end
  return currentNote:sub(1, prtStart - 1) .. "{prtstart}" .. export .. "{prtend}" .. currentNote:sub(prtEnd + #"{prtend}")
end

-------------------------------------------------------------------------------
-- Public API

-- Note for the selected version of an encounter: cooldown messages of all
-- enabled timers and rotations. options: see profile.mrtExportDefaults.
function PRT.MethodRaidToolsNote(encounter, options)
  local version = encounter.versions[encounter.selectedVersion]
  if not version then
    return ""
  end
  local noteOptions = PRT.TableUtils.Clone(options)
  noteOptions.selectedTimers, noteOptions.selectedRotations = {}, {}
  for _, timer in ipairs(version.Timers or {}) do
    noteOptions.selectedTimers[timer.name] = true
  end
  for _, rotation in ipairs(version.Rotations or {}) do
    noteOptions.selectedRotations[rotation.name] = true
  end
  return (noteFromEncounter(noteOptions, encounter):gsub("|", "||"))
end

function PRT.HasMethodRaidTools()
  return GetMethodRaidToolsNote() ~= nil
end

-- Writes the note into MRT: between {prtstart} and {prtend} if onlyTagged,
-- otherwise replacing the whole note. Returns false if the tags are missing.
function PRT.WriteMethodRaidToolsNote(text, onlyTagged)
  local note = GetMethodRaidToolsNote()
  if not note then
    return false
  end
  if onlyTagged then
    local updated = InjectIntoTags(note.Text1, text)
    if not updated then
      PRT.Error(
        L["Couldn't find %s and %s in your MethodRaidTools note. Put both into the note first."]:format(PRT.HighlightString("{prtstart}"), PRT.HighlightString("{prtend}"))
      )
      return false
    end
    note.Text1 = updated
  else
    note.Text1 = text
  end
  RefreshMethodRaidToolsNote()
  return true
end
