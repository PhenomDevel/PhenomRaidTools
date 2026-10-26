local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI

--[[
  What every new assignment and template starts as (PRT.MessageDefaults):
  the same cards as the assignment editor, plus the difficulties of new
  assignments. Changing it never touches existing assignments.
]]

UI.RegisterPage(
  {
    id = "defaults",
    label = L["New messages"],
    order = 45,
    build = function()
      local defaults = PRT.MessageDefaults()
      local cards = UI.Messages.Cards(defaults.message, {isTemplate = true, isDefaults = true})
      table.insert(
        cards,
        2,
        {
          title = L["When"],
          note = L["New assignments run on these difficulties. Their time is where you click into the timeline."],
          rows = UI.Messages.DifficultyRows(defaults.timing)
        }
      )
      return L["New messages"], L["What every new assignment and template starts with"], cards
    end
  }
)
