local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Message = {
  defaultTargets = {
    "$me",
    "ALL",
    "HEALER",
    "TANKS",
    "DAMAGER"
  }
}

PRT.Message = Message

local CooldownSoundFileMapping = {
  [64843] = "PRT: Divine Hymn",
  [265202] = "PRT: Holy Word: Salvation",
  [740] = "PRT: Tranquility",
  [108280] = "PRT: Healing Tide Totem",
  [115310] = "PRT: Revival",
  [62618] = "PRT: Power Word: Barrier",
  [98008] = "PRT: Spirit Link Totem",
  [31821] = "PRT: Aura Mastery",
  [320420] = "PRT: Darkness",
  [51052] = "PRT: Anti Magic Zone",
  [97462] = "PRT: Rallying Cry",
  [109964] = "PRT: Spirit Shell"
}

local Cooldowns = {
  externals = {
    33206, -- Pain Suppression
    47788, -- Guardian Spirit

    102342, -- Iron Bark

    6940, -- Blessing of Sacrifice
    1022, -- Blessing of Protection
    204018, -- Blessing of Spellwarding

    116849, -- Life Cocoon
  },
  raidHeal = {
    64843, -- Divine Hymn
    265202, -- Holy Word: Salvation

    740, -- Tranquility

    108280, -- Healing Tide Totem

    115310, -- Revival

    31884, -- Wings

    15286, -- Embrace

    33891, -- Tree

    197721, -- Flourish

    62618, -- Power Word: Barrier

    98008, -- Spirit Link Totem

    31821, -- Aura Mastery

    320420, -- Darkness

    51052, -- AMC

    109964 -- Spirit Shell
  },
  utility = {
    192077, -- Windrush Totem

    106898, -- Stampeding Roar

    97462, -- Rallying Cry

    16191, -- Mana Tide

    64901, -- Symbol of Hope
  },
  immunities = {
    31224, -- Cloak of Shadows
    204018, -- Blessing of Spellwarding
    642, -- Divine Shield
    45438, -- Iceblock
    186265, -- Turtle
    196555, -- Netherwalk
  }
}

local cooldownIconSize = 20


-------------------------------------------------------------------------------
-- Local Helper

function Message.TargetsPreviewString(targets)
  if targets then
    local previewNames = {}

    for _, target in ipairs(targets) do
      local names = {strsplit(",", PRT.ReplacePlayerNameTokens(target))}

      for _, name in ipairs(names) do
        local trimmedName = strtrim(name, " ")
        local coloredName = PRT.ClassColoredName(trimmedName)

        tinsert(previewNames, coloredName)
      end
    end

    return strjoin(", ", unpack(previewNames))
  else
    return ""
  end
end

function Message.ColoredRaidPlayerNames()
  local playerNames = {}

  for _, name in ipairs(PRT.PartyNames(false)) do
    tinsert(playerNames, { id = name, name = PRT.ClassColoredName(name)})
  end

  return playerNames
end

function Message.GenerateRaidRosterDropdownItems()
  local raidRosterItems = {}

  -- Add Raid Roster entries
  for k, v in pairs(PRT.db.profile.raidRoster) do
    local name = PRT.ClassColoredName(v)

    name = "$"..k.." ("..name..")"

    tinsert(raidRosterItems, { id = "$"..k , name = name})
  end

  -- Add Custom Encounter Placeholder
  -- Hacky because we do not have the encounter here...
  if PRT.currentEncounter then
    if PRT.currentEncounter.encounter then
      if PRT.currentEncounter.encounter.CustomPlaceholders then
        for _, customEncounterPlaceholder in ipairs(PRT.currentEncounter.encounter.CustomPlaceholders) do
          local coloredNames = {}

          for _, name in ipairs(customEncounterPlaceholder.names) do
            tinsert(coloredNames, PRT.ClassColoredName(name))
          end

          local name = strjoin(", ", unpack(coloredNames))
          name = "$"..customEncounterPlaceholder.name.." ("..name..")"
          tinsert(raidRosterItems, { id = "$"..customEncounterPlaceholder.name , name = name})
        end
      end
    end
  end

  -- Add Custom Placeholder
  for _, customPlaceholder in ipairs(PRT.db.profile.customPlaceholders) do
    local coloredNames = {}

    for _, name in ipairs(customPlaceholder.names) do
      tinsert(coloredNames, PRT.ClassColoredName(name))
    end

    local name = strjoin(", ", unpack(coloredNames))
    name = "$"..customPlaceholder.name.." ("..name..")"
    tinsert(raidRosterItems, { id = "$"..customPlaceholder.name , name = name})
  end

  -- Add groups
  local groupItems = {}
  for i = 1, 8, 1 do
    local identifier = "$group"..i
    if not tContains(groupItems, identifier) then
      tinsert(groupItems, identifier)
    end
  end

  for _, v in ipairs(groupItems) do
    tinsert(raidRosterItems, { id = v, name = v})
  end

  -- Add default targets (HEALER, TANK etc.)
  for _, name in ipairs(Message.defaultTargets) do
    tinsert(raidRosterItems, { id = name, name = name})
  end

  tinsert(raidRosterItems, { id = "$target", name = "$target"})

  raidRosterItems = table.mergecopy(raidRosterItems, Message.ColoredRaidPlayerNames())
  PRT.SortTableByName(raidRosterItems)
  return raidRosterItems
end

local function CooldownActionPreviewString(action)
  if action.withCountdown then
    return format("{spell:%s} %%.0f {spell:%s}", action.spellID or "", action.spellID or "")
  else
    return format("{spell:%s}", action.spellID or "")
  end
end

function Message.CompilePossibleCooldownItems()
  local cooldownItems = {
    {
      id = "custom",
      name = "|cFFf5b247"..L["cooldownActionCustomDropdownItem"].."|r"
    }
  }
  for _, cooldownGroup in pairs(Cooldowns) do
    for _, spellID in ipairs(cooldownGroup) do
      local name = GetSpellInfo(spellID)
      local cooldownItem = {
        id = spellID,
        name = strjoin(" ", PRT.TextureStringBySpellID(spellID), name)
      }

      tinsert(cooldownItems, cooldownItem)
    end
  end

  return cooldownItems
end

local function AddLoadTemplateActionWidgets(container, action)
  local templates = {}

  for templateName, _ in pairs(PRT.db.profile.templateStore.messages) do
    tinsert(templates, { id = templateName, name = templateName })
  end

  local templatesDropdown = PRT.Dropdown("loadTemplateActionTemplateDropdown", templates)
  templatesDropdown:SetCallback("OnValueChanged",
    function(widget)
      local templateMessage = PRT.db.profile.templateStore.messages[widget:GetValue()]

      if templateMessage then
        local newAction = PRT.TableUtils.CopyTable(templateMessage)
        PRT.TableUtils.OverwriteValues(action, newAction)
        container:ReleaseChildren()
        PRT.MessageWidget(action, container)
        PRT.Core.UpdateScrollFrame()
      end
    end)

  container:AddChild(templatesDropdown)
end

local function AddCooldownActionWidgets(container, action)
  local possibleTargets = Message.GenerateRaidRosterDropdownItems()
  local possibleCooldowns = Message.CompilePossibleCooldownItems()
  local targetDropdown = PRT.Dropdown("cooldownActionTargetDropdown", possibleTargets, action.targets[1], true)
  local cooldownSpellDropdownValue

  if action.hasCustomSpellID then
    cooldownSpellDropdownValue = "custom"
  else
    cooldownSpellDropdownValue = action.spellID
  end

  local cooldownSpellDropdown = PRT.Dropdown("cooldownActionSpellDropdown", possibleCooldowns, cooldownSpellDropdownValue)
  local actionPreview = PRT.Label(L["messagePreview"]..PRT.PrepareMessageForDisplay(CooldownActionPreviewString(action)))
  actionPreview:SetRelativeWidth(1)
  targetDropdown:SetCallback("OnValueChanged",
    function(widget)
      wipe(action.targets)
      tinsert(action.targets, widget:GetValue())
    end)

  cooldownSpellDropdown:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      action.spellID = value
      local previewString = CooldownActionPreviewString(action)
      action.message = previewString

      local soundFileName = CooldownSoundFileMapping[value]
      if soundFileName then
        local path = AceGUIWidgetLSMlists.sound[soundFileName]
        action.useCustomSound = true
        action.soundFile = path
        action.soundFileName = soundFileName
      else
        action.useCustomSound = false
        action.soundFile = nil
        action.soundFileName = nil
      end

      action.hasCustomSpellID = value == "custom"

      container:ReleaseChildren()
      AddCooldownActionWidgets(container, action)
      PRT.Core.UpdateScrollFrame()
      actionPreview:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(CooldownActionPreviewString(action)))
    end)

  local targetOverlayDropdownItems = {}
  for _, overlay in ipairs(PRT.db.profile.overlay.receivers) do
    local targetOverlayItem = {
      id = overlay.id,
      name = overlay.id..": "..overlay.label
    }

    tinsert(targetOverlayDropdownItems, targetOverlayItem)
  end

  local targetOverlayDropdown = PRT.Dropdown("messageTargetOverlay", targetOverlayDropdownItems, (action.targetOverlay or 1))
  targetOverlayDropdown:SetCallback("OnValueChanged",
    function(widget)
      action.targetOverlay = widget:GetValue()
    end)

  local withCountdownCheckbox = PRT.CheckBox("messageWithCountdown", action.withCountdown)
  withCountdownCheckbox:SetCallback("OnValueChanged",
    function(widget)
      action.withCountdown = widget:GetValue()
      actionPreview:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(CooldownActionPreviewString(action)))
    end)

  container:AddChild(targetDropdown)
  container:AddChild(targetOverlayDropdown)
  container:AddChild(cooldownSpellDropdown)

  if action.hasCustomSpellID then
    local customSpellIDEditBox = PRT.EditBox("messageCustomSpellID", action.spellID)
    customSpellIDEditBox:SetCallback("OnEnterPressed",
      function(widget)
        action.spellID = tonumber(widget:GetText())
        local previewString = CooldownActionPreviewString(action)
        action.message = previewString
        actionPreview:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(CooldownActionPreviewString(action)))
        widget:ClearFocus()
      end)

    container:AddChild(customSpellIDEditBox)
  end

  container:AddChild(withCountdownCheckbox)
  container:AddChild(actionPreview)
end

local function AddAdvancedActionWidgets(container, message)
  -- TODO: Rename message to action
  local targetsString = strjoin(", ", unpack(message.targets))
  local targetsPreviewString = Message.TargetsPreviewString(message.targets)
  local raidRosterItems = Message.GenerateRaidRosterDropdownItems()

  local targetsEditBox = PRT.EditBox("messageTargets", targetsString, true)
  targetsEditBox:SetWidth(500)

  local targetsPreviewLabel = PRT.Label(L["messagePreview"]..PRT.PrepareMessageForDisplay(targetsPreviewString))
  targetsPreviewLabel:SetWidth(500)

  local raidRosterDropdown = PRT.Dropdown("messageRaidRosterAddDropdown", raidRosterItems)
  raidRosterDropdown:SetWidth(500)

  local soundSelect = PRT.SoundSelect("messageSound", (message.soundFileName or L["messageStandardSound"]))
  soundSelect:SetCallback("OnValueChanged",
    function(widget, _, value)
      local path = AceGUIWidgetLSMlists.sound[value]
      message.soundFile = path
      message.soundFileName = value
      widget:SetText(value)

      if path then
        PlaySoundFile(path, "Master")
      end
    end)

  local useCustomSoundCheckbox = PRT.CheckBox("messageUseCustomSound", message.useCustomSound)
  useCustomSoundCheckbox:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      message.useCustomSound = value
      PRT.ReSelectTab(container)
    end)

  targetsEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      local targets = PRT.StringUtils.SplitToTable(text)
      message.targets = targets

      targetsPreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(Message.TargetsPreviewString(message.targets)))
      widget:ClearFocus()
    end)

  raidRosterDropdown:SetCallback("OnValueChanged",
    function(widget)
      tinsert(message.targets, widget:GetValue())
      targetsEditBox:SetText(strjoin(", ", unpack(message.targets)))
      targetsPreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(Message.TargetsPreviewString(message.targets)))
      widget:SetValue(nil)
    end)

  local messagePreviewLabel = PRT.Label(L["messagePreview"]..PRT.PrepareMessageForDisplay(message.message))
  messagePreviewLabel:SetWidth(500)
  local messageEditBox = PRT.EditBox("messageMessage", message.message, true)
  messageEditBox:SetWidth(500)
  messageEditBox:SetCallback("OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      message.message = text
      widget:ClearFocus()
      messagePreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(message.message))
    end)


  local delaySlider = PRT.Slider("messageDelay", message.delay, true)
  delaySlider:SetCallback("OnValueChanged",
    function(widget)
      message.delay = tonumber(widget:GetValue())
    end)

  local durationSlider = PRT.Slider("messageDuration", message.duration, true)
  durationSlider:SetSliderValues(0, 60, 0.5)
  durationSlider:SetCallback("OnValueChanged",
    function(widget)
      message.duration = tonumber(widget:GetValue())
    end)

  local targetOverlayDropdownItems = {}
  for _, overlay in ipairs(PRT.db.profile.overlay.receivers) do
    tinsert(targetOverlayDropdownItems, { id = overlay.id, name = overlay.id..": "..overlay.label})
  end

  local targetOverlayDropdown = PRT.Dropdown("messageTargetOverlay", targetOverlayDropdownItems, (message.targetOverlay or 1))
  targetOverlayDropdown:SetCallback("OnValueChanged",
    function(widget)
      message.targetOverlay = widget:GetValue()
    end)


  container:AddChild(targetsEditBox)
  container:AddChild(targetsPreviewLabel)
  container:AddChild(raidRosterDropdown)

  container:AddChild(messageEditBox)
  container:AddChild(messagePreviewLabel)

  for _, cooldownGroup in pairs(Cooldowns) do
    local cooldownIconsGroup = PRT.SimpleGroup()
    cooldownIconsGroup:SetLayout("Flow")

    for _, spellID in ipairs(cooldownGroup) do
      local _, _, icon = GetSpellInfo(spellID)
      local spellIcon = PRT.Icon(icon, spellID)
      spellIcon:SetHeight(cooldownIconSize + 4)
      spellIcon:SetWidth(cooldownIconSize + 4)
      spellIcon:SetImageSize(cooldownIconSize, cooldownIconSize)

      spellIcon:SetCallback("OnClick",
        function()
          message.message = message.message.."{spell:"..spellID.."}"
          messageEditBox:SetText(message.message)
          messagePreviewLabel:SetText(L["messagePreview"]..PRT.PrepareMessageForDisplay(message.message))
        end)
      cooldownIconsGroup:AddChild(spellIcon)
    end

    container:AddChild(cooldownIconsGroup)
  end

  container:AddChild(delaySlider)
  container:AddChild(durationSlider)
  container:AddChild(targetOverlayDropdown)
  container:AddChild(useCustomSoundCheckbox)

  if message.useCustomSound then
    container:AddChild(soundSelect)
  end
end

local function SetActionTypeDefaults(action)
  if action.type == "cooldown" then
    action.message = nil
    action.spellID = nil
  elseif action.type == "advanced" then
  -- Nothing for now
  end
end

local function AddActionTypeWidgets(container, action)
  local actionTypeDropdownItems = {
    {
      id = "cooldown",
      name = L["actionTypeCooldown"]
    },
    {
      id = "advanced",
      name = L["actionTypeAdvanced"]
    },
    {
      id = "loadTemplate",
      name = L["actionTypeLoadTemplate"],
      disabled = PRT.TableUtils.IsEmpty(PRT.db.profile.templateStore.messages)
    }
  }

  local actionTypeDropdown = PRT.Dropdown("actionType", actionTypeDropdownItems, action.type or "advanced")
  actionTypeDropdown:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      action.type = value
      SetActionTypeDefaults(action)
      container:ReleaseChildren()
      PRT.MessageWidget(action, container)
      PRT.ReSelectTab(container)
    end)

  container:AddChild(actionTypeDropdown)
end

local function AddTemplateWidgets(container, message)
  local saveAsTemplateButton = PRT.Button("saveAsTemplate")
  local saveAsTemplateNameEditbox = PRT.EditBox("saveAsTemplateName")
  saveAsTemplateNameEditbox:SetCallback("OnEnterPressed",
    function(widget)
      local value = widget:GetText()

      if PRT.db.profile.templateStore.messages[value] then
        PRT.Warn("A template with this name already exists. Please choose antother name.")
        widget:SetText("")
      else
        widget:ClearFocus()
      end
    end)

  saveAsTemplateButton:SetCallback("OnClick",
    function()
      PRT.ConfirmationDialog("saveAsTemplateDescription",
        function()
          local templateName = saveAsTemplateNameEditbox:GetText()

          if not PRT.StringUtils.IsEmpty(templateName) then
            PRT.Info("The template was saved.")

            -- make sure a message always has a type
            message.type = message.type or "advanced"

            PRT.db.profile.templateStore.messages[templateName] = PRT.TableUtils.CopyTable(message)
            saveAsTemplateNameEditbox:SetText("")
          end
        end,
        {
          saveAsTemplateNameEditbox
        })
    end)

  container:AddChild(saveAsTemplateButton)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.MessageWidget(message, container, saveableAsTemplate)
  AddActionTypeWidgets(container, message)

  if message.type == "cooldown" then
    local cooldownActionGroup = PRT.SimpleGroup()
    AddCooldownActionWidgets(cooldownActionGroup, message)
    container:AddChild(cooldownActionGroup)
  elseif message.type == "loadTemplate" then
    AddLoadTemplateActionWidgets(container, message)
  else
    AddAdvancedActionWidgets(container, message)
  end

  if saveableAsTemplate then
    AddTemplateWidgets(container, message)
  end
end
