local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceComm = LibStub("AceComm-3.0")

local UnitName, GetUnitName, UnitExists, UnitGroupRolesAssigned, UnitAffectingCombat = UnitName, GetUnitName, UnitExists, UnitGroupRolesAssigned, UnitAffectingCombat
local UnitIsGroupAssistant, SendChatMessage, UnitIsGroupLeader = UnitIsGroupAssistant, SendChatMessage, UnitIsGroupLeader
local GetRealmName, GetRaidTargetIndex, SetRaidTarget = GetRealmName, GetRaidTargetIndex, SetRaidTarget
local IsEncounterInProgress =IsEncounterInProgress

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
    UnitName("player").."-"..GetRealmName()
  }
}


-------------------------------------------------------------------------------
-- Local Helper

function MessageHandler.ExpandMessageTargets(message)
  local splittetTargets = {}

  for _, v in ipairs(message.targets) do
    if v == "$target" then
      -- Set event target as message target
      tinsert(splittetTargets, { message.eventTarget })
    else
      local names = PRT.ReplacePlayerNameTokens(v)
      -- Try to replace placeholder tokens otherwise
      tinsert(splittetTargets, { strsplit(",", names) })
    end
  end

  local targets = table.mergemany(unpack(splittetTargets))
  local existingTarget = {}
  local distinctTargets = {}

  for _, target in ipairs(targets) do
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
    SendChatMessage(msg, "WHISPER", nil, PRT.db.profile.myName)
  elseif UnitInRaid("player") and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then
    SendChatMessage(msg, "RAID_WARNING")
  end
end

local function ExecuteRaidTarget(message)
  if message.targets and message.targets[1] then
    local target = message.targets[1]

    if target == "$target" then
      target = message.eventTarget
    end

    local raidTargetName = "N/A"

    if message.raidtarget then
      raidTargetName = PRT.Static.Tables.RaidTargets[message.raidtarget].name
    end

    if PRT.IsTestMode() then
      target = "player"
      PRT.Debug("Overwriting target raidtarget action to", PRT.HighlightString("player"), "due to test mode")
    end

    if PRT.IsTestMode() or (UnitInRaid(target) and UnitExists(target)) then
      if not (GetRaidTargetIndex(target) == message.raidtarget) then
        PRT.Debug("Setting raid target", raidTargetName, "for unit", PRT.HighlightString(target))
        SetRaidTarget(target, message.raidtarget)
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
      targetMessage.sender = PRT.db.profile.myName

      local serializedMessage = PRT.Serialize(targetMessage)

      -- If in test mode send the message through the whipser channel in case we are not in a group
      if not PRT.PlayerInParty() then
        AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.addonMessage, serializedMessage, "WHISPER", PRT.db.profile.myName)
      end

      AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.addonMessage, serializedMessage, "RAID")
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
  if PRT.db.profile.messageFilter.filterBy == "names" then
    return (tContains(PRT.db.profile.messageFilter.requiredNames, message.sender) or
      tContains(PRT.db.profile.messageFilter.requiredNames, "$me") or
      PRT.db.profile.messageFilter.requiredNames == nil or
      PRT.db.profile.messageFilter.requiredNames == {} or
      PRT.TableUtils.IsEmpty(PRT.db.profile.messageFilter.requiredNames) or
      (PRT.db.profile.messageFilter.alwaysIncludeMyself and
      message.sender == select(1, UnitName("player"))))

  elseif PRT.db.profile.messageFilter.filterBy == "guildRank" then
    local senderGuildRankIndex = select(3, GetGuildInfo(message.sender))

    return (senderGuildRankIndex <= PRT.db.profile.messageFilter.requiredGuildRank)
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

function PRT:OnAddonMessage(message)
  if PRT.IsEnabled() then
    if PRT.IsInFight() or IsEncounterInProgress() or PRT.IsTestMode() then
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

function PRT:OnVersionRequest(message)
  if PRT.IsEnabled() then
    local _, messageTable = PRT.Deserialize(message)

    if messageTable.requestor then
      PRT.Debug("Version request from:", messageTable.requestor)

      local response = {
        type = "response",
        name = PRT.UnitFullName("player"),
        version = PRT.db.profile.version,
        enabled = PRT.db.profile.enabled
      }

      AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.versionResponse, PRT.Serialize(response), "RAID")
    end
  end
end

function PRT:OnVersionResponse(message)
  if PRT.IsEnabled() then
    local _, messageTable = PRT.Deserialize(message)
    PRT.Debug(string.format("Version response from %s with version %s (Addon Status: %s)",PRT.ClassColoredName(messageTable.name), PRT.HighlightString(messageTable.version), PRT.HighlightString(messageTable.enabled)))
    tinsert(PRT.db.profile.versionCheck, messageTable)
  end
end

function PRT:OnSyncRequest(_)
-- daten auspacken
-- abfrage, ob benutzer syncen will
-- encounter, placeholder, overlays, raid roster
end

function PRT:OnSyncResponse(_)
-- Rückmeldung an den Benutzer
end

-------------------------------------------------------------------------------
-- Public API

function PRT.ExecuteMessage(message)
  if message then
    MessageHandler.ExecuteMessageAction(message)
  end
end
