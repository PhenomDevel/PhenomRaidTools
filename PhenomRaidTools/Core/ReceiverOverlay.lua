-- luacheck: read globals C_Timer C_VoiceChat C_TTSSettings Enum GetBuildInfo
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local LSM = LibStub("LibSharedMedia-3.0")

--[[
  Message overlays. Every receiver of the profile (overlay.receivers) is one
  display: an anchor on the screen and the messages meant for this player,
  stacked from it. The message that ends first is next to the anchor.

  style       text | icons | bars
  grow        UP | DOWN | LEFT | RIGHT   direction of the stack
  from        anchor | center            stack starts at the anchor or is centered on it
  align       LEFT | CENTER | RIGHT      text alignment of vertical stacks
  spacing, maxEntries, iconSize, barWidth, barColor, fontSize, fontName, fontColor
  fontOutline NONE | OUTLINE | THICKOUTLINE
  fontShadow  shadow below the texts
  x, y        anchor offset from the screen center

  Frames are pooled and reused across encounters and profile changes. A
  display runs an OnUpdate only while it shows messages.
]]

local ReceiverOverlay = {}
PRT.ReceiverOverlay = ReceiverOverlay

local DEFAULTS = {
  style = "text",
  grow = "DOWN",
  from = "anchor",
  align = "CENTER",
  spacing = 4,
  maxEntries = 5,
  iconSize = 32,
  barWidth = 240,
  fontSize = 24,
  locked = true,
  enableSound = true
}

local DEFAULT_BAR_COLOR = {r = 0.18, g = 0.6, b = 0.84, a = 0.9}
local DEFAULT_SOUND_FILE = "Interface\\AddOns\\PhenomRaidTools\\Media\\Sounds\\ReceiveMessage.ogg"
local DEFAULT_SOUND_NAME = "PRT: Default"
local DEFAULT_FONT_COLOR = {r = 1, g = 1, b = 1, a = 1}
local DEFAULT_ICON = "Interface\\AddOns\\PhenomRaidTools\\Media\\Logo.blp"
local RAID_TARGET_ICON = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_%s"
local BAR_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local UPDATE_INTERVAL = 0.05
local MOVER_WIDTH, MOVER_HEIGHT = 180, 44

local displays = {}

-------------------------------------------------------------------------------
-- Config

function ReceiverOverlay.Get(config, key)
  local value = config[key]
  if value == nil then
    return DEFAULTS[key]
  end
  return value
end

local Get = ReceiverOverlay.Get

-- Receivers from before 3.0 store a TOPLEFT based position (left/top) of a
-- frame anchored at its own `anchor` point; the anchor itself was there.
local function EnsurePosition(config)
  if config.x == nil or config.y == nil then
    local width, height = UIParent:GetWidth(), UIParent:GetHeight()
    config.x = math.floor((config.left or width / 2) - width / 2 + 0.5)
    config.y = math.floor(height / 2 - (config.top or height / 2) + 0.5)
  end
end

local function Color(color, fallback)
  color = color or fallback
  return color.r or 1, color.g or 1, color.b or 1, color.a or 1
end

-------------------------------------------------------------------------------
-- Text

local FORMAT_SPEC = "%%[-+ #0]*%d*%.?%d*[dfgs]"

-- Messages may contain one format spec ("%.0f") for the remaining time;
-- "%%" is a literal percent sign. Never errors on other percent signs.
local function HasFormat(text)
  return text:gsub("%%%%", ""):find(FORMAT_SPEC) ~= nil
end

local function WithTime(text, remaining)
  local ok, result = pcall(string.format, text, remaining)
  if ok then
    return result
  end
  return (text:gsub("%%%%", "%%"))
end

-- For icons and bars, which show the time on their own.
local function WithoutTime(text)
  return (text:gsub("%%%%", "\001"):gsub("%s*" .. FORMAT_SPEC, ""):gsub("\001", "%%"))
end

local function FormatRemaining(remaining)
  if remaining >= 60 then
    return ("%d:%02d"):format(math.floor(remaining / 60), math.floor(remaining % 60))
  elseif remaining >= 10 then
    return ("%d"):format(math.floor(remaining + 0.5))
  end
  return ("%.1f"):format(remaining)
end

ReceiverOverlay.FormatRemaining = FormatRemaining
ReceiverOverlay.WithoutTime = WithoutTime

-- Icon of the message: its spell, a spell or raid marker in the text, or the logo.
function ReceiverOverlay.MessageIcon(message, raw)
  local icon = PRT.SpellIcon(message.spellID)
  if not icon and raw then
    icon = PRT.SpellIcon(raw:match("{spell:(%d+)}"))
    if not icon then
      local marker = raw:match("{rt(%d)}")
      icon = marker and RAID_TARGET_ICON:format(marker)
    end
  end
  return icon or DEFAULT_ICON
end

-------------------------------------------------------------------------------
-- Entries

local function CreateEntry(display)
  local entry = CreateFrame("Frame", nil, display.frame)
  entry.Icon = entry:CreateTexture(nil, "ARTWORK")
  entry.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  entry.Bar = CreateFrame("StatusBar", nil, entry)
  entry.Bar:SetStatusBarTexture(BAR_TEXTURE)
  entry.Bar.Background = entry.Bar:CreateTexture(nil, "BACKGROUND")
  entry.Bar.Background:SetAllPoints()
  entry.Bar.Background:SetColorTexture(0, 0, 0, 0.5)
  -- Texts above the bar.
  entry.Content = CreateFrame("Frame", nil, entry)
  entry.Content:SetAllPoints()
  entry.Content:SetFrameLevel(entry.Bar:GetFrameLevel() + 2)
  entry.Text = entry.Content:CreateFontString(nil, "OVERLAY")
  entry.Text:SetWordWrap(false)
  entry.Time = entry.Content:CreateFontString(nil, "OVERLAY")
  entry.Time:SetWordWrap(false)
  return entry
end

local function AcquireEntry(display)
  local entry = tremove(display.pool) or CreateEntry(display)
  entry:Show()
  return entry
end

local function ReleaseEntry(display, entry)
  entry:Hide()
  entry:ClearAllPoints()
  display.pool[#display.pool + 1] = entry
end

-- Sizes and arranges an entry's parts for the display's style.
local function SetupEntry(display, entry)
  local config = display.config
  local style = Get(config, "style")
  local size = Get(config, "fontSize")
  local r, g, b, a = Color(config.fontColor, DEFAULT_FONT_COLOR)
  PRT.SetOverlayFont(entry.Text, config, size)
  entry.Text:SetTextColor(r, g, b, a)
  entry.Text:ClearAllPoints()
  entry.Time:ClearAllPoints()
  entry.Icon:ClearAllPoints()
  entry.Bar:ClearAllPoints()

  entry.dynamic = style ~= "text" or entry.hasFormat
  entry.Icon:SetShown(style ~= "text")
  entry.Bar:SetShown(style == "bars")
  entry.Time:SetShown(style ~= "text")
  entry.lastShown = nil

  if style == "text" then
    entry.Text:SetJustifyH(Get(config, "align"))
    entry.Text:SetText(entry.hasFormat and WithTime(entry.text, entry.duration) or entry.text)
    entry.Text:SetPoint("CENTER")
    entry:SetSize(math.max(1, entry.Text:GetUnboundedStringWidth()), size * 1.25)
  elseif style == "icons" then
    local iconSize = Get(config, "iconSize")
    entry.Icon:SetTexture(entry.icon)
    entry.Icon:SetSize(iconSize, iconSize)
    entry.Icon:SetPoint("LEFT")
    PRT.SetOverlayFont(entry.Time, config, math.max(10, math.floor(iconSize * 0.45)))
    entry.Time:SetTextColor(1, 1, 1, 1)
    entry.Time:SetPoint("CENTER", entry.Icon)
    entry.Text:SetJustifyH("LEFT")
    entry.Text:SetText(entry.text)
    entry.Text:SetPoint("LEFT", entry.Icon, "RIGHT", 6, 0)
    entry:SetSize(iconSize + 6 + entry.Text:GetUnboundedStringWidth(), math.max(iconSize, size * 1.25))
  else
    local height = math.max(Get(config, "iconSize") * 0.75, size + 8)
    local width = Get(config, "barWidth")
    entry.Icon:SetTexture(entry.icon)
    entry.Icon:SetSize(height, height)
    entry.Icon:SetPoint("LEFT")
    entry.Bar:SetPoint("TOPLEFT", entry.Icon, "TOPRIGHT", 2, 0)
    entry.Bar:SetPoint("BOTTOMRIGHT")
    entry.Bar:SetStatusBarColor(Color(config.barColor, DEFAULT_BAR_COLOR))
    entry.Bar:SetMinMaxValues(0, math.max(0.01, entry.duration))
    PRT.SetOverlayFont(entry.Time, config, math.max(10, size - 4))
    entry.Time:SetTextColor(r, g, b, a)
    entry.Time:SetPoint("RIGHT", entry.Bar, "RIGHT", -6, 0)
    entry.Text:SetJustifyH("LEFT")
    entry.Text:SetText(entry.text)
    entry.Text:SetPoint("LEFT", entry.Bar, "LEFT", 6, 0)
    entry.Text:SetPoint("RIGHT", entry.Time, "LEFT", -6, 0)
    entry:SetSize(height + 2 + width, height)
  end
end

local function UpdateEntry(display, entry, now)
  local remaining = math.max(0, entry.expires - now)
  local shown = math.floor(remaining * 10 + 0.5) / 10
  if shown == entry.lastShown then
    if entry.Bar:IsShown() then
      entry.Bar:SetValue(remaining)
    end
    return
  end
  entry.lastShown = shown
  if Get(display.config, "style") == "text" then
    entry.Text:SetText(WithTime(entry.text, shown))
  else
    entry.Time:SetText(FormatRemaining(remaining))
    if entry.Bar:IsShown() then
      entry.Bar:SetValue(remaining)
    end
  end
end

-------------------------------------------------------------------------------
-- Layout

local VERTICAL_POINT = {UP = "BOTTOM", DOWN = "TOP"}
local HORIZONTAL_POINT = {RIGHT = "LEFT", LEFT = "RIGHT"}
local ALIGN_SUFFIX = {LEFT = "LEFT", CENTER = "", RIGHT = "RIGHT"}

local function Layout(display)
  local config, entries = display.config, display.entries
  local grow = Get(config, "grow")
  local spacing = Get(config, "spacing")
  local vertical = VERTICAL_POINT[grow] ~= nil

  local total = 0
  for index, entry in ipairs(entries) do
    total = total + (vertical and entry:GetHeight() or entry:GetWidth()) + (index > 1 and spacing or 0)
  end
  local offset = Get(config, "from") == "center" and -total / 2 or 0

  local sign = (grow == "UP" or grow == "RIGHT") and 1 or -1
  for _, entry in ipairs(entries) do
    entry:ClearAllPoints()
    if vertical then
      local suffix = ALIGN_SUFFIX[Get(config, "align")] or ""
      entry:SetPoint(VERTICAL_POINT[grow] .. suffix, display.frame, "CENTER", 0, sign * offset)
      offset = offset + entry:GetHeight() + spacing
    else
      entry:SetPoint(HORIZONTAL_POINT[grow], display.frame, "CENTER", sign * offset, 0)
      offset = offset + entry:GetWidth() + spacing
    end
  end
end

local function OnUpdate(frame, elapsed)
  local display = frame.display
  display.sinceUpdate = display.sinceUpdate + elapsed
  if display.sinceUpdate < UPDATE_INTERVAL then
    return
  end
  display.sinceUpdate = 0

  local now = GetTime()
  local entries, removed = display.entries, false
  for index = #entries, 1, -1 do
    if entries[index].expires <= now then
      ReleaseEntry(display, tremove(entries, index))
      removed = true
    end
  end
  if removed then
    Layout(display)
  end
  for _, entry in ipairs(entries) do
    if entry.dynamic then
      UpdateEntry(display, entry, now)
    end
  end
  if #entries == 0 then
    frame:SetScript("OnUpdate", nil)
    if display.onEmpty then
      display.onEmpty(display)
    end
  end
end

-------------------------------------------------------------------------------
-- Displays

local function SavePosition(display)
  local frame = display.frame
  frame:StopMovingOrSizing()
  local x, y = frame:GetCenter()
  local centerX, centerY = UIParent:GetCenter()
  display.config.x = math.floor(x - centerX + 0.5)
  display.config.y = math.floor(y - centerY + 0.5)
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", display.config.x, display.config.y)
  if PRT.UI then
    PRT.UI.RefreshValues()
  end
end

local function CreateMover(display)
  local mover = CreateFrame("Frame", nil, display.frame)
  mover:SetSize(MOVER_WIDTH, MOVER_HEIGHT)
  mover:SetPoint("CENTER")
  mover:SetFrameLevel(display.frame:GetFrameLevel() + 20)
  mover:EnableMouse(true)
  mover:RegisterForDrag("LeftButton")
  mover:SetScript(
    "OnDragStart",
    function()
      display.frame:StartMoving()
    end
  )
  mover:SetScript(
    "OnDragStop",
    function()
      SavePosition(display)
    end
  )
  local background = mover:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  background:SetColorTexture(0.05, 0.09, 0.13, 0.75)
  -- Anchor cross: where the first message starts.
  local horizontal = mover:CreateTexture(nil, "ARTWORK")
  horizontal:SetColorTexture(0.41, 0.8, 0.94, 0.9)
  horizontal:SetSize(MOVER_WIDTH, 1)
  horizontal:SetPoint("CENTER")
  local verticalLine = mover:CreateTexture(nil, "ARTWORK")
  verticalLine:SetColorTexture(0.41, 0.8, 0.94, 0.9)
  verticalLine:SetSize(1, MOVER_HEIGHT)
  verticalLine:SetPoint("CENTER")
  mover.Label = mover:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  mover.Label:SetPoint("TOP", 0, -4)
  mover.Hint = mover:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  mover.Hint:SetPoint("BOTTOM", 0, 4)
  mover.Hint:SetText(L["Drag to move"])
  return mover
end

local function CreateDisplay(index)
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetSize(1, 1)
  frame:SetFrameStrata("HIGH")
  frame:SetMovable(true)
  frame:SetClampedToScreen(true)
  local display = {index = index, frame = frame, entries = {}, pool = {}, sinceUpdate = 0}
  frame.display = display
  display.mover = CreateMover(display)
  return display
end

local function ApplyConfig(display, config)
  display.config = config
  EnsurePosition(config)
  local frame = display.frame
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", config.x, config.y)
  frame:Show()
  local unlocked = not Get(config, "locked")
  display.mover:SetShown(unlocked)
  if unlocked then
    display.mover.Label:SetText(("%d: %s"):format(display.index, config.label or ""))
  end
  for _, entry in ipairs(display.entries) do
    SetupEntry(display, entry)
  end
  Layout(display)
end

local function GetDisplay(index)
  local receivers = PRT.GetProfileDB().overlay.receivers
  local config = receivers[index] or receivers[1]
  if not config then
    return
  end
  index = receivers[index] and index or 1
  local display = displays[index]
  if not display then
    display = CreateDisplay(index)
    displays[index] = display
    ApplyConfig(display, config)
  elseif display.config ~= config then
    ApplyConfig(display, config)
  end
  return display
end

-------------------------------------------------------------------------------
-- Sound

-- What text to speech reads: the text without icons, markers, colors and countdown.
function ReceiverOverlay.SpokenText(message)
  local text = message.message or ""
  if message.type == "cooldown" then
    text = message.cooldownText or PRT.SpellName(message.spellID) or ""
  end
  text =
    text:gsub(
    "{spell:(%d+)}",
    function(spellID)
      return PRT.SpellName(spellID) or ""
    end
  )
  text = text:gsub("{rt%d}", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("%%[-+ #0]*%d*%.?%d*[dfgs]", "")
  return strtrim((text:gsub("%s+", " ")))
end

-- 12.0 dropped SpeakText's destination argument.
local SPEAK_WITHOUT_DESTINATION = select(4, GetBuildInfo()) >= 120000

local function Speak(text)
  if text == "" or not (C_VoiceChat and C_VoiceChat.SpeakText and C_TTSSettings) then
    return false
  end
  return pcall(
    function()
      local voiceID = C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard)
      local rate, volume = C_TTSSettings.GetSpeechRate(), C_TTSSettings.GetSpeechVolume()
      if SPEAK_WITHOUT_DESTINATION then
        C_VoiceChat.SpeakText(voiceID, text, rate, volume, true)
      else
        C_VoiceChat.SpeakText(voiceID, text, Enum.VoiceTtsDestination.LocalPlayback, rate, volume)
      end
    end
  )
end

-- Text to speech replaces the sound; it plays even with the overlay's sound off.
local function PlayMessageSound(message, config)
  if message.useTTS and Speak(ReceiverOverlay.SpokenText(message)) then
    return
  end
  if not Get(config, "enableSound") then
    return
  end
  if message.useCustomSound then
    local file = (message.soundFileName and LSM:Fetch("sound", message.soundFileName, true)) or message.soundFile
    if file and PlaySoundFile(file, "Master") then
      return
    end
  end
  local file = (config.defaultSoundFileName and LSM:Fetch("sound", config.defaultSoundFileName, true)) or config.defaultSoundFile
  if file then
    PlaySoundFile(file, "Master")
  end
end

-------------------------------------------------------------------------------
-- Public API

local function AddToDisplay(display, message, silent)
  local config = display.config
  if not silent then
    PlayMessageSound(message, config)
  end

  local raw = message.message or ""
  local entries = display.entries
  local maxEntries = Get(config, "maxEntries")
  while #entries >= maxEntries do
    -- The oldest message makes room.
    local oldest = 1
    for index, entry in ipairs(entries) do
      if entry.added < entries[oldest].added then
        oldest = index
      end
    end
    ReleaseEntry(display, tremove(entries, oldest))
  end

  local entry = AcquireEntry(display)
  local now = GetTime()
  entry.duration = message.duration or 5
  entry.expires = now + entry.duration
  entry.added = now
  local text = PRT.PrepareMessageForDisplay(raw)
  entry.hasFormat = HasFormat(text)
  entry.text = Get(config, "style") == "text" and text or WithoutTime(text)
  entry.icon = ReceiverOverlay.MessageIcon(message, raw)
  SetupEntry(display, entry)

  local position = #entries + 1
  for index, other in ipairs(entries) do
    if entry.expires < other.expires then
      position = index
      break
    end
  end
  tinsert(entries, position, entry)
  Layout(display)
  UpdateEntry(display, entry, now)

  display.sinceUpdate = 0
  display.frame:SetScript("OnUpdate", OnUpdate)
end

-- message: { message, duration, targetOverlay, spellID, useCustomSound, soundFile(Name), useTTS }
function ReceiverOverlay.AddMessage(message, silent)
  local display = GetDisplay(message.targetOverlay or 1)
  if display then
    AddToDisplay(display, message, silent)
  end
end

function ReceiverOverlay.Clear()
  for _, display in pairs(displays) do
    for index = #display.entries, 1, -1 do
      ReleaseEntry(display, tremove(display.entries, index))
    end
    display.frame:SetScript("OnUpdate", nil)
  end
end

-- After a setting or the profile changed: re-applies every receiver and
-- hides displays of removed ones.
function ReceiverOverlay.Refresh()
  local receivers = PRT.GetProfileDB().overlay.receivers
  for index, display in pairs(displays) do
    if receivers[index] then
      ApplyConfig(display, receivers[index])
    else
      for entryIndex = #display.entries, 1, -1 do
        ReleaseEntry(display, tremove(display.entries, entryIndex))
      end
      display.frame:SetScript("OnUpdate", nil)
      display.mover:Hide()
      display.config = nil
    end
  end
  for index in ipairs(receivers) do
    GetDisplay(index)
  end
end

-- Sample messages to see style, position and sound.
function ReceiverOverlay.Test(index)
  local receivers = PRT.GetProfileDB().overlay.receivers
  for receiverIndex, config in ipairs(receivers) do
    if index == nil or index == receiverIndex then
      for sampleIndex, message in ipairs(ReceiverOverlay.SampleMessages(config)) do
        message.targetOverlay = receiverIndex
        ReceiverOverlay.AddMessage(message, sampleIndex > 1)
      end
    end
  end
end

function ReceiverOverlay.SetLocked(locked)
  for _, config in ipairs(PRT.GetProfileDB().overlay.receivers) do
    config.locked = locked
  end
  ReceiverOverlay.Refresh()
end

function ReceiverOverlay.ResetPosition(index)
  local config = PRT.GetProfileDB().overlay.receivers[index]
  if config then
    config.x, config.y = 0, 200 - (index - 1) * 80
    ReceiverOverlay.Refresh()
  end
end

-- The receivers of a new profile: general messages at the top, healing
-- cooldowns on the left, utility cooldowns on the right. `purpose` lets the
-- editor put a chosen cooldown on the matching overlay.
function ReceiverOverlay.DefaultReceivers()
  local function Receiver(id, label, settings)
    local receiver = {
      id = id,
      name = id,
      label = label,
      locked = true,
      enableSound = true,
      fontColor = {r = 1, g = 1, b = 1, a = 1},
      defaultSoundFile = DEFAULT_SOUND_FILE,
      defaultSoundFileName = DEFAULT_SOUND_NAME
    }
    for key, value in pairs(settings) do
      receiver[key] = value
    end
    return receiver
  end
  return {
    Receiver(1, L["Messages"], {x = 0, y = 260, style = "text", grow = "DOWN", fontSize = 28}),
    Receiver(
      2,
      L["Healing cooldowns"],
      {purpose = "healing", x = -470, y = 100, style = "bars", grow = "DOWN", fontSize = 15, barWidth = 200, barColor = {r = 0.24, g = 0.66, b = 0.4, a = 0.9}}
    ),
    Receiver(
      3,
      L["Utility cooldowns"],
      {purpose = "utility", x = 470, y = 100, style = "bars", grow = "DOWN", fontSize = 15, barWidth = 200, barColor = {r = 0.2, g = 0.52, b = 0.82, a = 0.9}}
    )
  }
end

-- The receiver for a purpose ("healing", "utility"), nil if there is none.
function ReceiverOverlay.IndexForPurpose(purpose)
  for index, config in ipairs(PRT.GetProfileDB().overlay.receivers) do
    if config.purpose == purpose then
      return index
    end
  end
end

-------------------------------------------------------------------------------
-- Preview: a display inside another frame (the window's preview panel),
-- repeating sample messages while it is shown.

local PREVIEW_PAUSE = 0.6

-- Where the stack starts inside the panel, so it grows into the panel.
local PREVIEW_ANCHOR = {UP = "BOTTOM", DOWN = "TOP", LEFT = "RIGHT", RIGHT = "LEFT"}
local PREVIEW_INSET = 16

local Preview = {}
Preview.__index = Preview

function ReceiverOverlay.CreatePreview(parent)
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetSize(1, 1)
  local preview = setmetatable({parent = parent, display = {frame = frame, entries = {}, pool = {}, sinceUpdate = 0}}, Preview)
  frame.display = preview.display
  preview.display.onEmpty = function()
    preview.timer = C_Timer.NewTimer(PREVIEW_PAUSE, function()
      preview:Play()
    end)
  end
  return preview
end

function Preview:Clear()
  local display = self.display
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  for index = #display.entries, 1, -1 do
    ReleaseEntry(display, tremove(display.entries, index))
  end
  display.frame:SetScript("OnUpdate", nil)
end

function Preview:Play()
  self:Clear()
  if not self.config then
    return
  end
  for _, message in ipairs(self.messages) do
    AddToDisplay(self.display, message, true)
  end
  self:Fit()
end

-- The real overlay never wraps, so samples wider than the screen are scaled
-- down instead (anchor offsets are in the scaled space).
function Preview:Fit()
  local display = self.display
  local horizontal = not (display.grow == "UP" or display.grow == "DOWN")
  local width = 1
  for _, entry in ipairs(display.entries) do
    local entryWidth = entry:GetWidth() or 0
    width = horizontal and width + entryWidth + Get(self.config, "spacing") or math.max(width, entryWidth)
  end
  local scale = math.min(1, math.max(0.2, ((self.parent:GetWidth() or 0) - 2 * PREVIEW_INSET) / width))
  local anchor = self.anchor
  display.frame:SetScale(scale)
  display.frame:ClearAllPoints()
  display.frame:SetPoint("CENTER", self.parent, anchor.point, anchor.x / scale, anchor.y / scale)
end

-- config: a receiver (or the same fields); messages: sample messages.
function Preview:Show(config, messages)
  local display = self.display
  self.config, self.messages = config, messages
  display.config = config
  local frame = display.frame
  frame:ClearAllPoints()
  local grow = Get(config, "grow")
  local vertical = grow == "UP" or grow == "DOWN"
  local align = vertical and ALIGN_SUFFIX[Get(config, "align")] or ""
  local point = Get(config, "from") == "center" and "" or PREVIEW_ANCHOR[grow] or "TOP"
  point = (point .. align) ~= "" and point .. align or "CENTER"
  local x = point:find("LEFT") and PREVIEW_INSET or point:find("RIGHT") and -PREVIEW_INSET or 0
  local y = point:find("TOP") and -PREVIEW_INSET or point:find("BOTTOM") and PREVIEW_INSET or 0
  display.grow = grow
  self.anchor = {point = point, x = x, y = y}
  frame:SetPoint("CENTER", self.parent, point, x, y)
  frame:Show()
  self:Play()
end

function Preview:Hide()
  self:Clear()
  self.config = nil
  self.display.frame:Hide()
end

-- Sample messages of a receiver: a text with countdown, a spell, a marker.
function ReceiverOverlay.SampleMessages(config)
  return {
    {message = (config.label or "") .. " %.0f", duration = 6},
    {message = "{spell:31821} " .. L["Aura Mastery"], duration = 9, spellID = 31821},
    {message = "{rt1} " .. L["Soak"], duration = 4}
  }
end

function ReceiverOverlay.Initialize()
  ReceiverOverlay.Refresh()
end
