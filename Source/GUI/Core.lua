local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Tree = {}
PRT.Tree = Tree

-------------------------------------------------------------------------------
-- Local Helper

local RegisterESCHandler = function(name, container)
	_G[name] = container.frame
    -- Register the global variable `MyGlobalFrameName` as a "special frame"
    -- so that it is closed when the escape key is pressed.
    tinsert(UISpecialFrames, name)
end

local FilterEncounterTable = function(encounters, id)
    local value
    if encounters then
        for i, v in ipairs(encounters) do
            if v.id == id then
                if not value then
                    return i, v
                end
            end
        end
    end
end

local FilterTableByName = function(t, name)
    local value
    if t then
        for i, v in ipairs(t) do
            if v.name == name then
                if not value then                    
                    return i, v
                end
            end
        end
    end
end

Tree.GeneratePercentageTree = function(percentage)
    local t = {
        value = percentage.name,
        text = percentage.name
    }
    
    return t
end

Tree.GeneratePercentagesTree = function(percentages)
    local children = {}
    local t = {
        value = "percentages",
        text = "Percentages",
    }

    if table.getn(percentages) > 0 then
        t.children = children
        for i, percentage in ipairs(percentages) do
            table.insert(children, Tree.GeneratePercentageTree(percentage))
        end
    end
    
    return t
end

Tree.GeneratePowerPercentagesTree = function(percentages)
    local tree = Tree.GeneratePercentagesTree(percentages)
    tree.value = "powerPercentages"
    tree.text = "Power Percentages"

    return tree
end

Tree.GenerateHealthPercentagesTree = function(percentages)
    local tree = Tree.GeneratePercentagesTree(percentages)
    tree.value = "healthPercentages"
    tree.text = "Health Percentages"

    return tree
end

Tree.GenerateRotationTree = function(rotation)
    local t = {
        value = rotation.name,
        text = rotation.name
    }
    
    return t
end

Tree.GenerateRotationsTree = function(rotations)
    local children = {}
    local t = {
        value = "rotations",
        text = "Rotations",
    }

    if table.getn(rotations) > 0 then
        t.children = children
        for i, rotation in ipairs(rotations) do
            table.insert(children, Tree.GenerateRotationTree(rotation))
        end
    end
    
    return t
end

Tree.GenerateTimerTree = function(timer)
    local t = {
        value = timer.name,
        text = timer.name
    }
    
    return t
end

Tree.GenerateTimersTree = function(timers)
    local children = {}
    local t = {
        value = "timers",
        text = "Timers",
    }

    if table.getn(timers) > 0 then
        t.children = children
        for i, timer in ipairs(timers) do
            table.insert(children, Tree.GenerateTimerTree(timer))
        end
    end
    
    
    return t
end

Tree.GenerateEncounterTree = function(encounter)
    local children = {}
    local t = {
        value = encounter.id,
        text = encounter.name,
        children = {
            Tree.GenerateTimersTree(encounter.Timers),
            Tree.GenerateRotationsTree(encounter.Rotations),
            Tree.GenerateHealthPercentagesTree(encounter.HealthPercentages),
            Tree.GeneratePowerPercentagesTree(encounter.PowerPercentages)
        }
    }

    return t
end

Tree.GenerateEncountersTree = function(encounters)
    local children = {}

    local t = {
        value  = "encounters",
        text = "Encounters",
        children = children
    }    

    for i, encounter in ipairs(encounters) do
        table.insert(children, Tree.GenerateEncounterTree(encounter))
    end

    return t
end

Tree.GenerateOptionsTree = function()
    local t = {
        value = "options",
        text = "Options"
    }
    return t
end

Tree.GenerateTreeByProfile = function(profile)
    local t = {
        Tree.GenerateOptionsTree(),
        Tree.GenerateEncountersTree(profile.encounters)
    }

    return t
end

Tree.NewTriggerDeleteButton = function(container, t, idx)
    local deleteButtonText = PRT.Strings.GetText("Delete")
    local deleteButton = AceGUI:Create("Button")
    deleteButton:SetText(deleteButtonText)
    deleteButton:SetCallback("OnClick", 
        function() 
            table.remove(t, idx) 
            PRT.mainFrameContent:SetTree(Tree.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            container:ReleaseChildren()
        end)

    return deleteButton
end


-------------------------------------------------------------------------------
-- Options

Tree.AddOptionWidgets = function(container, profile)	    
    local optionsHeading = PRT.Heading("optionsHeading")
    
    local debugModeCheckbox = PRT.CheckBox("optionsDebugMode", profile.debugMode)
    debugModeCheckbox:SetFullWidth(true)
	debugModeCheckbox:SetCallback("OnValueChanged", 
		function(widget) 
			profile.debugMode = widget:GetValue() 
        end)

    local testModeCheckbox = PRT.CheckBox("optionsTestMode", profile.testMode)
    testModeCheckbox:SetFullWidth(true)
	testModeCheckbox:SetCallback("OnValueChanged", 
		function(widget) 
			profile.testMode = widget:GetValue() 
		end)	

	local testEncounterIDEditBox = PRT.EditBox("optionsTestEncounterID", profile.testEncounterID, true)	
	testEncounterIDEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			profile.testEncounterID = tonumber(widget:GetText()) 
		end)		
        
    container:AddChild(optionsHeading)      
    container:AddChild(debugModeCheckbox)
    container:AddChild(testModeCheckbox)
    container:AddChild(testEncounterIDEditBox)
end


-------------------------------------------------------------------------------
-- PowerPercentage

Tree.AddPowerPercentageOptions = function(container, profile, encounterID)
    local idx, encounter = FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local percentages = encounter.PowerPercentages

    local addButton = PRT.Button("New Health Percentage")
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            table.insert(percentages, newPercentage)
            PRT.mainFrameContent:SetTree(Tree.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            PRT.mainFrameContent:SelectByPath("encounters", encounterID, "powerPercentages", newPercentage.name)
        end)

    container:AddChild(addButton)
end

Tree.AddPowerPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.PowerPercentages
    local percentageIndex, percentage = FilterTableByName(percentages, triggerName)
    local deleteButton = Tree.NewTriggerDeleteButton(container, percentages, percentageIndex)

    container:AddChild(deleteButton)

    PRT.PercentageWidget(percentage, container)
end

-------------------------------------------------------------------------------
-- HealthPercentage

Tree.AddHealthPercentageOptions = function(container, profile, encounterID)
    local idx, encounter = FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local percentages = encounter.HealthPercentages

    local addButton = PRT.Button("New Health Percentage")
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newPercentage = PRT.EmptyPercentage()
            table.insert(percentages, newPercentage)
            PRT.mainFrameContent:SetTree(Tree.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            PRT.mainFrameContent:SelectByPath("encounters", encounterID, "healthPercentages", newPercentage.name)
        end)

    container:AddChild(addButton)
end

Tree.AddHealthPercentageWidget = function(container, profile, encounterID, triggerName)
    local _, encounter = FilterEncounterTable(profile.encounters, encounterID)    
    local percentages = encounter.HealthPercentages
    local percentageIndex, percentage = FilterTableByName(percentages, triggerName)
    local deleteButton = Tree.NewTriggerDeleteButton(container, percentages, percentageIndex)

    container:AddChild(deleteButton)

    PRT.PercentageWidget(percentage, container)
end


-------------------------------------------------------------------------------
-- Timer

Tree.AddTimerOptions = function(container, profile, encounterID)
    local idx, encounter = FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local timers = encounter.Timers

    local addButton = PRT.Button("New Timer")
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newTimer = PRT.EmptyTimer()
            table.insert(timers, newTimer)
            PRT.mainFrameContent:SetTree(Tree.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            PRT.mainFrameContent:SelectByPath("encounters", encounterID, "timers", newTimer.name)
        end)

    container:AddChild(addButton)
end

Tree.AddTimerWidget = function(container, profile, encounterID, triggerName)
    local idx, encounter = FilterEncounterTable(profile.encounters, encounterID)    
    local timers = encounter.Timers
    local timerIndex, timer = FilterTableByName(timers, triggerName)
    local deleteButton = Tree.NewTriggerDeleteButton(container, timers, timerIndex)

    container:AddChild(deleteButton)

    PRT.TimerWidget(timer, container)
end


-------------------------------------------------------------------------------
-- Rotations

Tree.AddRotationOptions = function(container, profile, encounterID)
    local idx, encounter = FilterEncounterTable(profile.encounters, tonumber(encounterID))
    local rotations = encounter.Rotations

    local addButton = PRT.Button("New Rotation")
    addButton:SetCallback("OnClick", 
        function(widget, event, key)
            local newRotation = PRT.EmptyRotation()
            table.insert(rotations, newRotation)
            PRT.mainFrameContent:SetTree(Tree.GenerateTreeByProfile(PRT.db.profile))
            PRT.mainFrameContent:DoLayout()
            PRT.mainFrameContent:SelectByPath("encounters", encounterID, "rotations", newRotation.name)
        end)

    container:AddChild(addButton)
end

Tree.AddRotationWidget = function(container, profile, encounterID, triggerName)    
    local idx, encounter = FilterEncounterTable(profile.encounters, encounterID)    
    local rotations = encounter.Rotations
    local rotationIndex, rotation = FilterTableByName(rotations, triggerName)
    local deleteButton = Tree.NewTriggerDeleteButton(container, rotations, rotationIndex)

    container:AddChild(deleteButton)
    PRT.RotationWidget(rotation, container)
end


-------------------------------------------------------------------------------
-- Encounter

Tree.AddEncountersWidgets = function(container, profile)
    local encounterHeading = PRT.Heading("encounterHeading")

    local addButton = PRT.Button("New Encounter")
    addButton:SetCallback("OnClick", 
    function(widget) 
        local newEncounter = PRT.EmptyEncounter()
        table.insert(profile.encounters, newEncounter)
        PRT.mainFrameContent:SetTree(Tree.GenerateTreeByProfile(PRT.db.profile))
        PRT.mainFrameContent:DoLayout()

        PRT.mainFrameContent:SelectByPath("encounters", newEncounter.id)
    end)

    local importButton = PRT.Button("encounterImport")
	importButton:SetCallback("OnClick", 
		function(widget) 
			PRT.CreateImportEncounterFrame(profile.encounters)
        end)
        
    container:AddChild(encounterHeading)
    container:AddChild(importButton)
    container:AddChild(addButton)
end

Tree.AddEncounterOptions = function(container, profile, encounterID)
    local encounterIndex, encounter = FilterEncounterTable(profile.encounters, tonumber(encounterID))

    local encounterHeading = PRT.Heading("encounterHeading")

	local encounterIDEditBox = PRT.EditBox("encounterID", encounter.id)	
	encounterIDEditBox:SetCallback("OnTextChanged", 
		function(widget) 
			encounter.id = tonumber(widget:GetText()) 
		end)		
        
    local encounterNameEditBox = PRT.EditBox("encounterName", encounter.name)	
    encounterNameEditBox:SetCallback("OnTextChanged", 
        function(widget) 
            encounter.name = widget:GetText()
        end)

    local exportButton = PRT.Button("encounterExport")
    exportButton:SetCallback("OnClick", 
        function(widget) 
            PRT.CreateExportEncounterFrame(encounter)
        end)

    local deleteButton = Tree.NewTriggerDeleteButton(container, profile.encounters, encounterIndex)

    container:AddChild(encounterHeading)   
    container:AddChild(encounterIDEditBox)
    container:AddChild(encounterNameEditBox)
    container:AddChild(exportButton)
    container:AddChild(deleteButton)
end

Tree.OnGroupSelected = function(container, key, profile)
    container:ReleaseChildren()
    
    local mainKey, encounterID, triggerType, triggerName = strsplit("\001", key)
    
    -- options selected
    if mainKey == "options" then        
        Tree.AddOptionWidgets(container, profile)

    -- encounters selected
    elseif mainKey == "encounters" and not triggerType and not triggerName and not encounterID then
        Tree.AddEncountersWidgets(container, profile)

    -- single encounter selected
    elseif encounterID and not triggerType and not triggerName then
        Tree.AddEncounterOptions(container, profile, encounterID)

    -- encounter trigger type selected
    elseif triggerType and not triggerName then
        if triggerType == "timers" then
            Tree.AddTimerOptions(container, profile, encounterID)
        elseif triggerType == "rotations" then
            Tree.AddRotationOptions(container, profile, encounterID)
        elseif triggerType == "healthPercentages" then
            Tree.AddHealthPercentageOptions(container, profile, encounterID)
        elseif triggerType == "powerPercentages" then
            Tree.AddPowerPercentageOptions(container, profile, encounterID)
        end
    
    -- single timer selected
    elseif triggerType == "timers" and triggerName then
        Tree.AddTimerWidget(container, profile, tonumber(encounterID), triggerName)

    -- single rotaion selected
    elseif triggerType == "rotations" and triggerName then
        Tree.AddRotationWidget(container, profile, tonumber(encounterID), triggerName)

    -- single healthPercentages selected        
    elseif triggerType == "healthPercentages" and triggerName then
        Tree.AddHealthPercentageWidget(container, profile, tonumber(encounterID), triggerName)

    -- single powerPercentages selected        
    elseif triggerType == "powerPercentages" and triggerName then
        Tree.AddPowerPercentageWidget(container, profile, tonumber(encounterID), triggerName)
    end

    container:DoLayout()
    PRT.mainFrameContent:RefreshTree()
end

PRT.CreateMainFrameContent = function(container, profile)
    local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("List")	
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetAutoAdjustHeight(true)
    
    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetLayout("Fill")
    treeGroup:SetTree(Tree.GenerateTreeByProfile(profile))
    treeGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            Tree.OnGroupSelected(scrollFrame, key, profile) 
        end)	
    PRT.mainFrameContent   = treeGroup        
    treeGroup:AddChild(scrollFrame)

    -- Expand encounters by default
    local treeGroupStatus = { groups = {} }
    treeGroup:SetStatusTable(treeGroupStatus)
    treeGroupStatus.groups["encounters"] = true    
    treeGroup:SelectByValue("options")
    treeGroup:RefreshTree()

	return treeGroup
end

-------------------------------------------------------------------------------
-- Public API

PRT.CreateMainFrame = function(profile)
	PRT.mainFrame = AceGUI:Create("Window")
	PRT.mainFrame:SetTitle("PhenomRaidTools")
	PRT.mainFrame:SetStatusText("PhenomRaidTools - Raid smarter not harder")
	PRT.mainFrame:SetLayout("Fill")
	PRT.mainFrame:SetCallback("OnClose",
		function(widget) 
			AceGUI:Release(widget) 
		end)
	PRT.mainFrame:SetWidth(800)
	RegisterESCHandler("mainFrame", PRT.mainFrame)

	PRT.mainFrame:AddChild(PRT.CreateMainFrameContent(PRT.mainFrame, profile))
end	