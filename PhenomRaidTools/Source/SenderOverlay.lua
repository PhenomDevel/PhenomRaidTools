local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local SenderOverlay = {}

local padding = 15

local headerColor = "FFFFF569"
local subHeaderColor = "FFFF7D0A"
local textColor = "FFFFFFFF"


-------------------------------------------------------------------------------
-- Local Helper

SenderOverlay.GenerateTimerString = function(timer)
    local timerString = ""
    
    if timer.started then
        local duration = PRT.Round(GetTime() - timer.startedAt, 0)
        timerString = PRT.Overlay.AddText(timerString, timer.name.." - "..duration.."s") 
    else
        timerString = PRT.Overlay.AddText(timerString, timer.name.." - inactive")  
    end

    return timerString
end

SenderOverlay.GenerateRotationString = function(rotation)
    local rotationString = ""
    
    if rotation.counter then
        local counter = rotation.counter
        rotationString = PRT.Overlay.AddText(rotationString, rotation.name.." - "..counter) 
    else
        rotationString = PRT.Overlay.AddText(rotationString, rotation.name.." - 1") 
    end

    return rotationString
end

SenderOverlay.UpdateFrame = function()
    if PRT.currentEncounter then        
        local overlayText = ""

        -- Timer
        if not table.empty(PRT.currentEncounter.encounter.Timers) then
            local timerString = ""
            for i, timer in ipairs(PRT.currentEncounter.encounter.Timers) do
                timerString = timerString..SenderOverlay.GenerateTimerString(timer)
            end

            overlayText = PRT.Overlay.AddSubHeading(overlayText, "Timers (s)")
            overlayText = overlayText..timerString            
        end

        -- Rotation
        if not table.empty(PRT.currentEncounter.encounter.Rotations) then
            local rotationString = ""
            for i, rotation in ipairs(PRT.currentEncounter.encounter.Rotations) do
                rotationString = rotationString..SenderOverlay.GenerateRotationString(rotation)
            end

            overlayText = PRT.Overlay.AddSubHeading(overlayText, "Rotations (counter)")
            overlayText = overlayText..rotationString
        end

        SenderOverlay.overlayFrame.text:SetText(overlayText)
    end    

    PRT.Overlay.UpdateSize(SenderOverlay.overlayFrame)
end

SenderOverlay.CreateOverlay = function(options)
    SenderOverlay.overlayFrame = PRT.Overlay.CreateOverlay(options, true)
    SenderOverlay.overlayFrame.header:SetText("PRT - Sender-Overlay")
    SenderOverlay.overlayFrame.text:SetJustifyH("LEFT")
    SenderOverlay.overlayFrame:SetPoint("CENTER", "UIParent", "CENTER", options.left, -options.top)
end

SenderOverlay.Hide = function()
    PRT.Overlay.Hide(SenderOverlay.overlayFrame)
end

SenderOverlay.Show = function()
    PRT.Overlay.Show(SenderOverlay.overlayFrame)
end

SenderOverlay.Initialize = function(options)
    if not SenderOverlay.overlayFrame and options.enabled then
        SenderOverlay.CreateOverlay(options)		
        SenderOverlay.UpdateFrame()
    end
end


-------------------------------------------------------------------------------
-- Public API

PRT.SenderOverlay = SenderOverlay