local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Overlay = {}


-------------------------------------------------------------------------------
-- Private Helper

Overlay.AddPositionSliders = function(container, frame, options)
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()

    local positionXSlider = PRT.Slider("optionsPositionX", PRT.Round(options.left, 1))
    positionXSlider:SetSliderValues(0, PRT.Round(screenWidth, 1), 0.1)
    positionXSlider:SetCallback("OnValueChanged", 
    function(widget) 
        local positionX = widget:GetValue() 
        options.left = positionX            
        PRT.Overlay.UpdatePosition(frame, options)
    end)

    local positionYSlider = PRT.Slider("optionsPositionY", PRT.Round(options.top, 1))
    positionYSlider:SetSliderValues(0, PRT.Round(screenHeight, 1), 0.1)
    positionYSlider:SetCallback("OnValueChanged", 
    function(widget) 
        local positionY = widget:GetValue() 
        options.top = positionY            
        PRT.Overlay.UpdatePosition(frame, options)
    end) 

    container:AddChild(positionXSlider)
    container:AddChild(positionYSlider)
end

Overlay.AddSenderOverlayWidget = function(container, options)
    local hideDisabledTriggersCheckbox = PRT.CheckBox("optionsHideDisabledTriggers", options.hideDisabledTriggers)
    local showOverlayCheckbox = PRT.CheckBox("optionsShowOverlay", options.enabled)
    local fontSelect = PRT.FontSelect("optionsFontSelect", options.fontName)
    local hideOverlayAfterCombatCheckbox = PRT.CheckBox("optionsHideOverlayAfterCombat", options.hideAfterCombat)
    local fontSizeSlider = PRT.Slider("overlayFontSize", options.fontSize)
    local backdropColor =  PRT.ColorPicker("overlayBackdropColor", options.backdropColor)   

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
               PRT.SenderOverlay.ShowPlaceholder(options)
           else
               PRT.SenderOverlay.Hide()
           end
       end)
   
   fontSelect:SetCallback("OnValueChanged", 
       function(widget, event, value)
           local path = AceGUIWidgetLSMlists.font[value]
           options.font = path
           options.fontName = value
           widget:SetText(value)
           PRT.Overlay.SetFont(PRT.SenderOverlay.overlayFrame, options)
       end)    
   
   hideOverlayAfterCombatCheckbox:SetRelativeWidth(1)
   hideOverlayAfterCombatCheckbox:SetCallback("OnValueChanged", function(widget) options.hideAfterCombat = widget:GetValue() end)
   
   fontSizeSlider:SetSliderValues(6, 72, 1)
   fontSizeSlider:SetCallback("OnValueChanged", 
       function(widget) 
           local fontSize = widget:GetValue() 
           options.fontSize = fontSize            
           PRT.Overlay.UpdateFont(PRT.SenderOverlay.overlayFrame, options)
           PRT.Overlay.UpdateSize(PRT.SenderOverlay.overlayFrame, options)
       end)
   
   backdropColor:SetHasAlpha(true)
   backdropColor:SetCallback("OnValueConfirmed", 
       function(widget, event, r, g, b, a) 
           options.backdropColor.a = a
           options.backdropColor.r = r
           options.backdropColor.g = g
           options.backdropColor.b = b
           PRT.Overlay.UpdateBackdrop(PRT.SenderOverlay.overlayFrame, r, g, b, a)
       end)   
   
   container:AddChild(showOverlayCheckbox)
   container:AddChild(hideOverlayAfterCombatCheckbox)
   container:AddChild(hideDisabledTriggersCheckbox)
   container:AddChild(fontSelect)
   container:AddChild(fontSizeSlider)
   container:AddChild(backdropColor)
   Overlay.AddPositionSliders(container, PRT.SenderOverlay.overlayFrame, options)
end

Overlay.AddReceiverOverlayWidget = function(container, options)
   local fontSizeSlider = PRT.Slider("overlayFontSize", options.fontSize)
   fontSizeSlider:SetSliderValues(6, 72, 1)
   fontSizeSlider:SetCallback("OnValueChanged", 
   function(widget) 
       local fontSize = widget:GetValue() 
       options.fontSize = fontSize            
       PRT.Overlay.UpdateFont(PRT.ReceiverOverlay.overlayFrame, options)
   end)

   local fontSelect = PRT.FontSelect("optionsFontSelect", options.fontName)
   fontSelect:SetCallback("OnValueChanged", 
       function(widget, event, value)
           local path = AceGUIWidgetLSMlists.font[value]
           options.font = path
           options.fontName = value
           widget:SetText(value)
           PRT.Overlay.SetFont(PRT.ReceiverOverlay.overlayFrame, options)
           PRT.ReceiverOverlay.ShowPlaceholder()
       end)

   local fontColor =  PRT.ColorPicker("overlayFontColor", options.fontColor)   
   fontColor:SetCallback("OnValueConfirmed", 
       function(widget, event, r, g, b, a) 
           options.fontColor.hex = format("%2x%2x%2x", r * 255, g * 255, b * 255)  
           options.fontColor.r = r
           options.fontColor.g = g
           options.fontColor.b = b
           options.fontColor.a = a
           PRT.ReceiverOverlay.UpdateFrame()
           PRT.ReceiverOverlay.ShowPlaceholder()
       end)

   local lockedCheckBox = PRT.CheckBox("overlayLocked", options.locked)
   lockedCheckBox:SetRelativeWidth(1)
   lockedCheckBox:SetCallback("OnValueChanged",
       function(widget)
           local v = widget:GetValue()
           options.locked = v
           if not v then                
               PRT.Overlay.UpdateBackdrop(PRT.ReceiverOverlay.overlayFrame, 0, 0, 0, 0.7)
               PRT.Overlay.SetMoveable(PRT.ReceiverOverlay.overlayFrame, true)
           else
               PRT.Overlay.UpdateBackdrop(PRT.ReceiverOverlay.overlayFrame, 0, 0, 0, 0)
               PRT.Overlay.SetMoveable(PRT.ReceiverOverlay.overlayFrame, false)
           end

           PRT.ReceiverOverlay.ShowPlaceholder()
       end)

   local enableSoundCheckbox = PRT.CheckBox("overlayEnableSound", options.enableSound)
   enableSoundCheckbox:SetRelativeWidth(1)
   enableSoundCheckbox:SetCallback("OnValueChanged", function(widget) options.enableSound = enableSoundCheckbox:GetValue() end)     
    
   local defaultSoundFileSelect = PRT.SoundSelect("overlayDefaultSoundFile", (options.defaultSoundFileName or options.defaultSoundFile))
   defaultSoundFileSelect:SetCallback("OnValueChanged", 
    function(widget, event, value)
        local defaultSoundFile = AceGUIWidgetLSMlists.sound[value]
        options.defaultSoundFile = defaultSoundFile
        options.defaultSoundFileName = value
        widget:SetText(value)
        if defaultSoundFile then
            PlaySoundFile(defaultSoundFile, "Master")
        end
    end)

   container:AddChild(lockedCheckBox)
   container:AddChild(fontSelect)
   container:AddChild(fontSizeSlider)
   container:AddChild(fontColor)
   container:AddChild(enableSoundCheckbox)
   container:AddChild(defaultSoundFileSelect)   
   Overlay.AddPositionSliders(container, PRT.ReceiverOverlay.overlayFrame, options)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddOverlayWidget = function(container, options)
   local senderGroup = PRT.InlineGroup("senderGroup")
   senderGroup:SetLayout("Flow")
   Overlay.AddSenderOverlayWidget(senderGroup, options.sender)

   local receiverGroup = PRT.InlineGroup("receiverGroup") 
   receiverGroup:SetLayout("Flow")   
   Overlay.AddReceiverOverlayWidget(receiverGroup, options.receiver)
   
   container:AddChild(senderGroup)
   container:AddChild(receiverGroup)
end