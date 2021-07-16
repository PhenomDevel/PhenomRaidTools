local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local addon = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local GeneralOptions = {
  messageFilterTypes = {
    {
      id = "names",
      name = L["Names"]
    },
    {
      id = "guildRank",
      name = L["Guild Rank"]
    }
  }
}

-------------------------------------------------------------------------------
-- General Options

function GeneralOptions.AddMessageFilterByNamesWidgets(container, options)
  local namesEditBox = PRT.EditBox(L["Names"], L["Comma separated list of player names."], strjoin(", ", unpack(options.requiredNames)), true)
  namesEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      options.requiredNames = PRT.StringUtils.SplitToTable(text)
      widget:ClearFocus()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end
  )
  container:AddChild(namesEditBox)
end

function GeneralOptions.AddMessageFilterByGuildRankWidgets(container, options)
  local guildRanks = PRT.GuildUtils.GetGuildRanksTable("player")
  local guildRankDropdownItems = {}

  for i, guildRank in ipairs(guildRanks) do
    tinsert(guildRankDropdownItems, {id = i, name = guildRank})
  end

  local guildRankDropdown = PRT.Dropdown(L["Guild Rank"], L["Filter out all messages\nbelow selected guild rank."], guildRankDropdownItems, options.requiredGuildRank)
  guildRankDropdown:SetCallback(
    "OnValueChanged",
    function(_, _, key)
      options.requiredGuildRank = key
    end
  )

  container:AddChild(guildRankDropdown)
end

function GeneralOptions.MessageFilterExplanationString(options)
  local message = ""

  if options.filterBy == "names" then
    if PRT.TableUtils.IsEmpty(options.requiredNames) then
      message =
        L["You currently filter messages by %s, but haven't configured any name yet. Therefore all messages from all players will be displayed."]:format(
        PRT.HighlightString(L["player names"])
      )
    else
      message = L["You currently filter messages by %s. Therefore only messages from those players will be displayed."]:format(PRT.HighlightString(L["player names"]))
    end
  elseif options.filterBy == "guildRank" then
    message =
      L["You currently filter messages by %s. Therefore only message from players with the configured guild rank or higher will be displayed."]:format(
      PRT.HighlightString(L["guild rank"])
    )
  end

  if options.alwaysIncludeMyself then
    message = message .. " " .. L["In addition you always include %s as valid sender."]:format(PRT.HighlightString(L["yourself"]))
  end

  return message
end

function GeneralOptions.AddMessageFilter(container, options)
  local messageFilterGroup = PRT.InlineGroup(L["Message Filter"])
  local alwaysIncludeMyselfCheckBox = PRT.CheckBox(L["Include myself"], L["Always includes yourself as valid sender."], options.alwaysIncludeMyself)
  local filterTypeDropDown = PRT.Dropdown(L["Filter by"], nil, GeneralOptions.messageFilterTypes, options.filterBy)
  local messageFilterExplanationString = GeneralOptions.MessageFilterExplanationString(options)
  local messageFilterExplanation = PRT.Label(messageFilterExplanationString)
  messageFilterExplanation:SetRelativeWidth(1)

  messageFilterGroup:SetLayout("Flow")
  filterTypeDropDown:SetCallback(
    "OnValueChanged",
    function(_, _, key)
      options.filterBy = key
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end
  )

  alwaysIncludeMyselfCheckBox:SetRelativeWidth(1)
  alwaysIncludeMyselfCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.alwaysIncludeMyself = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end
  )

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
  local runModeGroup = PRT.InlineGroup(L["Modes"])
  runModeGroup:SetLayout("Flow")

  local senderCheckBox = PRT.CheckBox(L["Sender Mode"], L["Activates the sender mode."], PRT.IsSender())
  local receiverCheckBox = PRT.CheckBox(L["Receiver Mode"], L["Activates the receiver mode."], PRT.IsReceiver())

  senderCheckBox:SetRelativeWidth(0.33)
  receiverCheckBox:SetRelativeWidth(0.33)

  senderCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.senderMode = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end
  )

  receiverCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.receiverMode = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end
  )

  runModeGroup:AddChild(senderCheckBox)
  runModeGroup:AddChild(receiverCheckBox)

  if not PRT.IsSender() and PRT.IsReceiver() then
    local helpLabel = PRT.Label(L["You are currently in receiver only mode. Therefore some features are disabled because they only relate to the sender mode."])
    helpLabel:SetRelativeWidth(1)
    runModeGroup:AddChild(helpLabel)
  end

  container:AddChild(runModeGroup)
end

function GeneralOptions.AddTestMode(container, options)
  local testModeGroup = PRT.InlineGroup(L["Test Mode"])
  testModeGroup:SetLayout("Flow")

  local testModeCheckbox = PRT.CheckBox(L["Enabled"], L["Activates the test mode."], options.testMode)
  local textEncounterIDDropdown = PRT.Dropdown(L["Select Encounter"], nil, options.encounters, options.testEncounterID, false, true)
  textEncounterIDDropdown:SetDisabled(not options.testMode)

  testModeCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.testMode = widget:GetValue()
      PRT.Core.UpdateTree()
      PRT.Core.ReselectCurrentValue()
    end
  )

  textEncounterIDDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      options.testEncounterID = tonumber(widget:GetValue())
    end
  )

  testModeGroup:AddChild(testModeCheckbox)
  testModeGroup:AddChild(textEncounterIDDropdown)

  if options.testMode then
    local testModeDescription = PRT.Label(L["You are currently in test mode. Some triggers behave slightly different in test mode."])
    testModeDescription:SetRelativeWidth(1)
    testModeGroup:AddChild(testModeDescription)
  end

  container:AddChild(testModeGroup)
end

function GeneralOptions.AddDebugMode(container, options)
  local debugModeGroup = PRT.InlineGroup(L["Debug Mode"])
  local debugModeCheckbox = PRT.CheckBox(L["Enabled"], L["Activates the debug mode."], options.debugMode, true)
  debugModeCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.debugMode = widget:GetValue()
      wipe(PRT.GetProfileDB().debugLog)
      container:ReleaseChildren()
      PRT.AddGeneralWidgets(container, options)
    end
  )
  debugModeCheckbox:SetRelativeWidth(1)
  debugModeGroup:AddChild(debugModeCheckbox)

  if options.debugMode then
    local debugLogMultilineEditBox = PRT.MultiLineEditBox(L["Debug Log"])
    debugLogMultilineEditBox:SetRelativeWidth(1)
    debugLogMultilineEditBox:DisableButton(true)
    debugLogMultilineEditBox:SetHeight(200)
    local debugLogText = ""
    for _, entry in ipairs(PRT.GetProfileDB().debugLog) do
      for _, entryLine in ipairs(entry) do
        debugLogText = debugLogText .. tostring(entryLine) .. " "
      end
      debugLogText = debugLogText .. "\n"
    end

    debugLogMultilineEditBox:SetText(debugLogText)
    debugModeGroup:AddChild(debugLogMultilineEditBox)
  end

  container:AddChild(debugModeGroup)
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddGeneralWidgets(container, options)
  local enabledCheckbox = PRT.CheckBox(L["Enabled"], nil, options.enabled)
  local versionCheckButton = PRT.Button(L["Version Check"])

  enabledCheckbox:SetRelativeWidth(1)
  enabledCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.enabled = widget:GetValue()
    end
  )

  container:AddChild(enabledCheckbox)
  GeneralOptions.AddRunMode(container, options)

  if PRT.IsReceiver() then
    GeneralOptions.AddMessageFilter(container, options.messageFilter)
  end

  if PRT.IsSender() then
    GeneralOptions.AddTestMode(container, options)
  end

  GeneralOptions.AddDebugMode(container, options)

  versionCheckButton:SetCallback(
    "OnClick",
    function()
      addon:VersionCheck()
    end
  )

  container:AddChild(versionCheckButton)
end
