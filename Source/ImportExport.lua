local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

local ImportExport = {}


-------------------------------------------------------------------------------
-- Local Helper

ImportExport.TableToString = function(t)
    local serialized = AceSerializer:Serialize(t)
    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})

    return LibDeflate:EncodeForPrint(compressed)
end

ImportExport.StringToTable = function(s)
    local decoded = LibDeflate:DecodeForPrint(s)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local worked, t = AceSerializer:Deserialize(decompressed)

    return worked, t
end

-------------------------------------------------------------------------------
-- Public API

PRT.CreateImportEncounterFrame = function(encounters)
    local importFrame = AceGUI:Create("Frame")
    importFrame:SetTitle("Import Encounter")
    importFrame:SetLayout("Fill")
    
    local importDataBox = AceGUI:Create("MultiLineEditBox")
    importDataBox:SetLabel("Encounter String")
    importDataBox:SetFocus()
    importDataBox:DisableButton(true)

    importFrame:AddChild(importDataBox)

    importFrame:SetCallback("OnClose", function(widget)
        local text = importDataBox:GetText()
        local worked, encounter = ImportExport.StringToTable(text)     
         
        if worked == true then
            table.insert(encounters, encounter)
            PRT.mainFrame:ReleaseChildren()
            PRT.mainFrame:AddChild(PRT.Core.CreateMainFrameContent(PRT.mainFrame, PRT.db.profile))            
        else
            if not (text == "") then
                PRT.Error("Import was not successfull.")
            end
        end
    end)    

    importFrame:Show()
end

PRT.CreateExportEncounterFrame = function(encounter)
    local exportFrame = AceGUI:Create("Frame")
    exportFrame:SetTitle("Export Encounter")
    exportFrame:SetLayout("Fill")
    
    local exportDataBox = AceGUI:Create("MultiLineEditBox")
    exportDataBox:SetLabel("String")
    exportDataBox:SetText(ImportExport.TableToString(encounter))
    exportDataBox:SetFocus()
    exportDataBox:DisableButton(true)
    exportDataBox:HighlightText()
    exportFrame:AddChild(exportDataBox)    
    
    exportFrame:Show()    
end