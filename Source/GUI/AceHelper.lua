local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

local AceHelper = {}

-------------------------------------------------------------------------------
-- Local Helper

AceHelper.AddTooltip = function(widget, tooltip)
	if tooltip and widget then
		widget:SetCallback("OnEnter", function(widget) 
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			if type(tooltip) == "table" then
				for i, entry in ipairs(tooltip) do
					GameTooltip:AddLine(entry)	
				end
			else
				GameTooltip:AddLine(tooltip)	
			end
			GameTooltip:Show()
		end)

		widget:SetCallback("OnLeave", 
		function(widget) 
			GameTooltip:FadeOut() 
		end)
	end	
end

AceHelper.MaximizeWidget = function(widget)
	widget:SetFullWidth(true)
	widget:SetFullHeight(true)
	widget:SetAutoAdjustHeight(true)
end

AceHelper.AddNewTab = function(widget, t, item)
    if not t then
        t = {}
    end
	tinsert(t, item)
	widget:SetTabs(PRT.TableToTabs(t, true))
	widget:DoLayout()
    widget:SelectTab(getn(t))
    
    PRT.mainFrameContent:DoLayout()
end

AceHelper.RemoveTab = function(widget, t, item)
	tremove(t, item)
	widget:SetTabs(PRT.TableToTabs(t, true))
	widget:DoLayout()
	widget:SelectTab(1)

	if getn(t) == 0 then
		widget:ReleaseChildren()
    end
    
    PRT.mainFrameContent:DoLayout()
end


-------------------------------------------------------------------------------
-- Public API

PRT.TabGroupSelected = function(widget, t, key, itemFunction, emptyItemFunction, deleteTextID)
	widget:ReleaseChildren()

	if key == "new" then
		local emptyItem = emptyItemFunction() or {}

		AceHelper.AddNewTab(widget, t, emptyItem)
    else	
		local item = nil
			        
        if t then
            item = t[key]
		end
		
		-- Has to add its childs to widget
		itemFunction(item, widget) 
		
		local deleteButtonText = PRT.Strings.GetText(deleteTextID)
		local deleteButton = AceGUI:Create("Button")
		deleteButton:SetText(deleteButtonText)
		deleteButton:SetCallback("OnClick", function() AceHelper.RemoveTab(widget, t, key) end)
	
		widget:AddChild(deleteButton)
	end
end

PRT.TabGroup = function(textID, tabs)
	local text = PRT.Strings.GetText(textID)
	local widget = AceGUI:Create("TabGroup")
	
	widget:SetTitle(text)
	widget:SetTabs(tabs)
	widget:SetLayout("List")

    AceHelper.MaximizeWidget(widget)
 
	return widget
 end

 PRT.Button = function(textID, addTooltip)
	local text = PRT.Strings.GetText(textID)

	local widget = AceGUI:Create("Button")

	if addTooltip then 		
		local tooltip = PRT.Strings.GetTooltip(textID)
		AceHelper.AddTooltip(widget, tooltip)
	end

	widget:SetText(text)

	return widget
 end

 PRT.Heading = function(textID)
	local text = PRT.Strings.GetText(textID)

	local widget = AceGUI:Create("Heading")

	widget:SetText(text)
	widget:SetFullWidth(true)

	return widget
 end
 
 PRT.Label = function(textID)
	local text = PRT.Strings.GetText(textID)

	local widget = AceGUI:Create("Label")

	widget:SetText(text)

	return widget
 end

 PRT.EditBox = function(textID, value, addTooltip)
	local text = PRT.Strings.GetText(textID)

	local widget = AceGUI:Create("EditBox")
	
	if addTooltip then 
		local tooltip = PRT.Strings.GetTooltip(textID)
		AceHelper.AddTooltip(widget, tooltip)
	end

	widget:SetLabel(text)
	widget:SetText(value)
	widget:SetWidth(200)
 
	return widget
 end

 PRT.Dropdown = function(textID, values, value)	
	local text = PRT.Strings.GetText(textID)

	local dropdownItems = {}
	for i,v in ipairs(values) do
		dropdownItems[v.id] = v.name
 	end

	local widget = AceGUI:Create("Dropdown")

	widget:SetLabel(text)	
	widget:SetText(dropdownItems[value])
	widget:SetWidth(200)
	widget:SetList(dropdownItems)

	return widget
 end

 PRT.CheckBox = function(textID, value, addTooltip)	
	local text = PRT.Strings.GetText(textID)	

	local widget = AceGUI:Create("CheckBox")
	if addTooltip then 
		local tooltip = PRT.Strings.GetTooltip(textID)
		AceHelper.AddTooltip(widget, tooltip)
	end

	widget:SetLabel(text)
	widget:SetValue(value)
 
	return widget
 end

 PRT.InlineGroup = function(textID)
	local text = PRT.Strings.GetText(textID)
	local widget = AceGUI:Create("InlineGroup")    
	
	widget:SetFullWidth(true)
	widget:SetLayout("List")
	widget:SetTitle(text)

    return widget
 end

 PRT.SelectFirstTab = function(container, t)
	container:SelectTab(nil)
    if t then
		if getn(t) > 0 then
			container:SelectTab(1)
		end
	end
 end