-- luacheck: read globals IsInGroup IsInRaid
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI
local colors = PRT.Widgets.colors

--[[
  Start page: what this client does (lead/player), whether the group has the
  current plans and which plans this client received. The plan of an
  encounter opens one level deeper with the confirmation of every member.
]]

local function EnabledEncounters()
  local encounters = {}
  for _, encounter in ipairs(PRT.GetProfileDB().encounters or {}) do
    if encounter.enabled and encounter.versions and encounter.versions[encounter.selectedVersion] then
      encounters[#encounters + 1] = encounter
    end
  end
  return encounters
end

local function FindEncounter(id)
  for _, encounter in ipairs(EnabledEncounters()) do
    if encounter.id == id then
      return encounter
    end
  end
end

local function Ago(timestamp)
  local seconds = math.max(0, time() - (timestamp or 0))
  if seconds < 60 then
    return L["just now"]
  elseif seconds < 3600 then
    return L["%d min ago"]:format(math.floor(seconds / 60))
  elseif seconds < 86400 then
    return L["%d h ago"]:format(math.floor(seconds / 3600))
  end
  return L["%d d ago"]:format(math.floor(seconds / 86400))
end

local function GroupText()
  if IsInRaid() then
    return L["Raid, %d players"]:format(GetNumGroupMembers())
  elseif IsInGroup() then
    return L["Party, %d players"]:format(GetNumGroupMembers())
  end
  return L["Not in a group"]
end

local function ModeRow(key, label, note)
  return {
    type = "checkbox",
    label = label,
    note = note,
    layout = true,
    get = function()
      return PRT.GetProfileDB()[key]
    end,
    set = function(value)
      PRT.GetProfileDB()[key] = value
    end
  }
end

local function StatusCard()
  return {
    title = L["Status"],
    rows = {
      ModeRow("senderMode", L["Lead"], L["Sends the plans of your enabled encounters to the group."]),
      ModeRow("receiverMode", L["Player"], L["Runs the plans received from the lead and shows the messages meant for you."]),
      {
        type = "live",
        get = function()
          if not PRT.IsEnabled() then
            return L["PhenomRaidTools is disabled."]
          elseif PRT.currentEncounter and PRT.currentEncounter.running then
            return L["Running the plan for %s."]:format(PRT.currentEncounter.encounter.name or "?")
          elseif PRT.IsBlizzardEncounterInProgress() then
            return L["Encounter in progress, no plan for it."]
          end
          return L["Ready. Plans start on the pull."]
        end
      }
    }
  }
end

-------------------------------------------------------------------------------
-- Lead

local STATUS_TEXT = {
  unsent = L["not sent yet"],
  changed = L["changed since sending"]
}

local function PlanItems()
  local items = {}
  for _, encounter in ipairs(EnabledEncounters()) do
    local status, members, confirmed = PRT.PlanSync.GetStatus(encounter)
    local note, color
    if STATUS_TEXT[status] then
      note, color = STATUS_TEXT[status], colors.notice
    else
      note = L["%d/%d confirmed"]:format(confirmed, #members)
      color = confirmed == #members and colors.ok or colors.notice
    end
    items[#items + 1] = {label = encounter.name, note = note, color = color}
  end
  return items
end

local function LeadCard()
  local canSend, reason = PRT.PlanSync.CanSend()
  local rows = {
    {
      type = "button",
      label = L["Send plans to the group"],
      note = L["Happens on every ready check as well, for plans that changed or aren't confirmed by everyone."],
      buttonText = L["Send"],
      layout = true,
      onClick = function()
        if PRT.PlanSync.CanSend() and PRT.PlanSync.SendPlans(true) == 0 then
          PRT.Info(L["No enabled encounter with a plan to send."])
        end
      end
    }
  }
  if not canSend then
    rows[#rows + 1] = {type = "notice", label = reason}
  end
  rows[#rows + 1] = {
    type = "list",
    label = L["Enabled encounters"],
    items = PlanItems,
    empty = L["No encounter is enabled."],
    onClick = function(index)
      UI.Push(EnabledEncounters()[index].id)
    end
  }
  return {title = L["Plans for your group"], rows = rows}
end

local function ConfirmationPage(encounter)
  local status, members, confirmed = PRT.PlanSync.GetStatus(encounter)
  local rows = {}
  if STATUS_TEXT[status] then
    rows[#rows + 1] = {type = "notice", label = L["The current plan is %s. The next ready check sends it."]:format(STATUS_TEXT[status])}
  end
  rows[#rows + 1] = {
    type = "list",
    items = function()
      local items = {}
      for _, member in ipairs(members) do
        items[#items + 1] = {
          label = PRT.ClassColoredName(member.name),
          note = member.confirmed and L["has the plan"] or L["no answer"],
          color = member.confirmed and colors.ok or colors.dim,
          tooltip = not member.confirmed and L["Not received yet, outdated or PhenomRaidTools missing."] or nil
        }
      end
      return items
    end,
    empty = L["Nobody else is in your group."]
  }
  return encounter.name, L["%d/%d confirmed"]:format(confirmed, #members), {{title = L["Group members"], rows = rows}}, {encounter.name}
end

-------------------------------------------------------------------------------
-- Player

local function ReceivedPlans()
  local plans = {}
  for id, received in pairs(PRT.GetGlobalDB().receivedPlans or {}) do
    plans[#plans + 1] = {id = id, received = received}
  end
  table.sort(
    plans,
    function(a, b)
      return (a.received.receivedAt or 0) > (b.received.receivedAt or 0)
    end
  )
  return plans
end

local function PlayerCard()
  return {
    title = L["Received plans"],
    note = L["Run on the pull of their encounter. The lead sends new ones on ready check."],
    rows = {
      {
        type = "list",
        items = function()
          local items = {}
          for _, entry in ipairs(ReceivedPlans()) do
            items[#items + 1] = {
              label = entry.received.name or tostring(entry.id),
              note = ("%s · %s"):format(PRT.ClassColoredName(entry.received.sender or "?"), Ago(entry.received.receivedAt))
            }
          end
          return items
        end,
        empty = L["No plan received yet."],
        onRemove = function(index)
          PRT.GetGlobalDB().receivedPlans[ReceivedPlans()[index].id] = nil
        end
      }
    }
  }
end

-------------------------------------------------------------------------------

UI.RegisterPage(
  {
    id = "overview",
    label = L["Overview"],
    order = 10,
    build = function(path)
      local encounter = path[1] and PRT.IsSender() and FindEncounter(path[1])
      if encounter then
        return ConfirmationPage(encounter)
      end
      local cards = {StatusCard()}
      if PRT.IsSender() then
        cards[#cards + 1] = LeadCard()
      end
      if PRT.IsReceiver() then
        cards[#cards + 1] = PlayerCard()
      end
      return L["Overview"], GroupText(), cards
    end
  }
)
