local _, PRT = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local AceComm = LibStub("AceComm-3.0")

local UnitName, GetUnitName, UnitExists, UnitGroupRolesAssigned = UnitName, GetUnitName, UnitExists, UnitGroupRolesAssigned
local UnitIsGroupAssistant, SendChatMessage, UnitIsGroupLeader = UnitIsGroupAssistant, SendChatMessage, UnitIsGroupLeader
local GetRealmName, GetRaidTargetIndex, SetRaidTarget = GetRealmName, GetRaidTargetIndex, SetRaidTarget
local IsEncounterInProgress = IsEncounterInProgress

local MessageHandler = {
  validTargets = {
    "ALL",
    "DAMAGER",
    "HEALER",
    "TANK",
    UnitName("player"),
    GetUnitName("player", true)
  },
  validPlayerTargets = {
    "ALL",
    UnitName("player"),
    GetUnitName("player", true),
    UnitName("player") .. "-" .. GetRealmName()
  }
}

-------------------------------------------------------------------------------
-- Local Helper

function MessageHandler.ExpandMessageTargets(message)
  local splittetTargets = {}

  for _, v in pairs(message.targets) do
    if v == "$target" then
      -- Set event target as message target
      tinsert(splittetTargets, {message.eventTarget})
    else
      local names = PRT.ReplacePlayerNameTokens(v)
      -- Try to replace placeholder tokens otherwise
      tinsert(splittetTargets, {strsplit(",", names)})
    end
  end

  local targets = PRT.TableUtils.MergeMany(unpack(splittetTargets))
  local existingTarget = {}
  local distinctTargets = {}

  for _, target in pairs(targets) do
    local trimmedTarget = strtrim(target, " ")
    if (not existingTarget[trimmedTarget]) then
      table.insert(distinctTargets, trimmedTarget)
      existingTarget[trimmedTarget] = true
    end
  end

  return distinctTargets
end

local function ExecuteRaidWarning(message)
  local msg = PRT.ReplacePlayerNameTokens(message.message)

  PRT.Debug("Sending raid warning", PRT.HighlightString(msg))

  if PRT.IsTestMode() then
    SendChatMessage(msg, "WHISPER", nil, PRT.GetProfileDB().myName)
  elseif UnitInRaid("player") and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then
    SendChatMessage(msg, "RAID_WARNING")
  end
end

local function ExecuteRaidTarget(message)
  if message.targets and message.targets[1] then
    local target = PRT.ReplacePlayerNameTokens(message.targets[1])

    if target == "$target" then
      target = message.eventTarget
    end

    if PRT.IsTestMode() then
      target = "player"
      PRT.Debug("Overwriting target raidtarget action to", PRT.HighlightString("player"), "due to test mode")
    end

    if PRT.IsTestMode() or (UnitInRaid(target) and UnitExists(target)) then
      local raidTargetName = "N/A"
      if message.raidtarget then
        if message.raidtarget ~= PRT.Static.TargetNoneNumber then
          raidTargetName = PRT.Static.Tables.RaidTargets[message.raidtarget].name
        end
      end

      if GetRaidTargetIndex(target) ~= message.raidtarget then
        -- If no raid target is selected we unselect the existing one
        local targetIndex = message.raidtarget
        if message.raidtarget == PRT.Static.TargetNoneNumber then
          message.raidtarget = nil
        end

        PRT.Debug("Setting raid target", raidTargetName, "for unit", PRT.HighlightString(target))
        SetRaidTarget(target, targetIndex)
      else
        PRT.Debug("Skipped setting raid target", raidTargetName, "because unit already has this raid target")
      end
    end
  end
end

local function ExecuteMessage(message)
  local messageTargets = MessageHandler.ExpandMessageTargets(message)

  for _, target in ipairs(messageTargets) do
    local targetMessage = PRT.TableUtils.Clone(message)
    targetMessage.target = target
    targetMessage.message = PRT.ReplacePlayerNameTokens(targetMessage.message)

    -- Cleanup unused fields
    targetMessage.targets = nil

    PRT.Debug("Try sending new message to", PRT.ClassColoredName(targetMessage.target))
    if UnitExists(targetMessage.target) or tContains(MessageHandler.validTargets, targetMessage.target) then
      targetMessage.sender = PRT.GetProfileDB().myName

      local serializedMessage = PRT.Serialize(targetMessage)

      -- If in test mode send the message through the whipser channel in case we are not in a group
      if not PRT.PlayerInParty() then
        AceComm:SendCommMessage(PRT.GetProfileDB().addonPrefixes.addonMessage, serializedMessage, "WHISPER", PRT.GetProfileDB().myName)
      end

      AceComm:SendCommMessage(PRT.GetProfileDB().addonPrefixes.addonMessage, serializedMessage, "RAID")
      PRT.Debug("Send message to", PRT.ClassColoredName(targetMessage.target), "with content", PRT.HighlightString(targetMessage.message))
    else
      -- Don't spam chat if a configured user is not in the raid. We expect those to happen sometimes
      if targetMessage.target ~= "N/A" then
        PRT.Debug("Target", PRT.HighlightString(targetMessage.target), "does not exist. Skipping message.")
      end
    end
  end
end

function MessageHandler.ExecuteMessageAction(message)
  if message.type == "raidwarning" then
    ExecuteRaidWarning(message)
  elseif message.type == "raidtarget" then
    ExecuteRaidTarget(message)
  else
    ExecuteMessage(message)
  end
end

function MessageHandler.IsValidSender(message)
  -- Filter received messages by configured message filter
  if PRT.GetProfileDB().messageFilter.filterBy == "names" then
    return (tContains(PRT.GetProfileDB().messageFilter.requiredNames, message.sender) or tContains(PRT.GetProfileDB().messageFilter.requiredNames, "$me") or
      PRT.GetProfileDB().messageFilter.requiredNames == nil or
      PRT.GetProfileDB().messageFilter.requiredNames == {} or
      PRT.TableUtils.IsEmpty(PRT.GetProfileDB().messageFilter.requiredNames) or
      (PRT.GetProfileDB().messageFilter.alwaysIncludeMyself and message.sender == select(1, UnitName("player"))))
  elseif PRT.GetProfileDB().messageFilter.filterBy == "guildRank" then
    local senderGuildRankIndex = select(3, GetGuildInfo(message.sender))

    return (senderGuildRankIndex <= PRT.GetProfileDB().messageFilter.requiredGuildRank)
  end

  return false
end

function MessageHandler.IsMessageForMe(message)
  -- Check if the message is relevant for myself by message targets
  if tContains(MessageHandler.validPlayerTargets, message.target) or message.target == UnitGroupRolesAssigned("player") then
    return true
  else
    return false
  end
end

function addon:OnAddonMessage(message)
  if PRT.IsEnabled() then
    if PRT.EncounterInProgress() or IsEncounterInProgress() or PRT.IsTestMode() or PRT.IsInFight() then
      if PRT.IsReceiver() then
        local _, messageTable = PRT.Deserialize(message)

        if MessageHandler.IsValidSender(messageTable) then
          if MessageHandler.IsMessageForMe(messageTable) then
            PRT.Debug("Received message from", PRT.ClassColoredName(messageTable.sender))
            PRT.ReceiverOverlay.AddMessage(messageTable)
          else
            PRT.Debug("Received a message from", PRT.ClassColoredName(messageTable.sender), "but it was not ment for you. Ignoring message.")
          end
        end
      end
    end
  end
end

function addon:OnVersionRequest(message)
  if PRT.IsEnabled() then
    local _, messageTable = PRT.Deserialize(message)

    if messageTable.requestor then
      PRT.Debug("Version request from:", messageTable.requestor)

      local response = {
        type = "response",
        name = PRT.UnitFullName("player"),
        version = PRT.GetProfileDB().version,
        enabled = PRT.GetProfileDB().enabled
      }

      AceComm:SendCommMessage(PRT.GetProfileDB().addonPrefixes.versionResponse, PRT.Serialize(response), "RAID")
    end
  end
end

function addon:OnVersionResponse(message)
  if PRT.IsEnabled() then
    local _, messageTable = PRT.Deserialize(message)
    PRT.Debug(
      string.format(
        "Version response from %s with version %s (Addon Status: %s)",
        PRT.ClassColoredName(messageTable.name),
        PRT.HighlightString(messageTable.version),
        PRT.HighlightString(messageTable.enabled)
      )
    )
    tinsert(PRT.GetProfileDB().versionCheck, messageTable)
  end
end

function addon:OnSyncRequest(_)
  -- daten auspacken
  -- abfrage, ob benutzer syncen will
  -- encounter, placeholder, overlays, raid roster
end

function addon:OnSyncResponse(_)
  -- Rückmeldung an den Benutzer
end

-------------------------------------------------------------------------------
-- Public API

function PRT.ExecuteMessage(message)
  if message then
    MessageHandler.ExecuteMessageAction(message)
  end
end
