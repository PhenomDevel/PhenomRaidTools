local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


RaidRoster = {
   tankCount = 3,
   healerCount = 6,
   ddCount = 21
}


-------------------------------------------------------------------------------
-- Private Helper

RaidRoster.ImportRaidRosterByGroup = function(options, container)
   wipe(options)
   local names = PRT.PartyNames(false)
   local tanksCounter = 0
   local healerCounter = 0
   local ddsCounter = 0

   for i, name in ipairs(names) do
       local playerRole = UnitGroupRolesAssigned(name);
       local raidRosterID

       if playerRole == "TANK" then
           tanksCounter = tanksCounter + 1
           raidRosterID = "tank"..tanksCounter
       elseif playerRole == "HEALER" then
           healerCounter = healerCounter + 1
           raidRosterID = "heal"..healerCounter
       elseif playerRole == "DAMAGER" then
           ddsCounter = ddsCounter + 1
           raidRosterID = "dd"..ddsCounter
       end
       
       if raidRosterID then
           options[raidRosterID] = name
       end
   end

   container:ReleaseChildren()
   PRT.AddRaidRosterWidget(container, options)
end

RaidRoster.ClearRaidRoster = function(options, container)
   wipe(options)

   container:ReleaseChildren()
   PRT.AddRaidRosterWidget(container, options)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddRaidRosterWidget = function(container, options)
   local importByGroupButton = PRT.Button("optionsRaidRosterImportByGroup")
   importByGroupButton:SetCallback("OnClick", function(_) PRT.ConfirmationDialog(L["importByGroupConfirmationText"], RaidRoster.ImportRaidRosterByGroup, options, container)  end)    
   local clearRaidRosterButton = PRT.Button("optionsRaidRosterClear")
   clearRaidRosterButton:SetCallback("OnClick", function(_) PRT.ConfirmationDialog(L["clearRaidRosterConfirmationText"], RaidRoster.ClearRaidRoster, options, container) end)
   local explanationLabel = PRT.Label("optionsRaidRosterExplanation", 14)
   explanationLabel:SetRelativeWidth(1)

   local tankGroup = PRT.InlineGroup("raidRosterTanksHeading")
   tankGroup:SetLayout("Flow")

   for i = 1, RaidRoster.tankCount do 
       local id = "tank"..i
       local value = options[id]
       local tankEditBox = PRT.EditBox(id, value)
       tankEditBox:SetCallback("OnEnterPressed", 
           function(widget) 
               local text = widget:GetText()
               if text ~= "" then
                   options[id] = text
               else
                   options[id] = nil
               end
               widget:ClearFocus()
           end)
       tankGroup:AddChild(tankEditBox)
   end 

   local healGroup = PRT.InlineGroup("raidRosterHealerHeading")
   healGroup:SetLayout("Flow")

   for i = 1, RaidRoster.healerCount do 
       local id = "heal"..i
       local value = options[id]
       local healEditBox = PRT.EditBox(id, value)
       healEditBox:SetCallback("OnEnterPressed", function(widget) 
           local text = widget:GetText()
           if text ~= "" then
               options[id] = text
           else
               options[id] = nil
           end
           widget:ClearFocus()
       end)
       
       healGroup:AddChild(healEditBox)
   end 

   local ddGroup = PRT.InlineGroup("raidRosterDDHeading")
   ddGroup:SetLayout("Flow")

   for i = 1, RaidRoster.ddCount do 
       local id = "dd"..i
       local value = options[id]
       local healEditBox = PRT.EditBox(id, value)
       healEditBox:SetCallback("OnEnterPressed", function(widget) 
           local text = widget:GetText()
           if text ~= "" then
               options[id] = text 
           else
               options[id] = nil
           end
           widget:ClearFocus()
       end)
       ddGroup:AddChild(healEditBox)
   end 

   container:AddChild(explanationLabel)
   container:AddChild(importByGroupButton)
   container:AddChild(clearRaidRosterButton)    
   container:AddChild(tankGroup)
   container:AddChild(healGroup)
   container:AddChild(ddGroup)
end