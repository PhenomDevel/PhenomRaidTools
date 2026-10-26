local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = PRT.UI

--[[
  First start guide in three steps: role, overlays, plans. Opens instead of
  the last page until it is finished once (global.onboarded); the settings
  page opens it again.
]]

local ROLES = {
  {value = "lead", label = L["I lead the raid"]},
  {value = "player", label = L["I play in a raid"]},
  {value = "both", label = L["Both"]}
}

local function Finish()
  PRT.GetGlobalDB().onboarded = true
  PRT.ReceiverOverlay.SetLocked(true)
  UI.Navigate("overview")
end

local function Cards()
  local lead = PRT.GetProfileDB().senderMode
  local planRows
  if lead then
    planRows = {
      {type = "description", label = L["Build a plan per boss: click into its timeline where an assignment belongs. On every ready check PRT sends the enabled plans to the group."]},
      {
        type = "nav",
        label = L["Create your first encounter"],
        onClick = function()
          UI.Navigate("encounters")
        end
      }
    }
  else
    planRows = {
      {type = "description", label = L["Nothing to prepare: your raid lead's plans arrive on the ready check and run on the pull. The overview shows which plans you have."]}
    }
  end
  return {
    {
      title = L["1 · Your role"],
      rows = {
        {type = "chips", values = ROLES, get = UI.GetRole, set = UI.SetRole},
        {type = "hint", label = L["Can be changed any time on the overview."]}
      }
    },
    {
      title = L["2 · Overlays"],
      note = L["Messages for you show on the overlays. Drag them where you want them."],
      rows = {
        {
          type = "button",
          label = L["Show sample messages"],
          buttonText = L["Test"],
          onClick = function()
            PRT.ReceiverOverlay.SetLocked(false)
            PRT.ReceiverOverlay.Test()
          end
        },
        {
          type = "nav",
          label = L["Style, size and sound"],
          onClick = function()
            UI.Navigate("overlays")
          end
        }
      }
    },
    {title = L["3 · Plans"], rows = planRows},
    {
      title = L["Ready"],
      rows = {
        {
          type = "button",
          label = L["Finish the guide"],
          note = L["Locks the overlays and opens the overview."],
          buttonText = L["Done"],
          onClick = Finish
        }
      }
    }
  }
end

UI.RegisterPage(
  {
    id = "welcome",
    label = L["Welcome"],
    order = 1000,
    hidden = true,
    build = function()
      return L["Welcome to PhenomRaidTools"], L["Three steps, then you are ready."], Cards()
    end
  }
)
