local _, PRT = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local AceComm = LibStub("AceComm-3.0")

local UnitName, GetUnitName, UnitExists, UnitGroupRolesAssigned = UnitName, GetUnitName, UnitExists, UnitGroupRolesAssigned
local UnitIsGroupAssistant, UnitIsGroupLeader = UnitIsGroupAssistant, UnitIsGroupLeader
local GetRealmName, GetRaidTargetIndex, SetRaidTarget = GetRealmName, GetRaidTargetIndex, SetRaidTarget

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
    local names = PRT.ReplacePlayerNameTokens(v)
    tinsert(splittetTargets, {strsplit(",", names)})
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

  if PRT.IsBlizzardEncounterInProgress() then
    PRT.Debug("Chat messages to other players are blocked during encounters. Skipping raid warning.")
  elseif PRT.IsTestMode() then
    PRT.SendChatMessage(msg, "WHISPER", nil, PRT.GetProfileDB().myName)
  elseif UnitInRaid("player") and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then
    PRT.SendChatMessage(msg, "RAID_WARNING")
  end
end

local function ExecuteRaidTarget(message)
  if message.targets and message.targets[1] then
    local target = PRT.ReplacePlayerNameTokens(message.targets[1])

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

      -- Raid markers may be secret during encounters; comparing one errors.
      local current = GetRaidTargetIndex(target)
      if issecretvalue and issecretvalue(current) then
        current = nil
      end

      if current == nil or current ~= message.raidtarget then
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

-- A plan received from the raid lead runs on every player: only the lead's
-- own run may act for the group (raid warnings, markers, messages to others).
local function IsRunningReceivedPlan()
  return PRT.currentEncounter ~= nil and PRT.currentEncounter.received == true
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

      -- Our own messages never go through the addon channel: it is blocked during encounters.
      if MessageHandler.IsMessageForMe(targetMessage) then
        MessageHandler.ShowMessage(targetMessage)
      end

      local onlyForMe = targetMessage.target ~= "ALL" and tContains(MessageHandler.validPlayerTargets, targetMessage.target)

      if not onlyForMe and PRT.PlayerInParty() and not IsRunningReceivedPlan() then
        if PRT.IsBlizzardEncounterInProgress() then
          if PRT.currentEncounter and not PRT.currentEncounter.loggedCommLockdown then
            PRT.Debug("Addon messages are blocked during encounters. Messages for other players are skipped.")
            PRT.currentEncounter.loggedCommLockdown = true
          end
        else
          AceComm:SendCommMessage(PRT.GetProfileDB().addonPrefixes.addonMessage, PRT.Serialize(targetMessage), "RAID")
          PRT.Debug("Send message to", PRT.ClassColoredName(targetMessage.target), "with content", PRT.HighlightString(targetMessage.message))
        end
      end
    else
      -- Don't spam chat if a configured user is not in the raid. We expect those to happen sometimes
      if targetMessage.target ~= "N/A" then
        PRT.Debug("Target", PRT.HighlightString(targetMessage.target), "does not exist. Skipping message.")
      end
    end
  end
end

function MessageHandler.ExecuteMessageAction(message)
  if IsRunningReceivedPlan() and (message.type == "raidwarning" or message.type == "raidtarget") then
    return
  end
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
    local requiredGuildRank = PRT.GetProfileDB().messageFilter.requiredGuildRank

    -- GetGuildInfo counts ranks from 0, the chosen rank (rank names) from 1.
    -- Not in the guild or no rank chosen yet: nothing to compare.
    return senderGuildRankIndex ~= nil and requiredGuildRank ~= nil and senderGuildRankIndex + 1 <= requiredGuildRank
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

function MessageHandler.ShowMessage(message)
  if PRT.IsReceiver() then
    PRT.ReceiverOverlay.AddMessage(message)
  end
end

function addon:OnAddonMessage(message)
  if PRT.IsEnabled() then
    if PRT.EncounterInProgress() or PRT.IsBlizzardEncounterInProgress() or PRT.IsTestMode() or PRT.IsInFight() then
      if PRT.IsReceiver() then
        local ok, messageTable = PRT.Deserialize(message)
        if not ok or type(messageTable) ~= "table" then
          return
        end

        -- Already shown locally when it was sent
        if messageTable.sender == PRT.GetProfileDB().myName then
          return
        end

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
    local ok, messageTable = PRT.Deserialize(message)

    if ok and type(messageTable) == "table" and messageTable.requestor then
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
    local ok, messageTable = PRT.Deserialize(message)
    if not ok or type(messageTable) ~= "table" then
      return
    end
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

-------------------------------------------------------------------------------
-- Public API

function PRT.ExecuteMessage(message)
  if message then
    MessageHandler.ExecuteMessageAction(message)
  end
end

-- Whether a message (one of its targets) is meant for this player; used to
-- preview the own assignments.
function PRT.IsMessageForMe(message)
  if message.type == "raidwarning" or message.type == "raidtarget" or not message.targets then
    return false
  end
  for _, target in ipairs(MessageHandler.ExpandMessageTargets(message)) do
    if target == "ALL" or MessageHandler.IsMessageForMe({target = target}) then
      return true
    end
  end
  return false
end

-- Shows a message on this client only (editor preview, overlay test).
function PRT.ShowTestMessage(message)
  local preview = PRT.TableUtils.Clone(message)
  preview.target = PRT.GetProfileDB().myName
  preview.targets = nil
  preview.message = PRT.ReplacePlayerNameTokens(preview.message or "")
  PRT.ReceiverOverlay.AddMessage(preview)
end
