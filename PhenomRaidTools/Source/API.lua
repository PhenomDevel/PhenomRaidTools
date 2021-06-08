--- API
-- Contains all functions which are exposed to the open world

local _, PRT = ...

local API = {}

-------------------------------------------------------------------------------
-- Public API

-------------------------------------------------------------------------------
-- Messages
do
  local validMessageTypes = {
    "raidtarget",
    "raidwarning",
    "cooldown",
    "advanced"
  }

  --- Send a message to the given players.
  -- The message will be sent to all players in `targets` and it will perform the corresponding action based on `type`.
  -- @param[type=string] type type of the message you want to send
  -- @param[type=table] targets table of targets which should receive the message
  -- @usage local PRT = _G["PRT"]
  -- @usage PRT:SendMessage("advanced", {"Phenom"})
  -- @return true
  function API:SendMessage(messageType, targets)
    assert(tContains(validMessageTypes, messageType), "`type` needs to be either `raidtarget`, `raidwarning`, `cooldown`, or `advanced`.")
    assert(type(targets) == "table", "`targets` needs to be a table of player names.")

    -- TODO
  end
end

-------------------------------------------------------------------------------
-- Placeholders
do
  local validPlaceholderTypes = {
    "player",
    "group"
  }

  local function assertPlaceholderParams(placeholderType, name, characterNames)
    -- is the type contained in our valid types?
    assert(tContains(validPlaceholderTypes, placeholderType), "`type` needs to be either `group`, or `player`.")

    -- is the name a non empty string?
    assert(not PRT.StringUtils.IsEmpty(name), "`name` has to be a non empty string.")

    -- are the playerNames a table?
    assert(type(characterNames) == "table", "`characterNames` needs to be a table of player names.")
  end

  --- Add a new global placeholder
  -- If a placeholder with this name already exists the character names will be merged when you set `overwriteCharacterNames` to true.
  -- @param[type=string] placeholderType the type of the placeholder. Can either be `group` or `player`
  -- @param[type=string] name the name of the placeholder. Can only be a name which is not already present
  -- @param[type=table] characterNames table of the player names which should be used for the placeholder
  -- @param[type=boolean] overwriteCharacterNames defines if the character names should be overwritten when a placeholder with this name already exists.
  -- @usage local PRT = _G["PRT"]
  -- @usage PRT:UpsertGlobalPlaceholder("player", "test", {"Phenom"}, true)
  -- @return true
  function API:UpsertGlobalPlaceholder(placeholderType, name, characterNames, overwriteCharacterNames)
    -- are the placeholder params valid?
    assertPlaceholderParams(placeholderType, name, characterNames)

    local placeholders = PRT.GetProfileDB().customPlaceholders

    local existingPlaceholder = placeholders[name]

    if existingPlaceholder then
      if overwriteCharacterNames then
        existingPlaceholder.characterNames = characterNames
      else
        existingPlaceholder.characterNames = PRT.TableUtils.MergeMany(existingPlaceholder.characterNames, characterNames)
      end
    else
      placeholders[name] = {
        name = name,
        type = placeholderType,
        characterNames = characterNames
      }
    end

    return true
  end

  --- Add a new encounter placeholder
  -- If a placeholder with this name already exists the charracter names will be merged when you set `overwriteCharacterNames` to true.
  -- @param[type=number] encounterID the encounter id for which the placeholder should be added
  -- @param[type=string] placeholderType the type of the placeholder. Can either be `group` or `player`
  -- @param[type=string] name the name of the placeholder. Can only be a name which is not already present
  -- @param[type=table] characterNames table of the player names which should be used for the placeholder
  -- @param[type=boolean] overwriteCharacterNames defines if the character names should be overwritten when a placeholder with this name already exists.
  -- @usage local PRT = _G["PRT"]
  -- @usage PRT:UpsertEncounterPlaceholder(1234, "player", "test", {"Phenom"}, true)
  -- @return true
  function API:UpsertEncounterPlaceholder(encounterID, placeholderType, name, characterNames, overwriteCharacterNames)
    -- does the encounter exist?
    local _, encounter = PRT.GetEncounterById(PRT.GetProfileDB().encounters, encounterID)
    assert(encounter, "It was no encounter found for the given `encounterID`.")
    local encounterVersion = encounter.versions[encounter.selectedVersion]

    -- are the placeholder params valid?
    assertPlaceholderParams(placeholderType, name, characterNames)

    local placeholders = encounterVersion.CustomPlaceholders
    local existingPlaceholder = placeholders[name]

    if existingPlaceholder then
      if overwriteCharacterNames then
        existingPlaceholder.characterNames = characterNames
      else
        existingPlaceholder.characterNames = PRT.TableUtils.MergeMany(existingPlaceholder.characterNames, characterNames)
      end
    else
      placeholders[name] = {
        name = name,
        type = placeholderType,
        characterNames = characterNames
      }
    end

    return true
  end
end

-------------------------------------------------------------------------------
-- Conditions

function API:TriggerCondition()
end

_G["PRT"] = API
