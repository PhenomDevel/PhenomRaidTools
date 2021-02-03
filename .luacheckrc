std = "luajit"
globals = {
  -- World of Warcraft related
  "UIParent",
  "LibStub",
  "strsplit",
  "strjoin",
  "tinsert",
  "GetLocale",
  "GameTooltip",
  "UnitName",
  "UnitAffectingCombat",
  "GetUnitName",
  "GetGuildInfo",
  "InterfaceOptionsFrame_OpenToCategory",
  "tContains",
  "GetScreenWidth",
  "GetScreenHeight",
  "AceGUIWidgetLSMlists",
  "PlaySoundFile",
  "wipe",
  "UnitGroupRolesAssigned",
  "GameFontHighlightSmall",
  "tremove",
  "GetSpellInfo",
  "UISpecialFrames",
  "strtrim",
  "strmatch",
  "GuildControlGetNumRanks",
  "GuildControlGetRankName",
  "GetTime",
  "CombatLogGetCurrentEventInfo",
  "UnitGUID",
  "UnitIsPlayer",
  "GetInstanceInfo",
  "UnitExists",
  "UnitIsDead",
  "UnitHealth",
  "UnitHealthMax",
  "UnitPower",
  "UnitPowerMax",
  "random",
  "CreateFrame",
  "BackdropTemplateMixin",

  -- Locals
  "L",
}
max_line_length=160
max_code_line_length=160
max_string_line_length=160
max_comment_line_length=160
max_cyclomatic_complexity=160

ignore={
 ".*self",
 ".*mergemany"
}