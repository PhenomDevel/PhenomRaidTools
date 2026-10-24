local _, PRT = ...

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
    ["dh"] = 12,
    ["evoker"] = 13
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
  }
}
