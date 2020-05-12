local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Overlay = {}

local padding = 15

local headerColor = "AABBCCFF"
local subHeaderColor = "FFCCBBAA"
local textColor = "FFFFFFFF"


-------------------------------------------------------------------------------
-- Local Helper

Overlay.SavePosition = function(widget)
    local left, top = widget:GetLeft(), widget:GetTop()

    PRT.db.profile.overlay.top = UIParent:GetHeight() - top
    PRT.db.profile.overlay.left = left
end

Overlay.AddHeading = function(s, text)
    return s.."|c"..headerColor..text.."|r\n"
end

Overlay.AddSubHeading = function(s, text)
    return s.."|c"..subHeaderColor..text.."|r\n"
end

Overlay.AddText = function(s, text)
    return s.."|c"..textColor..text.."|r\n"
end

Overlay.AddTimersText = function(s, timers)
    
end

Overlay.GenerateTimerString = function(timer)
    local timerString = ""
    
    if timer.started then
        local duration = PRT.Round(GetTime() - timer.startedAt, 0)
        timerString = Overlay.AddText(timerString, timer.name.." - "..duration.."s") 
    else
        timerString = Overlay.AddText(timerString, timer.name.." - inactive")  
    end

    return timerString
end

Overlay.GenerateRotationString = function(rotation)
    local rotationString = ""
    
    if rotation.counter then
        local counter = rotation.counter
        rotationString = Overlay.AddText(rotationString, rotation.name.." - "..counter) 
    else
        rotationString = Overlay.AddText(rotationString, rotation.name.." - 1") 
    end

    return rotationString
end

Overlay.UpdateSize = function()
    local headerWidth = Overlay.overlayFrame.header:GetStringWidth()
    local width = Overlay.overlayFrame.text:GetStringWidth()
    Overlay.overlayFrame:SetWidth(math.max(width, headerWidth) + (2 * padding))

    local headerHeight = Overlay.overlayFrame.header:GetStringHeight()
    local height = Overlay.overlayFrame.text:GetStringHeight()
    Overlay.overlayFrame:SetHeight(height + headerHeight + (2 * padding))
end

Overlay.UpdateFrame = function()
    if PRT.currentEncounter then
        -- Timer
        local timerString = ""
        for i, timer in ipairs(PRT.currentEncounter.encounter.Timers) do
            timerString = timerString..Overlay.GenerateTimerString(timer)
        end

        -- Rotation
        local rotationString = ""
        for i, rotation in ipairs(PRT.currentEncounter.encounter.Rotations) do
            rotationString = Overlay.AddText(rotationString, Overlay.GenerateRotationString(rotation))
        end

        local overlayText = ""

        -- Add Timer String
        overlayText = Overlay.AddSubHeading(overlayText, "Timers (s)")
        overlayText = overlayText..timerString
        overlayText = overlayText.."\n"

        -- Add Rotation String
        overlayText = Overlay.AddSubHeading(overlayText, "Rotations (counter)")
        overlayText = overlayText..rotationString

        Overlay.overlayFrame.text:SetText(overlayText)
    end    

    Overlay.UpdateSize()
end

Overlay.CreateOverlay = function()
    PRT.Debug("Creating overlay")
    local overlayFrame = CreateFrame("Frame", nil, UIParent)
    overlayFrame:EnableMouse(true)
    overlayFrame:SetMovable(true)
    overlayFrame:SetClampedToScreen(true)
    overlayFrame:RegisterForDrag("LeftButton")
    overlayFrame:SetScript("OnDragStart", overlayFrame.StartMoving)
    overlayFrame:SetScript("OnDragStop", 
        function(widget) 
            Overlay.SavePosition(widget) 
            overlayFrame:StopMovingOrSizing() 
        end)

    overlayFrame:SetBackdrop(
        {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
            edgeFile = nil, 
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { 
                left = 4, 
                right = 4, 
                top = 4, 
                bottom = 4 
        }});

    overlayFrame:SetBackdropColor(0, 0, 0, 0.7);
    overlayFrame:SetFrameStrata("MEDIUM")
    overlayFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", PRT.db.profile.overlay.left, -PRT.db.profile.overlay.top)

    overlayFrame.text = overlayFrame:CreateFontString(nil, "ARTWORK") 
    overlayFrame.text:SetJustifyH("LEFT")
    overlayFrame.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
    overlayFrame.text:SetPoint("TOPLEFT", padding, 2 * -padding)
    overlayFrame.text:SetText(text)

    local header = "PhenomRaidTools"
    overlayFrame.header = overlayFrame:CreateFontString(nil, "ARTWORK") 
    overlayFrame.header:SetJustifyH("LEFT")
    overlayFrame.header:SetFont("Fonts\\ARIALN.ttf", 16, "OUTLINE")
    overlayFrame.header:SetPoint("TOPLEFT", padding, -padding)
    overlayFrame.header:SetText(header)

    Overlay.overlayFrame = overlayFrame
end

Overlay.ClearText = function()
    if Overlay.overlayFrame then
        PRT.Debug("Clearing overlay text")
        Overlay.overlayFrame.text:SetText("")

        Overlay.UpdateSize()
    end
end

Overlay.Hide = function()
    if Overlay.overlayFrame then    
        PRT.Debug("Hide overlay")        
		Overlay.ClearText()
        Overlay.overlayFrame:Hide()
    end
end

Overlay.Show = function()
    if Overlay.overlayFrame then        
        PRT.Debug("Show overlay")        
        Overlay.ClearText()
        Overlay.UpdateFrame()
        Overlay.UpdateSize()
        Overlay.overlayFrame:Show()
    end
end

Overlay.Initialize = function()
    Overlay.CreateOverlay()		
    Overlay.UpdateFrame()
    Overlay.Show()
end

-------------------------------------------------------------------------------
-- Public API

PRT.Overlay = Overlay