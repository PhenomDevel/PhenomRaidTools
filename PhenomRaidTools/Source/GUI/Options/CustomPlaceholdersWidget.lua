local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local CustomPlaceholder = {}


-------------------------------------------------------------------------------
-- Local Helper

local newCustomPlaceholder = function()
   return {
      type = "player",
      name = "Placeholder",
      names = {
         "Change me"
      }
   }
end

local addCustomPlaceholderWidget = function(customPlaceholder, container, tabKey)
   local placeholderTypesDropdownItems = {
      { id = "group", name = L["optionsCustomPlaceholderTypeGroup"]},
      { id = "player", name = L["optionsCustomPlaceholderTypePlayer"]}
   }

   local placeholderTypeSelect = PRT.Dropdown("optionsCustomPlaceholderType", placeholderTypesDropdownItems, (customPlaceholder.type or "Player"))   
   placeholderTypeSelect:SetCallback("OnValueChanged",
      function(widget)
         local text = widget:GetValue()
         customPlaceholder.type = text
      end)  

   local nameEditBox = PRT.EditBox("optionsCustomPlaceholderName", customPlaceholder.name)
   nameEditBox:SetCallback("OnEnterPressed", 
      function(widget)
         local text = widget:GetText()
         customPlaceholder.name = text        
         widget:ClearFocus()
      end)  

   local clearEmptyNamesButton = PRT.Button("optionsCustomPlaceholderRemoveEmptyNames")
   clearEmptyNamesButton:SetCallback("OnClick",
      function()
         PRT.TableRemove(customPlaceholder.names, PRT.EmptyString)
         PRT.ReSelectTab(container)
      end)

   local addNameButton = PRT.Button("optionsCustomPlaceholderAddNameButton")
   addNameButton:SetCallback("OnClick",
      function()
         tinsert(customPlaceholder.names, "")         
         PRT.ReSelectTab(container)
      end)          
   
   local namesGroup = PRT.InlineGroup("Names")
   namesGroup:SetLayout("Flow")
   for idx, name in ipairs(customPlaceholder.names) do
      local nameEditBox = PRT.EditBox("name"..idx, name)
      nameEditBox:SetRelativeWidth(0.333)
      nameEditBox:SetCallback("OnEnterPressed", 
         function(widget)
            local text = widget:GetText()
            customPlaceholder.names[idx] = text
            widget:ClearFocus()
         end)
      namesGroup:AddChild(nameEditBox)
   end       

   container:AddChild(nameEditBox) 
   container:AddChild(placeholderTypeSelect)       
   container:AddChild(namesGroup)
   container:AddChild(addNameButton) 
   container:AddChild(clearEmptyNamesButton)
end

-------------------------------------------------------------------------------
-- Public API

PRT.AddCustomPlaceholdersWidget = function(container, customPlaceholders)
   local description = PRT.Label("optionsCustomPlaceholdersDescription", 14)
   local subDescription = PRT.Label("optionsCustomPlaceholdersSubDescription")   
   description:SetRelativeWidth(1)
   subDescription:SetRelativeWidth(1)   
   container:AddChild(description)
   container:AddChild(subDescription)

   local placeholderTabs = PRT.TableToTabs(customPlaceholders, true)
   local placeholdersTabGroup = PRT.TabGroup("optionsCustomPlaceholdersHeading", placeholderTabs)   
   placeholdersTabGroup:SetTitle(nil) 
   placeholdersTabGroup:SetLayout("Flow")
   placeholdersTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, customPlaceholders, key, addCustomPlaceholderWidget , newCustomPlaceholder, "optionsCustomPlaceholderDeleteButton") 
        end)

   PRT.SelectFirstTab(placeholdersTabGroup, customPlaceholders) 

   container:AddChild(placeholdersTabGroup)
end