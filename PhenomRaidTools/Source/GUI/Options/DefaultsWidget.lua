local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local defaultTranslations = {
  ["rotationDefaults"] = L["Rotation"],
  ["defaultIgnoreAfterActivation"] = L["Ignore after activation"],
  ["defaultShouldRestart"] = L["Restart"],
  ["defaultIgnoreDuration"] = L["Ignore for"],
  ["conditionDefaults"] = L["Condition"],
  ["defaultEvent"] = L["Event"],
  ["aditionalEvents"] = L["Additional Events"],
  ["messageDefaults"] = L["Message"],
  ["defaultDuration"] = L["Duration"],
  ["defaultTargets"] = L["Targets"],
  ["defaultMessage"] = L["Message"],
  ["percentageDefaults"] = L["Percentage"],
  ["defaultUnitID"] = L["Unit"],
  ["defaultCheckAgain"] = L["Check again"],
  ["defaultCheckAgainAfter"] = L["Check after"],
  ["defaultCooldownWithCountdownPattern"] = L["Cooldown with countdown pattern"],
  ["defaultCooldownWithoutCountdownPattern"] = L["Cooldown without countdown pattern"]
}

local defaultIgnorableKeys = {
  "defaultTargetOverlay",
  "defaultMessageType",
  "defaultEvent"
}

-------------------------------------------------------------------------------
-- Private Helper

local function addDefaultsWidgets(container, t)
  if t then
    for k, v in pairs(t) do
      if not tContains(defaultIgnorableKeys, k) then
        local widget = nil
        if type(v) == "boolean" then
          widget = PRT.CheckBox(defaultTranslations[k], nil, v)
          widget:SetCallback(
            "OnValueChanged",
            function()
              t[k] = widget:GetValue()
            end
          )
        elseif type(v) == "string" then
          widget = PRT.EditBox(defaultTranslations[k], nil, v)
          widget:SetCallback(
            "OnEnterPressed",
            function()
              t[k] = widget:GetText()
              widget:ClearFocus()
            end
          )
        elseif type(v) == "number" then
          widget = PRT.Slider(defaultTranslations[k], nil, v)
          widget:SetCallback(
            "OnValueChanged",
            function()
              t[k] = widget:GetValue()
            end
          )
        elseif type(v) == "table" then
          widget = PRT.EditBox(defaultTranslations[k], nil, strjoin(", ", unpack(v)), true)
          widget:SetWidth(300)
          widget:SetCallback(
            "OnEnterPressed",
            function()
              if widget:GetText() == "" then
                t[k] = {}
              else
                t[k] = {strsplit(",", widget:GetText())}
              end
              widget:ClearFocus()
            end
          )
        end

        if widget then
          widget:SetRelativeWidth(0.33)
          container:AddChild(widget)
        end
      end
    end
  end
end

local function AddMessageDefaultWidgets(container, t)
  local targetOverlayDropdownItems = {}
  for _, overlay in ipairs(PRT.GetProfileDB().overlay.receivers) do
    local targetOverlayItem = {
      id = overlay.id,
      name = overlay.id .. ": " .. overlay.label
    }

    tinsert(targetOverlayDropdownItems, targetOverlayItem)
  end

  local targetOverlayDropdown = PRT.Dropdown(L["Target Overlay"], L["Overlay on which the message should show up"], targetOverlayDropdownItems, (t.defaultTargetOverlay or 1))
  targetOverlayDropdown:SetRelativeWidth(0.33)
  targetOverlayDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      t.defaultTargetOverlay = widget:GetValue()
    end
  )

  local actionTypeDropdownItems = {
    [1] = {
      id = "cooldown",
      name = L["Cooldown"]
    },
    [2] = {
      id = "raidwarning",
      name = L["Raidwarning"]
    },
    [3] = {
      id = "raidtarget",
      name = L["Raidtarget"]
    },
    [4] = {
      id = "advanced",
      name = L["Advanced"]
    },
    [5] = {
      id = "loadTemplate",
      name = L["Load Template"],
      disabled = PRT.TableUtils.IsEmpty(PRT.GetProfileDB().templateStore.messages)
    }
  }

  local actionTypeDropdown = PRT.Dropdown(L["Type"], nil, actionTypeDropdownItems, t.defaultMessageType or "cooldown", nil, true)
  actionTypeDropdown:SetRelativeWidth(0.33)
  actionTypeDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      t.defaultMessageType = widget:GetValue()
    end
  )

  container:AddChild(actionTypeDropdown)
  container:AddChild(targetOverlayDropdown)
end

local function AddConditionDefaults(container, t)
  local eventDropDown = PRT.Dropdown(L["Event"], nil, PRT.Static.Tables.SupportedEvents, t.defaultEvent, true)
  eventDropDown:SetWidth(400)
  eventDropDown:SetCallback(
    "OnValueChanged",
    function(widget)
      local text = widget:GetValue()

      if text == "" then
        t.defaultEvent = nil
      else
        t.defaultEvent = text
      end

      widget:ClearFocus()
    end
  )

  container:AddChild(eventDropDown)
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddDefaultsGroups(container, options)
  PRT.AddHelpContainer(container, L["The defined default values will be used when creating new messages."])

  if options then
    for k, v in pairs(options) do
      local groupWidget = PRT.InlineGroup(defaultTranslations[k])
      groupWidget:SetLayout("Flow")

      addDefaultsWidgets(groupWidget, v)

      if k == "messageDefaults" then
        AddMessageDefaultWidgets(groupWidget, v)
      elseif k == "conditionDefaults" then
        AddConditionDefaults(groupWidget, v)
      end

      container:AddChild(groupWidget)
    end
  end
end
