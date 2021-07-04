local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local changelogLines = {
  PRT.ColoredString(L["Latest Features"], PRT.Static.Colors.Primary),
  PRT.ColoredString(L["Ability to export timers as MethodRaidTools note"], PRT.Static.Colors.Secondary),
  L["- Export any timer as MethodRaidTools note"],
  L["- %s This only works for messages with type %s"]:format(PRT.ColoredString("(!)", PRT.Static.Colors.Disabled), PRT.HighlightString(L["cooldown"])),
  L["- To do so you have to navigate to %s within any encounter and click %s"]:format(PRT.HighlightString(L["Timers"]), PRT.HighlightString(L["Generate MethodRaidTools Note"])),
  "",
  PRT.ColoredString(L["Spell database options tab"], PRT.Static.Colors.Secondary),
  L["- Within the spell database you can search any spell the game has to over"],
  L["- The spell database will be updated each patch automatically"],
  "",
  PRT.ColoredString(L["Profiles options tab"], PRT.Static.Colors.Secondary),
  L["- You can now enable and select specialization specific profiles"],
  L["- The profiles will change automatically once you change your specialization"]
}

-------------------------------------------------------------------------------
-- Public API

function PRT.AddChangelogWidgets(container)
  local changelogGroup = PRT.InlineGroup(L["Changelog"])
  local changelogString = strjoin("\n", unpack(changelogLines))
  local changeLogLabel = PRT.Label(changelogString, 14)

  changeLogLabel:SetRelativeWidth(1)

  changelogGroup:AddChild(changeLogLabel)
  container:AddChild(changelogGroup)
end
