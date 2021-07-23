local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Public API

PRT.Static = {
  ClassTokens = {
    ["warrior"] = 1,
    ["paladin"] = 2,
    ["hunter"] = 3,
    ["rogue"] = 4,
    ["priest"] = 5,
    ["dk"] = 6,
    ["shaman"] = 7,
    ["mage"] = 8,
    ["warlock"] = 9,
    ["monk"] = 10,
    ["druid"] = 11,
    ["dh"] = 12
  },
  TargetNone = "999",
  TargetNoneNumber = 999,
  Colors = {
    Primary = "ff577f",
    Secondary = "ff884b",
    Tertiary = "ffc764",
    Error = "ff6363",
    Debug = "dcabff",
    Info = "6bfdff",
    Warn = "ffc526",
    Highlight = "cdfffc",
    Disabled = "cf0000",
    Inactive = "ff7171",
    Enabled = "00c234",
    Success = "76ff68"
  },
  Tables = {
    RaidTargets = {
      [1] = {
        id = 1,
        name = L["Star"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t"
      },
      [2] = {
        id = 2,
        name = L["Circle"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t"
      },
      [3] = {
        id = 3,
        name = L["Diamond"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t"
      },
      [4] = {
        id = 4,
        name = L["Triangle"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t"
      },
      [5] = {
        id = 5,
        name = L["Moon"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t"
      },
      [6] = {
        id = 6,
        name = L["Square"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t"
      },
      [7] = {
        id = 7,
        name = L["Cross"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t"
      },
      [8] = {
        id = 8,
        name = L["Skull"] .. " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t"
      }
    },
    SupportedEvents = {
      {
        id = "ENCOUNTER_START",
        name = L["Encounter start"] .. " - |cFF69CCF0ENCOUNTER_START|r"
      },
      {
        id = "ENCOUNTER_END",
        name = L["Encounter end"] .. " - |cFF69CCF0ENCOUNTER_END|r"
      },
      {
        id = "SPELL_CAST_SUCCESS",
        name = L["Spell cast successfully"] .. " - |cFF69CCF0SPELL_CAST_SUCCESS|r"
      },
      {
        id = "SPELL_CAST_START",
        name = L["Spell cast started"] .. " - |cFF69CCF0SPELL_CAST_START|r"
      },
      {
        id = "SPELL_CAST_FAILED",
        name = L["Spell cast canceled"] .. " - |cFF69CCF0SPELL_CAST_FAILED|r"
      },
      {
        id = "SPELL_AURA_REMOVED",
        name = L["Buff/Debuff removed"] .. " - |cFF69CCF0SPELL_AURA_REMOVED|r"
      },
      {
        id = "SPELL_AURA_APPLIED",
        name = L["Buff/Debuff applied"] .. " - |cFF69CCF0SPELL_AURA_APPLIED|r"
      },
      {
        id = "SPELL_AURA_REFRESH",
        name = L["Buff/Debuff refreshed"] .. " - |cFF69CCF0SPELL_AURA_REFRESH|r"
      },
      {
        id = "SPELL_INTERRUPT",
        name = L["Spell interrupted"] .. " - |cFF69CCF0SPELL_INTERRUPT|r"
      },
      {
        id = "PLAYER_REGEN_DISABLED",
        name = L["Player entered combat"] .. " - |cFF69CCF0PLAYER_REGEN_DISABLED|r"
      },
      {
        id = "PLAYER_REGEN_ENABLED",
        name = L["Player left combat"] .. " - |cFF69CCF0PLAYER_REGEN_ENABLED|r"
      },
      {
        id = "UNIT_DIED",
        name = L["Unit died"] .. " - |cFF69CCF0UNIT_DIED|r"
      },
      {
        id = "PARTY_KILL",
        name = L["Unit killed"] .. " - |cFF69CCF0PARTY_KILL|r"
      }
    }
  }
}
