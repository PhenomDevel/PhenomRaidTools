local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
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
    if s ~= nil and s ~= "" then
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


-------------------------------------------------------------------------------
-- Public API

PRT.CreateImportEncounterFrame = function(encounters)
    local importFrame = PRT.Frame("importEncounter")
    importFrame:SetLayout("Fill")
    
    local importDataBox = PRT.MultiLineEditBox()
    importDataBox:SetFocus()
    importDataBox:DisableButton(true)

    importFrame:AddChild(importDataBox)

    importFrame:SetCallback("OnClose", function(widget)
        local text = importDataBox:GetText()
        local worked, encounter = ImportExport.StringToTable(text)     
         
        if worked == true then
            tinsert(encounters, encounter)
            PRT.mainWindow:ReleaseChildren()
            PRT.mainWindow:AddChild(PRT.Core.CreateMainWindowContent(PRT.db.profile))            
        else
            if not (text == "") then
                PRT.Error("Import was not successfull.")
            end
        end
    end)    

    importFrame:Show()
end

PRT.CreateExportEncounterFrame = function(encounter)
    local exportFrame = PRT.Frame("exportEncounter")  
    exportFrame:SetLayout("Fill")

    local exportDataBox = PRT.MultiLineEditBox(nil, ImportExport.TableToString(encounter))
    exportDataBox:SetLabel("String")
    exportDataBox:SetFocus()
    exportDataBox:DisableButton(true)
    exportDataBox:HighlightText()

    exportFrame:AddChild(exportDataBox)        
    exportFrame:Show()    
end