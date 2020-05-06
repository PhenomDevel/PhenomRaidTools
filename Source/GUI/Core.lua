local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local Core = {}
PRT.Core = Core

-------------------------------------------------------------------------------
-- Local Helper

local RegisterESCHandler = function(name, container)
	_G[name] = container.frame
    -- Register the global variable `MyGlobalFrameName` as a "special frame"
    -- so that it is closed when the escape key is pressed.
    tinsert(UISpecialFrames, name)
end

Core.GeneratePercentageTree = function(percentage)
    local t = {
        value = percentage.name,
        text = percentage.name
    }
    
    return t
end

Core.GeneratePercentagesTree = function(percentages)
    local children = {}
    local t = {
        value = "percentages",
        text = "Percentages",
    }

    if table.getn(percentages) > 0 then
        t.children = children
        for i, percentage in ipairs(percentages) do
            table.insert(children, Core.GeneratePercentageTree(percentage))
        end
    end
    
    return t
end

Core.GeneratePowerPercentagesTree = function(percentages)
    local tree = Core.GeneratePercentagesTree(percentages)
    tree.value = "powerPercentages"
    tree.text = "Power Percentages"

    return tree
end

Core.GenerateHealthPercentagesTree = function(percentages)
    local tree = Core.GeneratePercentagesTree(percentages)
    tree.value = "healthPercentages"
    tree.text = "Health Percentages"

    return tree
end

Core.GenerateRotationTree = function(rotation)
    local t = {
        value = rotation.name,
        text = rotation.name
    }
    
    return t
end

Core.GenerateRotationsTree = function(rotations)
    local children = {}
    local t = {
        value = "rotations",
        text = "Rotations",
    }

    if table.getn(rotations) > 0 then
        t.children = children
        for i, rotation in ipairs(rotations) do
            table.insert(children, Core.GenerateRotationTree(rotation))
        end
    end
    
    return t
end

Core.GenerateTimerTree = function(timer)
    local t = {
        value = timer.name,
        text = timer.name
    }
    
    return t
end

Core.GenerateTimersTree = function(timers)
    local children = {}
    local t = {
        value = "timers",
        text = "Timers",
    }

    if table.getn(timers) > 0 then
        t.children = children
        for i, timer in ipairs(timers) do
            table.insert(children, Core.GenerateTimerTree(timer))
        end
    end
    
    
    return t
end

Core.GenerateEncounterTree = function(encounter)
    local children = {}
    local t = {
        value = encounter.id,
        text = encounter.name,
        children = {
            Core.GenerateTimersTree(encounter.Timers),
            Core.GenerateRotationsTree(encounter.Rotations),
            Core.GenerateHealthPercentagesTree(encounter.HealthPercentages),
            Core.GeneratePowerPercentagesTree(encounter.PowerPercentages)
        }
    }

    return t
end

Core.GenerateEncountersTree = function(encounters)
    local children = {}

    local t = {
        value  = "encounters",
        text = "Encounters",
        children = children
    }    

    for i, encounter in ipairs(encounters) do
        table.insert(children, Core.GenerateEncounterTree(encounter))
    end

    return t
end

Core.GenerateOptionsTree = function()
    local t = {
        value = "options",
        text = "Options"
    }
    return t
end

Core.GenerateTreeByProfile = function(profile)
    local t = {
        Core.GenerateOptionsTree(),
        Core.GenerateEncountersTree(profile.encounters)
    }

    return t
end

Core.OnGroupSelected = function(container, key, profile)
    container:ReleaseChildren()
    
    local mainKey, encounterID, triggerType, triggerName = strsplit("\001", key)
    
    -- options selected
    if mainKey == "options" then        
        PRT.AddOptionWidgets(container, profile)

    -- encounters selected
    elseif mainKey == "encounters" and not triggerType and not triggerName and not encounterID then
        PRT.AddEncountersWidgets(container, profile)

    -- single encounter selected
    elseif encounterID and not triggerType and not triggerName then
        PRT.AddEncounterOptions(container, profile, encounterID)

    -- encounter trigger type selected
    elseif triggerType and not triggerName then
        if triggerType == "timers" then
            PRT.AddTimerOptionsWidgets(container, profile, encounterID)
        elseif triggerType == "rotations" then
            PRT.AddRotationOptions(container, profile, encounterID)
        elseif triggerType == "healthPercentages" then
            PRT.AddHealthPercentageOptions(container, profile, encounterID)
        elseif triggerType == "powerPercentages" then
            PRT.AddPowerPercentageOptions(container, profile, encounterID)
        end
    
    -- single timer selected
    elseif triggerType == "timers" and triggerName then
        PRT.AddTimerWidget(container, profile, tonumber(encounterID), triggerName)

    -- single rotaion selected
    elseif triggerType == "rotations" and triggerName then
        PRT.AddRotationWidget(container, profile, tonumber(encounterID), triggerName)

    -- single healthPercentages selected        
    elseif triggerType == "healthPercentages" and triggerName then
        PRT.AddHealthPercentageWidget(container, profile, tonumber(encounterID), triggerName)

    -- single powerPercentages selected        
    elseif triggerType == "powerPercentages" and triggerName then
        PRT.AddPowerPercentageWidget(container, profile, tonumber(encounterID), triggerName)
    end

    container:DoLayout()
    PRT.mainFrameContent:RefreshTree()
end

Core.CreateMainFrameContent = function(container, profile)
    local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("List")	
	scrollFrame:SetFullHeight(true)
	scrollFrame:SetAutoAdjustHeight(true)
    
    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetLayout("Fill")
    treeGroup:SetTree(Core.GenerateTreeByProfile(profile))
    treeGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            Core.OnGroupSelected(scrollFrame, key, profile) 
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
    PRT.mainFrame:SetWidth(850)
    PRT.mainFrame:SetHeight(600)
    PRT.mainFrame.frame:SetMinResize(400, 400)
	RegisterESCHandler("mainFrame", PRT.mainFrame)

	PRT.mainFrame:AddChild(Core.CreateMainFrameContent(PRT.mainFrame, profile))
end	