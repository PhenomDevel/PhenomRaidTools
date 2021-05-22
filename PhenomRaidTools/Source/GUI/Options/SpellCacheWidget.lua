local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")


local AceTimer = LibStub("AceTimer-3.0")

local spellIconSize = 48


-------------------------------------------------------------------------------
-- Spell Cache Panel

local function addLabelWithValue(label, value)
  local group = PRT.SimpleGroup()
  group:SetLayout("Flow")
  group:AddChild(PRT.Label(label..":"))
  group:AddChild(PRT.Label(value))

  return group, label, value
end

local function getStatusText(spellCache)
  local statusText

  if spellCache.completed then
    statusText = PRT.ColoredString(L["completed"], PRT.Static.Colors.Success)
  else
    statusText = PRT.ColoredString(L["running"], PRT.Static.Colors.Inactive)
  end

  return
    statusText
end

local function AddSpellCacheSearch(container, spellCache)
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
  local spellCache = PRT.GetGlobalDB().spellCache
  local spellCacheGroup = PRT.SimpleGroup()

  local descriptionLines = {
    L["Here you can search the spell database. The database is build up in the background and may not contain "..
      "all known spells just yet. If you can't find a spell please check back later when status is `completed`."],
    L["The spell database is globally available for all of your characters and will be build up regardless of which character you are playing."],
    PRT.ColoredString(L["The spell database will rebuild once the patch version changes. This is done so you always have the newest spells in the database."], PRT.Static.Colors.Inactive),
  }

  local enabledCheckBox = PRT.CheckBox(L["Enabled"], nil, spellCache.enabled)
  local descriptionText = strjoin("\n\n", unpack(descriptionLines))
  local descriptionLabel = PRT.Label(descriptionText)
  local statusGroup, _, statusValueLabel = addLabelWithValue(L["Status"], getStatusText(spellCache))
  local lastCheckedGroup, _, lastCheckedValueLabel = addLabelWithValue(L["Last checked id"], spellCache.lastCheckedId)
  local spellCountGroup, _, spellCountValueLabel = addLabelWithValue(L["Spell count"], PRT.TableUtils.Count(spellCache.spells))

  local startedAtGroup = addLabelWithValue(L["Started at"], spellCache.startedAt)
  local completedAtGroup = addLabelWithValue(L["Completed at"], spellCache.completedAt)

  local invalidateCacheButton = PRT.Button(L["Rebuild spell database"])

  descriptionLabel:SetRelativeWidth(1)

  spellCacheGroup:AddChild(descriptionLabel)
  spellCacheGroup:AddChild(PRT.Heading(nil))
  spellCacheGroup:AddChild(enabledCheckBox)
  spellCacheGroup:AddChild(statusGroup)
  spellCacheGroup:AddChild(lastCheckedGroup)
  spellCacheGroup:AddChild(spellCountGroup)
  spellCacheGroup:AddChild(startedAtGroup)
  spellCacheGroup:AddChild(completedAtGroup)
  spellCacheGroup:AddChild(invalidateCacheButton)
  AddSpellCacheSearch(spellCacheGroup, spellCache)

  enabledCheckBox:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      spellCache.enabled = value
      if value then
        PRT.SpellCache.Resume(spellCache)
      else
        PRT.SpellCache.PauseBuild(spellCache)
      end
    end)

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

          spellCacheGroup:ReleaseChildren()
          PRT.AddSpellCacheWidget(spellCacheGroup)
        end)
    end)

  if not spellCache.completed then
    spellCacheGroup:SetCallback("OnRelease",
      function()
        AceTimer:CancelTimer(updateTimer)
      end)
  end

  container:AddChild(spellCacheGroup)
end
