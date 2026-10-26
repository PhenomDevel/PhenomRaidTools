local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

--[[
  Demo: a short sample plan that runs right away, out of combat and in any
  role. Every assignment is for the own player, so it shows every kind of
  message (text, countdown, marker, own sound, text to speech, cooldowns) on
  the own overlays, together with the next assignments and the lead's
  overlay. It runs through the same timers as a real plan.
]]

local Demo = {}
PRT.Demo = Demo

local NAME = "PhenomRaidTools Demo"
-- Seconds after the last message disappeared.
local END_PAUSE = 2

local function Assignment(seconds, message)
  message.targets = {"$me"}
  message.targetOverlay = message.targetOverlay or 1
  message.duration = message.duration or 5
  message.delay = 0
  message.type = message.type or "advanced"
  return {seconds = seconds, messages = {message}}
end

local function Cooldown(seconds, spellID, fallbackName, overlay, settings)
  local message = {type = "cooldown", spellID = spellID, withCountdown = true, targetOverlay = overlay, duration = 8}
  if not PRT.SpellName(spellID) then
    message.cooldownText = fallbackName
  end
  for key, value in pairs(settings) do
    message[key] = value
  end
  message.message = PRT.CooldownMessageText(message)
  return Assignment(seconds, message)
end

-- The demo plan for the overlays of the current profile.
function Demo.Plan()
  local Overlay = PRT.ReceiverOverlay
  local healing = Overlay.IndexForPurpose("healing") or 1
  local utility = Overlay.IndexForPurpose("utility") or 1
  local timings = {
    Assignment({2}, {message = L["Demo: a text message, %.0f s left"], duration = 6}),
    Assignment({6}, {message = "{rt1} " .. L["Soak"] .. " - " .. L["with a marker and its own sound"], useCustomSound = true, soundFileName = "PRT: Soak"}),
    Assignment({10}, {message = L["Read aloud: move to the left"], useTTS = true}),
    Cooldown({14}, 31821, L["Aura Mastery"], healing, {useCustomSound = true, soundFileName = "PRT: Aura Mastery"}),
    Cooldown({18}, 97462, L["Rallying Cry"], utility, {useTTS = true})
  }
  -- One message on every other overlay, so each one shows up.
  local second = 22
  for index, config in ipairs(PRT.GetProfileDB().overlay.receivers) do
    if index ~= 1 and index ~= healing and index ~= utility then
      timings[#timings + 1] = Assignment({second}, {message = L["Overlay %d"]:format(index) .. ": " .. (config.label or ""), targetOverlay = index})
      second = second + 3
    end
  end
  timings[#timings + 1] = Assignment({second + 2, second + 6, second + 10}, {message = L["Repeats every 4 seconds"]})

  return {
    id = 0,
    name = NAME,
    Timers = {{enabled = true, name = "Pull", startCondition = {event = "ENCOUNTER_START"}, timings = timings}}
  }, second + 10 + 5 + END_PAUSE
end

function Demo.IsRunning()
  return PRT.currentEncounter ~= nil and PRT.currentEncounter.demo == true
end

-- Returns false while a real plan runs.
function Demo.Start()
  if PRT.currentEncounter and PRT.currentEncounter.running and not PRT.currentEncounter.demo then
    PRT.Warn(L["A plan is running. The demo can start after the fight."])
    return false
  end
  local plan, length = Demo.Plan()
  PRT.RunPlan(plan, false, true)
  PRT.EncounterTimer:ScheduleTimer(Demo.Stop, length)
  PRT.UI.RefreshPage("overlays")

  local overlays = PRT.GetProfileDB().overlay
  if not (overlays.upcoming.enabled and overlays.sender.enabled) then
    PRT.Info(L["Not every overlay is turned on, see the overlays page."])
  end
  return true
end

function Demo.Stop()
  if Demo.IsRunning() then
    PRT.StopPlan()
    PRT.UI.RefreshPage("overlays")
  end
end

function Demo.Toggle()
  if Demo.IsRunning() then
    Demo.Stop()
  else
    Demo.Start()
  end
end
