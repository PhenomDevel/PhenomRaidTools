local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Private Helper

local function addDefaultsWidgets(container, t)
  if t then
    for k, v in pairs(t) do
      local widget = nil

      if type(v) == "boolean" then
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


-------------------------------------------------------------------------------
-- Public API

function PRT.AddDefaultsGroups(container, options)
  local explanationLabel = PRT.Label("optionsDefaultsExplanation", 16)
  explanationLabel:SetRelativeWidth(1)
  container:AddChild(explanationLabel)

  if options then
    for k, v in pairs(options) do
      local groupWidget = PRT.InlineGroup(k)
      groupWidget:SetLayout("Flow")
      addDefaultsWidgets(groupWidget, v)
      container:AddChild(groupWidget)
    end
  end
end
