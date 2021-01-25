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

   local nameEditBox = PRT.EditBox("optionsCustomPlaceholderName", customPlaceholder.name, true)
   nameEditBox:SetCallback("OnEnterPressed", 
      function(widget)
         local text = widget:GetText()
         local cleanedText = string.gsub(text, " ", "") 
         customPlaceholder.name = cleanedText
         widget:SetText(cleanedText)
         widget:ClearFocus()
      end)  

   local clearEmptyNamesButton = PRT.Button("optionsCustomPlaceholderRemoveEmptyNames")
   clearEmptyNamesButton:SetCallback("OnClick",
      function()
         PRT.TableUtils.Remove(customPlaceholder.names, StringUtils.IsEmpty)
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

local importSuccess = function(container, customPlaceholders, importedCustomPlaceholders)
   if customPlaceholders then
      for i, customPlaceholder in ipairs(importedCustomPlaceholders) do
         tinsert(customPlaceholders, customPlaceholder)
      end
      container:ReleaseChildren()
      PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
      PRT.Info("Custom placeholders imported successfully.")         
   else
      PRT.Error("Something went wrong while importing custom placeholders.")
   end
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddCustomPlaceholdersTabGroup = function(container, customPlaceholders)
   local placeholderTabs = PRT.TableToTabs(customPlaceholders, true)
   local placeholdersTabGroup = PRT.TabGroup("optionsCustomPlaceholdersHeading", placeholderTabs)   
   placeholdersTabGroup:SetTitle(nil) 
   placeholdersTabGroup:SetLayout("Flow")
   placeholdersTabGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            PRT.TabGroupSelected(widget, customPlaceholders, key, addCustomPlaceholderWidget , newCustomPlaceholder, true, "optionsCustomPlaceholderDeleteButton") 
        end)

   PRT.SelectFirstTab(placeholdersTabGroup, customPlaceholders) 
   container:AddChild(placeholdersTabGroup)
end

PRT.AddCustomPlaceholdersWidget = function(container, customPlaceholders)
   local description = PRT.Label("optionsCustomPlaceholdersDescription", 14)
   local subDescription = PRT.Label("optionsCustomPlaceholdersSubDescription")   
   description:SetRelativeWidth(1)
   subDescription:SetRelativeWidth(1)   
   container:AddChild(description)
   container:AddChild(subDescription)

   local importButton = PRT.Button("importButton")
   importButton:SetCallback("OnClick",
      function()
         PRT.CreateImportFrame(
            function(t) 
               importSuccess(container, customPlaceholders, t) 
            end)
      end)

   local exportButton = PRT.Button("exportButton")
   exportButton:SetCallback("OnClick",
      function()
         PRT.CreateExportFrame(customPlaceholders)
      end)

   container:AddChild(importButton)
   container:AddChild(exportButton)
   PRT.AddCustomPlaceholdersTabGroup(container, customPlaceholders)
end