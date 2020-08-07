local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Encounter = {
    currentEncounters = {
        -- Castle Nathria
       { id = 9999, name = L["--- Castle Nathria ---"], disabled = true},
       { id = 10001, name = L["CN - Shriekwing"] },
       { id = 10002, name = L["CN - Altimor the Huntsman"] },
       { id = 10003, name = L["CN - Hungering Destroyer"] },
       { id = 10004, name = L["CN - Artificer Xy'Mox"] },
       { id = 10005, name = L["CN - Sun King's Salvation"] },
       { id = 10006, name = L["CN - Lady Inerva Darkvein"] },
       { id = 10007, name = L["CN - The Council of Blood"] },
       { id = 10008, name = L["CN - Sludgefist"] },
       { id = 10009, name = L["CN - Stoneborne Generals"] },
       { id = 10010, name = L["CN - Sire Denathrius"] },

        -- De Other Side
       { id = 20000, name = L["--- De Other Side ---"], disabled = true},
       { id = 20001, name = L["DOS - Hakkar the Soulflayer"] },
       { id = 20002, name = L["DOS - The Manastorms"] },
       { id = 20003, name = L["DOS - Dealer Xy'exa"] },
       { id = 20004, name = L["DOS - Mueh'zala"] },

        -- Halls of Atonement
        { id = 30000, name = L["--- Halls of Atonement ---"], disabled = true},
        { id = 30001, name = L["HOA - Halkias, the Sin-Stained Goliath"] },
        { id = 30002, name = L["HOA - Echelon"] },
        { id = 30003, name = L["HOA - High Adjudicator Aleez"] },
        { id = 30004, name = L["HOA - Lord Chamberlain"] },

        -- Mists of Tirna Scithe
        { id = 40000, name = L["--- Mists of Tirna Scithe ---"], disabled = true},
        { id = 40001, name = L["MOTS - Ingra Maloch"] },
        { id = 40002, name = L["MOTS - Mistcaller"] },
        { id = 40003, name = L["MOTS - Tred'ova"] },

        -- Necrotic Wake
        { id = 50000, name = L["--- Necrotic Wake ---"], disabled = true},
        { id = 50001, name = L["NW - Blightbone"] },
        { id = 50002, name = L["NW - Amarth, The Reanimator"] },
        { id = 50003, name = L["NW - Surgeon Stitchflesh"] },
        { id = 50004, name = L["NW - Nalthor the Rimebinder"] },

        -- Plaguefall
        { id = 60000, name = L["--- Plaguefall ---"], disabled = true},
        { id = 60001, name = L["PF - Globgrog"] },
        { id = 60002, name = L["PF - Doctor Ickus"] },
        { id = 60003, name = L["PF - Domina Venomblade"] },
        { id = 60004, name = L["PF - Margrave Stradama"] },

        -- Sanguine Depths
        { id = 70000, name = L["--- Sanguine Depths ---"], disabled = true},
        { id = 70001, name = L["SD - Kryxis the Voracious"] },
        { id = 70002, name = L["SD - Executor Tarvold"] },
        { id = 70003, name = L["SD - Grand Proctor Beryllia"] },
        { id = 70004, name = L["SD - General Kaal"] },

        -- Spires of Ascension
        { id = 80000, name = L["--- Spires of Ascension ---"], disabled = true},
        { id = 80001, name = L["SOA - Kin-Tara"] },
        { id = 80002, name = L["SOA - Ventunax"] },
        { id = 80003, name = L["SOA - Oryphrion"] },
        { id = 80004, name = L["SOA - Devo, Paragon of Doubt"] },

        -- Theater of Pain
        { id = 90000, name = L["--- Theater of Pain ---"], disabled = true},
        { id = 90001, name = L["TOP - An Affront of Challengers"] },
        { id = 90002, name = L["TOP - Gorechop"] },
        { id = 90003, name = L["TOP - Xav the Unfallen"] },
        { id = 90004, name = L["TOP - Kul'tharok"] },
        { id = 90003, name = L["TOP - Mordretha, the Endless Empress"] },
    }
}

local addOverviewHeader = function(container, header, enabled)
    local coloredText = ""

    if not enabled then
        coloredText = PRT.ColoredString(header.." (disabled)", PRT.db.profile.colors.disabled)
    else
        coloredText = PRT.ColoredString(header, PRT.db.profile.colors.success)
    end

    local headerLabel = PRT.Label(coloredText, 16)
    headerLabel:SetRelativeWidth(1)

    container:AddChild(headerLabel)
end

local addOverviewLine = function(container, text)
    local textLabel = PRT.Label(text, 14)
    textLabel:SetRelativeWidth(1)
    
    container:AddChild(textLabel)
end

local addOverviewEmptyLine = function(container)
    local textLabel = PRT.Label(" ")
    textLabel:SetRelativeWidth(1)
    
    container:AddChild(textLabel)
end

local addStringByCondition = function(container, name, condition)
    local conditionString = name.." - "..PRT.HighlightString(condition.event).." of "

    if condition.spellName and condition.spellID then
        local _, _, texture = GetSpellInfo(condition.spellID)
        conditionString = conditionString..PRT.TextureString(texture, 14)..condition.spellName.." ( "..PRT.HighlightString(condition.spellID).." )"
    else
        conditionString = conditionString.."N/A"
    end

    addOverviewLine(container, conditionString)
end

local addTimerOverviewEntry = function(container, timer)
    addOverviewHeader(container, timer.name, timer.enabled)
    
    addStringByCondition(container, "Start timer on", timer.startCondition)

    if timer.hasStopCondition then
        addStringByCondition(container, "Stop timer on", timer.stopCondition)
    end
    addOverviewLine(container, "Timings - "..PRT.HighlightString(#timer.timings))
    addOverviewEmptyLine(container)
end

local addRotationOverviewEntry = function(container, rotation)
    addOverviewHeader(container, rotation.name, rotation.enabled)

    if rotation.hasStartCondition then
        addStringByCondition(container, "Start tracking on", rotation.startCondition)
    end

    if rotation.hasStopCondition then
        addStringByCondition(container, "Stop tracking on", rotation.stopCondition)
    end

    addStringByCondition(container, "Trigger on", rotation.triggerCondition)

    addOverviewLine(container, "Entries - "..PRT.HighlightString(#rotation.entries))
    addOverviewEmptyLine(container)
end

local addPercentageOverviewEntry = function(container, prefix, percentage)
    addOverviewHeader(container, percentage.name, percentage.enabled)

    if percentage.hasStartCondition then
        addStringByCondition(container, "Start tracking on", percentage.startCondition)
    end

    if percentage.hasStopCondition then
        addStringByCondition(container, "Stop tracking on", percentage.stopCondition)
    end

    for i, value in ipairs(percentage.values) do
        addOverviewLine(container, "Trigger on "..prefix.." "..value.operator.." "..value.value)
    end

    addOverviewEmptyLine(container)
end


-------------------------------------------------------------------------------
-- Local Helper

Encounter.OverviewWidget = function(encounter)
    local overviewGroup = PRT.InlineGroup("encounterOverview")
    local timerGroup = PRT.InlineGroup(PRT.TextureString(237538).." "..L["timerOverview"])
    local rotationsGroup = PRT.InlineGroup(PRT.TextureString(450907).." "..L["rotationOverview"])
    local healthPercentageGroup = PRT.InlineGroup(PRT.TextureString(648207).." "..L["healthPercentageOverview"])
    local powerPercentageGroup = PRT.InlineGroup(PRT.TextureString(132849).." "..L["powerPercentageOverview"])

    -- Timers
    if not table.empty(encounter.Timers) then        
        for i, v in ipairs(encounter.Timers) do
            addTimerOverviewEntry(timerGroup, v)
        end   
        
        overviewGroup:AddChild(timerGroup)     
    end

    -- Rotations
    if not table.empty(encounter.Rotations) then        
        for i, v in ipairs(encounter.Rotations) do
            addRotationOverviewEntry(rotationsGroup, v)
        end  
        
        overviewGroup:AddChild(rotationsGroup)
    end

    -- Health Percentages
    if not table.empty(encounter.HealthPercentages) then        
        for i, v in ipairs(encounter.HealthPercentages) do
            addPercentageOverviewEntry(healthPercentageGroup, "HP", v)
        end       
        
        overviewGroup:AddChild(healthPercentageGroup)
    end

    -- Power Percentages
    if not table.empty(encounter.PowerPercentages) then        
        for i, v in ipairs(encounter.PowerPercentages) do
            addPercentageOverviewEntry(powerPercentageGroup, "POWER", v)
        end        
        
        overviewGroup:AddChild(powerPercentageGroup)    
    end
            
    return overviewGroup
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddEncountersWidgets = function(container, profile)
    local encounterOptionsGroup = PRT.InlineGroup("encounterHeading")

    local addButton = PRT.Button("newEncounter")
    addButton:SetCallback("OnClick",
    function(widget)
        local newEncounter = PRT.EmptyEncounter()
        tinsert(profile.encounters, newEncounter)
        PRT.Core.UpdateTree()
        PRT.mainWindowContent:SelectByPath("encounters", newEncounter.id)
    end)

    local importButton = PRT.Button("importEncounter")
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
    local enabledCheckBox = PRT.CheckBox("encounterEnabled", encounter.enabled)
    local encounterIDEditBox = PRT.EditBox("encounterID", encounter.id)
    local encounterNameEditBox = PRT.EditBox("encounterName", encounter.name)
    local encounterSelectDropdown = PRT.Dropdown("encounterSelectDropdown", Encounter.currentEncounters, nil, nil, true)
    local exportButton = PRT.Button("exportEncounter")
    local deleteButton = PRT.NewTriggerDeleteButton(container, profile.encounters, encounterIndex, "deleteEncounter", encounter.name)
    local overviewGroup = Encounter.OverviewWidget(encounter)

    encounterOptionsGroup:SetLayout("Flow")

    encounterIDEditBox:SetRelativeWidth(0.5)
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
                PRT.Error("The encounter id you entered was already taken by ", PRT.HighlightString(existingEncounter.name))
            end
        end)
    encounterNameEditBox:SetRelativeWidth(0.5)
    encounterNameEditBox:SetCallback("OnEnterPressed",
        function(widget)
            encounter.name = widget:GetText()
            PRT.Core.UpdateTree()
            PRT.mainWindowContent:DoLayout()
            PRT.Core.ReselectExchangeLast(encounter.id)
        end)

    encounterSelectDropdown:SetRelativeWidth(0.5)
	encounterSelectDropdown:SetCallback("OnValueChanged",
        function(widget, event, id)
            local idx, entry = PRT.FilterTableByID(Encounter.currentEncounters, id)
            -- TODO: Refactor and put together with above id function
            local _, existingEncounter = PRT.FilterEncounterTable(profile.encounters, id)

            if not existingEncounter then
                if id ~= "" and id ~= nil then
                    encounter.id = id
                    encounter.name = entry.name
                    PRT.Core.UpdateTree()
                    PRT.Core.ReselectExchangeLast(id)
                else
                    PRT.Error("Encounter id can not be empty")
                    if encounter.id then
                        encounterIDEditBox:SetText(encounter.id)
                        encounterNameEditBox:SetText(encounter.name)
                    end
                end
            else
                if encounter.id then
                    encounterIDEditBox:SetText(encounter.id)
                    encounterNameEditBox:SetText(encounter.name)
                end
                PRT.Error("The encounter id you entered was already taken by ", existingEncounter.name)
            end

            widget:SetValue(nil)
        end)

    exportButton:SetCallback("OnClick",
        function(widget)
            PRT.CreateExportEncounterFrame(encounter)
        end)

    enabledCheckBox:SetRelativeWidth(1)
    enabledCheckBox:SetCallback("OnValueChanged",
        function(widget)
            encounter.enabled = widget:GetValue()
            PRT.Core.UpdateTree()
        end)

        exportButton:SetRelativeWidth(0.25)
        deleteButton:SetRelativeWidth(0.25)

    encounterOptionsGroup:AddChild(enabledCheckBox)
    encounterOptionsGroup:AddChild(encounterIDEditBox)
    encounterOptionsGroup:AddChild(encounterNameEditBox)
    encounterOptionsGroup:AddChild(encounterSelectDropdown)
    encounterOptionsGroup:AddChild(exportButton)
    encounterOptionsGroup:AddChild(deleteButton)

    container:AddChild(encounterOptionsGroup)
    container:AddChild(overviewGroup)    
end
