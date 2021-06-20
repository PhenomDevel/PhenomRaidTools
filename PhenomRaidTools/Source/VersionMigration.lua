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
              characterNames = placeholder.names or {}
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
    version = "2.17.13",
    migrationFunction = function(profile)
      -- Make sure global placeholders have their name set
      for placeholderName, placeholder in pairs(profile.customPlaceholders) do
        placeholder.name = placeholderName
        placeholder.characterNames = placeholder.names or {}
      end

      -- make sure encounter placeholders have their name set
      for _, encounter in ipairs(profile.encounters) do
        for _, encounterVersion in ipairs(encounter.versions) do
          local placeholders = encounterVersion.CustomPlaceholders

          if placeholders then
            for placeholderName, placeholder in pairs(placeholders) do
              placeholder.name = placeholderName
              placeholder.characterNames = placeholder.names or {}
            end
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

  for _, migration in pairs(migrationFunctions) do
    if not processedMigrations[migration.version] then
      tinsert(pendingMigrations, migration)
    end
  end

  return pendingMigrations
end

-------------------------------------------------------------------------------
-- Public API

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
