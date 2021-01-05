local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Trigger = {}

local enabledDifficultiesDefaults = {
   Normal = true,
   Heroic = true,
   Mythic = true
}

Trigger.EnsureEnabledDifficulties = function(trigger)
   if not trigger.enabledDifficulties then
      local defaults = PRT.CopyTable(enabledDifficultiesDefaults)
      trigger.enabledDifficulties = defaults
   end
end

-------------------------------------------------------------------------------
-- Public API

PRT.AddEnabledDifficultiesGroup = function(container, trigger)
   Trigger.EnsureEnabledDifficulties(trigger)

   local enabledDifficultiesGroup = PRT.InlineGroup("Enable for")
   enabledDifficultiesGroup:SetLayout("Flow")

   local normalCheckbox = PRT.CheckBox("dungeonDifficultyNormal", trigger.enabledDifficulties.Normal or nil)
   normalCheckbox:SetRelativeWidth(0.33)
   normalCheckbox:SetCallback("OnValueChanged", 
       function(widget) 
            trigger.enabledDifficulties.Normal = widget:GetValue()     
            PRT.Core.UpdateTree()  
       end)

   local heroicCheckbox = PRT.CheckBox("dungeonDifficultyHeroic", trigger.enabledDifficulties.Heroic or nil)
   heroicCheckbox:SetRelativeWidth(0.33)
   heroicCheckbox:SetCallback("OnValueChanged", 
       function(widget) 
            trigger.enabledDifficulties.Heroic = widget:GetValue()  
            PRT.Core.UpdateTree()     
       end)

   local mythicCheckbox = PRT.CheckBox("dungeonDifficultyMythic", trigger.enabledDifficulties.Mythic or nil)
   mythicCheckbox:SetRelativeWidth(0.33)
   mythicCheckbox:SetCallback("OnValueChanged", 
       function(widget) 
            trigger.enabledDifficulties.Mythic = widget:GetValue()
            PRT.Core.UpdateTree()       
       end)

   enabledDifficultiesGroup:AddChild(normalCheckbox)
   enabledDifficultiesGroup:AddChild(heroicCheckbox)
   enabledDifficultiesGroup:AddChild(mythicCheckbox)

   container:AddChild(enabledDifficultiesGroup)
end

PRT.AddDescription = function(container, trigger)
   local descriptionMultiLineEditBox = PRT.MultiLineEditBox("descriptionMultiLineEditBox", trigger.description or "")   
   descriptionMultiLineEditBox:SetCallback("OnEnterPressed", 
		function(widget) 
			local text = widget:GetText()
			trigger.description = text
			widget:ClearFocus()
		end) 
   descriptionMultiLineEditBox:SetRelativeWidth(1)
   container:AddChild(descriptionMultiLineEditBox)
end