local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Public API

PRT.AddEncountersWidgets = function(container, profile)
    local encounterOptionsGroup = PRT.InlineGroup("encounterHeading")

    local addButton = PRT.Button("NEW ENCOUNTER")
    addButton:SetHeight(40)
    addButton:SetRelativeWidth(1)
    addButton:SetCallback("OnClick", 
    function(widget) 
        local newEncounter = PRT.EmptyEncounter()
        tinsert(profile.encounters, newEncounter)
        PRT.mainFrameContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
        PRT.mainFrameContent:DoLayout()

        PRT.mainFrameContent:SelectByPath("encounters", newEncounter.id)
    end)

    local importButton = PRT.Button("IMPORT ENCOUNTER")
    importButton:SetHeight(40)
    importButton:SetRelativeWidth(1)
	importButton:SetCallback("OnClick", 
		function(widget) 
			PRT.CreateImportEncounterFrame(profile.encounters)
        end)
        
    encounterOptionsGroup:SetLayout("Flow")
    encounterOptionsGroup:AddChild(importButton)
    encounterOptionsGroup:AddChild(addButton)

    container:AddChild(encounterOptionsGroup)
end

PRT.AddEncounterOptions = function(container, profile, encounterID)
    local encounterIndex, encounter = PRT.FilterEncounterTable(profile.encounters, tonumber(encounterID))

    local encounterOptionsGroup = PRT.InlineGroup("encounterHeading")
    encounterOptionsGroup:SetLayout("Flow")

	local encounterIDEditBox = PRT.EditBox("encounterID", encounter.id, true)	
	encounterIDEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			encounter.id = tonumber(widget:GetText()) 
		end)		
        
    local encounterNameEditBox = PRT.EditBox("encounterName", encounter.name)	
    encounterNameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            encounter.name = widget:GetText()
            PRT.mainFrameContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
    
            PRT.mainFrameContent:SelectByValue(encounter.name)
        end)

    local exportButton = PRT.Button("EXPORT ENCOUNTER")
    exportButton:SetHeight(40)
    exportButton:SetRelativeWidth(1)
    exportButton:SetCallback("OnClick", 
        function(widget) 
            PRT.CreateExportEncounterFrame(encounter)
        end)

    local enabledCheckBox = PRT.CheckBox("encounterEnabled", encounter.enabled)
    enabledCheckBox:SetRelativeWidth(1)
    enabledCheckBox:SetCallback("OnValueChanged", 
        function(widget) 
            print(widget:GetValue())
            encounter.enabled = widget:GetValue()
        end)

    local deleteButton = PRT.NewTriggerDeleteButton(container, profile.encounters, encounterIndex, "DELETE ENCOUNTER")

    encounterOptionsGroup:AddChild(enabledCheckBox)
    encounterOptionsGroup:AddChild(encounterIDEditBox)
    encounterOptionsGroup:AddChild(encounterNameEditBox)
    container:AddChild(encounterOptionsGroup)  
    container:AddChild(exportButton)
    container:AddChild(deleteButton)
end