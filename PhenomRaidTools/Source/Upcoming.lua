local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local LSM = LibStub("LibSharedMedia-3.0")

--[[
  Combat view (overlay.upcoming): this player's next assignments during an
  encounter, the next one large with a countdown, the following ones below.
  Read from the running plan's started timers; whether a message is meant
  for this player is decided once per message and encounter.
]]

local Upcoming = {}
PRT.Upcoming = Upcoming

local COLLECT_INTERVAL = 0.5
local UPDATE_INTERVAL = 0.1
local MAX_LINES = 6
local MOVER_WIDTH = 220

local frame, encounter
local entries = {}
local forMe = setmetatable({}, {__mode = "k"})
local texts = setmetatable({}, {__mode = "k"})

local function Options()
  return PRT.GetProfileDB().overlay.upcoming
end

local function IsForMe(message)
  local cached = forMe[message]
  if cached == nil then
    cached = PRT.IsMessageForMe(message)
    forMe[message] = cached
  end
  return cached
end

local function Text(message)
  local text = texts[message]
  if not text then
    text = PRT.ReceiverOverlay.WithoutTime(PRT.PrepareMessageForDisplay(message.message or ""))
    texts[message] = text
  end
  return text
end

-- Assignments within the lead time, soonest first.
local function Collect(now)
  wipe(entries)
  local options = Options()
  local leadTime = options.leadTime or 30
  for _, timer in ipairs(encounter.Timers or {}) do
    if timer.started and timer.startedAt then
      for _, timing in ipairs(timer.timings or {}) do
        local offset = timing.offset or 0
        for _, second in ipairs(timing.seconds or {}) do
          for _, message in ipairs(timing.messages or {}) do
            local fireAt = timer.startedAt + second + offset + (message.delay or 0)
            local remaining = fireAt - now
            if remaining > 0 and remaining <= leadTime and IsForMe(message) then
              entries[#entries + 1] = {fireAt = fireAt, message = message}
            end
          end
        end
      end
    end
  end
  table.sort(
    entries,
    function(a, b)
      return a.fireAt < b.fireAt
    end
  )
end

local function SavePosition()
  frame:StopMovingOrSizing()
  local x, y = frame:GetCenter()
  local centerX, centerY = UIParent:GetCenter()
  local options = Options()
  options.x, options.y = math.floor(x - centerX + 0.5), math.floor(y - centerY + 0.5)
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", options.x, options.y)
end

local function CreateOverlay()
  frame = CreateFrame("Frame", nil, UIParent)
  frame:SetSize(MOVER_WIDTH, 40)
  frame:SetFrameStrata("HIGH")
  frame:SetMovable(true)
  frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", SavePosition)
  frame.Background = frame:CreateTexture(nil, "BACKGROUND")
  frame.Background:SetAllPoints()
  frame.Background:SetColorTexture(0.05, 0.09, 0.13, 0.75)
  frame.Lines = {}
  for index = 1, MAX_LINES do
    local line = CreateFrame("Frame", nil, frame)
    line.Icon = line:CreateTexture(nil, "ARTWORK")
    line.Icon:SetPoint("LEFT")
    line.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    line.Time = line:CreateFontString(nil, "OVERLAY")
    line.Time:SetPoint("LEFT", line.Icon, "RIGHT", 6, 0)
    line.Text = line:CreateFontString(nil, "OVERLAY")
    line.Text:SetPoint("LEFT", line.Time, "RIGHT", 8, 0)
    line.Text:SetJustifyH("LEFT")
    line.Text:SetWordWrap(false)
    frame.Lines[index] = line
  end
  frame:Hide()
end

-- The first line is larger: it is the one coming up.
function Upcoming.Refresh()
  if not frame then
    CreateOverlay()
  end
  local options = Options()
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", options.x or 0, options.y or -150)
  local font = (options.fontName and LSM:Fetch("font", options.fontName, true)) or STANDARD_TEXT_FONT
  local size = options.fontSize or 18
  local y = 0
  for index, line in ipairs(frame.Lines) do
    local lineSize = index == 1 and math.floor(size * 1.4) or size
    line.Time:SetFont(font, lineSize, "OUTLINE")
    line.Text:SetFont(font, lineSize, "OUTLINE")
    line.Time:SetTextColor(1, 0.82, 0.3)
    line.Icon:SetSize(lineSize + 4, lineSize + 4)
    line:SetSize(MOVER_WIDTH, lineSize + 6)
    line:ClearAllPoints()
    line:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -y)
    y = y + lineSize + 8
  end
  local unlocked = options.locked == false
  frame.Background:SetShown(unlocked)
  frame:EnableMouse(unlocked)
end

local function Render(now)
  local options = Options()
  local count = math.min(options.count or 3, MAX_LINES)
  for index, line in ipairs(frame.Lines) do
    local entry = index <= count and entries[index]
    if entry then
      line.Icon:SetTexture(PRT.ReceiverOverlay.MessageIcon(entry.message, entry.message.message))
      line.Time:SetText(PRT.ReceiverOverlay.FormatRemaining(math.max(0, entry.fireAt - now)))
      line.Text:SetText(Text(entry.message))
      line:Show()
    else
      line:Hide()
    end
  end
  frame:SetShown(entries[1] ~= nil or options.locked == false)
end

local sinceCollect, sinceUpdate = 0, 0

local function OnUpdate(_, elapsed)
  sinceCollect, sinceUpdate = sinceCollect + elapsed, sinceUpdate + elapsed
  if sinceUpdate < UPDATE_INTERVAL then
    return
  end
  sinceUpdate = 0
  local now = GetTime()
  if sinceCollect >= COLLECT_INTERVAL then
    sinceCollect = 0
    Collect(now)
  end
  Render(now)
end

function Upcoming.Start(runningEncounter)
  local options = Options()
  if not options or not options.enabled then
    return
  end
  encounter = runningEncounter
  wipe(forMe)
  wipe(texts)
  Upcoming.Refresh()
  sinceCollect, sinceUpdate = COLLECT_INTERVAL, UPDATE_INTERVAL
  frame:SetScript("OnUpdate", OnUpdate)
end

function Upcoming.Stop()
  encounter = nil
  wipe(entries)
  if frame then
    frame:SetScript("OnUpdate", nil)
    if Options().locked ~= false then
      frame:Hide()
    end
  end
end

-- Placeholder lines to place it (unlocked) or hide it again (locked).
function Upcoming.ShowPreview()
  Upcoming.Refresh()
  if encounter then
    return
  end
  local now = GetTime()
  wipe(entries)
  local samples = {
    {message = "{spell:31821} " .. L["Aura Mastery"], spellID = 31821},
    {message = "{rt1} " .. L["Soak"]},
    {message = L["Move to the left"]}
  }
  for index, message in ipairs(samples) do
    entries[index] = {fireAt = now + index * 7, message = message}
  end
  Render(now)
  frame:SetShown(Options().locked == false)
end
