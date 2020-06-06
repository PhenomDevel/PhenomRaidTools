local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local ImportExport = {}


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
        local worked, encounter = PRT.StringToTable(text)     
         
        if worked == true then
            local idx, existingEncounter = PRT.FilterEncounterTable(encounters, encounter.id)
            if not existingEncounter then
                tinsert(encounters, encounter)
                PRT.mainWindow:ReleaseChildren()
                PRT.mainWindow:AddChild(PRT.Core.CreateMainWindowContent(PRT.db.profile))            
            else
                PRT.Error("Stopped import due to already existing encounter with the same id:", existingEncounter.name)
            end
        else
            if not (text == "") then
                PRT.Error("Import was not successfull.")
            end
        end
    end)    

    importFrame:Show()
    PRT.Core.RegisterFrame(importFrame)
end

PRT.CreateExportEncounterFrame = function(encounter)
    local exportFrame = PRT.Frame("exportEncounter")  
    exportFrame:SetLayout("Fill")

    local exportDataBox = PRT.MultiLineEditBox(nil, PRT.TableToString(encounter))
    exportDataBox:SetLabel("String")
    exportDataBox:SetFocus()
    exportDataBox:DisableButton(true)
    exportDataBox:HighlightText()

    exportFrame:AddChild(exportDataBox)        
    exportFrame:Show()
    PRT.Core.RegisterFrame(exportFrame)
end