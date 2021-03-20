local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Private Helper

local function Migrate248(profile)
-- TODO
end

local migrationFunctions = {
  --[1] = {
  --  version = "2.4.8",
  --  migrationFunction = Migrate248
  --},
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

  for _, migration in pairs(pendingMigrations) do
    PRT.Debug("Applying migration for version", PRT.HighlightString(migration.version))
    migration.migrationFunction(profile)
    profile.processedMigrations[migration.version] = true
  end
end
