local importButton = PRT.Button("encounterImport")
importButton:SetCallback("OnClick", 
function(widget) 
    PRT.Debug("Import") 
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Import Encounter")
    frame:SetLayout("Fill")
    
    local importBox = AceGUI:Create("MultiLineEditBox")
    importBox:SetLabel("String")

    frame:AddChild(importBox)

    frame:SetCallback("OnClose", function(widget)
        local worked, t = AceSerializer:Deserialize(importBox:GetText())
        PRT.PrintTable("", t)
    end)

    frame:Show()
end)

local exportButton = PRT.Button("encounterExport")
exportButton:SetCallback("OnClick", 
function() 
    PRT.Debug("Export") 
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Import Encounter")
    frame:SetLayout("Fill")
    
    local importBox = AceGUI:Create("MultiLineEditBox")
    importBox:SetLabel("String")
    importBox:SetText(AceSerializer:Serialize(encounter))

    frame:AddChild(importBox)
    frame:Show()
end)