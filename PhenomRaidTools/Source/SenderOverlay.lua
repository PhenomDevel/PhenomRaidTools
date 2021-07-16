local _, PRT = ...

local SenderOverlay = {}

-- Create local copies of API functions which we use
local GameFontHighlightSmall = GameFontHighlightSmall

-------------------------------------------------------------------------------
-- Local Helper

function SenderOverlay.GetNextTiming(timer, seconds)
  local nextTiming
  local lowestSecond

  for _, timing in ipairs(timer.timings) do
    for _, second in ipairs(timing.seconds) do
      local secondWithOffset = second + (timing.offset or 0)
      if secondWithOffset < (lowestSecond or 999999) and secondWithOffset > seconds then
        nextTiming = timing
        lowestSecond = second
      end
    end
  end

  return lowestSecond, nextTiming
end

function SenderOverlay.UpdateFrame(encounter, options)
  local overlayText

  if encounter then
    -- Set Header to encounter name
    local timeIntoCombat = PRT.SecondsToClock(GetTime() - encounter.startedAt)
    overlayText = PRT.ColoredString(encounter.name, PRT.Static.Colors.Primary) .. " (" .. PRT.ColoredString(timeIntoCombat, PRT.Static.Colors.Secondary) .. ")|n"

    -- Timer
    if not PRT.TableUtils.IsEmpty(encounter.Timers) then
      local timerStringComplete = ""

      for _, timer in ipairs(encounter.Timers) do
        local timerString = ""

        if timer.enabled or (not timer.enabled and not options.hideDisabledTriggers) then
          timerString = timerString .. PRT.ColoredString(timer.name, PRT.Static.Colors.Tertiary)

          if timer.started then
            local timeIntoTimer = GetTime() - timer.startedAt
            local timeIntoTimerString = PRT.SecondsToClock(timeIntoTimer)
            timerString = timerString .. " (" .. PRT.ColoredString(timeIntoTimerString, PRT.Static.Colors.Secondary) .. ")"

            local nextInSeconds, nextTiming = SenderOverlay.GetNextTiming(timer, timeIntoTimer)

            if nextInSeconds then
              local nextDelta = PRT.Round((nextInSeconds + (nextTiming.offset or 0)) - timeIntoTimer)
              timerString = timerString .. " [-" .. PRT.ColoredString(PRT.SecondsToClock(nextDelta), PRT.Static.Colors.Secondary) .. "]|n"
            else
              timerString = timerString .. "|n"
            end
          elseif timer.enabled ~= true then
            timerString = PRT.ColoredString(timerString .. " - disabled|n", PRT.Static.Colors.Disabled)
          else
            timerString = PRT.ColoredString(string.format(timerString .. " - inactive (%s/%s)|n", timer.occurence or 0, timer.triggerAtOccurence), PRT.Static.Colors.Inactive)
          end
        end

        timerStringComplete = timerStringComplete .. timerString
      end

      overlayText = overlayText .. PRT.ColoredString("Timers|n", PRT.Static.Colors.Secondary)
      overlayText = overlayText .. timerStringComplete
    end

    -- Rotation
    if not PRT.TableUtils.IsEmpty(encounter.Rotations) then
      local rotationStringComplete = ""

      for _, rotation in ipairs(encounter.Rotations) do
        local rotationString = ""

        if rotation.enabled or (not rotation.enabled and not options.hideDisabledTriggers) then
          rotationString = rotationString .. rotation.name

          if rotation.enabled ~= true then
            rotationString = PRT.ColoredString(rotationString .. " - disabled|n", PRT.Static.Colors.Disabled)
          else
            local isRotationActive = PRT.IsTriggerActive(rotation)

            if not isRotationActive then
              rotationString =
                PRT.ColoredString(string.format(rotationString .. " - inactive (%s/%s)|n", rotation.occurence or 0, rotation.triggerAtOccurence), SenderOverlay.inactiveColor)
            elseif isRotationActive and rotation.counter then
              rotationString = rotationString .. " - " .. PRT.ColoredString(rotation.counter, PRT.Static.Colors.Secondary) .. "|n"
            else
              rotationString = rotationString .. " - 0|n"
            end
          end
        end

        rotationStringComplete = rotationStringComplete .. rotationString
      end

      overlayText = overlayText .. "|n" .. PRT.ColoredString("Rotations", PRT.Static.Colors.Secondary) .. "|n"
      overlayText = overlayText .. rotationStringComplete
    end
  end

  SenderOverlay.overlayFrame.text:SetText(overlayText)
  PRT.Overlay.UpdateSize(SenderOverlay.overlayFrame, options)
  PRT.Overlay.UpdateBackdrop(SenderOverlay.overlayFrame, options)
end

function SenderOverlay.ShowPlaceholder(overlayFrame, options)
  SenderOverlay.Show()
  overlayFrame.text:SetText("PhenomRaidTools")
  PRT.Overlay.UpdateSize(overlayFrame, options)
  PRT.Overlay.UpdateBackdrop(overlayFrame, options)
end

function SenderOverlay.CreateOverlay(options)
  SenderOverlay.overlayFrame = PRT.Overlay.CreateOverlay(options, true)
  SenderOverlay.overlayFrame.text:SetJustifyH("LEFT")
  SenderOverlay.overlayFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", options.left, -options.top)
  SenderOverlay.overlayFrame.text:SetPoint("TOPLEFT", 15, -15)
  SenderOverlay.overlayFrame.text:SetFont((options.font or GameFontHighlightSmall:GetFont()), options.fontSize, "OUTLINE")
end

function SenderOverlay.Hide()
  PRT.Overlay.Hide(SenderOverlay.overlayFrame)
end

function SenderOverlay.Show()
  PRT.Overlay.Show(SenderOverlay.overlayFrame)
end

function SenderOverlay.Lock()
  PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, false)
end

function SenderOverlay.Unlock()
  PRT.Overlay.SetMoveable(PRT.SenderOverlay.overlayFrame, true)
end

function SenderOverlay.Initialize(options)
  if not SenderOverlay.overlayFrame then
    PRT.Debug("Initializing sender overlay")
    SenderOverlay.CreateOverlay(options)
  end

  if not options.enabled then
    SenderOverlay.Hide()
  end
end

function SenderOverlay.ReInitialize(senderOptions)
  SenderOverlay.Hide()
  SenderOverlay.overlayFrame = nil
  SenderOverlay.Initialize(senderOptions)
  SenderOverlay.Show()
end

-------------------------------------------------------------------------------
-- Public API

PRT.SenderOverlay = SenderOverlay
