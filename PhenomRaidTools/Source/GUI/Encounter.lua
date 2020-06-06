local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Encounter = {}

local stringByCondition = function(name, condition)
    local s = name.."|n"

    if condition.event then
        s = s.."    Event: "..PRT.ColoredString(condition.event, PRT.db.profile.colors.highlight).."|n"
    end

    if condition.spellName and condition.spellID then
        local _, _, texture = GetSpellInfo(condition.spellID)
        s = s.."    Spell: "..PRT.TextureString(texture)..condition.spellName.." ( "..PRT.ColoredString(condition.spellID, PRT.db.profile.colors.highlight).." )|n"  
    end

    return s
end

local stringByPercentage = function(name, percentage)
    local s = name.."|n"

    if percentage.unitID then
        s = s.."    UnitID: "..PRT.ColoredString(percentage.unitID, PRT.db.profile.colors.highlight).."|n"
    end

    return s
end

-------------------------------------------------------------------------------
-- Local Helper

Encounter.OverviewWidget = function(encounter)
    local overviewGroup = PRT.InlineGroup("encounterOverview")

    -- Timers
    if not table.empty(encounter.Timers) then
        local group = PRT.InlineGroup(PRT.TextureString(237538).." "..L["timerOverview"])
        for i, v in ipairs(encounter.Timers) do
            local s = stringByCondition(i..". "..v.name, v.startCondition)
           
            local label = PRT.Label(s)
            label:SetRelativeWidth(1)
            group:AddChild(label)
        end
        overviewGroup:AddChild(group)
    end

    -- Rotations
    if not table.empty(encounter.Rotations) then
        local group = PRT.InlineGroup(PRT.TextureString(450907).." "..L["rotationOverview"])
        
        for i, v in ipairs(encounter.Rotations) do
            local s = stringByCondition(i..". "..v.name, v.triggerCondition)
           
            local label = PRT.Label(s)
            label:SetRelativeWidth(1)
            group:AddChild(label)
        end
        overviewGroup:AddChild(group)
    end

    -- Health Percentages
    if not table.empty(encounter.HealthPercentages) then
        local group = PRT.InlineGroup(PRT.TextureString(648207).." "..L["healthPercentageOverview"])
        for i, v in ipairs(encounter.HealthPercentages) do
            local s = stringByPercentage(i..". "..v.name, v)

            local label = PRT.Label(s)
            label:SetRelativeWidth(1)
            group:AddChild(label)
        end
        overviewGroup:AddChild(group)
    end

    -- Power Percentages
    if not table.empty(encounter.PowerPercentages) then
        local group = PRT.InlineGroup(PRT.TextureString(132849).." "..L["powerPercentageOverview"])
        for i, v in ipairs(encounter.PowerPercentages) do
            local s = stringByPercentage(i..". "..v.name, v)
            
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
        PRT.Core.UpdateTree()
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
                    PRT.Core.UpdateTree()
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
            PRT.Core.UpdateTree()
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
            PRT.Core.UpdateTree() 
        end)

    local deleteButton = PRT.NewTriggerDeleteButton(container, profile.encounters, encounterIndex, "deleteEncounter", encounter.name)

    encounterOptionsGroup:AddChild(enabledCheckBox)
    encounterOptionsGroup:AddChild(encounterIDEditBox)
    encounterOptionsGroup:AddChild(encounterNameEditBox)

    local overviewGroup = Encounter.OverviewWidget(encounter)

    container:AddChild(encounterOptionsGroup)  
    container:AddChild(overviewGroup)
    container:AddChild(exportButton)
    container:AddChild(deleteButton)
end