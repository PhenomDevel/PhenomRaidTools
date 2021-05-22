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
      migration.migrationFunction(profile)
      profile.processedMigrations[migration.version] = true
    end
  end
end
