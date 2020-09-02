local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Overlay = {}
local padding = 15


-------------------------------------------------------------------------------
-- Public API

Overlay.SavePosition = function(widget, options)
    local left, top = widget:GetLeft(), widget:GetTop()

    options.top = UIParent:GetHeight() - top
    options.left = left
end

Overlay.UpdatePosition = function(container, options)
    if options then        
        container:ClearAllPoints()
        container:SetPoint("CENTER", "UIParent", "TOPLEFT", options.left, -options.top)
    end
end

Overlay.UpdateSize = function(container, options)
    local width = container.text:GetStringWidth()
    container:SetWidth(width + (2 * padding))

    local height = container.text:GetStringHeight()
    container:SetHeight(height + (2 * padding))    

    Overlay.UpdatePosition(container, options)
end

Overlay.UpdateFont = function(container, options)
    container.text:SetFont((options.font or GameFontHighlightSmall:GetFont()), options.fontSize, "OUTLINE")    
end

Overlay.UpdateBackdrop = function(container, r, g, b, a)
    container:SetBackdropColor(r, g, b, a);
end

Overlay.SetMoveable = function(widget, v)
    if widget then
        widget:EnableMouse(v)
        widget:SetMovable(v)
    end
end

Overlay.SetFont = function(container, options)
    container.text:SetFont((options.font or GameFontHighlightSmall:GetFont()), options.fontSize, "OUTLINE")
    Overlay.UpdateSize(container, options)
end

Overlay.CreateOverlay = function(options, withBackdrop)    
    local overlayFrame = CreateFrame("Frame", nil, UIParent)
    overlayFrame:EnableMouse(true)
    overlayFrame:SetMovable(true)
    overlayFrame:SetClampedToScreen(true)
    overlayFrame:RegisterForDrag("LeftButton")
    overlayFrame:SetScript("OnDragStart", overlayFrame.StartMoving)
    overlayFrame:SetScript("OnDragStop", 
        function(widget) 
            Overlay.SavePosition(widget, options) 
            overlayFrame:StopMovingOrSizing() 
        end)

    if withBackdrop then
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

        overlayFrame:SetBackdropColor((options.backdropColor.r or 0), (options.backdropColor.g or 0), (options.backdropColor.b or 0), (options.backdropColor.a or 0));
    end

    overlayFrame:SetFrameStrata("MEDIUM")
    overlayFrame:SetPoint("CENTER", "UIParent", "TOPLEFT", options.left, -options.top)

    overlayFrame.text = overlayFrame:CreateFontString(nil, "ARTWORK") 
    overlayFrame.text:SetJustifyH("CENTER")
    overlayFrame.text:SetFont(GameFontHighlightSmall:GetFont(), options.fontSize, "OUTLINE")
    overlayFrame.text:SetPoint("TOPLEFT", padding, -padding)
    overlayFrame.text:SetText("")

    return overlayFrame
end

Overlay.ClearText = function(widget)
    if widget then
        widget.text:SetText("")
    end
end

Overlay.Hide = function(widget)
    if widget then           
		Overlay.ClearText(widget)
        widget:Hide()
    end
end

Overlay.Show = function(widget)
    if widget then              
        Overlay.ClearText(widget)
        widget:Show()
    end
end

PRT.Overlay = Overlay