local _, PRT = ...

-------------------------------------------------------------------------------
-- Private Helper

-- The four receivers every profile had before 3.0.0-3 (AceDB defaults).
local function LegacyReceiver(id, name, fontSize, r, g, b)
  return {
    id = id,
    label = name,
    name = id,
    locked = true,
    fontSize = fontSize,
    fontColor = {hex = format("%02x%02x%02x%02x", 255, r * 255, g * 255, b * 255), r = r, g = g, b = b, a = 1},
    enableSound = true,
    defaultSoundFile = "Interface\\AddOns\\PhenomRaidTools\\Media\\Sounds\\ReceiveMessage.ogg",
    defaultSoundFileName = "PRT: Default"
  }
end

local LEGACY_RECEIVERS = {
  LegacyReceiver(1, "Default", 16, 1, 1, 1),
  LegacyReceiver(2, "Important", 84, 1, 0, 0),
  LegacyReceiver(3, "Personals/Unimportant", 64, 0, 1, 0),
  LegacyReceiver(4, "Healing/Special", 36, 0, 0, 1)
}

local function FillMissing(target, source)
  for key, value in pairs(source) do
    if target[key] == nil then
      target[key] = type(value) == "table" and PRT.TableUtils.Clone(value) or value
    elseif type(value) == "table" and type(target[key]) == "table" then
      FillMissing(target[key], value)
    end
  end
end

local migrationFunctions = {
  [1] = {
    version = "2.5.0",
    migrationFunction = function(profile)
      PRT.Debug("Prepare encounter tables to store more than one version.")

      for encounterIndex, encounter in ipairs(profile.encounters) do
        if not encounter.versions then
          profile.encounters[encounterIndex] = {
            selectedVersion = 1,
            name = encounter.name,
            id = encounter.id,
            enabled = encounter.enabled
          }
          profile.encounters[encounterIndex].versions = {
            encounter
          }

          encounter.name = encounter.name
        else
          PRT.Debug("Skipping encounter", PRT.HighlightString(encounter.name), "because it seems this encounter already got migrated.")
        end
      end

      return true
    end
  },
  [2] = {
    version = "2.7.4",
    migrationFunction = function(profile)
      PRT.Debug("Enabling all encounter versions. Some of them got disabled on migration 2.5.0.")

      for _, encounter in ipairs(profile.encounters) do
        for _, encounterVersion in ipairs(encounter.versions) do
          encounterVersion.enabled = true
        end
      end

      return true
    end
  },
  [3] = {
    version = "2.17.0",
    migrationFunction = function(profile)
      local migratePlaceholder = function(index, placeholder, newTable)
        -- if the index is a number proceed. If not we already did this migration (most likely)
        if type(index) == "number" then
          if newTable[placeholder.name] then
            -- There has to be a duplicate placeholder. So stop processing!
            PRT.Debug(string.format("Placeholder %s already exists. Merging character names.", PRT.HighlightString(placeholder.name)))
            newTable[placeholder.name].characterNames = PRT.TableUtils.MergeMany(newTable[placeholder.name].characterNames, placeholder.names)
          else
            newTable[placeholder.name] = {
              type = placeholder.type,
              characterNames = placeholder.names or placeholder.characterNames or {}
            }
          end
        end
      end

      -- Migrate global placeholders
      local newGlobalPlaceholders = {}
      for placeholderIndex, placeholder in pairs(profile.customPlaceholders or {}) do
        migratePlaceholder(placeholderIndex, placeholder, newGlobalPlaceholders)
      end
      profile.customPlaceholders = newGlobalPlaceholders

      -- Migrate encounter placeholders
      for _, encounter in ipairs(profile.encounters) do
        for _, encounterVersion in ipairs(encounter.versions) do
          local placeholders = encounterVersion.CustomPlaceholders
          local newPlaceholders = {}

          if encounterVersion.CustomPlaceholders then
            for placeholderIndex, placeholder in pairs(placeholders) do
              migratePlaceholder(placeholderIndex, placeholder, newPlaceholders)
            end

            encounter.CustomPlaceholders = newPlaceholders
          end
        end
      end

      return true
    end
  },
  [4] = {
    version = "2.17.14",
    migrationFunction = function(profile)
      -- Make sure global placeholders have their name set
      for placeholderName, placeholder in pairs(profile.customPlaceholders or {}) do
        placeholder.name = placeholderName
        placeholder.characterNames = placeholder.names or placeholder.characterNames or {}
      end

      -- make sure encounter placeholders have their name set
      for _, encounter in ipairs(profile.encounters) do
        for _, encounterVersion in ipairs(encounter.versions) do
          local placeholders = encounterVersion.CustomPlaceholders

          if placeholders then
            for placeholderName, placeholder in pairs(placeholders) do
              placeholder.name = placeholderName
              placeholder.characterNames = placeholder.names or placeholder.characterNames or {}
            end
          end
        end
      end

      return true
    end
  },
  [5] = {
    version = "2.23.0",
    migrationFunction = function(profile)
      PRT.Debug("Change targets table to `[name] = name` for `cooldown` messages")

      local updateEntries = function(entries)
        for _, entry in pairs(entries or {}) do
          for _, message in pairs(entry.messages or {}) do
            local targetsBackup = PRT.TableUtils.Clone(message.targets)

            if message.type == "cooldown" then
              wipe(message.targets)
              for _, target in pairs(targetsBackup) do
                message.targets[target] = target
              end
            end
          end
        end
      end

      for _, encounter in ipairs(profile.encounters) do
        for _, encounterVersion in ipairs(encounter.versions) do
          -- Timer
          for _, timer in pairs(encounterVersion.Timers or {}) do
            updateEntries(timer.timings)
          end

          -- Rotation
          for _, rotation in pairs(encounterVersion.Rotations or {}) do
            updateEntries(rotation.entries)
          end

          -- HP
          for _, percentage in pairs(encounterVersion.HealthPercentages or {}) do
            updateEntries(percentage.values)
          end

          -- Power
          for _, percentage in pairs(encounterVersion.PowerPercentages or {}) do
            updateEntries(percentage.values)
          end
        end
      end

      return true
    end
  },
  [6] = {
    version = "2.23.1",
    migrationFunction = function(profile)
      PRT.Debug("Change message template tables to `[template.name] = template`")

      if profile.templateStore.messages then
        local messageTemplateBackup = PRT.TableUtils.Clone(profile.templateStore.messages)
        wipe(profile.templateStore.messages)

        for _, template in pairs(messageTemplateBackup) do
          if template.name then
            profile.templateStore.messages[template.name] = template
          end
        end
      end

      return true
    end
  },
  [7] = {
    version = "3.0.0",
    migrationFunction = function(profile)
      -- Recorded combat log events; the recorder is gone with the combat log.
      profile.combatEventRecorder = nil

      return true
    end
  },
  [8] = {
    version = "3.0.0-2",
    migrationFunction = function(profile)
      -- Overlays: the new layout keeps the old look (text) and grow direction.
      for _, receiver in ipairs(profile.overlay.receivers or {}) do
        if receiver.grow == nil then
          receiver.grow = receiver.growDirection == "UP" and "UP" or "DOWN"
        end
        receiver.growDirection = nil
      end

      -- Cooldown messages stored their targets as { [name] = name }.
      PRT.ForEachMessage(profile, PRT.NormalizeTargets)

      return true
    end
  },
  [9] = {
    version = "3.0.0-3",
    migrationFunction = function(profile)
      -- Everything that can't or barely runs since Midnight is gone: rotations,
      -- health/power percentages, timers on combat log events, stop
      -- conditions, raid warnings and markers, placeholders, /prtm and its filter.
      for _, encounter in ipairs(profile.encounters or {}) do
        for _, version in ipairs(encounter.versions or {}) do
          PRT.CleanEncounterVersion(version)
        end
      end
      for name, template in pairs(profile.templateStore and profile.templateStore.messages or {}) do
        if not PRT.IsMessageSupported(template) then
          profile.templateStore.messages[name] = nil
        end
      end
      profile.customPlaceholders, profile.raidRoster, profile.messageFilter = nil, nil, nil
      local triggerDefaults = profile.triggerDefaults or {}
      triggerDefaults.rotationDefaults, triggerDefaults.percentageDefaults, triggerDefaults.conditionDefaults = nil, nil, nil
      local messageDefaults = triggerDefaults.messageDefaults
      if messageDefaults and messageDefaults.defaultMessageType and not PRT.IsMessageSupported({type = messageDefaults.defaultMessageType}) then
        messageDefaults.defaultMessageType = nil
      end
      if profile.mrtExportDefaults then
        profile.mrtExportDefaults.includeRotations = nil
      end

      -- Receivers lost their AceDB defaults (new profiles get three new
      -- ones): what an existing profile didn't store equalled the old defaults.
      local receivers = profile.overlay and profile.overlay.receivers
      if receivers and next(receivers) then
        for index, legacy in ipairs(LEGACY_RECEIVERS) do
          receivers[index] = receivers[index] or {}
          FillMissing(receivers[index], legacy)
        end
      end

      return true
    end
  }
}

local function GetPendingMigrations(profile)
  local pendingMigrations = {}
  local processedMigrations = profile.processedMigrations

  for _, migration in ipairs(migrationFunctions) do
    if not processedMigrations[migration.version] then
      tinsert(pendingMigrations, migration)
    end
  end

  return pendingMigrations
end

-------------------------------------------------------------------------------
-- Public API

function PRT.MigrateGlobalDB(db)
  db.spellCache = nil
end

function PRT.MigrateProfileDB(profile)
  local pendingMigrations = GetPendingMigrations(profile)

  if PRT.TableUtils.Count(pendingMigrations) > 0 then
    PRT.Debug("You have", PRT.HighlightString(PRT.TableUtils.Count(pendingMigrations)), "pending migration(s). They will be applied to your profile now.")

    for _, migration in pairs(pendingMigrations) do
      PRT.Debug("Applying migration for version", PRT.HighlightString(migration.version))
      local success = migration.migrationFunction(profile)

      if success then
        profile.processedMigrations[migration.version] = true
      end
    end
  end

  -- A new profile (or one whose receivers all equalled the old defaults).
  profile.overlay.receivers = profile.overlay.receivers or {}
  if not next(profile.overlay.receivers) then
    profile.overlay.receivers = PRT.ReceiverOverlay.DefaultReceivers()
  end
end
