local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Encounter = {}

-------------------------------------------------------------------------------
-- Local Helper

Encounter.OverviewWidget = function(encounter)
    local overviewGroup = PRT.InlineGroup("encounterOverview")

    -- Timers
    if not table.empty(encounter.Timers) then
        local group = PRT.InlineGroup("timerOverview")
        for i, v in ipairs(encounter.Timers) do
            local s = "- "..v.name.."\n"
            local s = "- "..v.name.."\n"
            if v.startCondition.event then
                s = s.."  - Event: "..v.startCondition.event.."\n"
            end

            if v.startCondition.spellName and v.startCondition.spellID then
                s = s.."  - Spell: "..v.startCondition.spellID.." / "..v.startCondition.spellName.."\n"  
            end
           
            local label = PRT.Label(s)
            label:SetRelativeWidth(1)
            group:AddChild(label)
        end
        overviewGroup:AddChild(group)
    end

    -- Rotations
    if not table.empty(encounter.Rotations) then
        local group = PRT.InlineGroup("rotationOverview")
        
        for i, v in ipairs(encounter.Rotations) do
            local s = "- "..v.name.."\n"
            if v.triggerCondition.event then
                s = s.."  - Event: "..v.triggerCondition.event.."\n"
            end

            if v.triggerCondition.spellName and v.triggerCondition.spellID then
                s = s.."  - Spell: "..v.triggerCondition.spellID.." / "..v.triggerCondition.spellName.."\n"  
            end
           
            local label = PRT.Label(s)
            label:SetRelativeWidth(1)
            group:AddChild(label)
        end
        overviewGroup:AddChild(group)
    end

    -- Health Percentages
    if not table.empty(encounter.HealthPercentages) then
        local group = PRT.InlineGroup("healthPercentageOverview")
        for i, v in ipairs(encounter.HealthPercentages) do
            local s = "- "..v.name.."\n"
            s = s.."  - UnitID: "..v.unitID.."\n"

            local label = PRT.Label(s)
            label:SetRelativeWidth(1)
            group:AddChild(label)
        end
        overviewGroup:AddChild(group)
    end

    -- Power Percentages
    if not table.empty(encounter.PowerPercentages) then
        local group = PRT.InlineGroup("powerPercentageOverview")
        for i, v in ipairs(encounter.PowerPercentages) do
            local s = "- "..v.name.."\n"
            s = s.."  - UnitID: "..v.unitID.."\n"
            
            local label = PRT.Label(s)
            label:SetRelativeWidth(1)
            group:AddChild(label)
        end
        overviewGroup:AddChild(group)
    end
    
    return overviewGroup
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddEncountersWidgets = function(container, profile)
    local encounterOptionsGroup = PRT.InlineGroup("encounterHeading")

    local addButton = PRT.Button("newEncounter")
    addButton:SetHeight(40)
    addButton:SetRelativeWidth(1)
    addButton:SetCallback("OnClick", 
    function(widget) 
        local newEncounter = PRT.EmptyEncounter()
        tinsert(profile.encounters, newEncounter)
        PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
        PRT.mainWindowContent:SelectByPath("encounters", newEncounter.id)
    end)

    local importButton = PRT.Button("importEncounter")
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
	encounterIDEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            local id = tonumber(widget:GetText()) 
            local _, existingEncounter = PRT.FilterEncounterTable(profile.encounters, id)

            if not existingEncounter then
                if id ~= "" and id ~= nil then
                    encounter.id = id     
                    PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
                    PRT.Core.ReselectExchangeLast(id)
                else
                    PRT.Error("Encounter id can not be empty")
                    if encounter.id then
                        widget:SetText(encounter.id)
                    end
                end
            else
                if encounter.id then
                    widget:SetText(encounter.id)
                end
                PRT.Error("The encounter id you entered was already taken by ", existingEncounter.name)
            end            
		end)		
        
    local encounterNameEditBox = PRT.EditBox("encounterName", encounter.name)	
    encounterNameEditBox:SetCallback("OnEnterPressed", 
        function(widget) 
            encounter.name = widget:GetText()
            PRT.mainWindowContent:SetTree(PRT.Core.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainWindowContent:DoLayout()    
            PRT.Core.ReselectExchangeLast(encounter.id)
        end)

    local exportButton = PRT.Button("exportEncounter")
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
            encounter.enabled = widget:GetValue()
        end)

    local deleteButton = PRT.NewTriggerDeleteButton(container, profile.encounters, encounterIndex, "deleteEncounter")

    encounterOptionsGroup:AddChild(enabledCheckBox)
    encounterOptionsGroup:AddChild(encounterIDEditBox)
    encounterOptionsGroup:AddChild(encounterNameEditBox)

    local overviewGroup = Encounter.OverviewWidget(encounter)

    container:AddChild(encounterOptionsGroup)  
    container:AddChild(overviewGroup)
    container:AddChild(exportButton)
    container:AddChild(deleteButton)
end