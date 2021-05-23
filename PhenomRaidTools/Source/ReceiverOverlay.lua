local _, PRT = ...

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
  local receiverOverlayOptions = PRT.GetProfileDB().overlay.receivers[(messageTable.targetOverlay or 1)]

  messageTable.expirationTime = GetTime() + (messageTable.duration or 5)
  if receiverOverlayOptions.enableSound then
    local soundFile = messageTable.soundFile
    local customWillPlay

    if soundFile and messageTable.useCustomSound then
      customWillPlay = PlaySoundFile(soundFile, "Master")
    end

    if not customWillPlay then
      if receiverOverlayOptions.defaultSoundFile then
        -- Play default soundfile if configured sound does not exist
        PlaySoundFile(receiverOverlayOptions.defaultSoundFile, "Master")
      else
        PRT.Warn("Tried to play default sound but there was a problem. Try selecting another sound as default sound.")
      end
    end
  end
  messageTable.message = PRT.PrepareMessageForDisplay(messageTable.message)
  local index = #ReceiverOverlay.messageStack + 1
  ReceiverOverlay.messageStack[index] = messageTable
  AceTimer:ScheduleTimer(
    function()
      ReceiverOverlay.messageStack[index] = ""
      ReceiverOverlay.UpdateFrameText()
    end,
    (messageTable.duration or 5)
  )

  ReceiverOverlay.UpdateFrameText()
end

function ReceiverOverlay.ShowPlaceholder(frame, options, _)
  local text = ""

  if options then
    text = options.name .. ": " .. (options.label or "LABEL")
  else
    text = (text or "Placeholder")
  end

  if not options.locked then
    text = text .. "\nDrag to move"
  end

  local color = PRT.RGBAToHex(options.fontColor.r, options.fontColor.g, options.fontColor.b, options.fontColor.a)

  frame.text:SetText(PRT.ColoredString(text, color, true))
  PRT.Overlay.UpdateSize(frame)
end

function ReceiverOverlay.ShowPlaceholders(receiverOptions)
  for i, receiverOverlay in ipairs(receiverOptions) do
    local frame = PRT.ReceiverOverlay.overlayFrames[i]
    ReceiverOverlay.ShowPlaceholder(frame, receiverOverlay)
  end
end

function ReceiverOverlay.UpdateFrameText()
  for frameIndex, frame in ipairs(ReceiverOverlay.overlayFrames) do
    local receiverOverlayOptions = PRT.GetProfileDB().overlay.receivers[frameIndex]
    local text = ""

    local startIndex = 1
    local step = 1
    local endIndex = #ReceiverOverlay.messageStack

    if (receiverOverlayOptions.growDirection or "UP") == "UP" then
      startIndex = #ReceiverOverlay.messageStack
      endIndex = 1
      step = -1
    end

    for i = startIndex, endIndex, step do
      local message = ReceiverOverlay.messageStack[i]
      if message ~= "" then
        -- Add text only to corresponding frame
        if (message.targetOverlay or 1) == frameIndex then
          if message.expirationTime > GetTime() then
            local timeLeftRaw = message.expirationTime - GetTime()
            local timeLeft = PRT.Round(timeLeftRaw, 2)
            local color = (PRT.GetProfileDB().overlay.receivers[frameIndex].fontColor.hex or "FFFFFFFF")

            if text == "" then
              text = PRT.ColoredString(string.format(message.message, timeLeft), color, true)
            else
              text = text .. "|n" .. PRT.ColoredString(string.format(message.message, timeLeft), color, true)
            end
          end
        end
      end
    end

    frame.text:SetText(text)
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

  if options.growDirection == "UP" then
    overlayFrame.text:SetPoint("BOTTOM", 0, 15)
  else
    overlayFrame.text:SetPoint("TOP", 0, -15)
  end

  overlayFrame.text:SetJustifyH("CENTER")
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

function ReceiverOverlay.Initialize(receiverOptions)
  if PRT.TableUtils.IsEmpty(ReceiverOverlay.overlayFrames) then
    ReceiverOverlay.overlayFrames = {}

    for i, receiver in ipairs(receiverOptions) do
      PRT.Debug("Initializing receiver overlay", i)
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

function ReceiverOverlay.ReInitialize(receiverOptions)
  ReceiverOverlay.HideAll()
  ReceiverOverlay.overlayFrames = nil
  ReceiverOverlay.Initialize(receiverOptions)
  ReceiverOverlay.ShowAll()
end

-------------------------------------------------------------------------------
-- Public API

PRT.ReceiverOverlay = ReceiverOverlay
