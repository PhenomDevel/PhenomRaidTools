local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local GetNumSpecializations, GetSpecializationInfo = GetNumSpecializations, GetSpecializationInfo

local Profiles = {}

-------------------------------------------------------------------------------
-- Private Helper

function Profiles.RedoLayout(container, options)
  container:ReleaseChildren()
  PRT.AddProfilesWidget(container, options)
end

function Profiles.UpdateCoreFrame()
  PRT.Core.UpdateTree()
  PRT.Core.ReselectCurrentValue()
  PRT.SenderOverlay.ShowPlaceholder(PRT.SenderOverlay.overlayFrame, PRT.GetProfileDB().overlay.sender)
  PRT.ReceiverOverlay.ShowPlaceholders(PRT.GetProfileDB().overlay.receivers)
end

-- show current profile
function Profiles.AddCurrentProfileWidget(container)
  local currentProfileString = string.format("%s: %s", L["Current Profile"], PRT.ColoredString(PRT.GetCurrentProfile(), PRT.Static.Colors.Highlight))

  local currentProfileLabel = PRT.Label(currentProfileString)
  currentProfileLabel:SetRelativeWidth(1)

  container:AddChild(currentProfileLabel)
end

function Profiles.AddResetCurrentProfileWidget(container)
  local resetProfileButton = PRT.Button(L["Reset Profile"])
  resetProfileButton:SetCallback(
    "OnClick",
    function()
      local profile = PRT.GetCurrentProfile()
      PRT.ConfirmationDialog(
        L["Are you sure you want to reset profile %s?"]:format(PRT.HighlightString(profile)),
        function()
          PRT.ResetProfile(profile)
          PRT.Info("Resetted Profile ", PRT.HighlightString(profile))
          Profiles.UpdateCoreFrame(container)
        end
      )
    end
  )

  container:AddChild(resetProfileButton)
end

function Profiles.AddChangeCurrentProfile(container)
  local selectProfileGroup = PRT.SimpleGroup()
  local existingProfiles = PRT.GetProfiles()
  local currentProfile = PRT.GetCurrentProfile()
  local descriptionLabel = PRT.Label(L["Select the profile you want to change to."])

  local selectableProfiles =
    PRT.TableUtils.Remove(
    existingProfiles,
    function(value)
      return value == currentProfile
    end
  )

  local selectableProfilesDropdown = PRT.Dropdown(L["Select Profile"], nil, selectableProfiles)
  selectableProfilesDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      local profile = widget:GetValue()
      PRT.SetProfile(profile)
      PRT.Info("Selected Profile ", PRT.HighlightString(profile))
      Profiles.UpdateCoreFrame()
    end
  )

  selectProfileGroup:AddChild(descriptionLabel)
  selectProfileGroup:AddChild(selectableProfilesDropdown)
  container:AddChild(selectProfileGroup)
end

function Profiles.AddNewProfileWidget(container)
  local newProfileGroup = PRT.SimpleGroup()
  local newProfileEditBox = PRT.EditBox(L["New Profile"])
  local descriptionLabel =
    PRT.Label(L["Type any name for the new profile you want to create. If the name is already taken profile will instead switch to the already existing one."])

  descriptionLabel:SetRelativeWidth(0.5)

  newProfileEditBox:SetCallback(
    "OnEnterPressed",
    function(widget)
      local profileName = widget:GetText()
      PRT.SetProfile(profileName)
      Profiles.UpdateCoreFrame()
    end
  )

  newProfileGroup:AddChild(descriptionLabel)
  newProfileGroup:AddChild(newProfileEditBox)
  container:AddChild(newProfileGroup)
end

function Profiles.DeleteProfileWidget(container)
  local deleteProfileGroup = PRT.SimpleGroup()
  local existingProfiles = PRT.GetProfiles()
  local currentProfile = PRT.GetCurrentProfile()
  local descriptionLabel = PRT.Label(L["Select a profile you want to delete. You can't delete the currently active profile."])

  descriptionLabel:SetRelativeWidth(0.5)

  local deletableProfiles =
    PRT.TableUtils.Remove(
    existingProfiles,
    function(value)
      return value == currentProfile
    end
  )

  local deletableProfilesDropdown = PRT.Dropdown(L["Delete Profile"], nil, deletableProfiles)
  deletableProfilesDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      local profile = widget:GetValue()
      PRT.ConfirmationDialog(
        L["Are you sure you want to delete profile %s?"]:format(PRT.HighlightString(profile)),
        function()
          PRT.DeleteProfile(profile)
          PRT.Info("Deleted Profile ", PRT.HighlightString(profile))
          Profiles.UpdateCoreFrame()
        end
      )
    end
  )

  deleteProfileGroup:AddChild(descriptionLabel)
  deleteProfileGroup:AddChild(deletableProfilesDropdown)
  container:AddChild(deleteProfileGroup)
end

function Profiles.AddSpecProfileSelect(options, container, specIndex, specName)
  local availableProfiles = PRT.GetProfiles()
  local selectedProfile = options.specSpecificProfiles.profileBySpec[specIndex]
  local profileDropdown = PRT.Dropdown(specName, nil, availableProfiles, selectedProfile)
  profileDropdown:SetDisabled(not options.specSpecificProfiles.enabled)
  profileDropdown:SetRelativeWidth(0.5)
  profileDropdown:SetCallback(
    "OnValueChanged",
    function(widget)
      local value = widget:GetValue()
      options.specSpecificProfiles.profileBySpec[specIndex] = value
    end
  )

  container:AddChild(profileDropdown)
end

function Profiles.AddSpecSpecificGroupWidget(options, container)
  local specSpecificGroup = PRT.InlineGroup(L["Specialization Profiles"])
  local enabledCheckBox = PRT.CheckBox(L["Enabled"], L["Once you change your current specialization the profile will change automatically."], options.specSpecificProfiles.enabled)
  local descriptionLabel = PRT.Label(L["Specialization specific profiles are global. If you enable it, it will be active for all profiles."])

  specSpecificGroup:SetLayout("Flow")
  enabledCheckBox:SetRelativeWidth(1)
  descriptionLabel:SetRelativeWidth(0.5)

  enabledCheckBox:SetCallback(
    "OnValueChanged",
    function(widget)
      options.specSpecificProfiles.enabled = widget:GetValue()
      Profiles.UpdateCoreFrame()
    end
  )

  specSpecificGroup:AddChild(descriptionLabel)
  specSpecificGroup:AddChild(enabledCheckBox)

  for i = 1, GetNumSpecializations(), 1 do
    local specName = select(2, GetSpecializationInfo(i))
    Profiles.AddSpecProfileSelect(options, specSpecificGroup, i, specName)
  end

  container:AddChild(specSpecificGroup)
end

-------------------------------------------------------------------------------
-- Public API

function PRT.AddProfilesWidget(container, options)
  -- Reset Profile
  Profiles.AddResetCurrentProfileWidget(container)

  -- Current Profile
  Profiles.AddCurrentProfileWidget(container)

  -- Change Profile
  local changeGroup = PRT.InlineGroup(L["Change"])
  Profiles.AddChangeCurrentProfile(changeGroup)
  container:AddChild(changeGroup)

  -- New Profile
  local newGroup = PRT.InlineGroup(L["New"])
  Profiles.AddNewProfileWidget(newGroup)
  container:AddChild(newGroup)

  -- Copy from Profile
  -- Profiles.CopyFromProfileWidget(container)

  -- Delete Profile
  local deleteGroup = PRT.InlineGroup(L["Delete"])
  Profiles.DeleteProfileWidget(deleteGroup)
  container:AddChild(deleteGroup)

  if PRT.IsRetail() then
    -- Spec Specific Profiles
    Profiles.AddSpecSpecificGroupWidget(options, container)
  end
end
