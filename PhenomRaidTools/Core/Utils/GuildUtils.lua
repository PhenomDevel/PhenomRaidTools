local _, PRT = ...

local GuildUtils = {}
PRT.GuildUtils = GuildUtils

-- Create local copies of API functions which we use
local GetGuildInfo, GuildControlGetNumRanks, GuildControlGetRankName = GetGuildInfo, GuildControlGetNumRanks, GuildControlGetRankName

-------------------------------------------------------------------------------
-- Guild Utils

function GuildUtils.GetGuildRanksTable(unitID)
  local guildRanks = {}

  if GetGuildInfo(unitID) then
    local rankCount = GuildControlGetNumRanks()

    for i = 1, rankCount do
      local rankName = GuildControlGetRankName(i)
      guildRanks[i] = rankName
    end
  end

  return guildRanks
end
