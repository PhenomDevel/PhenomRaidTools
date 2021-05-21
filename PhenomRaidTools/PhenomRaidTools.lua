local PRT = LibStub("AceAddon-3.0"):NewAddon("PhenomRaidTools", "AceConsole-3.0", "AceEvent-3.0");

local AceComm = LibStub("AceComm-3.0")
local AceTimer = LibStub("AceTimer-3.0")

local LibDBIcon = LibStub("LibDBIcon-1.0")
local PhenomRaidToolsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("PhenomRaidTools", {
  type = "data source",
  text = "PhenomRaidTools",
  icon = "Interface\\AddOns\\PhenomRaidTools\\Media\\Icons\\PRT.blp",
  OnClick = function(self, button)
    if button == "LeftButton" then
      PRT:Open()
    elseif button == "MiddleButton" then
      LibDBIcon:Hide("PhenomRaidTools")
      PRT.db.profile.minimap.hide = true
      PRT.Info("Minimap icon is now hidden. If you want to show it again use /prt minimap")
    end
  end,

  OnEnter = function()
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    GameTooltip:AddDoubleLine("|cFF69CCF0PhenomRaidTools|r", "v"..PRT.db.profile.version)
    GameTooltip:AddDoubleLine("|cFFdcabffProfile|r ",PRT.db:GetCurrentProfile())
    GameTooltip:AddDoubleLine("|cFFdcabffLeft-Click|r", "Open Config")
    GameTooltip:AddDoubleLine("|cFFdcabffMiddle-Click|r", "Hide minimap icon")
    GameTooltip:Show()
  end,

  OnLeave = function()
    GameTooltip:Hide()
  end})


-------------------------------------------------------------------------------
-- Ace standard functions

local function NewDefaultReceiverOverlay(id, name, fontSize, r, g, b)
  return {
    id = id,
    label = name,
    name = id,
    anchor = "CENTER",
    locked = true,
    top = 540 - ((id - 1) * 60),
    left = 960,
    fontSize = fontSize,
    fontColor = {
      hex = format("%02x%02x%02x%02x", 255, (r * 255), (g * 255), (b * 255)),
      r = r,
      g = g,
      b = b,
      a = 1
    },
    enableSound = true,
    defaultSoundFile = "Interface\\AddOns\\PhenomRaidTools\\Media\\Sounds\\ReceiveMessage.ogg",
    defaultSoundFileName = "ReceiveMessage"
  }
end

local defaults =  {
  char = {
    profileSettings = {
      specSpecificProfiles = {
        enabled = false,
        profileBySpec = {}
      }
    }
  },
  global = {
    spellCache = {
      enabled = false,
      completed = false,
      lastCheckedId = 0,
      spells = {}
    }
  },
  profile = {
    mainWindow = {
      width = nil,
      height = nil,
      top = nil,
      left = nil
    },
    mainWindowContent = {
      treeGroup = {
        width = nil
      }
    },
    myName = UnitName("player"),
    version = "@project-version@",
    messageFilter = {
      filterBy = "names",
      requiredGuildRank = nil,
      requiredNames = {},
      alwaysIncludeMyself = true
    },
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

    clipboard = {
      timer = nil,
      rotation = nil,
      percentage = nil,
      message = nil
    },
    customPlaceholders = {},
    overlay = {
      receivers = {
        [1] = NewDefaultReceiverOverlay(1, "Default", 16, 1, 1, 1),
        [2] = NewDefaultReceiverOverlay(2, "Important", 84, 1, 0, 0),
        [3] = NewDefaultReceiverOverlay(3, "Personals/Unimportant", 64, 0, 1, 0),
        [4] = NewDefaultReceiverOverlay(4, "Healing/Special", 36, 0, 0, 1)
      },

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
          r = 0,
          g = 0,
          b = 0,
          a = 1
        },
        enabled = true,
        hideAfterCombat = false,
        hideDisabledTriggers = false,
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
      rotationDefaults = {
        defaultShouldRestart = true,
        defaultIgnoreAfterActivation = false,
        defaultIgnoreDuration = 10
      },
      percentageDefaults = {
        defaultUnitID = "boss1",
        defaultCheckAgain = false,
        defaultCheckAgainAfter = 5,
      },
      conditionDefaults = {
        defaultEvent = "SPELL_CAST_START"
      },
      messageDefaults = {
        defaultMessage = "TODO",
        defaultDuration = 5,
        defaultTargets = {
          "$me"
        }
      }
    },

    encounters = {},
    currentEncounter = {
      inFight = false
    },

    colors = {

    },
    raidRoster = {},
    addonPrefixes = {
      addonMessage = "PRT_ADDON_MSG",
      versionRequest = "PRT_VERSION_REQ",
      versionResponse = "PRT_VERSION_RESP"
    },
    versionCheck = {},
    templateStore = {
      messages = {}
    },
    debugLog = {},
    processedMigrations = {

    }
  }
}

local options = {
  name = "PhenomRaidTools",
  type = "group",
  args = {

  },
}

function PRT:OnInitialize()
  -- Register DB
  self.db = LibStub("AceDB-3.0"):New("PhenomRaidToolsDB", defaults, true)
  options = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  -- Register Options
  LibStub("AceConfig-3.0"):RegisterOptionsTable("PhenomRaidTools", options)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PhenomRaidTools", "PhenomRaidTools")

  -- Initialize Minimap Icon
  LibDBIcon:Register("PhenomRaidTools", PhenomRaidToolsLDB, self.db.profile.minimap)

  local encounterIdx, _ = PRT.TableUtils.GetBy(self.db.profile.encounters, "id", 9999)

  if not encounterIdx and PRT.TableUtils.IsEmpty(self.db.profile.encounters) then
    table.insert(self.db.profile.encounters, PRT.ExampleEncounter())
  end

  -- Reset versions
  PRT.db.profile.versionCheck = {}

  -- Reset clipboard
  PRT.db.profile.clipboard = {}

  -- We hold the main frame within the global addon variable
  -- because we sometimes have to do a re-layout of the complete content
  PRT.mainWindow = nil
  PRT.mainWindowContent = nil

  PRT.SenderOverlay.Initialize(PRT.db.profile.overlay.sender)
  PRT.ReceiverOverlay.Initialize(PRT.db.profile.overlay.receivers)
  PRT.SenderOverlay.Hide()
  PRT.ReceiverOverlay.HideAll()

  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

  -- Check if profile db needs migration
  AceTimer:ScheduleTimer(PRT.MigrateProfileDB, 1, self.db.profile)

  -- Start spell cache building if needed
  PRT.SpellCache.Build(self.db.global.spellCache)

  -- Initially load global placeholders
  PRT.SetupGlobalCustomPlaceholders()
end

function PRT:RefreshConfig()
  PRT.Info("Active Profile was changed to", PRT.HighlightString(PRT.db:GetCurrentProfile()))

  PRT.ReceiverOverlay.ReInitialize(PRT.db.profile.overlay.receivers)
  PRT.SenderOverlay.ReInitialize(PRT.db.profile.overlay.sender)

  local encounterIdx, _ = PRT.TableUtils.GetBy(self.db.profile.encounters, "id", 9999)
  if not encounterIdx and PRT.TableUtils.IsEmpty(self.db.profile.encounters) then
    table.insert(self.db.profile.encounters, PRT.ExampleEncounter())
  end

  -- Check if profile db needs migration
  AceTimer:ScheduleTimer(PRT.MigrateProfileDB, 0.5, self.db.profile)
end

function PRT:OnEnable()
  PRT.RegisterWorldEvents()

  AceComm:RegisterComm(self.db.profile.addonPrefixes.addonMessage, self.OnAddonMessage)
  AceComm:RegisterComm(self.db.profile.addonPrefixes.versionRequest, self.OnVersionRequest)
  AceComm:RegisterComm(self.db.profile.addonPrefixes.versionResponse, self.OnVersionResponse)
end

function PRT:OnDisable()
  PRT.UnregisterWorldEvents()
end

function PRT:Open()
  if UnitAffectingCombat("player") then
    PRT.Info("Can't open during combat")
  else
    if (PRT.mainWindow and not PRT.mainWindow:IsShown()) or not PRT.mainWindow then
      PRT.CreateMainWindow(self.db.profile)
    end
  end
end

function PRT:PrintPartyOrRaidVersions()
  local myVersion = string.gsub(PRT.db.profile.version, "[^%d]+", "")
  local myVersionN = tonumber(myVersion)

  for _, response in pairs(PRT.db.profile.versionCheck) do
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

function PRT:VersionCheck(_)
  local request = {
    type = "request",
    requestor = strjoin("-", UnitFullName("player"))
  }

  if PRT.PlayerInParty() then
    PRT.Info("Initialize version check")
    PRT.Info("Waiting for everyone to respond...")

    self.db.profile.versionCheck = {}

    for _, name in ipairs(PRT.PartyNames()) do
      self.db.profile.versionCheck[name] = ""
    end

    AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.versionRequest, PRT.Serialize(request), "RAID")
    AceTimer:ScheduleTimer(PRT.PrintPartyOrRaidVersions, 5)
  else
    PRT.Info("You are currently running version", PRT.ColoredString(self.db.profile.version, PRT.Static.Colors.Highlight))
  end
end

function PRT:ToggleMinimapIcon()
  LibDBIcon:Show("PhenomRaidTools")
  PRT.db.profile.minimap.hide = false
end

function PRT:PrintHelp()
  PRT.Info("You can use following commands:")
  PRT.Info("/prt - Opens the config")
  PRT.Info("/prt versions - Will perform a version check on the current group")
  PRT.Info("/prt profile - Opens the profile page for PRT")
  PRT.Info("/prt minimap - Will enable the minimap icon")
  PRT.Info("/prtm $message - Will let you send a message to *ALL* players on the fly")
end

function PRT:ExecuteChatCommand(input)
  if input == "" or input == nil then
    PRT:Open()
  elseif input == "help" then
    PRT.PrintHelp()
  elseif input == "version" or input == "versions" then
    PRT:VersionCheck()
  elseif input == "minimap" then
    PRT:ToggleMinimapIcon()
  else
    PRT.PrintHelp()
  end
end

function PRT:InvokeMessage(msg)
  if PRT.db.profile.senderMode and PRT.db.profile.enabled and (PRT.IsTestMode() or true) then
    if PRT.currentEncounter then
      if PRT.currentEncounter.inFight then
        PRT.Debug("Sending new message invoked by chat command")
        local message = {
          targets = {"ALL"},
          message = msg,
          withSound = true,
        }
        PRT.ExecuteMessage(message)
        return
      end
    end
  end
  PRT.Info("Message by chat command was not send. Either you are not in combat or not in sender mode.")
end

-------------------------------------------------------------------------------
-- Chat Commands

PRT:RegisterChatCommand("prt", "ExecuteChatCommand")
PRT:RegisterChatCommand("prtv", "VersionCheck")
PRT:RegisterChatCommand("prtm", "InvokeMessage")
