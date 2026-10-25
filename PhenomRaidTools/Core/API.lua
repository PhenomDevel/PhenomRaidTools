--- API
-- Contains all functions which are exposed to the open world
-- @module api
-- @author Phenom

local API = {}

--- Message
-- @section Message
do
  --- Send an advanced message to the given players.
  -- WIP
  -- @usage local PRT = _G["PRT"]
  -- @usage PRT:SendAdvancedMessage(...)
  -- @return true
  function API:SendAdvancedMessage()
  end

  --- Send a cooldown message to the given players.
  -- WIP
  -- @usage local PRT = _G["PRT"]
  -- @usage PRT:SendCooldownMessage(...)
  -- @return true
  function API:SendCooldownMessage()
  end
end

--- Condition
-- @section Condition

--- Trigger the given condition.
-- Work in progress
-- @return WIP
function API:TriggerCondition()
end

_G["PRT"] = API
