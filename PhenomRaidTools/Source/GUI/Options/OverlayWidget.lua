local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Overlay = {}


-------------------------------------------------------------------------------
-- Private Helper

function Overlay.AddPositionSliderGroup(container, overlayFrame, options)
  local positionGroup = PRT.InlineGroup(L["Position"])
  positionGroup:SetLayout("List")

  local screenWidth = PRT.Round(GetScreenWidth())
  local screenHeight = PRT.Round(GetScreenHeight())

  local positionXSlider = PRT.Slider(L["X Offset"], nil, PRT.Round(options.left, 1))
  positionXSlider:SetRelativeWidth(1)
  positionXSlider:SetSliderValues(0, screenWidth, 0.1)
  positionXSlider:SetCallback("OnValueChanged",
    function(widget)
      local positionX = widget:GetValue()
      options.left = positionX

      PRT.Overlay.UpdateFrame(overlayFrame, options)
    end)

  local positionYSlider = PRT.Slider(L["Y Offset"], nil, PRT.Round(options.top, 1))
  positionYSlider:SetRelativeWidth(1)
  positionYSlider:SetSliderValues(0, screenHeight, 0.1)
  positionYSlider:SetCallback("OnValueChanged",
    function(widget)
      local positionY = widget:GetValue()
      options.top = positionY

      PRT.Overlay.UpdateFrame(overlayFrame, options)
    end)

  positionGroup:AddChild(positionXSlider)
  positionGroup:AddChild(positionYSlider)

  container:AddChild(positionGroup)
end

function Overlay.FontGroup(options, overlayFrame)
  local fontGroup = PRT.InlineGroup(L["Font"])
  fontGroup:SetLayout("Flow")

  local fontSizeSlider = PRT.Slider(L["Size"], nil, options.fontSize)
  local fontSelect = PRT.FontSelect(L["Font"], options.fontName)

  fontSizeSlider:SetSliderValues(6, 72, 1)
  fontSizeSlider:SetCallback("OnValueChanged",
    function(widget)
      local fontSize = widget:GetValue()
      options.fontSize = fontSize

      PRT.Overlay.UpdateFrame(overlayFrame, options)
    end)

  fontSelect:SetCallback("OnValueChanged",
    function(widget, _, value)
      local path = AceGUIWidgetLSMlists.font[value]
      options.font = path
      options.fontName = value
      widget:SetText(value)

      PRT.Overlay.UpdateFrame(overlayFrame, options)
      widget:ClearFocus()
    end)

  fontGroup:AddChild(fontSizeSlider)
  fontGroup:AddChild(fontSelect)

  return fontGroup
end

function Overlay.AddSoundGroup(container, options)
  local soundGroup = PRT.InlineGroup(L["Sound"])
  soundGroup:SetLayout("Flow")

  local enableSoundCheckbox = PRT.CheckBox(L["Enabled"], options.enableSound)
  enableSoundCheckbox:SetCallback("OnValueChanged",
    function()
      options.enableSound = enableSoundCheckbox:GetValue()
    end)

  local defaultSoundFileSelect = PRT.SoundSelect(L["Default Sound"], (options.defaultSoundFileName or options.defaultSoundFile))
  defaultSoundFileSelect:SetCallback("OnValueChanged",
    function(widget, _, value)
      local defaultSoundFile = AceGUIWidgetLSMlists.sound[value]
      options.defaultSoundFile = defaultSoundFile
      options.defaultSoundFileName = value
      widget:SetText(value)
      if defaultSoundFile then
        PlaySoundFile(defaultSoundFile, "Master")
      end
    end)

  soundGroup:AddChild(enableSoundCheckbox)
  soundGroup:AddChild(defaultSoundFileSelect)
  container:AddChild(soundGroup)
end

function Overlay.AddSenderOverlayWidget(container, options)
  local hideDisabledTriggersCheckbox = PRT.CheckBox(L["Hide disabled triggers"], nil, options.hideDisabledTriggers)
  local showOverlayCheckbox = PRT.CheckBox(L["Enabled"], nil, options.enabled)
  local hideOverlayAfterCombatCheckbox = PRT.CheckBox(L["Hide after combat"], nil, options.hideAfterCombat)
  local backdropColor =  PRT.ColorPicker(L["Backdrop Color"], options.backdropColor)

  -- Initialize widgets
  hideDisabledTriggersCheckbox:SetRelativeWidth(1)
  hideDisabledTriggersCheckbox:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.hideDisabledTriggers = value
    end)

  showOverlayCheckbox:SetRelativeWidth(1)
  showOverlayCheckbox:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.enabled = value
      if value then
        PRT.SenderOverlay.Show()
        PRT.SenderOverlay.ShowPlaceholder(PRT.SenderOverlay.overlayFrame, options)
      else
        PRT.SenderOverlay.Hide()
      end
    end)

  hideOverlayAfterCombatCheckbox:SetRelativeWidth(1)
  hideOverlayAfterCombatCheckbox:SetCallback("OnValueChanged", function(widget) options.hideAfterCombat = widget:GetValue() end)

  backdropColor:SetHasAlpha(true)
  backdropColor:SetCallback("OnValueConfirmed",
    function(_, _, r, g, b, a)
      options.backdropColor.a = a
      options.backdropColor.r = r
      options.backdropColor.g = g
      options.backdropColor.b = b

      PRT.Overlay.UpdateBackdrop(PRT.SenderOverlay.overlayFrame, options)
    end)


  container:AddChild(showOverlayCheckbox)
  container:AddChild(hideOverlayAfterCombatCheckbox)
  container:AddChild(hideDisabledTriggersCheckbox)
  container:AddChild(backdropColor)
  container:AddChild(Overlay.FontGroup(options, PRT.SenderOverlay.overlayFrame))
  Overlay.AddPositionSliderGroup(container, PRT.SenderOverlay.overlayFrame, options)
end

function Overlay.AddReceiverOverlayWidget(options, container, index)
  local overlayFrame = PRT.ReceiverOverlay.overlayFrames[index]
  local labelEditBox = PRT.EditBox(L["Overlay"], nil, options.label)
  labelEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      options.label = text
      PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
      PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
      widget:ClearFocus()
    end)

  local fontColor =  PRT.ColorPicker(L["Font Color"], options.fontColor)
  fontColor:SetCallback("OnValueConfirmed",
    function(_, _, r, g, b, a)
      options.fontColor.hex = PRT.RGBAToHex(r, g, b, a)
      options.fontColor.r = r
      options.fontColor.g = g
      options.fontColor.b = b
      options.fontColor.a = a
      PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
      PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
    end)

  local lockedCheckBox = PRT.CheckBox(L["Locked"], options.locked)
  lockedCheckBox:SetRelativeWidth(1)
  lockedCheckBox:SetCallback("OnValueChanged",
    function(widget)
      local v = widget:GetValue()
      options.locked = v
      PRT.Overlay.SetMoveable(overlayFrame, not v)
      PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
      PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
    end)

  local fontGroup = Overlay.FontGroup(options, overlayFrame)
  fontGroup:AddChild(fontColor)

  container:AddChild(labelEditBox)
  container:AddChild(lockedCheckBox)
  Overlay.AddSoundGroup(container, options)
  container:AddChild(fontGroup)
  Overlay.AddPositionSliderGroup(container, overlayFrame, options)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddOverlayWidget(container, options)
  local receiversTabs = PRT.TableToTabs(options.receivers)
  local receiversTabGroup = PRT.TabGroup(L["Receivers"], receiversTabs)
  receiversTabGroup:SetLayout("List")
  receiversTabGroup:SetCallback("OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, options.receivers, key, Overlay.AddReceiverOverlayWidget)
    end)

  PRT.SelectFirstTab(receiversTabGroup, options.receivers)

  if PRT.db.profile.senderMode then
    local senderGroup = PRT.InlineGroup(L["Sender"])
    senderGroup:SetLayout("Flow")
    Overlay.AddSenderOverlayWidget(senderGroup, options.sender)
    container:AddChild(senderGroup)
  end

  container:AddChild(receiversTabGroup)
end
