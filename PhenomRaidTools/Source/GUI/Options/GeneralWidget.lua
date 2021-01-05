local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local General = {
   runModes = {
      { 
         id = "receiver", 
         name = L["receiver"]
      }, 
      { 
         id = "sender", 
         name = L["sender"]
      }, 
      { 
         id = "sender+receiver", 
         name = L["sender+receiver"]
      }
   },

   senderModeSelections = {
      "sender",
      "sender+receiver"
   },

   receiverModeSelections = {
      "receiver",
      "sender+receiver"
   }
}

-------------------------------------------------------------------------------
-- Public API

PRT.AddGeneralWidgets = function(container, options)
    local enabledCheckbox = PRT.CheckBox("optionsEnabled", options.enabled)
    local debugModeCheckbox = PRT.CheckBox("optionsDebugMode", options.debugMode, true)
    local testModeCheckbox = PRT.CheckBox("optionsTestMode", options.testMode)
    local textEncounterIDDropdown = PRT.Dropdown("optionsTestEncounterID", options.encounters, options.testEncounterID)        
    local runModeDropdown = PRT.Dropdown("runModeDropdown", General.runModes, options.runMode)        
    local weakAuraModeCheckbox = PRT.CheckBox("optionsWeakAuraMode", options.weakAuraMode, true)
    local receiveMessagesFromEditBox = PRT.EditBox("optionsReceiveMessagesFrom", options.receiveMessagesFrom, true)
    local versionCheckButton = PRT.Button("optionsVersionCheck")
    local profilesOptionsButton = PRT.Button("optionsOpenProfiles")    

    receiveMessagesFromEditBox:SetCallback("OnEnterPressed",
        function(widget)
            local text = widget:GetText()
            options.receiveMessagesFrom = text
            widget:ClearFocus()
        end)

    local partyPlayerDropdownItems = {}
    for i, name in ipairs(PRT.PartyNames(false)) do
        tinsert(partyPlayerDropdownItems, { id = name, name = PRT.ClassColoredName(name)})
    end
    local receiveMessagesFromDropdown = PRT.Dropdown("optionsReceiveMessagesFromDropdown", partyPlayerDropdownItems)
    receiveMessagesFromDropdown:SetCallback("OnValueChanged", 
        function(widget)
            local text = widget:GetValue()
            options.receiveMessagesFrom = text
            receiveMessagesFromEditBox:SetText(text)
            receiveMessagesFromDropdown:SetValue(nil)
        end)

    debugModeCheckbox:SetCallback("OnValueChanged", function(widget) options.debugMode = widget:GetValue() end)
    debugModeCheckbox:SetRelativeWidth(1)

    testModeCheckbox:SetCallback("OnValueChanged", function(widget)	options.testMode = widget:GetValue() end)	

    textEncounterIDDropdown:SetCallback("OnValueChanged", function(widget) options.testEncounterID = tonumber(widget:GetValue()) end)  
        
    runModeDropdown:SetCallback("OnValueChanged", 
        function(widget) 
            local text = widget:GetValue()
            options.senderMode = tContains(General.senderModeSelections, text)
            options.receiverMode = tContains(General.receiverModeSelections, text)
            options.runMode = text
            PRT.Core.UpdateTree()
            PRT.Core.ReselectCurrentValue()
        end)   
            
    weakAuraModeCheckbox:SetCallback("OnValueChanged", function(widget)	options.weakAuraMode = widget:GetValue() end)	
    weakAuraModeCheckbox:SetRelativeWidth(1)

    enabledCheckbox:SetCallback("OnValueChanged", 
        function(widget) 
            options.enabled = widget:GetValue() 
        end)	

    container:AddChild(enabledCheckbox)
    container:AddChild(runModeDropdown)

    if not options.senderMode and options.receiverMode then
        local helpLabel = PRT.Label("optionsReceiverModeHelp", 14)
        container:AddChild(helpLabel)
    end

    if options.senderMode then
        container:AddChild(testModeCheckbox)    
        container:AddChild(textEncounterIDDropdown)   
    end
        
    container:AddChild(receiveMessagesFromEditBox)
    container:AddChild(receiveMessagesFromDropdown)
    container:AddChild(debugModeCheckbox)

    if options.senderMode then
        container:AddChild(weakAuraModeCheckbox)    
    end

    versionCheckButton:SetCallback("OnClick",
        function()
            PRT:VersionCheck()
        end)

    profilesOptionsButton:SetCallback("OnClick",
        function()
            PRT.mainWindow:Hide()
            InterfaceOptionsFrame_OpenToCategory("PhenomRaidTools")
            InterfaceOptionsFrame_OpenToCategory("PhenomRaidTools")
        end        
    )

    container:AddChild(versionCheckButton)
    container:AddChild(profilesOptionsButton)
end