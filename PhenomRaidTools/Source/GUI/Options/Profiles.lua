local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local GetNumSpecializations, GetSpecialization, GetSpecializationInfo = GetNumSpecializations, GetSpecialization, GetSpecializationInfo


-------------------------------------------------------------------------------
-- Private Helper

-- TODOs
-- show current profile
-- reset current profile
-- new profie
-- copy from other profile
-- delete profile with confirmation

local function RedoLayout(container, options)
  container:ReleaseChildren()
  PRT.AddProfilesWidget(container, options)
end

local function addSpecProfileSelect(options, container, specIndex, specName)
  local availableProfiles = PRT.db:GetProfiles()

  local selectedProfile = options.specSpecificProfiles.profileBySpec[specIndex]
  local profileDropdown = PRT.Dropdown(specName, nil, availableProfiles, selectedProfile)
  profileDropdown:SetDisabled(not options.specSpecificProfiles.enabled)
  profileDropdown:SetRelativeWidth(0.5)
  profileDropdown:SetCallback("OnValueChanged",
    function(widget)
      local value = widget:GetValue()

      options.specSpecificProfiles.profileBySpec[specIndex] = value
    end)

  container:AddChild(profileDropdown)
end

local function addEnabledWidget(options, container)
  local enabledCheckBox = PRT.CheckBox(L["Enabled"], L["Once you change your current specialization the profile will change automatically."], options.specSpecificProfiles.enabled)
  enabledCheckBox:SetCallback("OnValueChanged",
    function(widget)
      options.specSpecificProfiles.enabled = widget:GetValue()
      RedoLayout(container, options)
    end)

  container:AddChild(enabledCheckBox)
end


-------------------------------------------------------------------------------
-- Public API

function PRT.AddProfilesWidget(container, options)
  local specProfileGroup = PRT.InlineGroup(L["Specialization Profiles"])
  specProfileGroup:SetLayout("Flow")

  for i = 1, GetNumSpecializations(), 1 do
    local specName = select(2, GetSpecializationInfo(i))
    addSpecProfileSelect(options, specProfileGroup, i, specName)
  end

  addEnabledWidget(options, container)
  container:AddChild(specProfileGroup)
end
