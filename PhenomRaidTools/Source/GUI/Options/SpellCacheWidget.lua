local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local spellIconSize = 48

-------------------------------------------------------------------------------
-- Spell Cache Panel

local function addLabelWithValue(label, value)
  local group = PRT.SimpleGroup()
  local labelWidget = PRT.Label(label .. ":")
  local valueWidget = PRT.Label(value)

  group:SetLayout("Flow")
  group:AddChild(labelWidget)
  group:AddChild(valueWidget)

  return group, labelWidget, valueWidget
end

local function getStatusText(spellCache)
  local statusText

  if spellCache.completed then
    statusText = PRT.ColoredString(L["completed"], PRT.Static.Colors.Success)
  else
    statusText = PRT.ColoredString(L["running"], PRT.Static.Colors.Inactive)
  end

  return statusText
end

local function AddSpellCacheSearch(container, spellCache)
  local searchEditBox = PRT.EditBox(L["Search"])
  local spellsContainer = PRT.SimpleGroup()

  searchEditBox:SetRelativeWidth(1)
  spellsContainer:SetLayout("Flow")
  searchEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      widget:ClearFocus()
    end
  )

  searchEditBox:SetCallback(
    "OnTextChanged",
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
    end
  )

  container:AddChild(searchEditBox)
  container:AddChild(spellsContainer)
end

function PRT.AddSpellCacheWidget(container)
  local spellCache = PRT.GetGlobalDB().spellCache
  local spellCacheGroup = PRT.SimpleGroup()

  PRT.AddHelpContainer(
    container,
    {
      L[
        "Here you can search the spell database. The database is build up in the background and may not contain " ..
          "all known spells just yet. If you can't find a spell please check back later when status is `completed`."
      ],
      L["The spell database is globally available for all of your characters and will be build up regardless of which character you are playing."],
      PRT.ColoredString(
        L["The spell database will rebuild once the patch version changes. This is done so you always have the newest spells in the database."],
        PRT.Static.Colors.Inactive
      )
    }
  )

  local enabledCheckBox = PRT.CheckBox(L["Enabled"], nil, spellCache.enabled)
  local statusGroup, _, statusValueLabel = addLabelWithValue(L["Status"], getStatusText(spellCache))
  local lastCheckedGroup, _, lastCheckedValueLabel = addLabelWithValue(L["Last checked id"], spellCache.lastCheckedId)
  local spellCountGroup, _, spellCountValueLabel = addLabelWithValue(L["Spell count"], PRT.TableUtils.Count(spellCache.spells))

  local startedAtGroup = addLabelWithValue(L["Started at"], spellCache.startedAt)
  local completedAtGroup = addLabelWithValue(L["Completed at"], spellCache.completedAt)

  local invalidateCacheButton = PRT.Button(L["Rebuild spell database"])

  spellCacheGroup:AddChild(enabledCheckBox)
  spellCacheGroup:AddChild(statusGroup)
  spellCacheGroup:AddChild(lastCheckedGroup)
  spellCacheGroup:AddChild(spellCountGroup)
  spellCacheGroup:AddChild(startedAtGroup)
  spellCacheGroup:AddChild(completedAtGroup)
  spellCacheGroup:AddChild(invalidateCacheButton)
  AddSpellCacheSearch(spellCacheGroup, spellCache)

  enabledCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()

      if value then
        PRT.SpellCache.Resume(spellCache)
      else
        PRT.SpellCache.PauseBuild(spellCache)
      end
    end
  )

  local updateTimer
  if not spellCache.completed then
    updateTimer =
      AceTimer:ScheduleRepeatingTimer(
      function()
        statusValueLabel:SetText(getStatusText(spellCache) or "N/A")
        PRT.UpdateLabelWidth(statusValueLabel)
        lastCheckedValueLabel:SetText(spellCache.lastCheckedId or "N/A")
        PRT.UpdateLabelWidth(lastCheckedValueLabel)
        spellCountValueLabel:SetText(PRT.TableUtils.Count(spellCache.spells) or "N/A")
        PRT.UpdateLabelWidth(spellCountValueLabel)
      end,
      0.3
    )
  end

  invalidateCacheButton:SetCallback(
    "OnClick",
    function()
      local confirmationLabel = L["Rebuilding the spell cache can take a while.|nAre you sure you want to rebuild it?"]

      PRT.ConfirmationDialog(
        confirmationLabel,
        function()
          AceTimer:CancelTimer(updateTimer)
          PRT.SpellCache.Invalidate(spellCache)
          PRT.SpellCache.Build(spellCache)

          spellCacheGroup:ReleaseChildren()
          PRT.AddSpellCacheWidget(spellCacheGroup)
        end
      )
    end
  )

  if not spellCache.completed then
    spellCacheGroup:SetCallback(
      "OnRelease",
      function()
        AceTimer:CancelTimer(updateTimer)
      end
    )
  end

  container:AddChild(spellCacheGroup)
end
