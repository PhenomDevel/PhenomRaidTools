local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


local AceTimer = LibStub("AceTimer-3.0")

local spellIconSize = 48


-------------------------------------------------------------------------------
-- Spell Cache Panel

local function addLabelWithValue(container, label, value)
  local group = PRT.SimpleGroup()
  group:SetLayout("Flow")

  local label = PRT.Label(label..":")
  local value = PRT.Label(value)

  group:AddChild(label)
  group:AddChild(value)

  return group, label, value
end

local function getStatusText(spellCache)
  local statusText

  if spellCache.status == "completed" then
    statusText = PRT.ColoredString(spellCache.status, "FF76ff68")
  elseif spellCache.status == "running" then
    statusText = PRT.ColoredString(spellCache.status, "FFed3939")
  else
    statusText = spellCache.status
  end

  return
    statusText
end

function PRT.AddSpellCacheStatus(container, spellCache)
  local statusGroup = addLabelWithValue(container, L["Status"], getStatusText(spellCache))
  container:AddChild(statusGroup)
end

function PRT.AddSpellCacheSearch(container, spellCache)
  local searchEditBox = PRT.EditBox(L["Search"])
  local spellsContainer = PRT.SimpleGroup()

  searchEditBox:SetRelativeWidth(1)
  spellsContainer:SetLayout("Flow")
  searchEditBox:SetCallback("OnEnterPressed",
    function(widget)
      widget:ClearFocus()
    end)

  searchEditBox:SetCallback("OnTextChanged",
    function(widget)
      local value = widget:GetText()
      spellsContainer:ReleaseChildren()

      if string.len(value) >= 4 then
        local matches = PRT.SpellCache.GetMatches(spellCache, value, 150)

        for _, match in ipairs(matches) do
          local spellIcon = PRT.Icon(match.id)
          spellIcon:SetHeight(spellIconSize + 4)
          spellIcon:SetWidth(spellIconSize + 4)
          spellIcon:SetImageSize(spellIconSize, spellIconSize)
          spellsContainer:AddChild(spellIcon)
        end
      end

      container:DoLayout()
    end)

  container:AddChild(searchEditBox)
  container:AddChild(spellsContainer)
end

function PRT.AddSpellCacheWidget(container)
  local spellCache = PRT.db.global.spellCache

  local descriptionLines = {
    L["Here you can search the spell database. The database is build up in the background and may not contain "..
      "all known spells just yet. If you can't find a spell please check back later when status is `completed`."],
    L["The spell database is globally available for all of your characters and will be build up regardless of which character you are playing."],
    PRT.ColoredString(L["The spell database will rebuild once the patch version changes. This is done so you always have the newest spells in the database."], "FF6bfdff"),
  }

  local descriptionText = strjoin("\n\n", unpack(descriptionLines))
  local descriptionLabel = PRT.Label(descriptionText)
  local statusGroup, _, statusValueLabel = addLabelWithValue(container, L["Status"], getStatusText(spellCache))
  local lastCheckedGroup, _, lastCheckedValueLabel = addLabelWithValue(container, L["Last checked id"], spellCache.lastCheckedId)
  local spellCountGroup, _, spellCountValueLabel = addLabelWithValue(container, L["Spell count"], PRT.TableUtils.Count(spellCache.spells))

  local startedAtGroup = addLabelWithValue(container, L["Started at"], spellCache.startedAt)
  local completedAtGroup = addLabelWithValue(container, L["Completed at"], spellCache.completedAt)

  local invalidateCacheButton = PRT.Button(L["Rebuild spell database"])

  descriptionLabel:SetRelativeWidth(1)

  container:AddChild(descriptionLabel)
  container:AddChild(PRT.Heading(nil))
  container:AddChild(statusGroup)
  container:AddChild(lastCheckedGroup)
  container:AddChild(spellCountGroup)
  container:AddChild(startedAtGroup)
  container:AddChild(completedAtGroup)
  container:AddChild(invalidateCacheButton)
  PRT.AddSpellCacheSearch(container, spellCache)

  local updateTimer
  if not spellCache.completed then
    updateTimer = AceTimer:ScheduleRepeatingTimer(
      function()
        statusValueLabel:SetText(getStatusText(spellCache))
        PRT.UpdateLabelWidth(statusValueLabel)
        lastCheckedValueLabel:SetText(spellCache.lastCheckedId)
        PRT.UpdateLabelWidth(lastCheckedValueLabel)
        spellCountValueLabel:SetText(PRT.TableUtils.Count(spellCache.spells))
        PRT.UpdateLabelWidth(spellCountValueLabel)
      end,
      0.3
    )
  end

  invalidateCacheButton:SetCallback("OnClick",
    function()
      local confirmationLabel = L["Rebuilding the spell cache can take a while.|nAre you sure you want to rebuild it?"]

      PRT.ConfirmationDialog(confirmationLabel,
        function()
          AceTimer:CancelTimer(updateTimer)
          PRT.SpellCache.Invalidate(spellCache)
          PRT.SpellCache.Build(spellCache)

          container:ReleaseChildren()
          PRT.AddSpellCacheWidget(container)
        end)
    end)

  if not spellCache.completed then
    container:SetCallback("OnRelease",
      function()
        AceTimer:CancelTimer(updateTimer)
      end)

    container.backgroundTimer = updateTimer
  end
end
