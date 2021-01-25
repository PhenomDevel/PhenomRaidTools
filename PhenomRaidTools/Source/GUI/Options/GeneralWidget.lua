local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

-- Create local copies of API functions which we use
local GetGuildInfo, InterfaceOptionsFrame_OpenToCategory = GetGuildInfo, InterfaceOptionsFrame_OpenToCategory

local GeneralOptions = {
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
   },

   messageFilterTypes = {
       {
           id = "names", 
           name = "Names"
       },
       {
           id = "guildRank",
           name = "Guild Rank",
           disabled = not(select(1, {GetGuildInfo("player")}))
       }
   }
}


-------------------------------------------------------------------------------
-- General Options

GeneralOptions.AddMessageFilterByNamesWidgets = function(container, options)
    local namesEditBox = PRT.EditBox("messageFilterNamesEditBox", strjoin(", ", unpack(options.requiredNames)), true)
    namesEditBox:SetCallback("OnEnterPressed", 
        function(widget)
            local text = widget:GetText()
            options.requiredNames = PRT.StringUtils.SplitToTable(text)
            widget:ClearFocus()
        end)
    container:AddChild(namesEditBox)
end

GeneralOptions.AddMessageFilterByGuildRankWidgets = function(container, options)    
    local guildRanks = PRT.GuildUtils.GetGuildRanksTable("player")
    local guildRankDropdownItems = {}

    for i, guildRank in ipairs(guildRanks) do 
        tinsert(guildRankDropdownItems, { id = i, name = guildRank})
    end

    local guildRankDropdown = PRT.Dropdown("messageFilterGuildRankDropdown", guildRankDropdownItems, options.requiredGuildRank)
    guildRankDropdown:SetCallback("OnValueChanged", 
        function(widget, event, key)         
            options.requiredGuildRank = key
        end) 

    container:AddChild(guildRankDropdown)
end

GeneralOptions.AddMessageFilter = function(container, options)
    local messageFilterGroup = PRT.InlineGroup("messageFilterGroup")
    messageFilterGroup:SetLayout("Flow")
    local filterTypeDropDown = PRT.Dropdown("messageFilterByDropdown", GeneralOptions.messageFilterTypes, options.filterBy)
    
    filterTypeDropDown:SetCallback("OnValueChanged", 
        function(widget, event, key)         
            options.filterBy = key
            PRT.Core.UpdateTree()
            PRT.Core.ReselectCurrentValue()
        end) 

    messageFilterGroup:AddChild(filterTypeDropDown)

    if options.filterBy == "names" then
        GeneralOptions.AddMessageFilterByNamesWidgets(messageFilterGroup, options)
    elseif options.filterBy == "guildRank" then
        GeneralOptions.AddMessageFilterByGuildRankWidgets(messageFilterGroup, options)
    end

    container:AddChild(messageFilterGroup)
end

GeneralOptions.AddRunMode = function(container, options)
    local runModeGroup = PRT.InlineGroup("runModeGroup")
    runModeGroup:SetLayout("Flow")
    local runModeDropdown = PRT.Dropdown("runModeDropdown", GeneralOptions.runModes, options.runMode)     
    runModeDropdown:SetCallback("OnValueChanged", 
        function(widget) 
            local text = widget:GetValue()
            options.senderMode = tContains(GeneralOptions.senderModeSelections, text)
            options.receiverMode = tContains(GeneralOptions.receiverModeSelections, text)
            options.runMode = text
            PRT.Core.UpdateTree()
            PRT.Core.ReselectCurrentValue()
        end)  

    runModeGroup:AddChild(runModeDropdown)
    container:AddChild(runModeGroup)
end

GeneralOptions.AddTestMode = function(container, options)
    local testModeGroup = PRT.InlineGroup("testModeGroup")
    testModeGroup:SetLayout("Flow")

    local testModeCheckbox = PRT.CheckBox("testModeEnabled", options.testMode)
    local textEncounterIDDropdown = PRT.Dropdown("testModeEncounterID", options.encounters, options.testEncounterID) 

    testModeCheckbox:SetCallback("OnValueChanged", 
        function(widget)	
            options.testMode = widget:GetValue() 
        end)	

    textEncounterIDDropdown:SetCallback("OnValueChanged", 
        function(widget) 
            options.testEncounterID = tonumber(widget:GetValue()) 
        end) 

    testModeGroup:AddChild(testModeCheckbox)
    testModeGroup:AddChild(textEncounterIDDropdown)

    container:AddChild(testModeGroup)
end

GeneralOptions.AddDebugMode = function(container, options)
    local debugModeGroup = PRT.InlineGroup("debugModeGroup")
    local debugModeCheckbox = PRT.CheckBox("debugModeEnabled", options.debugMode, true)           
    debugModeCheckbox:SetCallback("OnValueChanged", function(widget) options.debugMode = widget:GetValue() end)
    debugModeCheckbox:SetRelativeWidth(1)

    debugModeGroup:AddChild(debugModeCheckbox)
    container:AddChild(debugModeGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddGeneralWidgets = function(container, options)
    local enabledCheckbox = PRT.CheckBox("optionsEnabled", options.enabled)        
    local versionCheckButton = PRT.Button("optionsVersionCheck")
    local profilesOptionsButton = PRT.Button("optionsOpenProfiles")            
                  
    enabledCheckbox:SetRelativeWidth(1)
    enabledCheckbox:SetCallback("OnValueChanged", 
        function(widget) 
            options.enabled = widget:GetValue() 
        end)	

    container:AddChild(enabledCheckbox)    
    GeneralOptions.AddRunMode(container, options)

    if not options.senderMode and options.receiverMode then
        local helpLabel = PRT.Label("optionsReceiverModeHelp", 14)
        container:AddChild(helpLabel)
    end

    if options.senderMode then
        GeneralOptions.AddTestMode(container, options) 
    end        

    if options.receiverMode then
        GeneralOptions.AddMessageFilter(container, options.messageFilter)
    end

    GeneralOptions.AddDebugMode(container, options)

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