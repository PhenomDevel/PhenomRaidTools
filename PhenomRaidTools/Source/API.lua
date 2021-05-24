--- API
-- Contains all functions which are exposed to the open world

local _, PRT = ...

local API = {}

-------------------------------------------------------------------------------
-- Public API

do
  local validMessageTypes = {
    "raidtarget",
    "raidwarning",
    "cooldown",
    "advanced"
  }

  --- Send a message to the given players.
  -- The message will be sent to all players in `targets` and it will perform the corresponding action based on `type`.
  -- @param type type of the message you want to send
  -- @param targets table of targets which should receive the message
  -- @usage _G["GPRTAPI"]:SendMessage("advanced", {"Phenom"})
  -- @return true when message could be sent
  function API:SendMessage(messageType, targets)
    assert(tContains(validMessageTypes, messageType), "`type` needs to be either `raidtarget`, `raidwarning`, `cooldown`, or `advanced`.")
    assert(type(targets) == "table", "`targets` needs to be a table of player names.")

    -- TODO
  end
end

do
  local validPlaceholderTypes = {
    "player",
    "group"
  }

  local function assertPlaceholderParams(placeholderType, name, playerNames)
    -- is the type contained in our valid types?
    assert(tContains(validPlaceholderTypes, placeholderType), "`type` needs to be either `group`, or `player`.")

    -- is the name a non empty string?
    assert(not PRT.StringUtils.IsEmpty(name), "`name` has to be a non empty string.")

    -- are the playerNames a table?
    assert(type(playerNames) == "table", "`playerNames` needs to be a table of player names.")
  end

  --- Add a new global placeholder
  -- @param placeholderType the type of the placeholder. Can either be `group` or `player`
  -- @param name the name of the placeholder. Can only be a name which is not already present
  -- @param playerNames table of the player names which should be used for the placeholder
  -- @usage _G["GPRTAPI"]:AddGlobalPlaceholder("player", "test", {"Phenom"})
  -- @return true when placeholder could be created
  function API:AddGlobalPlaceholder(placeholderType, name, playerNames)
    -- are the placeholder params valid?
    assertPlaceholderParams(placeholderType, name, playerNames)

    local placeholders = PRT.GetProfileDB().customPlaceholders

    -- does the placeholder with the name not already exist?
    local alreadyExists = PRT.TableUtils.GetBy(placeholders, "name", name)
    assert(not alreadyExists, string.format("Placeholder with name %s already exists.", PRT.HighlightString(name)))

    local newPlaceholder = {
      name = name,
      type = placeholderType,
      names = playerNames
    }

    tinsert(placeholders, newPlaceholder)

    return true
  end

  --- Add a new encounter placeholder
  -- @param encounterID the encounter id for which the placeholder should be added
  -- @param placeholderType the type of the placeholder. Can either be `group` or `player`
  -- @param name the name of the placeholder. Can only be a name which is not already present
  -- @param playerNames table of the player names which should be used for the placeholder
  -- @usage _G["GPRTAPI"]:AddEncounterPlaceholder(1234, "player", "test", {"Phenom"})
  -- @return true when placeholder could be created
  function API:AddEncounterPlaceholder(encounterID, placeholderType, name, playerNames)
    -- does the encounter exist?
    local _, encounter = PRT.GetEncounterById(PRT.GetProfileDB().encounters, encounterID)
    local encounterVersion = encounter.versions[encounter.selectedVersion]
    assert(encounter, "It was no encounter found for the given `encounterID`.")

    -- are the placeholder params valid?
    assertPlaceholderParams(placeholderType, name, playerNames)

    local placeholders = encounterVersion.CustomPlaceholders

    -- does the placeholder with the name not already exist?
    local alreadyExists = PRT.TableUtils.GetBy(placeholders, "name", name)
    assert(not alreadyExists, string.format("Placeholder with name %s already exists.", PRT.HighlightString(name)))

    -- Add the new placeholder
    local newPlaceholder = {
      name = name,
      type = placeholderType,
      names = playerNames
    }

    tinsert(placeholders, newPlaceholder)

    return true
  end
end

_G["GPRTAPI"] = API
