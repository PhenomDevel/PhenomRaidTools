local _, PRT = ...
local Media = LibStub("LibSharedMedia-3.0")

local Overlay = {}
local padding = 15

-- Create local copies of API functions which we use
local UIParent, GameFontHighlightSmall = UIParent, GameFontHighlightSmall

-------------------------------------------------------------------------------
-- Public API

function Overlay.SavePosition(frame, options)
  local left, top = frame:GetLeft(), frame:GetTop()

  if options.anchor == "CENTER" then
    left = left + (frame.text:GetStringWidth() / 2) + padding
    top = top - (frame.text:GetStringHeight() / 2) - padding
  end

  options.top = UIParent:GetHeight() - top
  options.left = left
end

function Overlay.UpdatePosition(frame, options)
  if options then
    frame:ClearAllPoints()
    frame:SetPoint(options.anchor or "CENTER", "UIParent", "TOPLEFT", options.left, -options.top)
  end
end

function Overlay.UpdateSize(frame, options)
  local width = frame.text:GetStringWidth()
  frame:SetWidth(width + (2 * padding))

  local height = frame.text:GetStringHeight()
  frame:SetHeight(height + (2 * padding))

  Overlay.UpdatePosition(frame, options)
end

function Overlay.UpdateFont(frame, options)
  local font

  if Media:HashTable("font")[options.fontName] then
    font = options.font
  else
    font = GameFontHighlightSmall:GetFont()
  end

  frame.text:SetFont(font, options.fontSize, "OUTLINE")
end

function Overlay.UpdateBackdrop(frame, options)
  if options then
    if options.locked then
      frame:SetBackdropColor(0, 0, 0, 0)
    else
      if options.backdropColor then
        frame:SetBackdropColor((options.backdropColor.r or 0), (options.backdropColor.g or 0), (options.backdropColor.b or 0), (options.backdropColor.a or 0.7))
      else
        frame:SetBackdropColor(0, 0, 0, 0.7)
      end
    end
  end
end

function Overlay.UpdateFrame(frame, options)
  Overlay.UpdateFont(frame, options)
  Overlay.UpdateSize(frame, options)
  Overlay.UpdateBackdrop(frame, options)
  Overlay.UpdatePosition(frame, options)
end

function Overlay.SetMoveable(frame, v)
  if frame then
    frame:EnableMouse(v)
    frame:SetMovable(v)
  end
end

function Overlay.SetFont(frame, options)
  frame.text:SetFont((options.font or GameFontHighlightSmall:GetFont()), options.fontSize, "OUTLINE")
  Overlay.UpdateSize(frame, options)
end

function Overlay.CreateOverlay(options, withBackdrop)
  local overlayFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  overlayFrame:SetWidth(1)
  overlayFrame:SetHeight(1)
  overlayFrame:EnableMouse(true)
  overlayFrame:SetMovable(true)
  overlayFrame:SetClampedToScreen(true)
  overlayFrame:RegisterForDrag("LeftButton")
  overlayFrame:SetScript("OnDragStart", overlayFrame.StartMoving)
  overlayFrame:SetScript(
    "OnDragStop",
    function(frame)
      Overlay.SavePosition(frame, options)
      overlayFrame:StopMovingOrSizing()
    end
  )

  if withBackdrop then
    overlayFrame:SetBackdrop(
      {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = nil,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
          left = 4,
          right = 4,
          top = 4,
          bottom = 4
        }
      }
    )

    overlayFrame:SetBackdropColor(0, 0, 0, 0)
  end

  overlayFrame:SetPoint("CENTER", 0, 0)
  overlayFrame.text = overlayFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  overlayFrame.text:SetFont(GameFontHighlightSmall:GetFont(), options.fontSize, "OUTLINE")
  overlayFrame.text:SetText("")

  return overlayFrame
end

function Overlay.ClearText(frame)
  if frame then
    frame.text:SetText("")
  end
end

function Overlay.Hide(frame)
  if frame then
    Overlay.ClearText(frame)
    frame:Hide()
  end
end

function Overlay.Show(frame)
  if frame then
    Overlay.ClearText(frame)
    frame:Show()
  end
end

PRT.Overlay = Overlay
