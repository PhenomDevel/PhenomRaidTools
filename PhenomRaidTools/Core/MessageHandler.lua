local _, PRT = ...
local addon = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local AceComm = LibStub("AceComm-3.0")

local UnitName, GetUnitName, UnitGroupRolesAssigned = UnitName, GetUnitName, UnitGroupRolesAssigned
local GetRealmName = GetRealmName

local MessageHandler = {
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

-- Plans run on every player (PlanSync), so a message is only ever shown
-- here: addon messages to the group are blocked during encounters.
function MessageHandler.IsMessageForMe(message)
  return tContains(MessageHandler.validPlayerTargets, message.target) or message.target == UnitGroupRolesAssigned("player")
end

function MessageHandler.ExecuteMessage(message, pressAt)
  if not (PRT.IsReceiver() or PRT.Demo.IsRunning()) or not PRT.IsMessageSupported(message) then
    return
  end
  for _, target in ipairs(MessageHandler.ExpandMessageTargets(message)) do
    if MessageHandler.IsMessageForMe({target = target}) then
      local shown = PRT.TableUtils.Clone(message)
      shown.target = target
      shown.targets = nil
      shown.pressIn = pressAt and pressAt - GetTime()
      shown.message = PRT.ReplacePlayerNameTokens(shown.message)
      PRT.ReceiverOverlay.AddMessage(shown)
      return
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

-- pressAt: the time (GetTime) the message counts down to, when it shows early.
function PRT.ExecuteMessage(message, pressAt)
  if message then
    MessageHandler.ExecuteMessage(message, pressAt)
  end
end

-- Whether a message (one of its targets) is meant for this player; used to
-- preview the own assignments.
function PRT.IsMessageForMe(message)
  if not PRT.IsMessageSupported(message) or not message.targets then
    return false
  end
  for _, target in ipairs(MessageHandler.ExpandMessageTargets(message)) do
    if target == "ALL" or MessageHandler.IsMessageForMe({target = target}) then
      return true
    end
  end
  return false
end
