local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local Media = LibStub("LibSharedMedia-3.0")
local Overlay = {}

local growDirectionDropdownOptions = {
  {
    id = "UP",
    name = L["Up"]
  },
  {
    id = "DOWN",
    name = L["Down"]
  }
}

-------------------------------------------------------------------------------
-- Private Helper

function Overlay.AddPositionSliderGroup(container, overlayFrame, options)
  local positionGroup = PRT.InlineGroup(L["Position"])
  positionGroup:SetLayout("Flow")

  local screenWidth = PRT.Round(GetScreenWidth())
  local screenHeight = PRT.Round(GetScreenHeight())

  local positionXSlider = PRT.Slider(L["X Offset"], nil, PRT.Round(options.left, 1))
  positionXSlider:SetRelativeWidth(0.5)
  positionXSlider:SetSliderValues(0, screenWidth, 0.1)
  positionXSlider:SetCallback(
    "OnValueChanged",
    function(widget)
      local positionX = widget:GetValue()
      options.left = positionX

      PRT.Overlay.UpdateFrame(overlayFrame, options)
    end
  )

  local positionYSlider = PRT.Slider(L["Y Offset"], nil, PRT.Round(options.top, 1))
  positionYSlider:SetRelativeWidth(0.5)
  positionYSlider:SetSliderValues(0, screenHeight, 0.1)
  positionYSlider:SetCallback(
    "OnValueChanged",
    function(widget)
      local positionY = widget:GetValue()
      options.top = positionY

      PRT.Overlay.UpdateFrame(overlayFrame, options)
    end
  )

  positionGroup:AddChild(positionXSlider)
  positionGroup:AddChild(positionYSlider)

  container:AddChild(positionGroup)
end

function Overlay.FontGroup(options, overlayFrame)
  local fontGroup = PRT.InlineGroup(L["Font"])
  fontGroup:SetLayout("Flow")

  local fontColor = PRT.ColorPicker(L["Font Color"], options.fontColor)
  local fontSizeSlider = PRT.Slider(L["Size"], nil, options.fontSize)
  local fontSelect = PRT.FontSelect(L["Font"], options.fontName)

  fontColor:SetRelativeWidth(0.33)
  fontSizeSlider:SetRelativeWidth(0.33)
  fontSelect:SetRelativeWidth(0.33)

  fontSizeSlider:SetSliderValues(6, 72, 1)
  fontSizeSlider:SetCallback(
    "OnValueChanged",
    function(widget)
      local fontSize = widget:GetValue()
      options.fontSize = fontSize

      PRT.Overlay.UpdateFrame(overlayFrame, options)
    end
  )

  fontSelect:SetCallback(
    "OnValueChanged",
    function(widget, _, value)
      local path = AceGUIWidgetLSMlists.font[value]
      options.font = path
      options.fontName = value
      widget:SetText(value)

      PRT.Overlay.UpdateFrame(overlayFrame, options)
      widget:ClearFocus()
    end
  )

  fontColor:SetCallback(
    "OnValueConfirmed",
    function(_, _, r, g, b, a)
      options.fontColor.hex = PRT.RGBAToHex(r, g, b, a)
      options.fontColor.r = r
      options.fontColor.g = g
      options.fontColor.b = b
      options.fontColor.a = a
      PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
      PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
    end
  )

  fontGroup:AddChild(fontColor)
  fontGroup:AddChild(fontSizeSlider)
  fontGroup:AddChild(fontSelect)

  return fontGroup
end

function Overlay.AddSoundGroup(container, options)
  local soundGroup = PRT.InlineGroup(L["Sound"])
  soundGroup:SetLayout("List")

  local enableSoundCheckbox = PRT.CheckBox(L["Enabled"], nil, options.enableSound)
  enableSoundCheckbox:SetCallback(
    "OnValueChanged",
    function()
      options.enableSound = enableSoundCheckbox:GetValue()
    end
  )

  local defaultSoundFileSelect = PRT.SoundSelect(L["Default Sound"], (options.defaultSoundFileName or options.defaultSoundFile))
  defaultSoundFileSelect:SetCallback(
    "OnValueChanged",
    function(widget, _, value)
      local defaultSoundFile = AceGUIWidgetLSMlists.sound[value]
      options.defaultSoundFile = defaultSoundFile
      options.defaultSoundFileName = value
      widget:SetText(value)
      if defaultSoundFile then
        PlaySoundFile(defaultSoundFile, "Master")
      end
    end
  )

  soundGroup:AddChild(enableSoundCheckbox)
  soundGroup:AddChild(defaultSoundFileSelect)
  container:AddChild(soundGroup)
end

function Overlay.AddSenderOverlayWidget(container, options)
  local hideDisabledTriggersCheckbox = PRT.CheckBox(L["Hide disabled triggers"], nil, options.hideDisabledTriggers)
  local showOverlayCheckbox = PRT.CheckBox(L["Enabled"], L["This will show/hide the sender overlay while in combat."], options.enabled)
  local hideOverlayAfterCombatCheckbox = PRT.CheckBox(L["Hide after combat"], nil, options.hideAfterCombat)
  local backdropColor = PRT.ColorPicker(L["Backdrop Color"], options.backdropColor)

  hideDisabledTriggersCheckbox:SetRelativeWidth(0.33)
  showOverlayCheckbox:SetRelativeWidth(0.33)
  hideOverlayAfterCombatCheckbox:SetRelativeWidth(0.33)

  local optionsGroup = PRT.SimpleGroup()
  optionsGroup:SetLayout("Flow")

  -- Initialize widgets
  hideDisabledTriggersCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.hideDisabledTriggers = value
    end
  )

  showOverlayCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.enabled = value
      if value then
        PRT.SenderOverlay.Show()
        PRT.SenderOverlay.ShowPlaceholder(PRT.SenderOverlay.overlayFrame, options)
      else
        PRT.SenderOverlay.Hide()
      end
    end
  )

  hideOverlayAfterCombatCheckbox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.hideAfterCombat = widget:GetValue()
    end
  )

  backdropColor:SetHasAlpha(true)
  backdropColor:SetCallback(
    "OnValueConfirmed",
    function(_, _, r, g, b, a)
      options.backdropColor.a = a
      options.backdropColor.r = r
      options.backdropColor.g = g
      options.backdropColor.b = b

      PRT.Overlay.UpdateBackdrop(PRT.SenderOverlay.overlayFrame, options)
    end
  )

  optionsGroup:AddChild(showOverlayCheckbox)
  optionsGroup:AddChild(hideOverlayAfterCombatCheckbox)
  optionsGroup:AddChild(hideDisabledTriggersCheckbox)
  container:AddChild(optionsGroup)
  container:AddChild(backdropColor)
  container:AddChild(Overlay.FontGroup(options, PRT.SenderOverlay.overlayFrame))
  Overlay.AddPositionSliderGroup(container, PRT.SenderOverlay.overlayFrame, options)
end

function Overlay.AddReceiverOverlayWidget(options, container, index)
  local overlayFrame = PRT.ReceiverOverlay.overlayFrames[index]

  local optionsGroup = PRT.SimpleGroup()
  optionsGroup:SetLayout("Flow")

  local lockedCheckBox = PRT.CheckBox(L["Locked"], nil, options.locked)
  local labelEditBox = PRT.EditBox(L["Name"], nil, options.label)
  local growDirectionDropdown = PRT.Dropdown(L["Grow Direction"], nil, growDirectionDropdownOptions, (options.growDirection or "UP"))

  lockedCheckBox:SetRelativeWidth(1)
  labelEditBox:SetRelativeWidth(0.33)
  growDirectionDropdown:SetRelativeWidth(0.33)

  labelEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local text = widget:GetText()
      options.label = text
      PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
      PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
      widget:ClearFocus()
    end
  )

  lockedCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      local v = widget:GetValue()
      options.locked = v
      PRT.Overlay.SetMoveable(overlayFrame, not v)
      PRT.ReceiverOverlay.ShowPlaceholder(overlayFrame, options)
      PRT.ReceiverOverlay.UpdateFrame(overlayFrame, options)
    end
  )

  growDirectionDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      options.growDirection = widget:GetValue()
    end
  )

  local fontGroup = Overlay.FontGroup(options, overlayFrame)

  optionsGroup:AddChild(lockedCheckBox)
  optionsGroup:AddChild(labelEditBox)
  optionsGroup:AddChild(growDirectionDropdown)
  container:AddChild(optionsGroup)
  Overlay.AddSoundGroup(container, options)
  container:AddChild(fontGroup)
  Overlay.AddPositionSliderGroup(container, overlayFrame, options)
end

local function ImportReceiverOverlaySettingsSuccess(overlayOptions, importedReceiverOptions)
  overlayOptions.receivers = importedReceiverOptions
  PRT.ReceiverOverlay.ReInitialize(overlayOptions.receivers)
  PRT.ReceiverOverlay.ShowPlaceholders(overlayOptions.receivers)

  -- ToDo check if fonts are existing
  for _, receiverOptions in pairs(overlayOptions.receivers) do
    if not Media:HashTable("font")[receiverOptions.fontName] then
      receiverOptions.font = nil
      receiverOptions.fontName = nil
    end
  end
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddOverlayWidget(container, options)
  -- Widgets
  local receiversTabs = PRT.TableToTabs(options.receivers)
  local receiversTabGroup = PRT.TabGroup(nil, receiversTabs)
  local receiversGroup = PRT.InlineGroup(L["Receivers"])
  local receiverActionGroup = PRT.SimpleGroup()
  local receiverImportButton = PRT.Button(L["Import"])
  local receiverExportButton = PRT.Button(L["Export"])

  -- Sender Settings
  if PRT.IsSender() then
    local senderGroup = PRT.InlineGroup(L["Sender"])
    senderGroup:SetLayout("Flow")
    Overlay.AddSenderOverlayWidget(senderGroup, options.sender)
    container:AddChild(senderGroup)
  end

  -- Receiver Settings
  receiverImportButton:SetCallback(
    "OnClick",
    function()
      PRT.CreateImportFrame(
        function(t)
          ImportReceiverOverlaySettingsSuccess(options, t)
          PRT.ReSelectTab(receiversTabGroup)
        end
      )
    end
  )

  receiverExportButton:SetCallback(
    "OnClick",
    function()
      PRT.CreateExportFrame(options.receivers)
    end
  )

  receiverActionGroup:SetLayout("Flow")
  receiverActionGroup:AddChild(receiverImportButton)
  receiverActionGroup:AddChild(receiverExportButton)

  receiversTabGroup:SetLayout("List")
  receiversTabGroup:SetCallback(
    "OnGroupSelected",
    function(widget, _, key)
      PRT.TabGroupSelected(widget, options.receivers, key, Overlay.AddReceiverOverlayWidget)
    end
  )

  PRT.SelectFirstTab(receiversTabGroup, options.receivers)
  receiversGroup:AddChild(receiverActionGroup)
  receiversGroup:AddChild(receiversTabGroup)
  container:AddChild(receiversGroup)
end
