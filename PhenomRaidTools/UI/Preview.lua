local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI
local Widgets = PRT.Widgets
local colors, fonts = Widgets.colors, Widgets.fonts

--[[
  Live preview next to the window: while a page edits something that shows
  on an overlay (an overlay's settings, an assignment), the panel beside the
  window plays it on a copy of that overlay, so there is no test button to
  press. Pages ask for it while building: UI.SetPreview(spec) with

    { kind = "receiver", config = receiver }
    { kind = "message", message = message }

  Any other page hides the panel. After a value changed the window calls
  Preview.Update(), which restarts the samples only if what they show changed.
]]

local Preview = {}
UI.Preview = Preview

local WIDTH, HEIGHT = 340, 300
local GAP = 8
local PADDING = 14
local HEADER = 52

local panel, overlay, current, signature

local function CreatePanel(window)
  panel = CreateFrame("Frame", nil, window)
  panel:SetSize(WIDTH, HEIGHT)
  panel:EnableMouse(true)
  Widgets.Fill(panel, colors.window)
  Widgets.Border(panel)
  panel.Title = Widgets.Text(panel, fonts.heading)
  panel.Title:SetPoint("TOPLEFT", PADDING, -PADDING)
  panel.Title:SetText(L["Preview"])
  panel.Note = Widgets.Text(panel, fonts.small)
  panel.Note:SetPoint("TOPLEFT", panel.Title, "BOTTOMLEFT", 0, -4)
  panel.Note:SetPoint("RIGHT", -PADDING, 0)

  -- The "screen": darker than the window, overlays are clipped to it.
  panel.Screen = CreateFrame("Frame", nil, panel)
  panel.Screen:SetPoint("TOPLEFT", PADDING, -HEADER)
  panel.Screen:SetPoint("BOTTOMRIGHT", -PADDING, PADDING)
  panel.Screen:SetClipsChildren(true)
  Widgets.Fill(panel.Screen, colors.screen)
  Widgets.Border(panel.Screen)

  overlay = PRT.ReceiverOverlay.CreatePreview(panel.Screen)
  -- Always right of the window, even partly off screen: a panel that changes
  -- sides while the window moves is more confusing than one cut off.
  panel:SetPoint("TOPLEFT", window, "TOPRIGHT", GAP, 0)
  panel:Hide()
end

local function Append(parts, value)
  if type(value) == "table" then
    local keys = {}
    for key in pairs(value) do
      keys[#keys + 1] = tostring(key)
    end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = key
      local entry = value[key]
      if entry == nil then
        entry = value[tonumber(key)]
      end
      Append(parts, entry)
    end
  else
    parts[#parts + 1] = tostring(value)
  end
end

local function Receiver(spec)
  if spec.kind == "receiver" then
    return spec.config
  end
  local receivers = PRT.GetProfileDB().overlay.receivers
  return receivers[spec.message.targetOverlay or 1] or receivers[1]
end

-- What the samples show: the overlay's settings and, for a message, its text.
local function Signature(spec)
  local parts = {}
  Append(parts, Receiver(spec))
  if spec.kind == "message" then
    local message = spec.message
    Append(parts, {message.message, message.duration, message.spellID, message.type})
  end
  return table.concat(parts, "\001")
end

local function Samples(spec, config)
  if spec.kind == "receiver" then
    return PRT.ReceiverOverlay.SampleMessages(config)
  end
  local message = spec.message
  return {{message = message.message or "", duration = message.duration or 5, spellID = message.spellID}}
end

local function Play()
  local config = Receiver(current)
  if not config then
    overlay:Hide()
    return
  end
  if current.kind == "receiver" then
    panel.Note:SetText(L["Changes show right away."])
  else
    panel.Note:SetText(L["On %s, as your players see it."]:format(config.label or "?"))
  end
  overlay:Show(config, Samples(current, config))
end

-- After a page was built: show the panel for its spec, or hide it.
function Preview.Apply(window, spec)
  if not spec then
    Preview.Hide()
    return
  end
  if not panel then
    CreatePanel(window)
  end
  panel:Show()
  local newSignature = Signature(spec)
  local changed = not current or current.kind ~= spec.kind or newSignature ~= signature or not overlay.config
  current, signature = spec, newSignature
  if changed then
    Play()
  end
end

-- A value changed: replay if the overlay or the message look different now.
function Preview.Update()
  if not (panel and panel:IsShown() and current) then
    return
  end
  local newSignature = Signature(current)
  if newSignature ~= signature then
    signature = newSignature
    Play()
  end
end

function Preview.Hide()
  if panel then
    panel:Hide()
    overlay:Hide()
  end
  current, signature = nil, nil
end
