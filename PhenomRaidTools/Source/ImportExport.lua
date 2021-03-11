local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

-------------------------------------------------------------------------------
-- Public API

function PRT.CreateImportFrame(successFunction)
  if not PRT.Core.FrameExists("importFrame") then
    local importFrame = PRT.Frame(L["Import"])
    importFrame:SetLayout("Fill")
    local childs = {importFrame.frame:GetChildren()}
    childs[1]:SetText("Import")

    local importDataBox = PRT.MultiLineEditBox(L["Import String"])
    importDataBox:SetFocus()
    importDataBox:DisableButton(true)

    importFrame:AddChild(importDataBox)

    importFrame:SetCallback("OnClose",
      function()
        local text = importDataBox:GetText()
        local worked, t = PRT.StringToTable(text)

        if worked == true then
          successFunction(t)
        else
          if not (text == "") then
            PRT.Error("Import was not successfull.")
          end
        end

        PRT.Core.UnregisterFrame("importFrame")
      end)

    importFrame:Show()
    PRT.Core.RegisterFrame("importFrame", importFrame)
  end
end

function PRT.CreateExportFrame(t)
  if not PRT.Core.FrameExists("exportFrame") then
    local exportFrame = PRT.Frame(L["Export"])
    exportFrame:SetLayout("Fill")
    exportFrame:SetCallback("OnClose",
      function()
        PRT.Core.UnregisterFrame("exportFrame")
      end)

    local exportDataBox = PRT.MultiLineEditBox(L["Export String"], PRT.TableToString(t))
    exportDataBox:SetLabel("String")
    exportDataBox:SetFocus()
    exportDataBox:DisableButton(true)
    exportDataBox:HighlightText()

    exportFrame:AddChild(exportDataBox)
    exportFrame:Show()
    PRT.Core.RegisterFrame("exportFrame", exportFrame)
  end
end
