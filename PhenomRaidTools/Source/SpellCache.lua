local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local SpellCache = {}

PRT.SpellCache = SpellCache

local GetBuildInfo = GetBuildInfo


-------------------------------------------------------------------------------
-- Public API
-- Original Idea from WeakAuras2

function SpellCache.Invalidate(spellCache)
  local currentWowVersion = GetBuildInfo()
  PRT.Debug("Spell database was cleared.")

  AceTimer:CancelTimer(spellCache.timerId)

  spellCache.wowVersion = currentWowVersion
  spellCache.completed = false
  spellCache.lastCheckedId = 0
  spellCache.spells = {}
  spellCache.status = "running"
  spellCache.startedAt = PRT.Now()
  PRT.Debug("Spell database will be updated in the background.")
end

function SpellCache.CheckWowVersion(spellCache)
  local currentWowVersion = GetBuildInfo()

  if spellCache.wowVersion ~= currentWowVersion then
    PRT.Debug("WoW version has changed. Previous:",
      PRT.HighlightString(spellCache.wowVersion), "Current:", PRT.HighlightString(currentWowVersion))
    SpellCache.Invalidate(spellCache)
  end
end

function SpellCache.Build(spellCache)
  SpellCache.CheckWowVersion(spellCache)

  if not spellCache.completed then
    local backgroundRoutine = coroutine.create(
      function()
        local id = spellCache.lastCheckedId or 0
        local failedAttempt = 0

        while failedAttempt < 400 do
          id = id + 1
          local name, _, icon = GetSpellInfo(id)

          if not PRT.StringUtils.IsEmpty(name) then
            -- PRT.Debug("SpellCache: Found spell", PRT.HighlightString(name), "(", PRT.HighlightString(id), ")")

            if(icon == 136243) then -- 136243 is the a gear icon, we can ignore those spells
              failedAttempt = 0;
            else
              spellCache.spells[id] = {
                id = id,
                name = name
              }

              failedAttempt = 0
            end
          else
            failedAttempt = failedAttempt + 1
          end

          spellCache.lastCheckedId = id
          coroutine.yield()
        end

        PRT.Debug("Building of spell database completed. Found", PRT.HighlightString(PRT.TableUtils.Count(spellCache.spells)), "spells")

        spellCache.completedAt = PRT.Now()
        spellCache.completed = true
        spellCache.status = "completed"
      end)

    local timerId = AceTimer:ScheduleRepeatingTimer(
      -- We retrieve one spell every 16ms (roughly 60 calculations per second)
      function()
        coroutine.resume( backgroundRoutine )
      end,
      0.016
    )

    spellCache.timerId = timerId
  end
end

function SpellCache.GetMatches(spellCache, term, count)
  local matches = {}
  local matchCount = 0

  local lowerTerm = string.lower(term)

  for _, spell in pairs(spellCache.spells) do
    if string.find(string.lower(spell.name), lowerTerm) then
      matchCount = matchCount + 1
      matches[matchCount] = spell
    end
    if matchCount >= count then
      break
    end
  end

  PRT.TableUtils.SortByKey(matches, "name")

  return matches
end
