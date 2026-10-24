local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI

local function Version()
  local version = C_AddOns.GetAddOnMetadata("PhenomRaidTools", "Version") or ""
  if version:find("@project", 1, true) then
    return L["Development version"]
  end
  return version
end

UI.RegisterPage(
  {
    id = "about",
    label = L["About"],
    order = 900,
    build = function()
      local _, _, _, interface = GetBuildInfo()
      return L["About"], ("%s %s · %s %d"):format(L["Version"], Version(), L["Interface"], interface), {
        {
          title = L["New window"],
          note = L["PRT is moving to this window page by page. Until a page exists here, use the previous window."],
          rows = {
            {
              type = "button",
              label = L["Previous window"],
              note = L["Opens with `/prt`."],
              buttonText = L["Open"],
              onClick = function()
                LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools"):Open()
              end
            }
          }
        },
        {
          title = L["Commands"],
          rows = {
            {type = "description", label = L["`/prt ui` opens this window."]},
            {type = "description", label = L["`/prt` opens the previous window."]},
            {type = "description", label = L["`/prt versions` checks the versions in your group."]}
          }
        }
      }
    end
  }
)
