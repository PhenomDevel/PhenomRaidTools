local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local RaidRoster = {
  tankCount = 3,
  healerCount = 6,
  ddCount = 21
}

-------------------------------------------------------------------------------
-- Private Helper

function RaidRoster.ImportRaidRosterByGroup(options, container)
  wipe(options)
  local names = PRT.PartyNames(false)
  local tanksCounter = 0
  local healerCounter = 0
  local ddsCounter = 0

  for _, name in ipairs(names) do
    local playerRole = UnitGroupRolesAssigned(name)
    local raidRosterID

    if playerRole == "TANK" then
      tanksCounter = tanksCounter + 1
      raidRosterID = "tank" .. tanksCounter
    elseif playerRole == "HEALER" then
      healerCounter = healerCounter + 1
      raidRosterID = "heal" .. healerCounter
    elseif playerRole == "DAMAGER" then
      ddsCounter = ddsCounter + 1
      raidRosterID = "dd" .. ddsCounter
    end

    if raidRosterID then
      options[raidRosterID] = name
    end
  end

  container:ReleaseChildren()
  PRT.AddRaidRosterWidget(container, options)
end

function RaidRoster.ClearRaidRoster(options, container)
  wipe(options)

  container:ReleaseChildren()
  PRT.AddRaidRosterWidget(container, options)
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddRaidRosterWidget(container, options)
  local importByGroupButton = PRT.Button(L["Import raid"])
  importByGroupButton:SetCallback(
    "OnClick",
    function(_)
      PRT.ConfirmationDialog(L["Are you sure you want to import your current group?"], RaidRoster.ImportRaidRosterByGroup, nil, options, container)
    end
  )

  local clearRaidRosterButton = PRT.Button(L["Clear"])
  clearRaidRosterButton:SetCallback(
    "OnClick",
    function(_)
      PRT.ConfirmationDialog(L["Are you sure you want to clear the current raid roster?"], RaidRoster.ClearRaidRoster, nil, options, container)
    end
  )

  PRT.AddHelpContainer(container, L["You can import or define your raid roster and use the placeholder within your triggers."])

  local tankGroup = PRT.InlineGroup(L["Tanks"])
  tankGroup:SetLayout("Flow")

  for i = 1, RaidRoster.tankCount do
    local id = "tank" .. i
    local value = options[id]
    local tankEditBox = PRT.EditBox(L[id], nil, value)
    tankEditBox:SetRelativeWidth(0.33)
    tankEditBox:SetCallback(
      "OnEnterPressed",
      function(widget)
        local text = widget:GetText()
        if text ~= "" then
          options[id] = text
        else
          options[id] = nil
        end
        widget:ClearFocus()
      end
    )
    tankGroup:AddChild(tankEditBox)
  end

  local healGroup = PRT.InlineGroup(L["Healer"])
  healGroup:SetLayout("Flow")

  for i = 1, RaidRoster.healerCount do
    local id = "heal" .. i
    local value = options[id]
    local healEditBox = PRT.EditBox(L[id], nil, value)
    healEditBox:SetRelativeWidth(0.33)
    healEditBox:SetCallback(
      "OnEnterPressed",
      function(widget)
        local text = widget:GetText()
        if text ~= "" then
          options[id] = text
        else
          options[id] = nil
        end
        widget:ClearFocus()
      end
    )

    healGroup:AddChild(healEditBox)
  end

  local ddGroup = PRT.InlineGroup(L["Damage"])
  ddGroup:SetLayout("Flow")

  for i = 1, RaidRoster.ddCount do
    local id = "dd" .. i
    local value = options[id]
    local ddEditBox = PRT.EditBox(L[id], nil, value)
    ddEditBox:SetRelativeWidth(0.33)
    ddEditBox:SetCallback(
      "OnEnterPressed",
      function(widget)
        local text = widget:GetText()
        if text ~= "" then
          options[id] = text
        else
          options[id] = nil
        end
        widget:ClearFocus()
      end
    )
    ddGroup:AddChild(ddEditBox)
  end

  container:AddChild(importByGroupButton)
  container:AddChild(clearRaidRosterButton)
  container:AddChild(tankGroup)
  container:AddChild(healGroup)
  container:AddChild(ddGroup)
end
