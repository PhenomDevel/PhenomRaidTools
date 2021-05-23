--- API
-- Contains all functions which are exposed to the open world

local _, PRT = ...

local API = {
  message = {
    validTypes = {
      "raidtarget",
      "raidwarning",
      "cooldown",
      "advanced"
    }
  }
}

--- Send a message to the given players
-- The message will be sent to all players in `targets`. it will perform the corresponding action based on `type`.
-- @param type type of the message you want to send
-- @param targets table of targets which should receive the message
-- @return true or false
API.SendMessage = function(self, type, targets)
  -- Targets needs to be a table with player names
  assert(tContains(self.message.validTypes, type), "`type` needs to be either `raidtarget`, `raidwarning`, `cooldown`, or `advanced`.")
  assert(type(targets) == "table", "`targets` needs to be a table of player names.")

  -- TODO
end

---
API.AddGlobalCustomPlaceholder = function(self, type, name, playerNames)
  assert(tContains(self.placeholder.validTypes, type), "`type` needs to be either `group`, or `player`.")
  assert(not PRT.StringUtils.IsEmpty(name), "`name` has to be a non empty string.")
  assert(type(playerNames) == "table", "`playerNames` needs to be a table of player names.")

  -- TODO
end

_G["GPRTAPI"] = API
