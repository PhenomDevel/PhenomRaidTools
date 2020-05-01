local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


-------------------------------------------------------------------------------
-- Public API

PRT.MaximizeWidget = function(widget)
	widget:SetFullWidth(true)
	widget:SetFullHeight(true)
	widget:SetAutoAdjustHeight(true)
 end

 PRT.AddNewTab = function(widget, t, item)
    if not t then
        t = {}
    end
	table.insert(t, item)
	widget:SetTabs(PRT.TableToTabs(t, true))
	widget:DoLayout()
    widget:SelectTab(table.getn(t))
    
    PRT.mainFrameContent:DoLayout()
 end

 PRT.RemoveTab = function(widget, t, item)
	table.remove(t, item)
	widget:SetTabs(PRT.TableToTabs(t, true))
	widget:DoLayout()
	widget:SelectTab(1)

	if table.getn(t) == 0 then
		widget:ReleaseChildren()
    end
    
    PRT.mainFrameContent:DoLayout()
 end

 PRT.TabGroupSelected = function(widget, t, key, itemFunction, emptyItemFunction, deleteButtonText)
	widget:ReleaseChildren()

	if key == "new" then
		local emptyItem = emptyItemFunction() or {}

		PRT.AddNewTab(widget, t, emptyItem)
    else	
		local item = nil
			        
        if t then
            item = t[key]
		end
		
        local actualItem = itemFunction(item)
		if actualItem then
			widget:AddChild(actualItem)
		end
 
		local deleteButton = AceGUI:Create("Button")
		deleteButton:SetText(deleteButtonText or "delete")
		deleteButton:SetCallback("OnClick", function() PRT.RemoveTab(widget, t, key) end)
	
		widget:AddChild(deleteButton)
	end
	
    PRT.mainFrameContent:DoLayout()
end

PRT.TabGroup = function(title, tabs)
	local widget = AceGUI:Create("TabGroup")
    if title then
        widget:SetTitle(title)
    end
	widget:SetTabs(tabs)
    PRT.MaximizeWidget(widget)
 
	return widget
 end

 PRT.Heading = function(title)
	local widget = AceGUI:Create("Heading")
	widget:SetText(title)
    widget:SetRelativeWidth(1)

	return widget
 end
 
 PRT.Label = function(label)
	local widget = AceGUI:Create("Label")
	widget:SetText(label)

	return widget
 end

 PRT.EditBox = function(label, value)
	local widget = AceGUI:Create("EditBox")
	widget:SetLabel(label)
	widget:SetText(value)
	widget:SetWidth(200)
 
	return widget
 end

 PRT.Dropdown = function(label, values, value)
	local dropdownItems = {}
	for i,v in ipairs(values) do
		dropdownItems[v.id] = v.name
 	end

	local widget = AceGUI:Create("Dropdown")
	widget:SetLabel(label)
	widget:SetText(value)
	widget:SetWidth(200)
	widget:SetList(dropdownItems)
	return widget
 end

 PRT.CheckBox = function(label, value)
	local widget = AceGUI:Create("CheckBox")
	widget:SetLabel(label)
	widget:SetValue(value)
 
	return widget
 end

 PRT.SimpleGroup = function()
    local widget = AceGUI:Create("SimpleGroup")    
    PRT.MaximizeWidget(widget)
    widget:SetLayout("Flow")

    return widget
 end

 PRT.SelectFirstTab = function(container, t)
	container:SelectTab(nil)
    if t then
		if table.getn(t) > 0 then
			container:SelectTab(1)
		end
	end
 end