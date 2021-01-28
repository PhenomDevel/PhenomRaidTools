local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Difficulties = {
   difficultyStrings = {
      "Normal",
      "Heroic",
      "Mythic"
   }
}

-------------------------------------------------------------------------------
-- Public API

PRT.AddDifficultyWidgets = function(container, options)
   local explanationLabel = PRT.Label("optionsDifficultyExplanation", 16)
   explanationLabel:SetRelativeWidth(1)

   local dungeonGroup = PRT.InlineGroup("dungeonHeading")
   dungeonGroup:SetLayout("Flow")
   
   for i, difficulty in ipairs(Difficulties.difficultyStrings) do
       local widget = PRT.CheckBox("dungeonDifficulty"..difficulty, options["dungeon"][difficulty])
       widget:SetCallback("OnValueChanged", function(widget, event, key) options["dungeon"][difficulty] = widget:GetValue() end)           
       dungeonGroup:AddChild(widget)
   end

   local raidGroup = PRT.InlineGroup("raidHeading")
   raidGroup:SetLayout("Flow")

   for i, difficulty in ipairs(Difficulties.difficultyStrings) do
       local widget = PRT.CheckBox("raidDifficulty"..difficulty, options["raid"][difficulty])
       widget:SetCallback("OnValueChanged", function(widget, event, key) options["raid"][difficulty] = widget:GetValue() end)       
       raidGroup:AddChild(widget)
   end

   container:AddChild(explanationLabel)
   container:AddChild(dungeonGroup)
   container:AddChild(raidGroup)
end