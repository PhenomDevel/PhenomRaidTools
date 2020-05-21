local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Options = {
    tankCount = 3,
    healerCount = 6,
    ddCount = 21,
    difficultyStrings = {
        "Normal", -- Localization
        "Heroic",
        "Mythic"
    },

    senderModeSelections = {
        "sender",
        "sender+receiver"
    },

    receiverModeSelections = {
        "receiver",
        "sender+receiver"
    },
    runModes = {
        { 
            id = "receiver", 
            name = "Receiver" 
        }, 
        { 
            id = "sender", 
            name = "Sender" 
        }, 
        { 
            id = "sender+receiver", 
            name = "Sender & Receiver"
        }
    }
}


-------------------------------------------------------------------------------
-- Local Helper

Options.AddRaidRosterWidget = function(container, options)
    local explanationLabel = PRT.Label("optionsRaidRosterExplanation")
    explanationLabel:SetRelativeWidth(1)

    local tankGroup = PRT.InlineGroup("Tanks")
    tankGroup:SetLayout("Flow")

    for i = 1, Options.tankCount do 
        local id = "tank"..i
        local value = options[id]
        local tankEditBox = PRT.EditBox(id, value)
        tankEditBox:SetCallback("OnEnterPressed", 
            function(widget) 
                local text = widget:GetText()
                if text ~= "" then
                    options[id] = text
                else
                    options[id] = nil
                end
                widget:ClearFocus()
            end)
        tankGroup:AddChild(tankEditBox)
    end 

    local healGroup = PRT.InlineGroup("Healer")
    healGroup:SetLayout("Flow")

    for i = 1, Options.healerCount do 
        local id = "heal"..i
        local value = options[id]
        local healEditBox = PRT.EditBox(id, value)
        healEditBox:SetCallback("OnEnterPressed", function(widget) 
            local text = widget:GetText()
            if text ~= "" then
                options[id] = text
            else
                options[id] = nil
            end
            widget:ClearFocus()
        end)
        
        healGroup:AddChild(healEditBox)
    end 

    local ddGroup = PRT.InlineGroup("Damage Dealer")
    ddGroup:SetLayout("Flow")

    for i = 1, Options.ddCount do 
        local id = "dd"..i
        local value = options[id]
        local healEditBox = PRT.EditBox(id, value)
        healEditBox:SetCallback("OnEnterPressed", function(widget) 
            local text = widget:GetText()
            if text ~= "" then
                options[id] = text 
            else
                options[id] = nil
            end
            widget:ClearFocus()
        end)
        ddGroup:AddChild(healEditBox)
    end 

    container:AddChild(explanationLabel)
    container:AddChild(tankGroup)
    container:AddChild(healGroup)
    container:AddChild(ddGroup)
end

Options.AddDefaultsWidgets = function(container, t)
    if t then
        for k, v in pairs(t) do
            local widget = nil

            if type(v) == "boolean" then
                widget = PRT.CheckBox(k, v)
                widget:SetCallback("OnValueChanged", function(widget) t[k] = widget:GetValue() end)
            elseif type(v) == "string" then
                widget = PRT.EditBox(k, v)
                widget:SetCallback("OnEnterPressed", function(widget) t[k] = widget:GetText() end)
            elseif type(v) == "number" then
                widget = PRT.Slider(k, v)
                widget:SetCallback("OnValueChanged", function(widget) t[k] = widget:GetValue() end)
            elseif type(v) == "table" then
                widget = PRT.EditBox(k, strjoin(", ", unpack(v)), true)              
                widget:SetWidth(300)
                widget:SetCallback("OnEnterPressed", 
                    function(widget) 
                        if widget:GetText() == "" then
                            t[k] = {}
                        else
                            t[k] = { strsplit(",", widget:GetText()) }                         
                        end
                    end)
            end
    
            if widget then
                container:AddChild(widget)
            end
        end
    end
end

Options.AddDefaultsGroups = function(container, options)
    local explanationLabel = PRT.Label("optionsDefaultsExplanation")
    explanationLabel:SetRelativeWidth(1)
    container:AddChild(explanationLabel)
    
    if options then
        for k, v in pairs(options) do
            local groupWidget = PRT.InlineGroup(k)
            groupWidget:SetLayout("Flow")
            Options.AddDefaultsWidgets(groupWidget, v)
            container:AddChild(groupWidget)
        end
    end    
end

Options.AddDifficultyWidgets = function(container, options)
    local explanationLabel = PRT.Label("optionsDifficultyExplanation")
    explanationLabel:SetRelativeWidth(1)

    local dungeonGroup = PRT.InlineGroup("dungeonHeading")
    dungeonGroup:SetLayout("Flow")
    
    for i, difficulty in ipairs(Options.difficultyStrings) do
        local widget = PRT.CheckBox("dungeonDifficulty"..difficulty, options["dungeon"][difficulty])
        widget:SetCallback("OnValueChanged", function(widget, event, key) options["dungeon"][difficulty] = widget:GetValue() end)
        widget:SetWidth(100)                
        dungeonGroup:AddChild(widget)
    end

    local raidGroup = PRT.InlineGroup("raidHeading")
    raidGroup:SetLayout("Flow")

    for i, difficulty in ipairs(Options.difficultyStrings) do
        local widget = PRT.CheckBox("raidDifficulty"..difficulty, options["raid"][difficulty])
        widget:SetCallback("OnValueChanged", function(widget, event, key) options["raid"][difficulty] = widget:GetValue() end)
        widget:SetWidth(100)
        raidGroup:AddChild(widget)
    end

    container:AddChild(explanationLabel)
    container:AddChild(dungeonGroup)
    container:AddChild(raidGroup)
end

Options.AddGeneralWidgets = function(container, options)
    local debugModeCheckbox = PRT.CheckBox("optionsDebugMode", options.debugMode, true)
	debugModeCheckbox:SetCallback("OnValueChanged", function(widget) options.debugMode = widget:GetValue() end)
    debugModeCheckbox:SetRelativeWidth(1)

    local testModeCheckbox = PRT.CheckBox("optionsTestMode", options.testMode)
	testModeCheckbox:SetCallback("OnValueChanged", function(widget)	options.testMode = widget:GetValue() end)	
    testModeCheckbox:SetRelativeWidth(1)

    local textEncounterIDDropdown = PRT.Dropdown("optionsTestEncounterID", options.encounters, options.testEncounterID)        
    textEncounterIDDropdown:SetCallback("OnValueChanged", function(widget) options.testEncounterID = tonumber(widget:GetValue()) end)  
    
    local runModeDropdown = PRT.Dropdown("runModeDropdown", Options.runModes, options.runMode)        
    runModeDropdown:SetCallback("OnValueChanged", 
        function(widget) 
            local text = widget:GetValue()
            options.senderMode = tContains(Options.senderModeSelections, text)
            options.receiverMode = tContains(Options.receiverModeSelections, text)
            options.runMode = text
        end)     
    
    container:AddChild(runModeDropdown)
    container:AddChild(debugModeCheckbox)
    container:AddChild(testModeCheckbox)    
    container:AddChild(textEncounterIDDropdown)
end

Options.AddSenderOverlayWidget = function(container, options)
    local showOverlayCheckbox = PRT.CheckBox("optionsShowOverlay", options.enabled)
    showOverlayCheckbox:SetRelativeWidth(1)
    showOverlayCheckbox:SetCallback("OnValueChanged", 
        function(widget) 
            local value = widget:GetValue() 
            options.enabled = value
            if value then
                PRT.SenderOverlay.Show()
                PRT.SenderOverlay.ShowPlaceholder()
            else
                PRT.SenderOverlay.Hide()
            end
        end)
    
    local hideOverlayAfterCombatCheckbox = PRT.CheckBox("optionsHideOverlayAfterCombat", options.hideAfterCombat)
    hideOverlayAfterCombatCheckbox:SetRelativeWidth(1)
    hideOverlayAfterCombatCheckbox:SetCallback("OnValueChanged", function(widget) options.hideAfterCombat = widget:GetValue() end)

    local fontSizeSlider = PRT.Slider("overlayFontSize", options.fontSize)
    fontSizeSlider:SetSliderValues(6, 72, 1)
    fontSizeSlider:SetCallback("OnValueChanged", 
        function(widget) 
            local fontSize = widget:GetValue() 
            options.fontSize = fontSize            
            PRT.Overlay.UpdateFont(PRT.SenderOverlay.overlayFrame, fontSize)
            PRT.Overlay.UpdateSize(PRT.SenderOverlay.overlayFrame)
        end)

    local backdropColor =  PRT.ColorPicker("overlayBackdropColor", options.backdropColor)
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
    container:AddChild(fontSizeSlider)
    container:AddChild(backdropColor)
end

Options.AddReceiverOverlayWidget = function(container, options)
    local fontSizeSlider = PRT.Slider("overlayFontSize", options.fontSize)
    fontSizeSlider:SetSliderValues(6, 72, 1)
    fontSizeSlider:SetCallback("OnValueChanged", 
    function(widget) 
        local fontSize = widget:GetValue() 
        options.fontSize = fontSize            
        PRT.Overlay.UpdateFont(PRT.ReceiverOverlay.overlayFrame, fontSize)
    end)

    local fontColor =  PRT.ColorPicker("overlayFontColor", options.fontColor)
    fontColor:SetCallback("OnValueConfirmed", 
        function(widget, event, r, g, b, a) 
            options.fontColor.hex = format("%2x%2x%2x", r * 255, g * 255, b * 255)  
            options.fontColor.r = r
            options.fontColor.g = g
            options.fontColor.b = b
            options.fontColor.a = a
        end)

    local lockedCheckBox = PRT.CheckBox("overlayLocked", options.locked)
    lockedCheckBox:SetCallback("OnValueChanged",
        function(widget)
            local v = widget:GetValue()
            options.locked = v
            if not v then                
                PRT.Overlay.UpdateBackdrop(PRT.ReceiverOverlay.overlayFrame, 0, 0, 0, 0.7)
                PRT.Overlay.SetMoveable(PRT.ReceiverOverlay.overlayFrame, true)
                PRT.ReceiverOverlay.ShowPlaceholder()
            else
                PRT.Overlay.UpdateBackdrop(PRT.ReceiverOverlay.overlayFrame, 0, 0, 0, 0)
                PRT.Overlay.SetMoveable(PRT.ReceiverOverlay.overlayFrame, false)
                PRT.Overlay.ClearText(PRT.ReceiverOverlay.overlayFrame)
            end
        end)

    local enableSoundCheckbox = PRT.CheckBox("overlayEnableSound", options.enableSound)
    enableSoundCheckbox:SetCallback("OnValueChanged", function(widget) options.enableSound = enableSoundCheckbox:GetValue() end)     

    container:AddChild(enableSoundCheckbox)
    container:AddChild(lockedCheckBox)
    container:AddChild(fontSizeSlider)
    container:AddChild(fontColor)
    
end

Options.AddOverlayWidget = function(container, options)
    local senderGroup = PRT.InlineGroup("senderGroup")
    senderGroup:SetLayout("Flow")
    Options.AddSenderOverlayWidget(senderGroup, options.sender)

    local receiverGroup = PRT.InlineGroup("receiverGroup") 
    receiverGroup:SetLayout("Flow")   
    Options.AddReceiverOverlayWidget(receiverGroup, options.receiver)
        
    container:AddChild(senderGroup)
    container:AddChild(receiverGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddOptionWidgets = function(container, profile)
    local optionsTabs = {
        { value = "general", text = "General" },
        { value = "difficulties", text = "Difficulties" },
        { value = "defaults", text = "Trigger Defaults" },
        { value = "raidRoster", text = "Raid Roster" },
        { value = "overlay", text = "Overlays" }
    }

    local optionsTabsGroup = PRT.TabGroup(nil, optionsTabs)
    optionsTabsGroup:SetLayout("Flow")
    optionsTabsGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key)             
            widget:ReleaseChildren()
                         
            if key ==  "general" then
                Options.AddGeneralWidgets(widget, PRT.db.profile)
            elseif key == "difficulties" then
                Options.AddDifficultyWidgets(widget, PRT.db.profile.enabledDifficulties)
            elseif key == "defaults" then
                Options.AddDefaultsGroups(widget, PRT.db.profile.triggerDefaults) 
            elseif key == "raidRoster" then
                Options.AddRaidRosterWidget(widget, PRT.db.profile.raidRoster) 
            elseif key == "overlay" then
                Options.AddOverlayWidget(widget, PRT.db.profile.overlay)
            end

            if PRT.mainWindowContent.scrollFrame then
                PRT.mainWindowContent.scrollFrame:DoLayout()
            end
        end)

    container:AddChild(optionsTabsGroup) 
    optionsTabsGroup:SelectTab("general")
end