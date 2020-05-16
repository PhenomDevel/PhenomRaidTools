local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local SenderOverlay = {
    timerColor = "FF00f276",
    rotationColor = "FFffa763",    
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

SenderOverlay.UpdateFrame = function(text)
    local encounter
    if PRT.currentEncounter then
        encounter = PRT.currentEncounter.encounter
    end

    local overlayText = text

    if encounter then        
        -- Set Header to encounter name
        local timeIntoCombat = PRT.SecondsToClock(GetTime() - encounter.startedAt)
        overlayText = encounter.name.." |cFF3d94ff"..timeIntoCombat.."|r\n"

        -- Timer
        if not table.empty(encounter.Timers) then
            local timerString = ""
            for i, timer in ipairs(encounter.Timers) do
                timerString = timerString..timer.name 
                
                if timer.started then
                    local timeIntoTimer = GetTime() - timer.startedAt
                    local timeIntoTimerString = PRT.SecondsToClock(timeIntoTimer)
                    timerString = timerString.." - |c"..SenderOverlay.timerColor..timeIntoTimerString.."|r "

                    local nextInSeconds, nextTiming = SenderOverlay.GetNextTiming(timer, timeIntoTimer)

                    if nextInSeconds then
                        local nextDelta = PRT.Round(nextInSeconds - timeIntoTimer)
                        timerString = timerString.."[-|c"..SenderOverlay.timerColor..PRT.SecondsToClock(nextDelta).."|r]\n"
                    else
                        timerString = timerString.."\n"
                    end
                else
                    timerString = timerString.." - |cFFFF0000inactive|r\n"
                end
            end

            overlayText = overlayText.."|c"..SenderOverlay.timerColor.."Timers|r\n"   
            overlayText = overlayText..timerString      
        end

        -- Rotation
        if not table.empty(encounter.Rotations) then
            local rotationString = ""
            for i, rotation in ipairs(encounter.Rotations) do
                rotationString = rotationString..rotation.name.." - |c"..SenderOverlay.rotationColor

                if rotation.counter then
                    rotationString = rotationString..rotation.counter.."|r\n"
                else
                    rotationString = rotationString.."0|r\n"
                end
            end

            overlayText = overlayText.."|c"..SenderOverlay.rotationColor    .."Rotations|r\n"  
            overlayText = overlayText..rotationString
        end        
    end    

    SenderOverlay.overlayFrame.text:SetText(overlayText)
    PRT.Overlay.UpdateSize(SenderOverlay.overlayFrame)
end

SenderOverlay.ShowPlaceholder = function()
    SenderOverlay.Show()
    SenderOverlay.overlayFrame.text:SetText("PhenomRaidTools")
    PRT.Overlay.UpdateSize(SenderOverlay.overlayFrame)
end

SenderOverlay.CreateOverlay = function(options)
    SenderOverlay.overlayFrame = PRT.Overlay.CreateOverlay(options, true)
    SenderOverlay.overlayFrame.text:SetJustifyH("LEFT")
    SenderOverlay.overlayFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", options.left, -options.top)
end

SenderOverlay.Hide = function()
    PRT.Overlay.Hide(SenderOverlay.overlayFrame)
end

SenderOverlay.Show = function()
    PRT.Overlay.Show(SenderOverlay.overlayFrame)
end

SenderOverlay.Initialize = function(options)
    if not SenderOverlay.overlayFrame and options.enabled then
        PRT.Debug("Initializing sender overlay")
        SenderOverlay.CreateOverlay(options)
        SenderOverlay.Hide()
    end
end


-------------------------------------------------------------------------------
-- Public API

PRT.SenderOverlay = SenderOverlay