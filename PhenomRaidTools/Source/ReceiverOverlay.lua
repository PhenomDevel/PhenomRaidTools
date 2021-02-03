local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local ReceiverOverlay = {
  messageStack = {}
}

-- Create local copies of API functions which we use
local GameFontHighlightSmall = GameFontHighlightSmall


-------------------------------------------------------------------------------
-- Local Helper

function ReceiverOverlay.ClearMessageStack()
  ReceiverOverlay.messageStack = {}
end

function ReceiverOverlay.AddMessage(messageTable)
  local receiverOverlayFrame = PRT.db.profile.overlay.receivers[(messageTable.targetOverlay or 1)]

  messageTable.expirationTime = GetTime() + (messageTable.duration or 5)
  if receiverOverlayFrame.enableSound then
    local soundFile = messageTable.soundFile
    local customWillPlay

    if soundFile and messageTable.useCustomSound then
      customWillPlay = PlaySoundFile(soundFile, "Master")
    end

    if not customWillPlay then
      if receiverOverlayFrame.defaultSoundFile then
        -- Play default soundfile if configured sound does not exist
        PlaySoundFile(receiverOverlayFrame.defaultSoundFile, "Master")
      else
        PRT.Warn("Tried to play default sound but there was a problem. Try selecting another sound as default sound.")
      end
    end
  end
  messageTable.message = PRT.PrepareMessageForDisplay(messageTable.message)
  local index = #ReceiverOverlay.messageStack+1
  ReceiverOverlay.messageStack[index] = messageTable
  AceTimer:ScheduleTimer(
    function()
      ReceiverOverlay.messageStack[index] = ""
      ReceiverOverlay.UpdateFrameText()
    end,
    (messageTable.duration or 5))

  ReceiverOverlay.UpdateFrameText()
end

function ReceiverOverlay.ShowPlaceholder(frame, options, _)
  local text = ""

  if options then
    text = options.name..": "..(options.label or "LABEL")
  else
    text = (text or "Placeholder")
  end

  if not options.locked then
    text = text.."\nDrag to move"
  end

  local color = PRT.RGBAToHex(options.fontColor.r, options.fontColor.g, options.fontColor.b, options.fontColor.a)

  frame.text:SetText(PRT.ColoredString(text, color))
  PRT.Overlay.UpdateSize(frame)
end

function ReceiverOverlay.UpdateFrameText()
  for frameIndex, frame in ipairs(ReceiverOverlay.overlayFrames) do
    local text = ""

    for _, message in pairs(ReceiverOverlay.messageStack) do
      if message ~= "" then
        -- Add text only to corresponding frame
        if (message.targetOverlay or 1) == frameIndex then
          if message.expirationTime > GetTime() then
            local timeLeftRaw = message.expirationTime - GetTime()
            local timeLeft = PRT.Round(timeLeftRaw, 2)
            local color = (PRT.db.profile.overlay.receivers[frameIndex].fontColor.hex or "FFFFFFFF")

            if text == "" then
              text = PRT.ColoredString(string.format(message.message, timeLeft), color)
            else
              text = text.."|n"..PRT.ColoredString(string.format(message.message, timeLeft), color)
            end
          end
        end
      end
    end

    frame.text:SetText(text)
    PRT.Overlay.UpdateSize(frame)
  end
end

function ReceiverOverlay.UpdateFrame(frame, options)
  PRT.Overlay.UpdateSize(frame, options)
  PRT.Overlay.UpdateBackdrop(frame, options)
  PRT.Overlay.UpdateFont(frame, options)
  PRT.Overlay.UpdatePosition(frame, options)
end

function ReceiverOverlay.CreateOverlay(options)
  local overlayFrame = PRT.Overlay.CreateOverlay(options, true)
  overlayFrame:ClearAllPoints()
  overlayFrame:SetPoint("CENTER", "UIParent", "CENTER", options.left, -options.top)

  overlayFrame.text:SetJustifyH("CENTER")
  overlayFrame.text:SetPoint("CENTER")
  overlayFrame.text:SetFont((options.font or GameFontHighlightSmall:GetFont()), options.fontSize, "OUTLINE")

  PRT.Overlay.SetMoveable(overlayFrame, false)

  return overlayFrame
end

function ReceiverOverlay.Hide(frame)
  PRT.Overlay.Hide(frame)
end

function ReceiverOverlay.Show(frame)
  PRT.Overlay.Show(frame)
end

function ReceiverOverlay.HideAll()
  if ReceiverOverlay.overlayFrames then
    for _, overlayFrame in ipairs(ReceiverOverlay.overlayFrames) do
      PRT.Overlay.Hide(overlayFrame)
    end
  end
end

function ReceiverOverlay.ShowAll()
  if ReceiverOverlay.overlayFrames then
    for _, overlayFrame in ipairs(ReceiverOverlay.overlayFrames) do
      PRT.Overlay.Show(overlayFrame)
    end
  end
end

function ReceiverOverlay.Initialize(receivers)
  if not ReceiverOverlay.overlayFrames then
    ReceiverOverlay.overlayFrames = {}

    for i, receiver in ipairs(receivers) do
      PRT.Debug("Initializing receiver overlay"..i)
      local receiverOverlay = ReceiverOverlay.CreateOverlay(receiver)

      if not receiver.locked then
        PRT.Overlay.UpdateBackdrop(receiverOverlay, receiver)
        PRT.Overlay.SetMoveable(receiverOverlay, true)
        receiverOverlay.text:SetText("Placeholder")
      end

      PRT.Overlay.UpdateSize(receiverOverlay, receiver)

      tinsert(ReceiverOverlay.overlayFrames, receiverOverlay)
    end
  end
end


-------------------------------------------------------------------------------
-- Public API

PRT.ReceiverOverlay = ReceiverOverlay
