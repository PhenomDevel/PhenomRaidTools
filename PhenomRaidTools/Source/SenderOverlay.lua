local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local SenderOverlay = {
    timerColor = "ff009dff",
    rotationColor = "ff80ff00",   
    disabledColor = "FFb30c00",
    inactiveColor = "FF8f8f8f"
}


-------------------------------------------------------------------------------
-- Local Helper

SenderOverlay.GetNextTiming = function(timer, seconds)
    local nextTiming
    local lowestSecond

    for i, timing in ipairs(timer.timings) do
        for i, second in ipairs(timing.seconds) do
            if second < (lowestSecond or 999999) and second > seconds then
                nextTiming = timing
                lowestSecond = second
            end
        end
    end

    return lowestSecond, nextTiming    
end

SenderOverlay.UpdateFrame = function(encounter, options)
    local overlayText = text

    if encounter then        
        -- Set Header to encounter name
        local timeIntoCombat = PRT.SecondsToClock(GetTime() - encounter.startedAt)
        overlayText = encounter.name.." ("..PRT.HighlightString(timeIntoCombat)..")|n"

        -- Timer
        if not table.empty(encounter.Timers) then
            local timerStringComplete = ""

            for i, timer in ipairs(encounter.Timers) do
                local timerString = ""
                
                if timer.enabled or (not timer.enabled and not options.hideDisabledTriggers) then
                    timerString = timerString..timer.name 
                    
                    if timer.started then
                        local timeIntoTimer = GetTime() - timer.startedAt
                        local timeIntoTimerString = PRT.SecondsToClock(timeIntoTimer)
                        timerString = timerString.." ("..PRT.ColoredString(timeIntoTimerString, SenderOverlay.timerColor)..")"

                        local nextInSeconds, nextTiming = SenderOverlay.GetNextTiming(timer, timeIntoTimer)

                        if nextInSeconds then
                            local nextDelta = PRT.Round(nextInSeconds - timeIntoTimer)
                            timerString = timerString.." [-"..PRT.ColoredString(PRT.SecondsToClock(nextDelta), SenderOverlay.timerColor).."]|n"
                        else
                            timerString = timerString.."|n"
                        end
                    elseif timer.enabled ~= true then
                        timerString = PRT.ColoredString(timerString.." - disabled|n", SenderOverlay.disabledColor)
                    else
                        timerString = PRT.ColoredString(timerString.." - inactive|n", SenderOverlay.inactiveColor)
                    end
                end

                timerStringComplete = timerStringComplete..timerString
            end

            overlayText = overlayText..PRT.ColoredString("Timers|n", SenderOverlay.timerColor)
            overlayText = overlayText..timerStringComplete
        end

        -- Rotation
        if not table.empty(encounter.Rotations) then
            local rotationStringComplete = ""

            for i, rotation in ipairs(encounter.Rotations) do
                local rotationString = ""

                if rotation.enabled or (not rotation.enabled and not options.hideDisabledTriggers) then
                    rotationString = rotationString..rotation.name

                    if rotation.enabled ~= true then
                        rotationString = PRT.ColoredString(rotationString.." - disabled|n", SenderOverlay.disabledColor)
                    else
                        if rotation.counter then
                            rotationString = rotationString.." - "..PRT.ColoredString(rotation.counter, SenderOverlay.rotationColor).."|n"
                        else
                            rotationString = rotationString.." - 0|n"
                        end
                    end
                end

                rotationStringComplete = rotationStringComplete..rotationString
            end

            overlayText = overlayText.."|n"..PRT.ColoredString("Rotations", SenderOverlay.rotationColor).."|n"
            overlayText = overlayText..rotationStringComplete
        end
    end    

    SenderOverlay.overlayFrame.text:SetText(overlayText)
    PRT.Overlay.UpdateSize(SenderOverlay.overlayFrame, options)
end

SenderOverlay.ShowPlaceholder = function(options)
    SenderOverlay.Show()
    SenderOverlay.overlayFrame.text:SetText("PhenomRaidTools")
    PRT.Overlay.UpdateSize(SenderOverlay.overlayFrame, options)
end

SenderOverlay.CreateOverlay = function(options)
    SenderOverlay.overlayFrame = PRT.Overlay.CreateOverlay(options, true)
    SenderOverlay.overlayFrame.text:SetJustifyH("LEFT")
    SenderOverlay.overlayFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", options.left, -options.top)
    SenderOverlay.overlayFrame.text:SetFont((options.font or GameFontHighlightSmall:GetFont()), options.fontSize, "OUTLINE")
end

SenderOverlay.Hide = function()
    PRT.Overlay.Hide(SenderOverlay.overlayFrame)
end

SenderOverlay.Show = function()
    PRT.Overlay.Show(SenderOverlay.overlayFrame)
end

SenderOverlay.Initialize = function(options)    
    if not SenderOverlay.overlayFrame then
        PRT.Debug("Initializing sender overlay")
        SenderOverlay.CreateOverlay(options)        
    end

    if not options.enabled then                        
        SenderOverlay.Hide()
    end
end


-------------------------------------------------------------------------------
-- Public API

PRT.SenderOverlay = SenderOverlay