local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Public API

PRT.Static = {
  Tables = {
    RaidTargets = {
      [1] = {
        id = 1,
        name = L["Star"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t"
      },
      [2] = {
        id = 2,
        name = L["Circle"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t"
      },
      [3] = {
        id = 3,
        name = L["Diamond"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t"
      },
      [4] = {
        id = 4,
        name = L["Triangle"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t"
      },
      [5] = {
        id = 5,
        name = L["Moon"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t"
      },
      [6] = {
        id = 6,
        name = L["Square"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t"
      },
      [7] = {
        id = 7,
        name = L["Cross"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t"
      },
      [8] = {
        id = 8,
        name = L["Skull"].." |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t"
      }
    },

    SupportedEvents = {
      {
        id = "ENCOUNTER_START",
        name = L["Encounter start"]..(" - ENCOUNTER_START")
      },
      {
        id = "ENCOUNTER_END",
        name = L["Encounter end"].." - ENCOUNTER_END"
      },
      {
        id = "SPELL_CAST_SUCCESS",
        name = L["Spell cast successfully"].." - SPELL_CAST_SUCCESS"
      },
      {
        id = "SPELL_CAST_START",
        name = L["Spell cast started"].." - SPELL_CAST_START"
      },
      {
        id = "SPELL_CAST_FAILED",
        name = L["Spell cast canceled"].." - SPELL_CAST_FAILED"
      },
      {
        id = "SPELL_AURA_REMOVED",
        name = L["Buff/Debuff removed"].." - SPELL_AURA_REMOVED"
      },
      {
        id = "SPELL_AURA_APPLIED",
        name = L["Buff/Debuff applied"].." - SPELL_AURA_APPLIED"
      },
      {
        id = "SPELL_AURA_REFRESH",
        name = L["Buff/Debuff refreshed"].." - SPELL_AURA_REFRESH"
      },
      {
        id = "SPELL_INTERRUPT",
        name = L["Spell interrupted"].." - SPELL_INTERRUPT"
      },
      {
        id = "PLAYER_REGEN_DISABLED",
        name = L["Player entered combat"].." - PLAYER_REGEN_DISABLED"
      },
      {
        id = "PLAYER_REGEN_ENABLED",
        name = L["Player left combat"].." - PLAYER_REGEN_ENABLED"
      },
      {
        id = "UNIT_DIED",
        name = L["Unit died"].." - UNIT_DIED"
      },
      {
        id = "PARTY_KILL",
        name = L["Unit killed"].." - PARTY_KILL"
      },
    }
  }
}
