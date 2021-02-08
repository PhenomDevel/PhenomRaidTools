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

function PRT.AddDifficultyWidgets(container, options)
  local explanationLabel = PRT.Label("optionsDifficultyExplanation")
  explanationLabel:SetRelativeWidth(1)

  local dungeonGroup = PRT.InlineGroup("dungeonHeading")
  dungeonGroup:SetLayout("Flow")

  for _, difficulty in ipairs(Difficulties.difficultyStrings) do
    local widget = PRT.CheckBox("dungeonDifficulty"..difficulty, options["dungeon"][difficulty])
    widget:SetCallback("OnValueChanged",
      function()
        options["dungeon"][difficulty] = widget:GetValue()
      end)
    dungeonGroup:AddChild(widget)
  end

  local raidGroup = PRT.InlineGroup("raidHeading")
  raidGroup:SetLayout("Flow")

  for _, difficulty in ipairs(Difficulties.difficultyStrings) do
    local widget = PRT.CheckBox("raidDifficulty"..difficulty, options["raid"][difficulty])
    widget:SetCallback("OnValueChanged",
      function()
        options["raid"][difficulty] = widget:GetValue()
      end)
    raidGroup:AddChild(widget)
  end

  container:AddChild(explanationLabel)
  container:AddChild(dungeonGroup)
  container:AddChild(raidGroup)
end
