local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local UI = PRT.UI

-------------------------------------------------------------------------------
-- About page: who made the addon, version and links. The same page (content
-- and layout) exists in all addons by Phenom.

local DISCORD = "https://discord.gg/GAYDjBF"

local links = {
  {label = "Discord", url = DISCORD},
  {label = "CurseForge", url = "https://www.curseforge.com/projects/381654"},
  {label = "Wago", url = "https://addons.wago.io/addons/nQN57KBw"},
  {label = "GitHub", url = "https://github.com/PhenomDevel/PhenomRaidTools"},
  {label = L["Report a bug"], url = "https://github.com/PhenomDevel/PhenomRaidTools/issues"},
  {label = L["Support Phenom"], url = "https://streamlabs.com/phenombutbetter/tip"}
}

local otherAddons = {
  {name = "AskAzeroth", note = L["Ask questions in game, experienced players answer in threads."]},
  {name = "BlizzHUDTweaks", note = L["Fade and tweak the default Blizzard HUD, without replacing it."]},
  {name = "Guild Finder Forever", note = L["In-game marketplace for guilds and players looking for a guild."]},
  {name = "Quality of Life Forever", note = L["Many small quality-of-life improvements, each switchable on its own."]}
}

local function GetVersion()
  local version = C_AddOns.GetAddOnMetadata("PhenomRaidTools", "Version")
  if not version or version:find("@project", 1, true) then
    return L["Development version"]
  end
  return version
end

local function Cards()
  local linkRows = {}
  for _, link in ipairs(links) do
    linkRows[#linkRows + 1] = {
      type = "text",
      label = link.label,
      tooltip = L["Click the field, then press Ctrl+C to copy the link."],
      readOnly = true,
      width = 190,
      get = function()
        return link.url
      end
    }
  end

  local addonLines = {}
  for _, other in ipairs(otherAddons) do
    addonLines[#addonLines + 1] = ("{%s}: %s"):format(other.name, other.note)
  end

  return {
    {
      title = "PhenomRaidTools",
      note = L["Made by Phenom"],
      rows = {
        {
          type = "description",
          label = L["Plan per boss which player sees which message when; the raid lead syncs the plan before the pull."]
        },
        {
          type = "description",
          label = ("%s: {%s}\n%s: {Phenom}\n%s: {MIT} (%s)"):format(
            L["Version"],
            GetVersion(),
            L["Author"],
            L["License"],
            L["free and open source"]
          )
        },
        {type = "notice", label = L["Questions, ideas or problems? Join Phenom's Discord:"] .. " " .. DISCORD}
      }
    },
    {
      title = L["Links"],
      note = L["Click a field, then press Ctrl+C to copy the link."],
      rows = linkRows
    },
    {
      title = L["More addons by Phenom"],
      rows = {
        {type = "description", label = table.concat(addonLines, "\n")}
      }
    }
  }
end

UI.RegisterPage(
  {
    id = "about",
    label = L["About"],
    order = 90,
    build = function()
      return L["About"], L["%s by Phenom"]:format("PhenomRaidTools"), Cards()
    end
  }
)
