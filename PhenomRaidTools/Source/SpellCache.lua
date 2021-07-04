local _, PRT = ...

local AceTimer = LibStub("AceTimer-3.0")

local SpellCache = {}

PRT.SpellCache = SpellCache

local GetBuildInfo, GetSpellDescription = GetBuildInfo, GetSpellDescription

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
  spellCache.startedAt = PRT.Now()
  spellCache.completedAt = nil
  PRT.Debug("Spell database will be updated in the background.")
end

function SpellCache.CheckWowVersion(spellCache)
  local currentWowVersion = GetBuildInfo()

  if spellCache.wowVersion ~= currentWowVersion then
    PRT.Debug("WoW version has changed. Previous:", PRT.HighlightString(spellCache.wowVersion), "Current:", PRT.HighlightString(currentWowVersion))
    SpellCache.Invalidate(spellCache)
  end
end

function SpellCache.Build(spellCache)
  if spellCache.enabled then
    SpellCache.CheckWowVersion(spellCache)

    if not spellCache.completed then
      local backgroundRoutine =
        coroutine.create(
        function()
          local id = spellCache.lastCheckedId or 0
          local failedAttempt = 0

          while failedAttempt < 400 do
            id = id + 1

            local name, _, icon = GetSpellInfo(id)
            local description = GetSpellDescription(id)

            if (not PRT.StringUtils.IsEmpty(name)) then
              if icon ~= 136243 or (not PRT.StringUtils.IsEmpty(description)) then
                spellCache.spells[id] = {
                  id = id,
                  name = name
                }
              end

              failedAttempt = 0
            else
              failedAttempt = failedAttempt + 1
            end

            spellCache.lastCheckedId = id
            coroutine.yield()
          end

          PRT.Debug("Building of spell database completed. Found", PRT.HighlightString(PRT.TableUtils.Count(spellCache.spells)), "spells")

          spellCache.completedAt = PRT.Now()
          spellCache.completed = true
        end
      )

      local timerId =
        AceTimer:ScheduleRepeatingTimer(
        -- We retrieve one spell every 16ms (roughly 60 calculations per second)
        function()
          coroutine.resume(backgroundRoutine)
        end,
        0.016
      )

      spellCache.timerId = timerId
    end
  end
end

function SpellCache.PauseBuild(spellCache)
  if spellCache.timerId and not spellCache.completed then
    AceTimer:CancelTimer(spellCache.timerId)
    spellCache.timerId = nil
    PRT.Debug("Building of spell database paused.")
  end
end

function SpellCache.Resume(spellCache)
  if not spellCache.timerId and not spellCache.completed then
    SpellCache.Build(spellCache)
    PRT.Debug("Building of spell database resumed.")
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
