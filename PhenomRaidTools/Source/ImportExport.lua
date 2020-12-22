local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local ImportExport = {}


-------------------------------------------------------------------------------
-- Public API

PRT.CreateImportFrame = function(successFunction)
    if not PRT.Core.FrameExists("importFrame") then
        local importFrame = PRT.Frame("importFrame")
        importFrame:SetLayout("Fill")
        local childs = {importFrame.frame:GetChildren()}
        childs[1]:SetText("Import")
        
        local importDataBox = PRT.MultiLineEditBox()
        importDataBox:SetFocus()
        importDataBox:DisableButton(true)

        importFrame:AddChild(importDataBox)

        importFrame:SetCallback("OnClose", function(widget)
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

PRT.CreateExportFrame = function(t)
    if not PRT.Core.FrameExists("exportFrame") then
        local exportFrame = PRT.Frame("exportFrame")  
        exportFrame:SetLayout("Fill")
        exportFrame:SetCallback("OnClose", 
            function(widget)
                PRT.Core.UnregisterFrame("exportFrame")
            end)        

        local exportDataBox = PRT.MultiLineEditBox(nil, PRT.TableToString(t))
        exportDataBox:SetLabel("String")
        exportDataBox:SetFocus()
        exportDataBox:DisableButton(true)
        exportDataBox:HighlightText()

        exportFrame:AddChild(exportDataBox)        
        exportFrame:Show()
        PRT.Core.RegisterFrame("exportFrame", exportFrame)
    end
end