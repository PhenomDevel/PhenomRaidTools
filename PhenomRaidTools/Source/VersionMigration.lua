local _, PRT = ...

-------------------------------------------------------------------------------
-- Private Helper

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
      for placeholderIndex, placeholder in pairs(profile.customPlaceholders) do
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
      for placeholderName, placeholder in pairs(profile.customPlaceholders) do
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
        for _, entry in pairs(entries) do
          for _, message in pairs(entry.messages) do
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
          for _, timer in pairs(encounterVersion.Timers) do
            updateEntries(timer.timings)
          end

          -- Rotation
          for _, rotation in pairs(encounterVersion.Rotations) do
            updateEntries(rotation.entries)
          end

          -- HP
          for _, percentage in pairs(encounterVersion.HealthPercentages) do
            updateEntries(percentage.values)
          end

          -- Power
          for _, percentage in pairs(encounterVersion.PowerPercentages) do
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
  --if PRT.IsDevelopmentVersion() then
  --profile.processedMigrations["2.7.4"] = false
  --   PRT.Debug("Skipping migrations due to development version.")
  --end

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
end
