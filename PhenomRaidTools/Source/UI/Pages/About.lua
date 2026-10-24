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
          title = L["What's new"],
          rows = {
            {
              type = "button",
              label = L["Notes of this version"],
              buttonText = L["Open"],
              onClick = function()
                PRT.WhatsNew.Show()
              end
            }
          }
        },
        {
          title = L["Commands"],
          rows = {
            {type = "description", label = L["`/prt` opens this window."]},
            {type = "description", label = L["`/prt sync` sends your plans to the group (also on every ready check)."]},
            {type = "description", label = L["`/prt versions` checks the versions in your group."]},
            {type = "description", label = L["`/prt news` shows what's new."]},
            {type = "description", label = L["`/prt minimap` shows the minimap icon again."]},
            {type = "description", label = L["`/prtm text` shows a message to everyone in combat; during boss encounters only to you, the game blocks addon messages there."]}
          }
        }
      }
    end
  }
)
