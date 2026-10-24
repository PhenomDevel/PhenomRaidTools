local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local LSM = LibStub("LibSharedMedia-3.0")

--[[
  Lead status during an encounter (overlay.sender): elapsed time and every
  timer with the time to its next timing.
  Updated once a second while the lead's own plan runs; movable out of combat.
]]

local SenderOverlay = {}
PRT.SenderOverlay = SenderOverlay

local PADDING = 10
local UPDATE_INTERVAL = 1

local frame

local function Options()
  return PRT.GetProfileDB().overlay.sender
end

local function SavePosition()
  frame:StopMovingOrSizing()
  local options = Options()
  options.anchor = "TOPLEFT"
  options.left = math.floor(frame:GetLeft() + 0.5)
  options.top = math.floor(UIParent:GetTop() - frame:GetTop() + 0.5)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", options.left, -options.top)
end

local function CreateOverlay()
  frame = CreateFrame("Frame", nil, UIParent)
  frame:SetFrameStrata("MEDIUM")
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", SavePosition)
  frame.Background = frame:CreateTexture(nil, "BACKGROUND")
  frame.Background:SetAllPoints()
  frame.Text = frame:CreateFontString(nil, "OVERLAY")
  frame.Text:SetPoint("TOPLEFT", PADDING, -PADDING)
  frame.Text:SetJustifyH("LEFT")
  frame:Hide()
end

local function Resize()
  frame:SetSize(frame.Text:GetStringWidth() + 2 * PADDING, frame.Text:GetStringHeight() + 2 * PADDING)
end

local function SetText(text)
  frame.Text:SetText(text)
  Resize()
end

-- Applies position, font and colors.
function SenderOverlay.Refresh()
  if not frame then
    CreateOverlay()
  end
  local options = Options()
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", options.left or 615, -(options.top or 50))
  local font = (options.fontName and LSM:Fetch("font", options.fontName, true)) or options.font or STANDARD_TEXT_FONT
  frame.Text:SetFont(font, options.fontSize or 14, "OUTLINE")
  local color = options.fontColor or {}
  frame.Text:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
  local backdrop = options.backdropColor or {}
  frame.Background:SetColorTexture(backdrop.r or 0, backdrop.g or 0, backdrop.b or 0, backdrop.a or 0.7)
  Resize()
end

local function NextTiming(timer, elapsed)
  local nextAt
  for _, timing in ipairs(timer.timings or {}) do
    for _, second in ipairs(timing.seconds or {}) do
      local at = second + (timing.offset or 0)
      if at > elapsed and (not nextAt or at < nextAt) then
        nextAt = at
      end
    end
  end
  return nextAt
end

local function Colored(text, color)
  return PRT.ColoredString(text, color)
end

local function TimerLine(timer, options, now)
  local colors = PRT.Static.Colors
  if timer.enabled == false then
    return not options.hideDisabledTriggers and Colored(timer.name .. " - " .. L["disabled"], colors.Disabled) or nil
  end
  if not timer.started then
    return Colored(timer.name .. " - " .. L["inactive"], colors.Inactive)
  end
  local elapsed = now - timer.startedAt
  local line = Colored(timer.name, colors.Tertiary) .. " (" .. Colored(PRT.SecondsToClock(elapsed), colors.Secondary) .. ")"
  local nextAt = NextTiming(timer, elapsed)
  if nextAt then
    line = line .. " [-" .. Colored(PRT.SecondsToClock(PRT.Round(nextAt - elapsed)), colors.Secondary) .. "]"
  end
  return line
end

local function Update(encounter)
  local options, colors, now = Options(), PRT.Static.Colors, GetTime()
  local lines = {Colored(encounter.name or "", colors.Primary) .. " (" .. Colored(PRT.SecondsToClock(now - encounter.startedAt), colors.Secondary) .. ")"}
  if encounter.Timers and #encounter.Timers > 0 then
    lines[#lines + 1] = Colored(L["Timers"], colors.Secondary)
    for _, timer in ipairs(encounter.Timers) do
      lines[#lines + 1] = TimerLine(timer, options, now)
    end
  end
  SetText(table.concat(lines, "|n"))
end

-- The lead's own plan started; scheduled on the encounter timer, so it
-- stops with the encounter.
function SenderOverlay.Start(encounter)
  SenderOverlay.Refresh()
  frame:EnableMouse(false)
  frame:Show()
  Update(encounter)
  PRT.EncounterTimer:ScheduleRepeatingTimer(Update, UPDATE_INTERVAL, encounter)
end

function SenderOverlay.Stop()
  if not frame or not frame:IsShown() then
    return
  end
  if Options().hideAfterCombat then
    frame:Hide()
  else
    frame:EnableMouse(true)
  end
end

-- Shows the overlay with a placeholder to place it.
function SenderOverlay.ShowPreview()
  SenderOverlay.Refresh()
  SetText(Colored("PhenomRaidTools", PRT.Static.Colors.Primary) .. "|n" .. L["Lead status during encounters. Drag to move."])
  frame:EnableMouse(true)
  frame:Show()
end

function SenderOverlay.Hide()
  if frame then
    frame:Hide()
  end
end

function SenderOverlay.IsShown()
  return frame ~= nil and frame:IsShown()
end
