local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Overlay = {}

local padding = 15

local headerColor = "AABBCCFF"
local textColor = "FFFFFFFF"


-------------------------------------------------------------------------------
-- Local Helper

Overlay.SavePosition = function(widget)
    local left, bottom = widget:GetLeft(), widget:GetBottom()

    PRT.db.profile.overlay.bottom = bottom
    PRT.db.profile.overlay.left = left
end

Overlay.AddHeading = function(s, text)
    return s.."|c"..headerColor..text.."|r\n"
end

Overlay.AddText = function(s, text)
    return s.."|c"..textColor..text.."|r\n"
end

Overlay.AddTimersText = function(s, timers)
    
end


-------------------------------------------------------------------------------
-- Public API

Overlay.Open = function()
    local overlayFrame = CreateFrame("Frame",nil,UIParent)
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
    overlayFrame:SetWidth(100) 
    overlayFrame:SetHeight(100) 
    overlayFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", PRT.db.profile.overlay.left or 50, PRT.db.profile.overlay.bottom or 50)

    local text = ""
    text = Overlay.AddHeading(text, "PhenomRaidTools - Overlay")
    text = Overlay.AddText(text, "Timer")

    overlayFrame.text = overlayFrame:CreateFontString(nil, "ARTWORK") 
    overlayFrame.text:SetJustifyH("LEFT")
    overlayFrame.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
    overlayFrame.text:SetPoint("TOPLEFT", padding, -padding)
    overlayFrame.text:SetText(text)

    local width = overlayFrame.text:GetStringWidth()
    overlayFrame:SetWidth(width + (2 * padding))
end

PRT.Overlay = Overlay