local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local SenderOverlay = {
    timerColor = "FF1aBB00",
    rotationColor = "FFcc1100",   
    disabledColor = "FFb30c00",
    inactiveColor = "FF8f8f8f"
}


-------------------------------------------------------------------------------
-- Local Helper

local inactiveColor = function(s)
    return "|c"..SenderOverlay.inactiveColor..s.."|r"
end

local disabledColor = function(s)
    return "|c"..SenderOverlay.disabledColor..s.."|r"
end

local timerColor = function(s)
    return "|c"..SenderOverlay.timerColor..s.."|r"
end

local rotationColor = function(s)
    return "|c"..SenderOverlay.rotationColor..s.."|r"
end

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
        overlayText = encounter.name.." (|cFF3d94ff"..timeIntoCombat.."|r)\n"

        -- Timer
        if not table.empty(encounter.Timers) then
            local timerStringComplete = ""
            for i, timer in ipairs(encounter.Timers) do
                local timerString = ""
                timerString = timerString..timer.name 
                
                if timer.started then
                    local timeIntoTimer = GetTime() - timer.startedAt
                    local timeIntoTimerString = PRT.SecondsToClock(timeIntoTimer)
                    timerString = timerString.." ("..timerColor(timeIntoTimerString)..")"

                    local nextInSeconds, nextTiming = SenderOverlay.GetNextTiming(timer, timeIntoTimer)

                    if nextInSeconds then
                        local nextDelta = PRT.Round(nextInSeconds - timeIntoTimer)
                        timerString = timerString.." [-"..timerColor(PRT.SecondsToClock(nextDelta)).."]\n"
                    else
                        timerString = timerString.."\n"
                    end
                elseif timer.enabled ~= true then
                    timerString = disabledColor(timerString.." - disabled\n")
                else
                    timerString = inactiveColor(timerString.." - inactive\n")
                end

                timerStringComplete = timerStringComplete..timerString
            end

            overlayText = overlayText..timerColor("Timers\n")
            overlayText = overlayText..timerStringComplete
        end

        -- Rotation
        if not table.empty(encounter.Rotations) then
            local rotationString = ""
            for i, rotation in ipairs(encounter.Rotations) do
                rotationString = rotationString..rotation.name.." - |c"..SenderOverlay.rotationColor

                if rotation.enabled ~= true then
                    rotationString = rotationString.."|cFFFF0000disabled|r\n"
                else
                    if rotation.counter then
                        rotationString = rotationString..rotation.counter.."|r\n"
                    else
                        rotationString = rotationString.."0|r\n"
                    end
                end
            end

            overlayText = overlayText.."|c"..SenderOverlay.rotationColor    .."Rotations|r\n"  
            overlayText = overlayText..rotationString
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