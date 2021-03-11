local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

-- Create local copies of API functions which we use
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

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
      name = "Guild Rank"
    }
  }
}


-------------------------------------------------------------------------------
-- General Options

function GeneralOptions.AddMessageFilterByNamesWidgets(container, options)
  local namesEditBox = PRT.EditBox("messageFilterNamesEditBox", strjoin(", ", unpack(options.requiredNames)), true)
  namesEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      options.requiredNames = PRT.StringUtils.SplitToTable(text)
      widget:ClearFocus()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end)
  container:AddChild(namesEditBox)
end

function GeneralOptions.AddMessageFilterByGuildRankWidgets(container, options)
  local guildRanks = PRT.GuildUtils.GetGuildRanksTable("player")
  local guildRankDropdownItems = {}

  for i, guildRank in ipairs(guildRanks) do
    tinsert(guildRankDropdownItems, { id = i, name = guildRank})
  end

  local guildRankDropdown = PRT.Dropdown("messageFilterGuildRankDropdown", guildRankDropdownItems, options.requiredGuildRank)
  guildRankDropdown:SetCallback("OnValueChanged",
    function(_, _, key)
      options.requiredGuildRank = key
    end)

  container:AddChild(guildRankDropdown)
end

function GeneralOptions.MessageFilterExplanationString(options)
  local message = ""

  if options.filterBy == "names" then
    if PRT.TableUtils.IsEmpty(options.requiredNames) then
      message = L["messageFilterExplanationNoNames"]
    else
      message = L["messageFilterExplanationNames"]
    end
  elseif options.filterBy == "guildRank" then
    message = L["messageFilterExplanationGuildRank"]
  end

  if options.alwaysIncludeMyself then
    message = message..L["messageFilterExplanationAlwaysIncludeMyself"]
  end

  return message
end

function GeneralOptions.AddMessageFilter(container, options)
  local messageFilterGroup = PRT.InlineGroup("messageFilterGroup")
  local alwaysIncludeMyselfCheckBox = PRT.CheckBox("messageFilterAlwaysIncludeMyself", options.alwaysIncludeMyself)
  local filterTypeDropDown = PRT.Dropdown("messageFilterByDropdown", GeneralOptions.messageFilterTypes, options.filterBy)
  local messageFilterExplanationString = GeneralOptions.MessageFilterExplanationString(options)
  local messageFilterExplanation = PRT.Label(messageFilterExplanationString)
  messageFilterExplanation:SetRelativeWidth(1)

  messageFilterGroup:SetLayout("Flow")
  filterTypeDropDown:SetCallback("OnValueChanged",
    function(_, _, key)
      options.filterBy = key
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end)

  alwaysIncludeMyselfCheckBox:SetRelativeWidth(1)
  alwaysIncludeMyselfCheckBox:SetCallback("OnValueChanged",
    function(widget)
      options.alwaysIncludeMyself = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end)

  messageFilterGroup:AddChild(filterTypeDropDown)

  if options.filterBy == "names" then
    GeneralOptions.AddMessageFilterByNamesWidgets(messageFilterGroup, options)
  elseif options.filterBy == "guildRank" then
    GeneralOptions.AddMessageFilterByGuildRankWidgets(messageFilterGroup, options)
  end

  messageFilterGroup:AddChild(alwaysIncludeMyselfCheckBox)
  messageFilterGroup:AddChild(messageFilterExplanation)

  container:AddChild(messageFilterGroup)
end

function GeneralOptions.AddRunMode(container, options)
  local runModeGroup = PRT.InlineGroup("runModeGroup")
  runModeGroup:SetLayout("Flow")

  local senderCheckBox = PRT.CheckBox("sender", options.senderMode)
  local receiverCheckBox = PRT.CheckBox("receiver", options.receiverMode)

  senderCheckBox:SetCallback("OnValueChanged",
    function(widget)
      options.senderMode = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end)

  receiverCheckBox:SetCallback("OnValueChanged",
    function(widget)
      options.receiverMode = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end)

  runModeGroup:AddChild(senderCheckBox)
  runModeGroup:AddChild(receiverCheckBox)
  container:AddChild(runModeGroup)
end

function GeneralOptions.AddTestMode(container, options)
  local testModeGroup = PRT.InlineGroup("testModeGroup")
  testModeGroup:SetLayout("Flow")

  local testModeCheckbox = PRT.CheckBox("testModeEnabled", options.testMode)
  local textEncounterIDDropdown = PRT.Dropdown("testModeEncounterID", options.encounters, options.testEncounterID, false, true)
  textEncounterIDDropdown:SetDisabled(not options.testMode)

  testModeCheckbox:SetCallback("OnValueChanged",
    function(widget)
      options.testMode = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end)

  textEncounterIDDropdown:SetCallback("OnValueChanged",
    function(widget)
      options.testEncounterID = tonumber(widget:GetValue())
    end)

  testModeGroup:AddChild(testModeCheckbox)
  testModeGroup:AddChild(textEncounterIDDropdown)

  if options.testMode then
    local testModeDescription = PRT.Label(L["testModeDescription"])
    testModeDescription:SetRelativeWidth(1)
    testModeGroup:AddChild(testModeDescription)
  end

  container:AddChild(testModeGroup)
end

function GeneralOptions.AddDebugMode(container, options)
  local debugModeGroup = PRT.InlineGroup("debugModeGroup")
  local debugModeCheckbox = PRT.CheckBox("debugModeEnabled", options.debugMode, true)
  debugModeCheckbox:SetCallback("OnValueChanged",
    function(widget)
      options.debugMode = widget:GetValue()
      wipe(PRT.db.profile.debugLog)
      container:ReleaseChildren()
      PRT.AddGeneralWidgets(container, options)
    end)
  debugModeCheckbox:SetRelativeWidth(1)
  debugModeGroup:AddChild(debugModeCheckbox)

  if options.debugMode then
    local debugLogMultilineEditBox = PRT.MultiLineEditBox("optionsDebugLog")
    debugLogMultilineEditBox:SetRelativeWidth(1)
    debugLogMultilineEditBox:DisableButton(true)
    debugLogMultilineEditBox:SetHeight(200)
    local debugLogText = ""
    for _, entry in ipairs(PRT.db.profile.debugLog) do
      for _, entryLine in ipairs(entry) do
        debugLogText = debugLogText..tostring(entryLine).." "
      end
      debugLogText = debugLogText.."\n"
    end

    debugLogMultilineEditBox:SetText(debugLogText)
    debugModeGroup:AddChild(debugLogMultilineEditBox)
  end

  container:AddChild(debugModeGroup)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddGeneralWidgets(container, options)
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
    local helpLabel = PRT.Label("optionsReceiverModeHelp")
    container:AddChild(helpLabel)
  end

  if options.receiverMode then
    GeneralOptions.AddMessageFilter(container, options.messageFilter)
  end

  if options.senderMode then
    GeneralOptions.AddTestMode(container, options)
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
