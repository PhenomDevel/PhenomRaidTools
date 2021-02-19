local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local specialWidgetNames = {
  "defaultTargetOverlay"
}

-------------------------------------------------------------------------------
-- Private Helper

local function addDefaultsWidgets(container, t)
  if t then
    for k, v in pairs(t) do
      local widget = nil
      if tContains(specialWidgetNames, k) then
      -- do nothing
      elseif type(v) == "boolean" then
        widget = PRT.CheckBox(k, v)
        widget:SetCallback("OnValueChanged",
          function()
            t[k] = widget:GetValue()
          end)
      elseif type(v) == "string" then
        widget = PRT.EditBox(k, v)
        widget:SetCallback("OnEnterPressed",
          function()
            t[k] = widget:GetText()
            widget:ClearFocus()
          end)
      elseif type(v) == "number" then
        widget = PRT.Slider(k, v)
        widget:SetCallback("OnValueChanged",
          function()
            t[k] = widget:GetValue()
          end)
      elseif type(v) == "table" then
        widget = PRT.EditBox(k, strjoin(", ", unpack(v)), true)
        widget:SetWidth(300)
        widget:SetCallback("OnEnterPressed",
          function()
            if widget:GetText() == "" then
              t[k] = {}
            else
              t[k] = { strsplit(",", widget:GetText()) }
            end
            widget:ClearFocus()
          end)
      end

      if widget then
        container:AddChild(widget)
      end
    end
  end
end

local function AddMessageDefaultWidgets(container, t)
  local targetOverlayDropdownItems = {}
  for _, overlay in ipairs(PRT.db.profile.overlay.receivers) do
    local targetOverlayItem = {
      id = overlay.id,
      name = overlay.id..": "..overlay.label
    }

    tinsert(targetOverlayDropdownItems, targetOverlayItem)
  end

  local targetOverlayDropdown = PRT.Dropdown("messageTargetOverlay", targetOverlayDropdownItems, (t.defaultTargetOverlay or 1))
  targetOverlayDropdown:SetCallback("OnValueChanged",
    function(widget)
      t.defaultTargetOverlay = widget:GetValue()
    end)

  container:AddChild(targetOverlayDropdown)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddDefaultsGroups(container, options)
  local explanationLabel = PRT.Label("optionsDefaultsExplanation")
  explanationLabel:SetRelativeWidth(1)
  container:AddChild(explanationLabel)

  if options then
    for k, v in pairs(options) do
      local groupWidget = PRT.InlineGroup(k)
      groupWidget:SetLayout("Flow")
      addDefaultsWidgets(groupWidget, v)

      if k == "messageDefaults" then
        AddMessageDefaultWidgets(groupWidget, v)
      end

      container:AddChild(groupWidget)
    end
  end
end
