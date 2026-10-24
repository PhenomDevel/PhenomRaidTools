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
    }
  }
}
