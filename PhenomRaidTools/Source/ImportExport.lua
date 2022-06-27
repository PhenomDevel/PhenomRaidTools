local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

-------------------------------------------------------------------------------
-- Public API

function PRT.Serialize(t)
  local serialized = AceSerializer:Serialize(t)
  local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})

  return LibDeflate:EncodeForPrint(compressed)
end

function PRT.Deserialize(s)
  if s and s ~= "" then
    local decoded = LibDeflate:DecodeForPrint(s)
    if decoded then
      local decompressed = LibDeflate:DecompressDeflate(decoded)

      if decompressed then
        local worked, t = AceSerializer:Deserialize(decompressed)

        return worked, t
      else
        PRT.Error("String could not be decompressed. Aborting import.")
      end
    else
      PRT.Error("String could not be decoded. Aborting import.")
    end
  end

  return nil
end

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

    importFrame:SetCallback(
      "OnClose",
      function()
        local text = importDataBox:GetText()
        local worked, t = PRT.Deserialize(text)

        if worked == true then
          successFunction(t)
        else
          if text ~= "" then
            PRT.Error("Import was not successfull.")
          end
        end

        PRT.Core.UnregisterFrame("importFrame")
      end
    )

    importFrame:Show()
    PRT.Core.RegisterFrame("importFrame", importFrame)
  end
end

function PRT.CreateExportFrame(data)
  if not PRT.Core.FrameExists("exportFrame") then
    local exportFrame = PRT.Frame(L["Export"])
    exportFrame:SetLayout("Fill")
    exportFrame:SetCallback(
      "OnClose",
      function()
        PRT.Core.UnregisterFrame("exportFrame")
      end
    )

    local exportData = data
    if type(data) == "table" then
      exportData = PRT.Serialize(data)
    end

    local exportDataBox = PRT.MultiLineEditBox(L["Export String"], exportData)
    exportDataBox:SetLabel("String")
    exportDataBox:SetFocus()
    exportDataBox:DisableButton(true)
    exportDataBox:HighlightText()

    exportFrame:AddChild(exportDataBox)
    exportFrame:Show()
    PRT.Core.RegisterFrame("exportFrame", exportFrame)
  end
end
