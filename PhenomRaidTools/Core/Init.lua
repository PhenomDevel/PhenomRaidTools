local _, PRT = ...
local addon = LibStub("AceAddon-3.0"):NewAddon("PhenomRaidTools", "AceConsole-3.0", "AceEvent-3.0")

local AceComm = LibStub("AceComm-3.0")

local LibDBIcon = LibStub("LibDBIcon-1.0")
local PhenomRaidToolsLDB =
  LibStub("LibDataBroker-1.1"):NewDataObject(
  "PhenomRaidTools",
  {
    type = "data source",
    text = "PhenomRaidTools",
    icon = "Interface\\AddOns\\PhenomRaidTools\\Media\\Logo.blp",
    OnClick = function(self, button)
      if button == "LeftButton" then
        addon:Open()
      elseif button == "MiddleButton" then
        LibDBIcon:Hide("PhenomRaidTools")
        PRT.GetProfileDB().minimap.hide = true
        PRT.Info("Minimap icon is now hidden. If you want to show it again use /prt minimap")
      end
    end,
    OnEnter = function()
      GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
      GameTooltip:AddDoubleLine("|cFF69CCF0PhenomRaidTools|r", "v" .. PRT.GetProfileDB().version)
      GameTooltip:AddDoubleLine("|cFFdcabffProfile|r ", PRT.GetCurrentProfile())
      GameTooltip:AddDoubleLine("|cFFdcabffLeft-Click|r", "Open window")
      GameTooltip:AddDoubleLine("|cFFdcabffMiddle-Click|r", "Hide minimap icon")
      GameTooltip:Show()
    end,
    OnLeave = function()
      GameTooltip:Hide()
    end
  }
)

-------------------------------------------------------------------------------
-- Ace standard functions

do
  local defaults = {
    char = {
      profileSettings = {
        specSpecificProfiles = {
          enabled = false,
          profileBySpec = {}
        }
      }
    },
    global = {
      onboarded = false
    },
    profile = {
      myName = UnitName("player"),
      version = "@project-version@",
      enabled = true,
      testMode = false,
      testEncounterID = 9999,
      testEncounterName = "Example Encounter",
      debugMode = false,
      showOverlay = false,
      hideOverlayAfterCombat = true,
      runMode = "receiver",
      senderMode = false,
      receiverMode = true,
      clipboard = {},
      -- overlay.receivers has no AceDB defaults: a new profile gets
      -- ReceiverOverlay.DefaultReceivers() (see PRT.MigrateProfileDB).
      overlay = {
        sender = {
          anchor = "TOPLEFT",
          top = 50,
          left = 615,
          fontSize = 14,
          backdropColor = {
            r = 0,
            g = 0,
            b = 0,
            a = 0.7
          },
          fontColor = {
            hex = "FFFFFF",
            r = 1,
            g = 1,
            b = 1,
            a = 1
          },
          enabled = true,
          hideAfterCombat = false,
          hideDisabledTriggers = false
        },
        upcoming = {
          enabled = true,
          locked = true,
          x = 0,
          y = -150,
          count = 3,
          leadTime = 30,
          fontSize = 18
        }
      },
      minimap = {
        hide = false
      },
      enabledDifficulties = {
        dungeon = {
          Normal = true,
          Heroic = true,
          Mythic = true
        },
        raid = {
          Normal = true,
          Heroic = true,
          Mythic = true
        }
      },
      triggerDefaults = {
        -- Filled by PRT.MessageDefaults().
        messageDefaults = {}
      },
      mrtExportDefaults = {
        includeTimers = true,
        withEmptyLines = false,
        withEncounterName = true,
        forceMethodRaidToolsUpdate = false,
        updatePRTTag = true,
        withPersonalization = false
      },
      encounters = {},
      currentEncounter = {
        inFight = false
      },
      colors = {},
      addonPrefixes = {
        versionRequest = "PRT_VERSION_REQ",
        versionResponse = "PRT_VERSION_RESP"
      },
      versionCheck = {},
      templateStore = {
        messages = {}
      },
      debugLog = {},
      processedMigrations = {}
    }
  }

  local db

  function PRT.GetGlobalDB()
    return db.global or {}
  end

  function PRT.GetProfileDB()
    return db.profile or {}
  end

  function PRT.GetCharDB()
    return db.char or {}
  end

  function PRT.GetProfiles()
    return db:GetProfiles()
  end

  function PRT.DeleteProfile(profile)
    return db:DeleteProfile(profile)
  end

  function PRT.SetProfile(profile)
    return db:SetProfile(profile)
  end

  function PRT.ResetProfile(profile)
    return db:ResetProfile(profile)
  end

  function PRT.CopyProfile(profile)
    return db:CopyProfile(profile)
  end

  function PRT.GetCurrentProfile()
    return db:GetCurrentProfile()
  end

  function addon:OnInitialize()
    local isNewInstall = _G.PhenomRaidToolsDB == nil
    db = LibStub("AceDB-3.0"):New("PhenomRaidToolsDB", defaults, true)

    -- Initialize Minimap Icon
    LibDBIcon:Register("PhenomRaidTools", PhenomRaidToolsLDB, PRT.GetProfileDB().minimap)

    -- Reset versions
    PRT.GetProfileDB().versionCheck = {}

    -- Reset clipboard
    PRT.GetProfileDB().clipboard = {}

    db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

    -- Migrations run before the overlays read their (migrated) settings.
    PRT.MigrateGlobalDB(PRT.GetGlobalDB())
    PRT.MigrateProfileDB(PRT.GetProfileDB())
    PRT.ReceiverOverlay.Initialize()

    PRT.WhatsNew.Initialize(isNewInstall)
  end
end

function addon:RefreshConfig()
  PRT.Info("Active Profile was changed to", PRT.HighlightString(PRT.GetCurrentProfile()))

  local encounterIdx, _ = PRT.TableUtils.GetBy(PRT.GetProfileDB().encounters, "id", 9999)
  if not encounterIdx and PRT.TableUtils.IsEmpty(PRT.GetProfileDB().encounters) then
    table.insert(PRT.GetProfileDB().encounters, PRT.ExampleEncounter())
  end

  PRT.MigrateProfileDB(PRT.GetProfileDB())
  PRT.ReceiverOverlay.Clear()
  PRT.ReceiverOverlay.Refresh()
  if PRT.SenderOverlay.IsShown() then
    PRT.SenderOverlay.Refresh()
  end
  PRT.UI.Refresh()
end

function addon:OnEnable()
  PRT.RegisterWorldEvents()

  AceComm:RegisterComm(PRT.GetProfileDB().addonPrefixes.versionRequest, self.OnVersionRequest)
  AceComm:RegisterComm(PRT.GetProfileDB().addonPrefixes.versionResponse, self.OnVersionResponse)
  PRT.PlanSync.Initialize()
end

function addon:OnDisable()
  PRT.UnregisterWorldEvents()
end

-- The first start guide opens until it is finished once.
function addon:Open()
  if not PRT.GetGlobalDB().onboarded and not PRT.UI.IsShown() then
    PRT.UI.Navigate("welcome")
  else
    PRT.UI.Toggle()
  end
end

function addon:PrintPartyOrRaidVersions()
  local myVersion = string.gsub(PRT.GetProfileDB().version, "[^%d]+", "")
  local myVersionN = tonumber(myVersion)

  for _, response in pairs(PRT.GetProfileDB().versionCheck) do
    local playerName, version, enabled = response.name, response.version, response.enabled

    local playerWithServer = GetUnitName(playerName, true)
    local coloredName = PRT.ClassColoredName(playerWithServer)

    if version == "" or version == nil then
      PRT.Info(coloredName, ":", PRT.ColoredString("no response", PRT.Static.Colors.Disabled))
    else
      local parsedVersion = string.gsub(version, "[^%d]+", "")
      local parsedVersionN = tonumber(parsedVersion)

      local statusString

      if enabled then
        statusString = PRT.ColoredString("Enabled", PRT.Static.Colors.Success)
      else
        statusString = PRT.ColoredString("Enabled", PRT.Static.Colors.Inactive)
      end

      if parsedVersionN and myVersionN then
        if parsedVersionN >= myVersionN then
          PRT.Info(string.format("%s -> %s:%s", coloredName, PRT.ColoredString(version, PRT.Static.Colors.Success), statusString))
        elseif parsedVersionN < myVersionN then
          PRT.Info(string.format("%s -> %s:%s", coloredName, PRT.ColoredString(version, PRT.Static.Colors.Inactive), statusString))
        end
      else
        PRT.Info(string.format("%s -> ???", coloredName))
      end
    end
  end
end

function addon:VersionCheck(_)
  local request = {
    type = "request",
    requestor = strjoin("-", UnitFullName("player"))
  }

  if PRT.PlayerInParty() then
    PRT.Info("Initialize version check")
    PRT.Info("Waiting for everyone to respond...")

    PRT.GetProfileDB().versionCheck = {}

    for _, name in ipairs(PRT.PartyNames()) do
      PRT.GetProfileDB().versionCheck[name] = ""
    end

    AceComm:SendCommMessage(PRT.GetProfileDB().addonPrefixes.versionRequest, PRT.Serialize(request), "RAID")
    PRT.Timer:ScheduleTimer(addon.PrintPartyOrRaidVersions, 5, addon)
  else
    PRT.Info("You are currently running version", PRT.ColoredString(PRT.GetProfileDB().version, PRT.Static.Colors.Highlight))
  end
end

function addon:ToggleMinimapIcon()
  LibDBIcon:Show("PhenomRaidTools")
  PRT.GetProfileDB().minimap.hide = false
end

function addon:PrintHelp()
  PRT.Info("You can use following commands:")
  PRT.Info("/prt - Opens the window")
  PRT.Info("/prt versions - Will perform a version check on the current group")
  PRT.Info("/prt sync - Sends your plans to the group (also done on ready check)")
  PRT.Info("/prt news - Shows what's new")
  PRT.Info("/prt demo - Plays a sample fight with every kind of message for you")
  PRT.Info("/prt minimap - Will enable the minimap icon")
end

function addon:ExecuteChatCommand(input)
  if input == "" or input == nil or input == "ui" then
    addon:Open()
  elseif input == "news" then
    PRT.WhatsNew.Show()
  elseif input == "profile" or input == "profiles" then
    PRT.UI.Navigate("profiles")
  elseif input == "help" then
    addon:PrintHelp()
  elseif input == "version" or input == "versions" then
    addon:VersionCheck()
  elseif input == "sync" then
    if PRT.PlanSync.SendPlans(true) == 0 then
      PRT.Info("Nothing sent. Sync needs sender mode, a group and at least one enabled encounter.")
    end
  elseif input == "demo" then
    PRT.Demo.Toggle()
  elseif input == "minimap" then
    addon:ToggleMinimapIcon()
  else
    addon:PrintHelp()
  end
end

-------------------------------------------------------------------------------
-- Chat Commands

addon:RegisterChatCommand("prt", "ExecuteChatCommand")
addon:RegisterChatCommand("prtv", "VersionCheck")
