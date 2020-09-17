local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Overlay = {}


-------------------------------------------------------------------------------
-- Private Helper

Overlay.AddPositionSliderGroup = function(container, overlayFrame, options)
    local positionGroup = PRT.InlineGroup("overlayPositionGroup")
    positionGroup:SetLayout("List")

    local screenWidth = PRT.Round(GetScreenWidth())
    local screenHeight = PRT.Round(GetScreenHeight())

    local positionXSlider = PRT.Slider("optionsPositionX", PRT.Round(options.left, 1))
    positionXSlider:SetRelativeWidth(1)
    positionXSlider:SetSliderValues(0, screenWidth, 0.1)
    positionXSlider:SetCallback("OnValueChanged", 
        function(widget) 
            local positionX = widget:GetValue() 
            options.left = positionX            

            PRT.Overlay.UpdateFrame(overlayFrame, options)
        end)

    local positionYSlider = PRT.Slider("optionsPositionY", PRT.Round(options.top, 1))
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

Overlay.FontGroup = function(options, overlayFrame)
    local fontGroup = PRT.InlineGroup("overlayFontGroup")
    fontGroup:SetLayout("Flow")

    local fontSizeSlider = PRT.Slider("overlayFontSize", options.fontSize)
    local fontSelect = PRT.FontSelect("optionsFontSelect", options.fontName)

    fontSizeSlider:SetSliderValues(6, 72, 1)
    fontSizeSlider:SetCallback("OnValueChanged", 
    function(widget) 
        local fontSize = widget:GetValue() 
        options.fontSize = fontSize            
        
        PRT.Overlay.UpdateFrame(overlayFrame, options)
    end)
     
    fontSelect:SetCallback("OnValueChanged", 
        function(widget, event, value)
            local path = AceGUIWidgetLSMlists.font[value]
            options.font = path
            options.fontName = value
            widget:SetText(value)
            
            PRT.Overlay.UpdateFrame(overlayFrame, options)
        end)

    fontGroup:AddChild(fontSizeSlider)
    fontGroup:AddChild(fontSelect)

    return fontGroup
end

Overlay.AddSoundGroup = function(container, options)
    local soundGroup = PRT.InlineGroup("overlaySoundGroup")
    soundGroup:SetLayout("Flow")

    local enableSoundCheckbox = PRT.CheckBox("overlayEnableSound", options.enableSound)
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

     soundGroup:AddChild(enableSoundCheckbox)
     soundGroup:AddChild(defaultSoundFileSelect)
     container:AddChild(soundGroup)
end

Overlay.AddSenderOverlayWidget = function(container, options)
    local hideDisabledTriggersCheckbox = PRT.CheckBox("optionsHideDisabledTriggers", options.hideDisabledTriggers)
    local showOverlayCheckbox = PRT.CheckBox("optionsShowOverlay", options.enabled)
    local hideOverlayAfterCombatCheckbox = PRT.CheckBox("optionsHideOverlayAfterCombat", options.hideAfterCombat)
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
               PRT.SenderOverlay.ShowPlaceholder(PRT.SenderOverlay.overlayFrame, options)
           else
               PRT.SenderOverlay.Hide()
           end
       end)
   
   hideOverlayAfterCombatCheckbox:SetRelativeWidth(1)
   hideOverlayAfterCombatCheckbox:SetCallback("OnValueChanged", function(widget) options.hideAfterCombat = widget:GetValue() end)   
   
   backdropColor:SetHasAlpha(true)
   backdropColor:SetCallback("OnValueConfirmed", 
       function(widget, event, r, g, b, a) 
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

Overlay.AddReceiverOverlayWidget = function(options, container, index)
    local overlayFrame = PRT.ReceiverOverlay.overlayFrames[index]
    local labelEditBox = PRT.EditBox("", options.label)
    labelEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            local text = widget:GetText()
            options.label = text
            PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
            PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
            widget:ClearFocus()
        end) 

   local fontColor =  PRT.ColorPicker("overlayFontColor", options.fontColor) 
   fontColor:SetCallback("OnValueConfirmed", 
       function(widget, event, r, g, b, a) 
           options.fontColor.hex = PRT.RGBAToHex(r, g, b, a)
           options.fontColor.r = r
           options.fontColor.g = g
           options.fontColor.b = b
           options.fontColor.a = a
           PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
           PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
       end)

   local lockedCheckBox = PRT.CheckBox("overlayLocked", options.locked)
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

PRT.AddOverlayWidget = function(container, options)
   local senderGroup = PRT.InlineGroup("senderGroup")
   senderGroup:SetLayout("Flow")
   Overlay.AddSenderOverlayWidget(senderGroup, options.sender)

   local receiversTabs = PRT.TableToTabs(options.receivers)    
   local receiversTabGroup = PRT.TabGroup("receiversGroup", receiversTabs)
   receiversTabGroup:SetLayout("List")
   receiversTabGroup:SetCallback("OnGroupSelected", 
       function(widget, event, key) 
           PRT.TabGroupSelected(widget, options.receivers, key, Overlay.AddReceiverOverlayWidget) 
       end)

    PRT.SelectFirstTab(receiversTabGroup, options.receivers)    	

   container:AddChild(senderGroup)
   container:AddChild(receiversTabGroup)
end