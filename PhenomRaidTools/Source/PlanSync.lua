-- luacheck: read globals IsInGroup IsInRaid
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

--[[
  Plan distribution. Since Midnight addon messages are blocked during
  encounters, the raid lead sends the plans before the pull (ready check or
  /prt sync) and every player runs them locally (EventHandler).

  Lead -> group:  { type = "plan", encounterID, name, hash, plan }, one
                  message per enabled encounter whose plan changed or isn't
                  confirmed by everyone yet.
  Player -> lead: { type = "ack", encounterID, hash } (whisper)

  Plans are accepted only from the group leader or an assistant and stored
  per encounter in the global DB (receivedPlans).
]]

local PlanSync = {}
PRT.PlanSync = PlanSync

local PREFIX = "PRT_PLAN"
local PROTOCOL = 1

local TRIGGER_TYPES = {
  Timers = "timer",
  Rotations = "rotation",
  HealthPercentages = "healthPercentage",
  PowerPercentages = "powerPercentage"
}

-- encounterID -> { hash, sentAt, acks = { [name] = hash } }; this session only.
local sent = {}

local function ReceivedPlans()
  local global = PRT.GetGlobalDB()
  global.receivedPlans = global.receivedPlans or {}
  return global.receivedPlans
end

-- The selected version without triggers that can't run anyway; the lead's
-- global placeholders are added to the encounter's own (those win).
local function BuildPlan(encounterVersion)
  local plan = PRT.TableUtils.Clone(encounterVersion)
  for key, triggerType in pairs(TRIGGER_TYPES) do
    local kept = {}
    for _, trigger in ipairs(plan[key] or {}) do
      if trigger.enabled ~= false and not PRT.GetUnsupportedReason(triggerType, trigger) then
        kept[#kept + 1] = trigger
      end
    end
    plan[key] = kept
  end
  plan.CustomPlaceholders = plan.CustomPlaceholders or {}
  for name, placeholder in pairs(PRT.GetProfileDB().customPlaceholders or {}) do
    if plan.CustomPlaceholders[name] == nil then
      plan.CustomPlaceholders[name] = PRT.TableUtils.Clone(placeholder)
    end
  end
  return plan
end

local function PlanHash(plan)
  return LibDeflate:Adler32(AceSerializer:Serialize(plan))
end

local function GroupChannel()
  if IsInRaid() then
    return "RAID"
  elseif IsInGroup() then
    return "PARTY"
  end
end

local function IsGroupLead(name)
  return UnitIsGroupLeader(name) or UnitIsGroupAssistant(name)
end

local function Send(message, channel, target)
  AceComm:SendCommMessage(PREFIX, PRT.Serialize(message), channel, target, "BULK")
end

-- The other group members, with realm.
local function Members()
  local members = {}
  for _, name in ipairs(PRT.PartyNames(true)) do
    if name ~= PRT.UnitFullName("player") then
      members[#members + 1] = name
    end
  end
  return members
end

-- Everyone in the group (except us) confirmed this hash.
local function AllConfirmed(state)
  for _, name in ipairs(Members()) do
    if state.acks[name] ~= state.hash then
      return false
    end
  end
  return true
end

-- The overview page reflects new plans and confirmations right away.
local function RefreshOverview()
  if PRT.UI then
    PRT.UI.RefreshPage("overview")
  end
end

-------------------------------------------------------------------------------
-- Lead

-- Sends the plans of all enabled encounters; without `force` only those that
-- changed or aren't confirmed by everyone. Returns the number sent.
-- Whether plans can be sent now; otherwise false and why.
function PlanSync.CanSend()
  if not PRT.IsEnabled() or not PRT.IsSender() then
    return false, L["Sending plans needs sender mode."]
  elseif not GroupChannel() then
    return false, L["You are not in a group."]
  elseif not IsGroupLead("player") then
    return false, L["Only the group leader or an assistant can send plans."]
  elseif PRT.IsBlizzardEncounterInProgress() then
    return false, L["Plans can't be sent during an encounter."]
  end
  return true
end

function PlanSync.SendPlans(force)
  local channel = GroupChannel()
  if not channel or not PRT.IsEnabled() or not PRT.IsSender() then
    return 0
  end
  if PRT.IsBlizzardEncounterInProgress() then
    PRT.Warn(L["Plans can't be sent during an encounter."])
    return 0
  end

  local count = 0
  for _, encounter in ipairs(PRT.GetProfileDB().encounters) do
    local encounterVersion = encounter.enabled and encounter.versions and encounter.versions[encounter.selectedVersion]
    if encounterVersion then
      local plan = BuildPlan(encounterVersion)
      local hash = PlanHash(plan)
      local state = sent[encounter.id]
      if force or not state or state.hash ~= hash or not AllConfirmed(state) then
        sent[encounter.id] = {hash = hash, sentAt = time(), acks = state and state.hash == hash and state.acks or {}}
        Send({protocol = PROTOCOL, type = "plan", encounterID = encounter.id, name = encounter.name, hash = hash, plan = plan}, channel)
        count = count + 1
      end
    end
  end
  if count > 0 then
    PRT.Info(L["Sending %d plan(s) to your group."]:format(count))
    RefreshOverview()
  end
  return count
end

-- For the overview: who confirmed the current plan of an encounter.
-- Returns hash, { [name] = true } or nil if it wasn't sent this session.
function PlanSync.GetConfirmations(encounterID)
  local state = sent[encounterID]
  if not state then
    return
  end
  local confirmed = {}
  for name, hash in pairs(state.acks) do
    if hash == state.hash then
      confirmed[name] = true
    end
  end
  return state.hash, confirmed
end

-- For the overview: the sync state of an encounter's selected version.
-- Returns status ("unsent" | "changed" | "sent"), { { name, confirmed } } for
-- the other group members, confirmed count.
function PlanSync.GetStatus(encounter)
  local encounterVersion = encounter.versions and encounter.versions[encounter.selectedVersion]
  local state = sent[encounter.id]
  local status = "unsent"
  if state and encounterVersion then
    status = state.hash == PlanHash(BuildPlan(encounterVersion)) and "sent" or "changed"
  end
  local members, confirmedCount = {}, 0
  for _, name in ipairs(Members()) do
    local confirmed = state ~= nil and state.acks[name] == state.hash
    members[#members + 1] = {name = name, confirmed = confirmed}
    if confirmed then
      confirmedCount = confirmedCount + 1
    end
  end
  return status, members, confirmedCount
end

-------------------------------------------------------------------------------
-- Player

-- The plan received for an encounter: { sender, name, hash, receivedAt, plan } or nil.
function PlanSync.GetReceivedPlan(encounterID)
  return ReceivedPlans()[encounterID]
end

local function OnPlan(message, sender)
  if not PRT.IsReceiver() then
    return
  end
  if not IsGroupLead(sender) then
    PRT.Debug("Ignored plan from", PRT.ClassColoredName(sender), "(not leader or assistant)")
    return
  end

  local known = ReceivedPlans()[message.encounterID]
  ReceivedPlans()[message.encounterID] = {
    sender = sender,
    name = message.name,
    hash = message.hash,
    receivedAt = time(),
    plan = message.plan
  }
  if not known or known.hash ~= message.hash then
    PRT.Info(L["Received plan for %s from %s."]:format(PRT.HighlightString(message.name), PRT.ClassColoredName(sender)))
  end
  Send({protocol = PROTOCOL, type = "ack", encounterID = message.encounterID, hash = message.hash}, "WHISPER", sender)
  RefreshOverview()
end

local function OnAck(message, sender)
  local state = sent[message.encounterID]
  if state then
    state.acks[sender] = message.hash
    RefreshOverview()
  end
end

local function OnMessage(_, text, _, sender)
  if not PRT.IsEnabled() or sender == PRT.UnitFullName("player") then
    return
  end
  local ok, message = PRT.Deserialize(text)
  if not ok or type(message) ~= "table" or message.protocol ~= PROTOCOL then
    return
  end
  if message.type == "plan" and type(message.plan) == "table" then
    OnPlan(message, sender)
  elseif message.type == "ack" then
    OnAck(message, sender)
  end
end

function PlanSync.Initialize()
  AceComm:RegisterComm(PREFIX, OnMessage)
end

-- Ready check: the lead sends what changed.
function PlanSync.OnReadyCheck()
  if PRT.IsSender() and IsGroupLead("player") then
    PlanSync.SendPlans(false)
  end
end
