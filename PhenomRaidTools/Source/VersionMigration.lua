local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


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
  local pendingMigrations = GetPendingMigrations(profile)

  PRT.Debug("You have", PRT.HighlightString(PRT.TableUtils.Count(pendingMigrations)), "pending migrations. They will be applied to your profile now.")

  -- if PRT.IsDevelopmentVersion() then
  --   PRT.Debug("Skipping migrations due to development version.")
  -- else
  for _, migration in pairs(pendingMigrations) do
    PRT.Debug("Applying migration for version", PRT.HighlightString(migration.version))
    migration.migrationFunction(profile)
    profile.processedMigrations[migration.version] = true
  end
  --end
end
