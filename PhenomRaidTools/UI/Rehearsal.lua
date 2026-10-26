-- luacheck: read globals C_Timer GetTime
local _, PRT = ...

local UI = PRT.UI

--[[
  Rehearsal of a plan on the encounter page: a playhead runs from the pull
  (in real time or faster) and every assignment it passes shows on the real
  overlays, as during the encounter, without an encounter. The page passes
  the assignments to play, already filtered (view, difficulty):

    Rehearsal.Play(events, length)   events() -> { { at = seconds, message } }
    Rehearsal.Pause()
    Rehearsal.Seek(seconds)          also while playing; clears the overlays
    Rehearsal.Position() -> seconds
]]

local Rehearsal = {speed = 1}
UI.Rehearsal = Rehearsal

local TICK = 0.1

local position = 0
local ticker, startedAt, startPosition, played, events, length

function Rehearsal.Position()
  if ticker then
    return math.min(length, startPosition + (GetTime() - startedAt) * Rehearsal.speed)
  end
  return position
end

function Rehearsal.IsPlaying()
  return ticker ~= nil
end

-- As ExecuteMessage shows it to its target; faster than real time it stays silent.
local function Show(message)
  local shown = PRT.TableUtils.Clone(message)
  shown.message = PRT.ReplacePlayerNameTokens(shown.message)
  shown.targets = nil
  PRT.ReceiverOverlay.AddMessage(shown, Rehearsal.speed > 1)
end

local function Tick()
  local now = Rehearsal.Position()
  for _, event in ipairs(events()) do
    if event.at > played and event.at <= now then
      Show(event.message)
    end
  end
  played = now
  if now >= length or not UI.IsShown() then
    Rehearsal.Pause()
    UI.RefreshPage("encounters")
  end
end

local function Restart(from)
  startedAt, startPosition = GetTime(), from
  -- Assignments right at the start show as well.
  played = from - 0.001
end

function Rehearsal.Play(source, total)
  if ticker then
    return
  end
  events, length = source, total
  if position >= total then
    position = 0
  end
  Restart(position)
  ticker = C_Timer.NewTicker(TICK, Tick)
end

function Rehearsal.Pause()
  if ticker then
    position = Rehearsal.Position()
    ticker:Cancel()
    ticker = nil
  end
end

function Rehearsal.Seek(seconds)
  position = math.max(0, seconds)
  if ticker then
    Restart(position)
  end
  PRT.ReceiverOverlay.Clear()
end

function Rehearsal.SetSpeed(speed)
  local now = Rehearsal.Position()
  Rehearsal.speed = speed
  if ticker then
    Restart(now)
    played = now
  end
end

-- A real pull ends the rehearsal.
function Rehearsal.Stop()
  Rehearsal.Pause()
  position = 0
end
