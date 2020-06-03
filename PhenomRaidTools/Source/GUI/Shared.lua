local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

PRT.NewTriggerDeleteButton = function(container, t, idx, textID)
   local deleteButton = PRT.Button(textID)
   deleteButton:SetHeight(40)
   deleteButton:SetRelativeWidth(1)
   deleteButton:SetCallback("OnClick",
			    function()
			       tremove(t, idx)
			       PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
			       PRT.mainWindowContent:DoLayout()
			       container:ReleaseChildren()
   end)

   return deleteButton
end

PRT.PartyOrRaidNames = function()
   local names = {}

   if UnitInParty("player") then
      for i=1, 5 do
	 local index = "party"..i
	 local playerName = GetRaidRosterInfo(i)
	 tinsert(names, playerName)
      end
   elseif UnitInRaid("player") then
      for i=1, 40 do
	 local index = "raid"..i
	 local playerName = GetRaidRosterInfo(i)
	 tinsert(names, playerName)
      end
   else
      local name = UnitName("player")
      tinsert(names, name)
   end

   return names
end

PRT.ColoredPartyOrRaidNames = function()
   local names = PRT.PartyOrRaidNames()
   local coloredNames = {}
   for i, name in ipairs(names) do
      local _, _, classIndex = UnitClass(name)
      local color = PRT.db.profile.colors.classes[classIndex]
      local coloredName = nil

      if color then
	 coloredName = "|cFF"..color..name.."|r"
      else
	 coloredName = name
      end

      tinsert(coloredNames, coloredName)
   end

   return coloredNames
end

PRT.ClassColorName = function(name)
   if name then
      local _, _, classIndex = UnitClass(name)
      local color = PRT.db.profile.colors.classes[classIndex]
      local coloredName = name

      if color then
	 coloredName = "|cFF"..color..name.."|r"
      else
	 coloredName = name
      end

      return name, coloredName
   else
      return name
   end
end
